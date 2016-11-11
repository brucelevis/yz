globalmgr = globalmgr or {}

function globalmgr.init()
	assert(not globalmgr.binit)
	globalmgr.binit = true
	local server = cserver.new()
	server:loadfromdatabase()
	server:add("runno",1)
	if server:query("runno") == 1 then
		server:create()
	end
	globalmgr.server = server

	local votemgr = cvotemgr.new()
	globalmgr.votemgr = votemgr

	local globalshopdb = cglobalshopdb.new()
	globalshopdb:loadfromdatabase()
	globalmgr.shop = globalshopdb

	globalmgr.rank = {}
	local arenarank = carenarank.new()
	arenarank:loadfromdatabase()
	globalmgr.rank.arena = arenarank

	globalmgr.redpacketmgr = credpacketmgr.new({
		name = "redpacketmgr",
	})

	-- 公会管理器
	if cserver.isunionsrv() then
		unionmgr = cunionmgr.new()
		unionmgr:loadfromdatabase()
	end

	if cserver.isdatacenter() then
		local petcommentmgr = cpetcommentmgr.new()
		petcommentmgr:loadfromdatabase()
		globalmgr.petcommentmgr = petcommentmgr
	end
end

function globalmgr.onlogin(player)
	for i,ranks in pairs(globalmgr.rank) do
		if ranks.onlogin then
			ranks:onlogin(player)
		end
	end
end

function globalmgr.onlogoff(player,reason)
	for i,ranks in pairs(globalmgr.rank) do
		if ranks.onlogoff then
			ranks:onlogoff(player,reason)
		end
	end
end

function globalmgr.onhourupdate()
end

function globalmgr.onfivehourupdate()
	globalmgr.shop:onfivehourupdate()
	for i,ranks in pairs(globalmgr.rank) do
		if ranks.onfivehourupdate then
			ranks:onfivehourupdate()
		end
	end
	if cserver.isunionsrv() then
		unionmgr:onfivehourupdate()
	end
end

-- 生成和服务器相关的全局唯一id
-- @parameter name : 玩法标识
function globalmgr.genid(name,srvname,maxid)
	srvname = srvname or cserver.getsrvname()
	maxid = maxid or 1000000000
	if not globalmgr._id then
		globalmgr._id = {}
	end
	if not globalmgr._id[name] then
		globalmgr._id[name] = {}
	end
	if not globalmgr._id[name][srvname] then
		globalmgr._id[name][srvname] = 0
	end
	globalmgr._id[name][srvname] = globalmgr._id[name][srvname] + 1
	if globalmgr._id[name][srvname] >= maxid then
		globalmgr._id[name][srvname] = 1
	end
	local srv = data_RoGameSrvList[srvname] or data_RoCenterSrvList[srvname]
	return srv.srvno * maxid + globalmgr._id[name][srvname]
end

function globalmgr.srvname(id,maxid)
	maxid = maxid or 1000000000
	local srvno = math.floor(id/maxid)
	if not globalmgr._srvno_srvname then
		globalmgr._srvno_srvname = {}
		for srvname,srv in pairs(data_RoGameSrvList) do
			globalmgr._srvno_srvname[srv.srvno] = srvname
		end
		for srvname,srv in pairs(data_RoCenterSrvList) do
			globalmgr._srvno_srvname[srv.srvno] = srvname
		end
	end
	return assert(globalmgr._srvno_srvname[srvno])
end

function globalmgr.home_srvname(pid,maxid)
	maxid = maxid or 1000000
	return globalmgr.srvname(pid,maxid)
end

function globalmgr.now_srvname(pid)
	local self_srvname = cserver.getsrvname()
	if playermgr.checkonline(pid) then
		return self_srvname,true
	end
	local resume = resumemgr.getresume(pid)
	return resume:get("now_srvname"),resume:get("online")
end

function __hotfix(oldmod)
	globalmgr._srvno_srvname = nil
end

return globalmgr
