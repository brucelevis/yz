net = net or {}
function net.init()
	net.test = require "gamelogic.net.test"
	net.login = require "gamelogic.net.login"
	net.msg = require "gamelogic.net.msg"
	net.friend = require "gamelogic.net.friend"
	net.mail = require "gamelogic.net.mail"
	net.team = require "gamelogic.net.team"
	net.scene = require "gamelogic.net.scene"
	net.task = require "gamelogic.net.task"
	net.kuafu = require "gamelogic.net.kuafu"
	net.item = require "gamelogic.net.item"
end

-- 框架初始化完毕后调用，在serverinfo:startgame
function net.dispatch()
	require "gamelogic.service.init"
	require "gamelogic.cluster.init"
	g_serverinfo:regNewDispatcher("service",service.dispatch)
	g_serverinfo:regNewDispatcher("cluster",rpc.dispatch)
end

-- c2s
local reqnet = net_reqnet
function reqnet:netcommad(obj,request)
	local pid = obj.pid
	local protoname = request.p
	local subprotoname = request.s
	local request = request.a
	logger.log("debug","netclient",format("[recv] pid=%s agent=%s protoname=%s subprotoname=%s request=%s",pid,obj.__agent,protoname,subprotoname,request))
	if not obj.passlogin and protoname ~= "login" then
		logger.log("warning","netclient",format("[not passlogin] pid=%s request=%s",pid,request))
		return
	end
	if not net[protoname] then
		logger.log("warning","netclient",format("[unknow proto] pid=%s request=%s",pid,request))
		return
	end
	local C2S = net[protoname].C2S
    local func = C2S[subprotoname]
    if not func then
        logger.log("warning","netclient",format("[unknow cmd] pid=%s request=%s",pid,request))
        return
    end

	local r = func(obj,request)
	return r
end

function __hotfix(oldmod)
	net.init()
end

return net
