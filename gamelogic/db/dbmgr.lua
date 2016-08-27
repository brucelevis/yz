dbmgr = dbmgr or {}

function dbmgr.init()
	dbmgr.conns = {}
	dbmgr.wait_coroutine = {}
end

function dbmgr.getdb(srvname)
	if srvname and tonumber(srvname) then -- pid
		srvname = route.getsrvname(srvname)
	end
	srvname = srvname or cserver.getsrvname()
	local conn = dbmgr.conns[srvname]
	if not conn then
		local conf
		if srvname == cserver.getsrvname() then
			conf = {
				host = skynet.getenv("dbip") or "127.0.0.1",
				port = tonumber(skynet.getenv("dbport")) or 6379,
				db = tonumber(skynet.getenv("dbno")) or 0,
				auth = skynet.getenv("dbauth") or "nomogadbpwd",
			}
		else
			-- 只支持游戏服之间跨服存数据
			local srv = assert(data_RoGameSrvList[srvname])
			conf = deepcopy(srv.db)
			conf.auth = conf.auth or "nomogadbpwd"
			conf.host = srv.inner_ip
		end
		-- 防止同一个服多次初始化redis
		dbmgr.conns[srvname] = "initing"
		conn = cdb.new(conf)  -- 调用了阻塞API
		dbmgr.conns[srvname] = conn
		local wait_coroutine = dbmgr.wait_coroutine
		dbmgr.wait_coroutine = {}
		for i,co in ipairs(wait_coroutine) do
			skynet.error(string.format("getdb(%s) wakeup %s",srvname,co))
			skynet.wakeup(co)
		end
	elseif conn == "initing" then
		-- 挂起当前协程，等db初始化完后再返回，防止高并发db多次初始化
		local co = coroutine.running()
		table.insert(dbmgr.wait_coroutine,co)
		skynet.error(string.format("getdb(%s) wait %s",srvname,co))
		skynet.wait(co)
		conn = dbmgr.conns[srvname]
	end
	return conn
end

function dbmgr.shutdown()
	for srvname,conn in pairs(dbmgr.conns) do
		conn:disconnect()
	end
end

return dbmgr
