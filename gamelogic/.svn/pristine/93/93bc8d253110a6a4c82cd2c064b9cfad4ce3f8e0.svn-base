netcluster_war = netcluster_war or {}

-- warsrv -> gamesrv 协议处理
local CMD = {}
function CMD.echo(srvname,request)
	logger.log("debug","war",format("[CMD.echo] srvname=%s request=%s",srvname,request))
	return request  -- 返回给游戏服的值，一般协议无需返回，这里仅作测试
end

function CMD.forward(srvname,request)
	logger.log("debug","war",format("[CMD.forward] srvname=%s request=%s",srvname,request))
	local pid = assert(request.pid,"no pid")
	local protoname = assert(request.protoname,"no protoname")
	local protoname,subprotoname = string.match(protoname,"([^_]-)%_(.+)")
	request.pid = nil
	request.protoname = nil
	sendpackage(pid,protoname,subprotoname,request)
end


function netcluster_war.dispatch(source,cmd,...)
	assert(type(source) == "string","Invalid source:" .. tostring(source))
	local func = assert(CMD[cmd],"Unknow cmd:" .. tostring(cmd))
	return func(source,...)
end

return netcluster_war
