clustermgr = clustermgr or {}

function clustermgr.checkserver()
	timer.timeout("clustermgr.checkserver",20,clustermgr.checkserver)
	local self_srvname = cserver.getsrvname()
	-- 游戏服之间集群
	local srvlist = data_RoGameSrvList
	for srvname,srv in pairs(srvlist) do
		if clustermgr.needconnect(srvname,self_srvname) then
			local ok = clustermgr.nodown(srvname)
			if not ok then
				clustermgr.disconnect(srvname)
			else
				clustermgr.onconnect(srvname)
			end
		end
	end
	for srvname,srv in pairs(data_RoCenterSrvList) do
		if not cserver.isaccountcenter(srvname)
			and clustermgr.needconnect(srvname,self_srvname,true) then
			local ok = clustermgr.nodown(srvname)
			if not ok then
				clustermgr.disconnect(srvname)
			else
				clustermgr.onconnect(srvname)
			end
		end
	end
	if cserver.isgamesrv() then
		-- 数据中心,自身战斗服
		local srvlist = {cserver.warsrv(),}
		for _,srvname in pairs(srvlist) do
			assert(self_srvname ~= srvname)
			local ok = clustermgr.nodown(srvname)
			if not ok then
				clustermgr.disconnect(srvname)
			else
				clustermgr.onconnect(srvname)
			end
		end
	end
end

--
function clustermgr.needconnect(srvname,self_srvname,bforce)
	local srv = data_RoGameSrvList[srvname] or data_RoCenterSrvList[srvname]
	self_srvname = self_srvname or cserver.getsrvname()
	local self_srv = data_RoGameSrvList[self_srvname] or data_RoCenterSrvList[self_srvname]
	if self_srvname ~= srvname and
		self_srv.cluster_zone == srv.cluster_zone then
		if bforce then
			return true
		else
			return cserver.isopensrv(srvname)
		end
	end
	return false
end

function clustermgr.isconnect(srvname)
	return clustermgr.connection[srvname]
end

function clustermgr.nodown(srvname)
	local ok,result = pcall(rpc.call,srvname,"heartbeat")
	return ok
end

function clustermgr.onconnect(srvname)
	local oldstate = clustermgr.connection[srvname]
	if not oldstate then
		clustermgr.connection[srvname] = 1
		local self_srvname = cserver.getsrvname()
		logger.log("info","cluster",string.format("%s connected %s",self_srvname,srvname))
		if cserver.isdatacenter(srvname) then
			playermgr.broadcast(function (player)
				sendpackage(player.pid,"player","switch",{
					friend = true,
				})
			end)
			resumemgr.recover_refs()
		end

		if cserver.isgamesrv(self_srvname) and cserver.isgamesrv(srvname) then
			--route.syncto(srvname)
		end
	end
end

function clustermgr.disconnect(srvname)
	local oldstate = clustermgr.connection[srvname]
	if oldstate then
		oldstate = oldstate + 1
		clustermgr.connection[srvname] = oldstate
		-- 连续>=3次以上断开连接才算断开连接
		if oldstate > 3 then
			logger.log("critical","cluster",string.format("%s lost connect %s",cserver.getsrvname(),srvname))
			clustermgr.connection[srvname] = nil
			if cserver.isdatacenter(srvname) then
				playermgr.broadcast(function (player)
					sendpackage(player.pid,"player","switch",{
						friend = false,
					})
				end)
			end
		end
	end
end

function clustermgr.heartbeat(srvname)
	return true
end

function clustermgr.init()
	clustermgr.connection = {}
	-- 开启集群
	local srvname = skynet.getenv("srvname")
	skynet_cluster.open(srvname)

	-- 启服60s后再连接其他服，防止所有服同时启动,那一刻call阻塞导致启服失败
	timer.timeout("clustermgr.checkserver",60,clustermgr.checkserver)
	--clustermgr.checkserver()
end

function __hotfix(oldmod)
	skynet_cluster.reload()
	print("skynet_cluster.reload ok")
end

return clustermgr
