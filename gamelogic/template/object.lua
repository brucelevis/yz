require "gamelogic.base.class"

cresourcemgr = class.new("resourcemgr")

function cresourcemgr:init(templ)
	self.template = templ
	self.npclist = {}
	self.scenelist = {}
end

function cresourcemgr:save()
	local data = {}
	data.npc = {}
	for _,npc in pairs(self.npclist) do
		table.insert(data.npc,npc.save())
	end
	data.scene = {}
	for _,scene in pairs(self.scenelist) do
		table.insert(data.scene,scene.save())
	end
	return data
end

function cresourcemgr:load(data)
	if not data or not next(data) then
		return
	end
	for npcinfo in data.npc do
		local npc = self.template:restore_npc(npcinfo)
		self:addnpc(npc)
	end
	for sceneinfo in data.scene do
		local scene = self.template:restrore_scene(sceneinfo)
		sefl:addscene(scene)
	end
end

function cresourcemgr:addnpc(npc)
	self.npclist[npc.id] = npc
end

function cresourcemgr:addscene(scene)
	self.scenelist[scene.id] = scene
end

function cresourcemgr:release()
	for _,npc in pairs(self.npclist) do
		npc.release()
	end
	for _,scene in pairs(self.scenelist) do
		scene.release()
	end
	self.template = nil
	self.npclist = nil
	self.scenelist = nil
end

cnpc = class("templ_npc")

function cnpc:init(templ)
	self.template = templ
end

cscene = class("templ_scene")

function cscene:init(templ)
	self.template = templ
end

cwar = class("templ_war")

function cwar:init(templ)
	self.template = templ
end

object = {
	cresourcemgr = cresourcemgr,
	cnpc = cnpc,
	cscene = cscene,
	cwar = cwar,
}

return object

