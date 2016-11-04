package.path = package.path  .. ";../src/?.lua;../src/?.luo;../src/?/init.lua;../src/?/init.luo"
--print("package.path:",package.path)
--print("package.cpath:",package.cpath)

skynet = skynet or require "skynet"
socket = socket or require "socket"
httpd = httpd or require "http.httpd"
sockethelper = sockethelper or require "http.sockethelper"
urllib = urllib or require "http.url"
cjson = cjson or require "cjson"
require "gamelogic.logger.init"
require "gamelogic.auxilary.http"
require "gamelogic.base.util"
require "gamelogic.hotfix.init"
require "gamelogic.errcode"

local function __onconnect(id,ip,port)
	socket.start(id)
	local code,url,method,header,body = httpd.read_request(sockethelper.readfunc(id),8192)
	if code then
		if code ~= 200 then
			response(id,code)
		else
			
			local agent = {
				id = id,
				ip = ip,
				port = port,
				method = method,
				agent = skynet.self(),
			}
			local unescape_body = header["unescape_body"]
			--pprintf("agent=%s method=%s query=%s header=%s body=%s",agent,method,query,header,body)
			local resp = ""
			if method == "GET" then
				if skynet.getenv("servermode") ~= "DEBUG" then
					response(id,405)
					return
				end
				local path,query = urllib.parse(url)
				local modname = "gamelogic.service.http" .. path
				local modname = modname:gsub("/",".")
				local isok,func = pcall(require,modname)
				if isok then
					query = query and urllib.parse_query(query)
					if not unescape_body then
						body = body and urllib.parse_query(body)
					end
					local isok,status,result = xpcall(func,onerror,agent,query,header,body)
					logger.log("debug","request",format("[request] agent=%s method=%s url=%s header=%s body=%s isok=%s status=%s result=%s",agent,method,url,header,body,isok,status,result))
					if not isok then
						skynet.error(string.format("exec %s,isok=%s status=%s result=%s",isok,url,status,result))
						response(id,500)
					else
						response(id,200,pack_response(status,result))
					end
				else
					--skynet.error(func)
					response(id,404)
				end
			elseif method == "POST" then
				local path,query = urllib.parse(url)
				local modname = "gamelogic.service.http" .. path
				local modname = modname:gsub("/",".")
				local isok,func = pcall(require,modname)
				if isok then
					query = query and urllib.parse_query(query)
					if not unescape_body then
						body = body and urllib.parse_query(body)
					end
					local isok,status,result = xpcall(func,onerror,agent,query,header,body)

					logger.log("debug","request",format("[request] agent=%s method=%s url=%s header=%s body=%s isok=%s status=%s result=%s",agent,method,url,header,body,isok,status,result))
					if not isok then
						skynet.error(string.format("exec %s,isok=%s status=%s result=%s",isok,url,status,result))
						response(id,500)
					else
						response(id,200,pack_response(status,result))
					end
				else
					--skynet.error(func)
					response(id,404)
				end
			end
		end
	else
		if url == sockethelper.socket_error then
			skynet.error("socket closed")
		else
			skynet.error(url)
		end
	end
	socket.close(id)
end

local function rpc(cmd,...)
	logger.log("info","webagent","rpc",cmd,...)
	cmd = "return " .. cmd
	local chunk = load(cmd,"=(load)","bt",_G)
	local func = chunk()
	if type(func) ~= "function" then
		return func
	else
		return func(...)
	end
end

local function exec(cmd)
	logger.log("info","webagent","exec",cmd)
	local chunk = load(cmd,"=(load)","bt",_G)
	if chunk then
		chunk()
	end
end

local mode = ...
-- 启动服务时才调用skynet.start，否则热更新该模块，由于重复调用skynet.start会报错
if mode == "newservice" then
	skynet.start(function ()
		skynet.dispatch("lua",function (session,source,cmd,...)
			if cmd == "start" then
				__onconnect(...)
			elseif cmd == "rpc" then
				skynet.retpack(rpc(cmd,...))
			elseif cmd == "exec" then
				exec(...)
			end
		end)
	end)
else
	__agent = __agent or {}
	return function (httpport,agentnum)
		httpport = httpport or 80
		agentnum = agentnum or 1
		local id = socket.listen("0.0.0.0",httpport)
		local servicename = "gamelogic/service/httpd"
		for i=1,agentnum do
			__agent[i] = skynet.newservice(servicename,"newservice")
		end
		local balance = 0
		socket.start(id,function (id,addr)
			balance = balance + 1
			if balance > agentnum then
				balance = 1
			end
			local ip,port = string.match(addr,"^(.+):(.+)$")
			skynet.send(__agent[balance],"lua","start",id,ip,port)
		end)
	end

end



