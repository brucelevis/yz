--战斗技能容器
cwarskilldb = class("cwarskilldb",ccontainer)

function cwarskilldb:init(conf)
	ccontainer.init(self,conf)
	self.skillpoint = 0
	self.skillslot = { [1] = nil, [2] = nil, [3] = nil, [4] = nil,}
	self.loadstate = "unload"
end

function cwarskilldb:load(data)
	if table.isempty(data) then
		return
	end
	ccontainer.load(self,data)
	self.skillpoint = data.skillpoint
	self.skillslot = data.skillslot
end

function cwarskilldb:save()
	data = ccontainer.save(self)
	data.skillpoint = self.skillpoint
	data.skillslot = self.skillslot
	return data
end

function cwarskilldb:getwarskilldata(skillid)
	return data_0201_Skill[skillid]
end

function cwarskilldb:openskill_byjob(job)
end

function cwarskilldb:learnskill(skillid)
	if not self:canlearn(skillid) then
		return
	end
	local skill = self:get(skillid)
	local lv = skill.level
	self:update(skillid,{ level = lv + 1,})
end

function cwarskildb:canlearn(skillid)
	return true
end

function cwarskilldb:wieldskill(skillid,position)
end

function cwarskilldb:reset_skillpoint()
end



