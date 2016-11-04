skynet_cluster = require "cluster"
rpc = rpc or {}

function rpc.init()
	clustermgr.init()
	netcluster.init()
	route.init()
	resumemgr.init()
end

function rpc.dispatch (_,session,source,_,srvname,protoname,...)
	logger.log("debug","netcluster",format("[recv] source=%s session=%d srvname=%s protoname=%s,request=%s",source,session,srvname,protoname,{...}))
	local rettbl = table.pack(pcall(rpc.__dispatch,session,source,srvname,protoname,...))
	local isok = table.remove(rettbl,1)
	if isok then
		skynet.ret(skynet.pack(table.unpack(rettbl)))
	else
		local errmsg = table.concat(rettbl)
		logger.log("error","errdetail",errmsg)
		skynet.response()(false)
	end
end

function rpc.__dispatch(session,source,srvname,protoname,...)
	if protoname == "heartbeat" then
		return clustermgr.heartbeat(srvname)
	else
		local mod = assert(netcluster[protoname],string.format("[cluster] from %s,unknow protoname:%s",srvname,protoname))
		return mod.dispatch(srvname,...)
	end
end

local MAINSRV_NAME="SKYNETSERVICE"

function rpc.call(srvname,protoname,cmd,...)
	local self_srvname = skynet.getenv("srvname")
	assert(srvname ~= self_srvname,"cluster call self,srvname:" .. tostring(srvname))
	local request = {...}
	logger.log("debug","netcluster",format("[call] srvname=%s protoname=%s cmd=%s request=%s",srvname,protoname,cmd,request))
	local ret = {skynet_cluster.call(srvname,MAINSRV_NAME,"cluster",self_srvname,protoname,cmd,...)} 
	logger.log("debug","netcluster",format("[return] srvname=%s protoname=%s cmd=%s request=%s retval=%s",srvname,protoname,cmd,request,ret))
	return table.unpack(ret)

end

function rpc.pcall(srvname,protoname,cmd,...)
	return pcall(rpc.call,srvname,protoname,cmd,...)
end

return rpc


