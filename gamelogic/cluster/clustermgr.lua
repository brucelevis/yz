clustermgr = clustermgr or {}

function clustermgr.checkserver()
	timer.timeout("clustermgr.checkserver",60,clustermgr.checkserver)
	local self_srvname = cserver.getsrvname()
	-- 游戏服之间集群
	local srvlist = data_RoGameSrvList
	for srvname,_ in pairs(srvlist) do
		if srvname ~= self_srvname then
			local ok,result = pcall(rpc.call,srvname,"heartbeat")
			if not ok then
				clustermgr.disconnect(srvname)
			else
				clustermgr.onconnect(srvname)
			end
		end
	end
	if not cserver.isdatacenter() then
		-- 数据中心,自身战斗服
		local srvlist = {cserver.datacenter(),cserver.warsrv(),}
		for _,srvname in pairs(srvlist) do
			assert(self_srvname ~= srvname)
			local ok,result = pcall(rpc.call,srvname,"heartbeat")
			if not ok then
				clustermgr.disconnect(srvname)
			else
				clustermgr.onconnect(srvname)
			end
		end
	end
end

function clustermgr.isconnect(srvname)
	return clustermgr.connection[srvname]
end

function clustermgr.onconnect(srvname)
	local oldstate = clustermgr.connection[srvname]
	clustermgr.connection[srvname] = true
	if not oldstate then
		local self_srvname = cserver.getsrvname()
		logger.log("info","cluster",string.format("%s connected %s",self_srvname,srvname))
		if cserver.isdatacenter(srvname) then
			playermgr.broadcast(function (player)
				sendpackage(player.pid,"player","switch",{
					friend = true,
				})
			end)
		end

		if cserver.isgamesrv(self_srvname) and cserver.isgamesrv(srvname) then
			route.syncto(srvname)
		end
	end
end

function clustermgr.disconnect(srvname)
	local oldstate = clustermgr.connection[srvname]
	clustermgr.connection[srvname] = nil
	if oldstate then
		logger.log("critical","cluster",string.format("%s lost connect %s",cserver.getsrvname(),srvname))
		if cserver.isdatacenter(srvname) then
			playermgr.broadcast(function (player)
				sendpackage(player.pid,"player","switch",{
					friend = false,
				})
			end)
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

	-- 启服60s后再连接其他服，防止所有服同时启动服务器那一刻call阻塞导致启服失败
	timer.timeout("clustermgr.checkserver",60,clustermgr.checkserver)
	--clustermgr.checkserver()
end

function __hotfix(oldmod)
	skynet_cluster.reload()
	print("skynet_cluster.reload ok")
end

return clustermgr
