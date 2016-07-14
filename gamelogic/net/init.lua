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
	net.war = require "gamelogic.net.war"
	net.title = require "gamelogic.net.title"
	net.safelock = require "gamelogic.net.safelock"
end

-- 框架初始化完毕后调用，在serverinfo:startgame
function net.dispatch()
	require "gamelogic.service.init"
	require "gamelogic.cluster.init"
	g_serverinfo:regNewDispatcher("service",service.dispatch)
	g_serverinfo:regNewDispatcher("cluster",rpc.dispatch)
end

-- 认证登录前允许的协议
local allow_proto_before_passlogin = {
	login = true,
	kuafu = true,
}

-- c2s
local reqnet = net_reqnet
function reqnet:netcommad(obj,request)
	local protoname = request.p
	local subprotoname = request.s
	local request = request.a
	local player = playermgr.getobjectbyfd(obj.__fd)
	if not player then
		player = obj
	end
	local link_pid = obj.pid
	local pid = player.pid
	logger.log("debug","netclient",format("[recv] link_pid=%s pid=%s agent=%s protoname=%s subprotoname=%s request=%s",link_pid,pid,obj.__agent,protoname,subprotoname,request))
	if not obj.passlogin and not allow_proto_before_passlogin[protoname] then
		logger.log("warning","netclient",format("[not passlogin] link_pid=%s pid=%s request=%s",link_pid,pid,request))
		return
	end
	if not net[protoname] then
		logger.log("warning","netclient",format("[unknow proto] link_pid=%s pid=%s request=%s",link_pid,pid,request))
		return
	end
	local C2S = net[protoname].C2S
    local func = C2S[subprotoname]
    if not func then
        logger.log("warning","netclient",format("[unknow cmd] link_pid=%s pid=%s request=%s",link_pid,pid,request))
        return
    end
	local r = func(player,request)
	return r
end

function __hotfix(oldmod)
	net.init()
end

return net
