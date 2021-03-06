dbmgr = dbmgr or {}

function dbmgr.init()
	dbmgr.conns = {}
	dbmgr.wait_coroutine = {}
end

function dbmgr.getsrvname(pid)
	return globalmgr.home_srvname(pid)
end

function dbmgr.getdb(srvname)
	if srvname and tonumber(srvname) then -- pid
		srvname = dbmgr.getsrvname(tonumber(srvname))
	end
	srvname = srvname or cserver.getsrvname()
	local conn = dbmgr.conns[srvname]
	if not conn then
		local srv = data_RoGameSrvList[srvname] or data_RoCenterSrvList[srvname]
		local conf = deepcopy(srv.db)
		conf.auth = conf.auth or "nomogadbpwd"
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
