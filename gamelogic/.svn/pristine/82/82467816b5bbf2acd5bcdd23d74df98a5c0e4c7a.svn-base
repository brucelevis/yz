require "gamelogic.base.class"
require "gamelogic.base.databaseable"

cresourcemgr = class("cresourcemgr",cdatabaseable)

function cresourcemgr:init(templ,playunit)
	self.template = templ
	self.playunit = playunit
	cdatabaseable.init(self,{
		pid = self.playunit.pid,
		flag = string.format("res_%s",self.template.name)
	})
	self.data = {}
	self.npclist = {}
	self.scenelist = {}
	self.npcid = 0
end

function cresourcemgr:save()
	local data = {}
	data.npc = {}
	for _,npc in pairs(self.npclist) do
		table.insert(data.npc,{
			nid = npc.nid,
			type = npc.type,
			name = npc.name,
			pos = npc.pos,
			isclient = npc.isclient,
			mapid = npc.mapid,
		})
	end
	data.scene = {}
	for mapid,scenelst in pairs(self.scenelist) do
		table.insert(data.scene,{
			mapid = mapid,
			num = table.count(scenelst),
		})
	end
	data.data = self.data
	return data
end

function cresourcemgr:load(data)
	if not data or not next(data) then
		return
	end
	for _,scene in ipairs(data.scene) do
		local mapid = scene.mapid
		local num = scene.num
		for i = 1,num do
			self:addscene(mapid)
		end
	end
	for _,npc in ipairs(data.npc) do
		self:addnpc(npc)
		self:enterscene(npc)
	end
	self.data = data.data or {}
end

--[[
npc = {
	nid = 导表id,
	type = 怪物类型,
	name = 名字,
	mapid = 地图id,
	pos = 坐标，
	isclient = 是否仅为客户端npc,
}
]]--
function cresourcemgr:addnpc(npc)
	assert(npc.nid)
	assert(npc.mapid)
	npc.id = self:gennpcid()
	self.npclist[npc.id] = npc
	if npc.isclient then
		npc.sceneid = npc.mapid
	end
end

function cresourcemgr:gennpcid()
	if self.npcid >= MAX_NUMBER then
		self.npcid = 0
	end
	self.npcid = self.npcid + 1
	return self.npcid
end

function cresourcemgr:enterscene(npc,sceneid)
	if npc.isclient then
		return
	end
	--检查是否添加到自己创建的场景里面
	if not sceneid and self.scenelist[npc.mapid] then
		for _,scid in ipairs(self.scenelist[npc.mapid]) do
			if scenemgr.getscene(scid) then
				sceneid = scid
				break
			end
		end
	end
	--检查是否添加到全局场景中
	if not sceneid then
		local scene = scenemgr.getscene(npc.mapid)
		if scene then
			sceneid = scene.id
		end
	end
	assert(sceneid)
	scenemgr.addnpc(npc,sceneid)
end

function cresourcemgr:delnpc(npc)
	self.npclist[npc.id] = nil
	if npc.isclient then
		return
	end
	scenemgr.delnpc(npc.id,npc.sceneid)
end

function cresourcemgr:addscene(map)
	local scene = scenemgr.addscene(map)
	if scene then
		if not self.scenelist[map.mapid] then
			self.scenelist[map.mapid] = {}
		end
		table.insert(self.scenelist[map.mapid],scene.id)
		return scene
	end
end

function cresourcemgr:delscene(sceneid)
	local scene = scenemgr.getscene(sceneid)
	if scene then
		local mapid = scene.mapid
		if self.scenelist[mapid] then
			local remove = nil
			for idx,scid in ipairs(self.scenelist[mapid]) do
				if scid == sceneid then
					remove = idx
					break
				end
			end
			if remove then
				table.remove(self.scenelist[mapid],remove)
			end
		end
		scenemgr.delscene(sceneid)
	end
end

function cresourcemgr:getscenes(mapid)
	if not self.scenelist[mapid] then
		return
	end
	local scenes = {}
	for _,sceneid in ipairs(self.scenelist[mapid]) do
		scene = scenemgr.getscene(sceneid)
		if scene then
			table.insert(scenes,scene)
		end
	end
	return scenes
end

function cresourcemgr:release()
	for _,npc in pairs(self.npclist) do
		self:delnpc(npc)
	end
	for mapid,scidlst in pairs(self.scenelist) do
		for _,sceneid in ipairs(scidlst) do
			scenemgr.delscene(sceneid)
		end
	end
	self.template = nil
	self.playunit = nil
	self.npclist = nil
	self.scenelist = nil
end

return cresourcemgr

