scenemgr = scenemgr or {}

function scenemgr.init()
	scenemgr.scenes = {}
	local normal_map = data_0501_Map
	for mapid,v in pairs(normal_map) do
		-- 普通地图：场景ID保持和地图ID一致，其他副本场景均从100ID开始
		scenemgr.addscene(mapid,mapid)
	end
	assert(#normal_map < 100)
	scenemgr.sceneid = 100
	scenemgr.npcid = 0
	scenemgr.starttimer_checkallnpc()
end

function scenemgr.getmap(mapid)
	return data_0501_Map[mapid]
end

function scenemgr.gen_sceneid()
	if scenemgr.sceneid > MAX_NUMBER then
		scenemgr.sceneid = 100
	end
	scenemgr.sceneid = scenemgr.sceneid + 1
	return scenemgr.sceneid
end

function scenemgr.addscene(mapid,sceneid)
	require "gamelogic.scene.init"
	sceneid = sceneid or scenemgr.gen_sceneid()
	local map = scenemgr.getmap(mapid)
	local param = {
		mapid = mapid,
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
	scenemgr.npcid = scenemgr.npcid + 1
	if scenemgr.npcid > MAX_NUMBER then
		scenemgr.npcid = 1
	end
	return scenemgr.npcid
end

--/*
-- npc => {
--		id : npcid,
--		type : 怪物类型,
--		name : 名字,
--		sceneid : 场景ID,
--		loc : 坐标,
--		purpose : 用途,
--		exceedtime : 过期时间点,
--		lifenum : 生命数,
--		max_warcnt : 同时发生的最大战斗数,
-- }
--*/
function scenemgr.addnpc(npc,sceneid)
	if sceneid then
		npc.sceneid = sceneid
	end
	sceneid = npc.sceneid
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return false
	end
	local npcs = scene.npcs
	local npcid = scenemgr.gennpcid()
	npc.id = npcid
	logger.log("info","scene",format("[addnpc] npcid=%s npc=%s",npcid,npc))
	scene.npcs[npcid] = npc
	if npc.onadd then
		npc.onadd(npc)
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
		if npc.ondel then
			npc.ondel(npc)
		end
		logger.log("info","scene",format("[delnpc] npcid=%s npc=%s",npcid,npc))
		scene.npcs[npcid] = nil
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
	logger.log("info","scene",format("[updatenpc] npcid=%s updateattr=%s",updateattr))
	for k,v in pairs(updateattr) do
		npc[k] = v
	end
	if npc.onupdate then
		npc.onupdate(npc,updateattr)
	end
end

function scenemgr.checknpc(npc)
	if npc.exceedtime then
		local now = os.time()
		return npc.exceedtime < now
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

return scenemgr
