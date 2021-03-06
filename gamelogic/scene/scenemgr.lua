scenemgr = scenemgr or {}

function scenemgr.init()
	scenemgr.scenes = {}
	scenemgr.newcomer_sceneids = {}   -- 新手村场景
	scenemgr.sceneid = 1000
	local normal_map = data_0401_Map
	assert(#normal_map < scenemgr.sceneid)
	for mapid,v in pairs(normal_map) do
		-- 普通地图：场景ID保持和地图ID一致，其他副本场景均从100ID开始
		if mapid == 2 then	-- 新手村地图
			local scene = scenemgr.addscene(mapid,mapid)
			table.insert(scenemgr.newcomer_sceneids,scene.sceneid)
			-- for i = 1,4 do
			-- 	local scene = scenemgr.addscene(mapid)
			-- 	table.insert(scenemgr.newcomer_sceneids,scene.sceneid)
			-- end
		else
			scenemgr.addscene(mapid,mapid)
		end
	end
	-- 保证动态NPC生成的ID和客户端NPC（固定NPC）id不一样
	scenemgr.npcid = data_GameID.npc.endid
	scenemgr.itemid = 0
	scenemgr.starttimer_checkallnpc()
	scenemgr.starttimer_checkallitem()
	scenemgr.starttimer_statscene()
end

function scenemgr.getmap(mapid)
	local mapinfo = data_0401_Map[mapid]
	local map = require(string.format("gamelogic.data.mapdata.%s",mapinfo.mapfile))
	map.height = map.gridNum[2] * map.gridSize[2]
	map.width = map.gridNum[1] * map.gridSize[1]
	map.block_height = mapinfo.block_height		-- 九宫格高度（视野高度)
	map.block_width	= mapinfo.block_width		-- 九宫格宽度(视野跨度)
	map.name = mapinfo.name
	return map
end

function scenemgr.gen_sceneid()
	if scenemgr.sceneid > MAX_NUMBER then
		scenemgr.sceneid = 1000
	end
	scenemgr.sceneid = scenemgr.sceneid + 1
	return scenemgr.sceneid
end

function scenemgr.addscene(mapid,sceneid)
	sceneid = sceneid or scenemgr.gen_sceneid()
	local map
	local mapname
	if type(mapid) == "table" then
		map = mapid
		mapname = map.name
		map = scenemgr.getmap(map.mapid)
	else
		map = scenemgr.getmap(mapid)
		mapname = map.name
	end
	local map = scenemgr.getmap(mapid)
	local param = {
		mapid = mapid,
		mapname = mapname,
		width = map.width,
		height = map.height,
		block_width = map.block_width,
		block_height = map.block_height,
		sceneid = sceneid,
	}
	assert(scenemgr.scenes[sceneid] == nil)
	local scene = cscene.new(param)
	logger.log("info","scene",string.format("[addscene] sceneid=%s mapid=%s",sceneid,mapid))
	scenemgr.scenes[sceneid] = scene
	return scene
end

function scenemgr.delscene(sceneid)
	local scene = scenemgr.getscene(sceneid)
	if scene then
		logger.log("info","scene",string.fromat("[delscene] sceneid=%s mapid=%s",sceneid,scene.mapid))
		scene:exit()
		scenemgr.scenes[sceneid] = nil
	end
end

function scenemgr.getscene(sceneid)
	return scenemgr.scenes[sceneid]
end

function scenemgr.gennpcid()
	if scenemgr.npcid > MAX_NUMBER then
		scenemgr.npcid = data_GameID.npc.endid
	end
	scenemgr.npcid = scenemgr.npcid + 1
	return scenemgr.npcid
end

