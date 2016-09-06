local socket = require "clientsocket"
local bit32 = require "bit32"

socketmgr = socketmgr or {}

function socketmgr.init()
	socketmgr.servers = {}
	for srvname,v in pairs(srvlist) do
		--pcall(socketmgr.getsrv,srvname)
	end
end

function socketmgr.getsrv(srvname)
	if not socketmgr.servers[srvname] then
		local srv = assert(srvlist[srvname],"unknow srvname:" .. tostring(srvname))
		local fd = assert(socket.connect(srv.ip,srv.port))
		local tmp = {
			fd = fd,
			srvname = srvname,
			last = "",
		}
		socketmgr.servers[srvname] = tmp
	end
	return socketmgr.servers[srvname]
end

function socketmgr.delsrv(srvname)
	socketmgr.servers[srvname] = nil
end

function socketmgr.close(srvname) 
	local srv = socketmgr.getsrv(srvname)
	if srv then
		socketmgr.delsrv(srvname)
		os.exit()
		--socket.close(srv.fd)
	end
end

function socketmgr.onclose(srvname)
	local srv = assert(socketmgr.servers[srvname])
	socketmgr.delsrv(srvname)
end

function socketmgr.unpack_package(text)
	local size = #text
	if size < 2 then
		return nil,text
	end
	local s = text:byte(1) * 256 + text:byte(2)
	if size < s + 2 then
		return nil,text
	end
	return text:sub(3,s+2),text:sub(s+3)
end

function socketmgr.recv_package(srvname)
	local srv = socketmgr.getsrv(srvname)
	local result
	result,srv.last = socketmgr.unpack_package(srv.last)
	if result then
		return result
	end
	local r = socket.recv(srv.fd)
	if not r then
		return nil
	end
	if r == "" then
		socketmgr.onclose(srvname)
		error(string.format("%s server closed",srvname))
	end
	result,srv.last = socketmgr.unpack_package(srv.last .. r)
	return result
end

function socketmgr.send_package(srvname,pack)
	local srv = socketmgr.getsrv(srvname)
	local fd = assert(srv.fd)
	local size = #pack
	local package = string.char(bit32.extract(size,8,8)) ..
		string.char(bit32.extract(size,0,8)) ..
		pack
	socket.send(fd,package)
end


function socketmgr.send_request(srvname,protoname,subprotoname,request)
	local str = agent.request(protoname .. "_" .. subprotoname,request)
	socketmgr.send_package(srvname,str)
end

local function usage()
	print("usage: lua gamelogic/init.lua")
end

function socketmgr.dispatch()
	while true do
		socket.usleep(100)
		while true do
			for srvname,srv in pairs(socketmgr.servers) do
				local v = socketmgr.recv_package(srvname)
				if not v then
					break
				end
				agent.dispatch(srvname,v)
			end
			local cmd = socket.readstdin()
			if cmd then
				if cmd == "exit" then
					break
				end
				local func = load(cmd)	
				local ok,result = pcall(func)
				if not ok then
					print(result)
				end
			end
		end
	end
end


return socketmgr
