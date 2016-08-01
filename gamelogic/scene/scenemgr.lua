scenemgr = scenemgr or {}

function scenemgr.init()
	scenemgr.scenes = {}
	scenemgr.newcomer_sceneids = {}   -- 新手村场景
	scenemgr.sceneid = 1000
	local normal_map = data_0401_Map
	assert(#normal_map < scenemgr.sceneid)
	for mapid,v in pairs(normal_map) do
		-- 普通地图：场景ID保持和地图ID一致，其他副本场景均从100ID开始
		if mapid == 1 then	-- 新手村地图
			local scene = scenemgr.addscene(mapid,mapid)
			table.insert(scenemgr.newcomer_sceneids,scene.sceneid)
			for i = 1,4 do
				local scene = scenemgr.addscene(mapid)
				table.insert(scenemgr.newcomer_sceneids,scene.sceneid)
			end
		else
			scenemgr.addscene(mapid,mapid)
		end
	end
	-- 保证动态NPC生成的ID和客户端NPC（固定NPC）id不一样
	scenemgr.npcid = data_GameID.npc.endid
	scenemgr.itemid = 0
	scenemgr.starttimer_checkallnpc()
	scenemgr.starttimer_checkallitem()
end

function scenemgr.getmap(mapid)
	return data_0401_Map[mapid]
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
	end
	mapname = mapname or map.name
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
--		pos : 坐标,
--		purpose : 用途分类,
--		exceedtime : 过期时间点,
--		lifenum : 生命数,
--		max_warcnt : 同时发生的最大战斗数,
--		cur_warcnt : 当前正在进行的战斗数,
-- }
--*/
function scenemgr.addnpc(npc,sceneid)
	assert(npc.shape)
	assert(npc.pos)
	if sceneid then
		npc.sceneid = sceneid
	end
	sceneid = npc.sceneid
	assert(sceneid)
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return false
	end
	if not scene:isvalidpos(npc.pos) then
		npc.pos = scene:fixpos(npc.pos)
	end
	local npcs = scene.npcs
	local npcid = scenemgr.gennpcid()
	npc.id = npcid
	npc.mapid = scene.mapid
	logger.log("info","scene",format("[addnpc] npcid=%s npc=%s",npcid,npc))
	npc.createtime = os.time()
	scene.npcs[npcid] = npc
	scene:broadcast("scene","addnpc",{npc=npc})
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

		scene:broadcast("scene","delnpc",{id=npc.id,sceneid=npc.sceneid})
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
		scene:broadcast("scene","updatenpc",updateattr)
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
--		pos : 坐标,
--		exceedtime : 过期时间点,
--		num : 数量
--		bind : 绑定标志
-- }
--*/
function scenemgr.additem(item,sceneid)
	assert(item.type)
	assert(item.pos)
	if sceneid then
		item.sceneid = sceneid
	end
	sceneid = item.sceneid
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return false
	end
	local items = scene.items
	local itemid = scenemgr.genitemid()
	item.id = itemid
	logger.log("info","scene",format("[additem] itemid=%s item=%s",itemid,item))
	scene.items[itemid] = item
	scene:broadcast("scene","additem",{item=item})
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


return scenemgr
