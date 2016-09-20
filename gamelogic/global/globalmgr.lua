globalmgr = globalmgr or {}

function globalmgr.init()
	assert(not globalmgr.binit)
	globalmgr.binit = true
	globalmgr.id = 0
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
end

function globalmgr.genid()
	if globalmgr.id > MAX_NUMBER then
		globalmgr.id = 0
	end
	globalmgr.id = globalmgr.id + 10000
	return globalmgr.id-10000,globalmgr.id
end

return globalmgr
