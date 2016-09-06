local socket = require "clientsocket"
local sproto = require "sproto"

agent = agent or {}

function agent.init()
	local proto = require "proto.init"
	local c2s = proto.getc2s()
	local s2c = proto.gets2c()
	agent.host = sproto.parse(s2c):host "package"
	agent.request = agent.host:attach(sproto.parse(c2s))
	agent.wait_proto = {}
end

local function dispatch(srvname,typ,...)
	if typ == "REQUEST" then
		local cmd,request,response = ...
		local protoname,subprotoname = string.match(cmd,"([^_]-)%_(.+)") 
		local r
		local callback = wakeup(protoname,subprotoname)
		if callback then
			r = callback(srvname,request)
		else
			if not net[protoname] then
				print(format("unknow proto,srvname=%s cmd=%s request=%s",srvname,cmd,request))
				return
			end
			local S2C = net[protoname].S2C
			local func = S2C[subprotoname]
			if not func then
				print(format("unknow cmd,srvname=%s cmd=%s request=%s",srvname,cmd,request))
				return
			end
			r = func(srvname,request)
		end
		if response then
			local ret = response(r)
			--print(">>>>",protoname,subprotoname,r,response,ret,"end")
			-- don't response
		end
	else
	end
end

function agent.dispatch(srvname,v)
	if v == "G\n" then -- 连接成功后服务端发过来的“加密标识"
		return
	end
	local isok,errmsg = pcall(dispatch,srvname,agent.host:dispatch(v))
	if not isok then
		agent.wait_proto = {}
		print(errmsg)
	end
end

function wait(protoname,subprotoname,callback)
	if not agent.wait_proto[protoname] then
		agent.wait_proto[protoname] = {}
	end
	if not agent.wait_proto[protoname][subprotoname] then
		agent.wait_proto[protoname][subprotoname] = {}
	end
	table.insert(agent.wait_proto[protoname][subprotoname],callback)
end

function wakeup(protoname,subprotoname)
	local tbl = agent.wait_proto[protoname]
	if not tbl or not next(tbl) then
		return
	end
	tbl = tbl[subprotoname]
	if not tbl or not next(tbl) then
		return
	end
	local callback = table.remove(tbl,1)
	return callback
end

return agent