--/*
-- npc => {
--		id : npcid,
--		shape : 怪物造型,
--		name : 名字,
--		sceneid : 场景ID,
--		posid : 坐标ID,
--		purpose : 用途分类,
--		exceedtime : 过期时间点,
--		lifenum : 生命数,
--		max_warcnt : 同时发生的最大战斗数,
--		cur_warcnt : 当前正在进行的战斗数,
-- }
--*/
function scenemgr.addnpc(npc,sceneid)
	assert(npc.shape)
	assert(npc.posid or npc.pos)
	if sceneid then
		npc.sceneid = sceneid
	elseif not npc.sceneid then
		npc.sceneid = scenemgr.getmapid(npc.posid)
	end
	sceneid = npc.sceneid
	assert(sceneid)
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return false
	end
	if not npc.pos then
		local _,x,y = scenemgr.getpos(npc.posid)
		npc.pos = {x = x, y = y, dir = npc.dir or 1}
	end
	if not scene:isvalidpos(npc.pos) then
		npc.pos = scene:fixpos(npc.pos)
	end
	local npcs = scene.npcs
	if not npc.id then
		local npcid = scenemgr.gennpcid()
		npc.id = npcid
	end
	npc.mapid = scene.mapid
	npc.createtime = os.time()
	logger.log("info","scene",format("[addnpc] npcid=%s npc=%s",npc.id,npc))
	scene.npcs[npc.id] = npc
	if npc.onadd then
		npc:onadd()
	else
		scene:broadcast("scene","addnpc",{ npc = scene:packnpc(npc) })
	end
	return true
end

function scenemgr.delnpc(npcid,sceneid)
	if sceneid then
		return scenemgr.__delnpc(npcid,sceneid)
	else
		for sceneid,scene in pairs(scenemgr.scenes) do
			local npc = scenemgr.__delnpc(npcid,sceneid)
			if npc then
				return npc
			end
		end
	end
end

function scenemgr.__delnpc(npcid,sceneid)
	assert(sceneid)
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return
	end
	local npc = scene.npcs[npcid]
	if npc then
		logger.log("info","scene",format("[delnpc] npcid=%s npc=%s",npcid,npc))
		scene.npcs[npcid] = nil

		if npc.ondel then
			npc:ondel()
		else
			scene:broadcast("scene","delnpc",{id=npc.id,sceneid=npc.sceneid})
		end
		return npc
	end
end

function scenemgr.getnpc(npcid,sceneid)
	if sceneid then
		local scene = scenemgr.getscene(sceneid)
		if not scene then
			return
		end
		return scene.npcs[npcid]
	else
		for sceneid,scene in pairs(scenemgr.scenes) do
			local npc = scene.npcs[npcid]
			if npc then
				return npc
			end
		end
	end
end

function scenemgr.updatenpc(npc,updateattr)
	if table.isempty(updateattr) then
		return
	end
	logger.log("info","scene",format("[updatenpc] npcid=%s updateattr=%s",updateattr))
	for k,v in pairs(updateattr) do
		npc[k] = v
	end
	local scene = scenemgr.getscene(npc.sceneid)
	if scene then
		updateattr.id = npc.id
		if npc.onupdate then
			npc:onupdate(updateattr)
		else
			scene:broadcast("scene","updatenpc",updateattr)
		end
	end
end

function scenemgr.checknpc(npc)
	if npc.exceedtime then
		local now = os.time()
		return npc.exceedtime > now
	end
	return true
end

function scenemgr.starttimer_checkallnpc()
	local delay = scenemgr.checkallnpc_delay or 300
	timer.timeout("timer.checkallnpc",delay,scenemgr.starttimer_checkallnpc)
	for sceneid,scene in pairs(scenemgr.scenes) do
		for npcid,npc in pairs(scene.npcs) do
			if not scenemgr.checknpc(npc) then
				scenemgr.delnpc(npcid,sceneid)
			end
		end
	end
end

function scenemgr.starttimer_statscene()
	local normal_map = data_0401_Map
	local stat = {}
	for mapid,v in pairs(normal_map) do
		local mapids = {mapid}
		if mapid == 2 then -- 新手村
			mapids = scenemgr.newcomer_sceneids
		end
		for i,sceneid in pairs(mapids) do
			local scene = scenemgr.getscene(sceneid)
			local info = scene:info()
			info.mapname = scene.mapname
			stat[mapid] = info
		end
	end
	logger.log("info","scene",format("[stat] scenes=%s",stat))
	local delay = skynet.getenv("servermode") == "DEBUG" and 30 or 90
	timer.timeout("timer.statscene",delay,scenemgr.starttimer_statscene)
end

function scenemgr.genitemid()
	if scenemgr.itemid > MAX_NUMBER then
		scenemgr.itemid = 0
	end
	scenemgr.itemid = scenemgr.itemid + 1
	return scenemgr.itemid
