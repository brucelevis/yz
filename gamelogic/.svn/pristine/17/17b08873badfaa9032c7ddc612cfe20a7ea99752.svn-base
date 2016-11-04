route = route or {}

function route.init()
	route.map = {}
	route.sync_state = {}
	local self_srvname = skynet.getenv("srvname")
	route.map[self_srvname] = {}
	local pids = route.map[self_srvname]
	local db = dbmgr.getdb()
	local pidlist = db:hkeys(db:key("role","list")) or {}
	print("server all pids:",#pidlist)
	for i,v in ipairs(pidlist) do
		pids[tonumber(v)] = true
	end
end

function route.onlogin(player)
	-- 上线时检查一次“玩家路由”是否存在，不存在则设置并同步到其他服，防止由于异常情况（如：内网删除数据库/网络不好每同步到),没有设置正确的“玩家路由”
	local pid = player.pid
	-- 上线的玩家可能是跨服过来的玩家
	if not player.home_srvname then -- 本服玩家
		if not route.getsrvname(pid) then
			local self_srvname = skynet.getenv("srvname")
			local db = dbmgr.getdb()
			db:hset(db:key("role","list"),pid,1)
			route.addroute({pid},self_srvname)
		end
	end
end

function route.getsrvname(pid)
	for srvname,pids in pairs(route.map) do
		if pids[pid] then
			return srvname
		end
	end
	--error("pid not map to a server,pid:" .. tostring(pid))
end

function route.addroute(pids,srvname)
	if type(pids) == "number" then
		pids = {pids,}
	end
	local self_srvname = skynet.getenv("srvname")
	srvname = srvname or self_srvname
	if not route.map[srvname] then
		route.map[srvname] = {}
	end
	for _,pid in ipairs(pids) do
		route.map[srvname][pid] = true
	end
	if srvname == self_srvname then
		for servername,_ in pairs(clustermgr.connection) do
			if cserver.isgamesrv(servername) and servername ~= self_srvname then
				rpc.pcall(servername,"route","addroute",pids)
			end
		end
	end
end

function route.delroute(pids,srvname)
	if type(pids) == "number" then
		pids = {pids,}
	end
	local self_srvname = skynet.getenv("srvname")
	srvname = srvname or self_srvname
	local pidlist = route.map[srvname]
	if pidlist then
		for _,pid in ipairs(pids) do
			pidlist[pid] = nil
		end
	end
	if srvname == self_srvname then
		for servername,_ in pairs(clustermgr.connection) do
			if cserver.isgamesrv(servername) and servername ~= self_srvname then
				rpc.pcall(servername,"route","delroute",pids)
			end
		end
	end
end

function route.syncto(srvname)
	xpcall(function ()
		local step = 5000
		local self_srvname = skynet.getenv("srvname")
		if not cserver.isgamesrv(self_srvname) or not cserver.isgamesrv(srvname) then
			return
		end
		local pidlist = route.map[self_srvname]
		pidlist = table.keys(pidlist)
		logger.log("debug","route",format("[syncto] server(%s->%s) pidlist=%s",skynet.getenv("srvname"),srvname,pidlist))
		for i = 1,#pidlist,step do
			rpc.call(srvname,"route","addroute",table.slice(pidlist,i,i+step-1))
		end
		rpc.call(srvname,"route","sync_finish")
	end,onerror)
end

local CMD = {}
function CMD.addroute(srvname,pids)
	logger.log("debug","route",format("[CMD.addroute] srvname=%s pids=%s",srvname,pids))
	route.addroute(pids,srvname)
end

function CMD.sync_finish(srvname)
	logger.log("debug","route",string.format("[CMD.sync_finish] srvname=%s",srvname))
	route.sync_state[srvname] = true
end

function CMD.delroute(srvname,pids)
	logger.log("debug","route",format("[CMD.delroute] srvname=%s pids=%s",srvname,pids))
	route.delroute(pids,srvname)
end

function route.dispatch(srvname,cmd,...)
	assert(cserver.isgamesrv(srvname),"[route.dispatch] Not a gamesrv:" .. tostring(srvname))
	local func = assert(CMD[cmd],"[route] Unknow cmd:" .. tostring(cmd))
	return func(srvname,...)
end

return route