end

--/*
-- item => {
--		id : itemid,
--		type : 物品类型,
--		sceneid : 场景ID,
--		posid : 坐标ID,
--		exceedtime : 过期时间点,
--		num : 数量
--		bind : 绑定标志
-- }
--*/
function scenemgr.additem(item,sceneid)
	assert(item.type)
	assert(item.posid)
	if sceneid then
		item.sceneid = sceneid
	end
	sceneid = item.sceneid
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return false
	end
	local _,x,y = scenemgr.getpos(item.posid)
	item.pos = { x = x, y = y,}
	local items = scene.items
	local itemid = scenemgr.genitemid()
	item.id = itemid
	logger.log("info","scene",format("[additem] itemid=%s item=%s",itemid,item))
	scene.items[itemid] = item
	scene:broadcast("scene","additem",{ item = scene:packitem(item) })
	return true
end

function scenemgr.delitem(itemid,sceneid)
	if sceneid then
		return scenemgr.__delitem(itemid,sceneid)
	else
		for sceneid,scene in pairs(scenemgr.scenes) do
			local item = scenemgr.__delitem(itemid,sceneid)
			if item then
				return item
			end
		end
	end
end

function scenemgr.__delitem(itemid,sceneid)
	assert(sceneid)
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return
	end
	local item = scene.items[itemid]
	if item then
		logger.log("info","scene",format("[delitem] itemid=%s item=%s",itemid,item))
		scene.items[itemid] = nil

		scene:broadcast("scene","delitem",{id=item.id,sceneid=item.sceneid})
		return item
	end
end

function scenemgr.getitem(itemid,sceneid)
	if sceneid then
		local scene = scenemgr.getscene(sceneid)
		if not scene then
			return
		end
		return scene.items[itemid]
	else
		for sceneid,scene in pairs(scenemgr.scenes) do
			local item = scene.items[itemid]
			if item then
				return item
			end
		end
	end
end

function scenemgr.updateitem(item,updateattr)
	if table.isempty(updateattr) then
		return
	end
	logger.log("info","scene",format("[updateitem] itemid=%s updateattr=%s",updateattr))
	for k,v in pairs(updateattr) do
		item[k] = v
	end
	local scene = scenemgr.getscene(item.sceneid)
	if scene then
		updateattr.id = item.id
		scene:broadcast("scene","updateitem",updateattr)
	end
	
end

function scenemgr.checkitem(item)
	if item.exceedtime then
		local now = os.time()
		return item.exceedtime > now
	end
	return true
end

function scenemgr.starttimer_checkallitem()
	local delay = scenemgr.checkallitem_delay or 300
	timer.timeout("timer.checkallitem",delay,scenemgr.starttimer_checkallitem)
	for sceneid,scene in pairs(scenemgr.scenes) do
		for itemid,item in pairs(scene.items) do
			if not scenemgr.checkitem(item) then
				scenemgr.delitem(itemid,sceneid)
			end
		end
	end
end

-- 获得X像素坐标
function scenemgr.getx(posid)
	local data = data_0401_MapDstPoint[posid] or data_0401_MapDstPoint[tostring(posid)]
	local mapid = data.mapId
	local gridx = data.grid[1]
	local map = scenemgr.getmap(mapid)
	local grid_width = map.gridSize[1]
	local map_width = map.width
	local x = math.floor(grid_width * (gridx + 0.5))
	return math.min(map_width,math.max(0,x))
end

-- 获得Y像素坐标
function scenemgr.gety(posid)
	local data = data_0401_MapDstPoint[posid] or data_0401_MapDstPoint[tostring(posid)]
	local mapid = data.mapId
	local gridy = data.grid[2]
	local map = scenemgr.getmap(mapid)
	local grid_height = map.gridSize[2]
	local map_height = map.height
	local y = math.floor(map_height - grid_height * (gridy + 0.5))
	return math.min(map_height,math.max(0,y))
end

-- 获取地图id
function scenemgr.getmapid(posid)
	local data = data_0401_MapDstPoint[posid] or data_0401_MapDstPoint[tostring(posid)]
	return data.mapId
end

function scenemgr.getpos(posid)
	return scenemgr.getmapid(posid),scenemgr.getx(posid),scenemgr.gety(posid)
end

