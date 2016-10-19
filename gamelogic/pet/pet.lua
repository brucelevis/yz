cpet = class("cpet",cdatabaseable,{
	zizhi_minratio = 50,	--最小资质比
	zizhi_maxratio = 100,	--最大资质比
	skillslimit = 15,	--技能格子数上限
})

function cpet:init(param)
	param = param or { pid = 0, flag = "pet", }
	cdatabaseable.init(self,param)
	self.id = param.id
	self.type = param.type
	self.createtime = param.createtime
	-- 位置一般是放入容器后才有的属性
	self.pos = param.pos
	self.data = {}
	self.lv = 1
	self.exp = 0
	self.status = petaux.status("兴奋")
	self.relationship = petaux.relationship("陌生")
	self.close = 0		-- 亲密度
	self.zizhi = {
		liliang = 0,
		minjie = 0,
		tili = 0,
		zhili = 0,
		lingqiao = 0,
		xingyun = 0,
	}
	self.zizhi_ratio = {
		liliang = self.zizhi_minratio,
		minjie = self.zizhi_minratio,
		tili = self.zizhi_minratio,
		lingqiao = self.zizhi_minratio,
		xingyun = self.zizhi_minratio,
	}
	self.skills = {}
	self.equipmentdb = ccontainer.new({
		pid = self.pid,
		name = "petequipdb",
	})
end

function cpet:config()
	local data = petaux.getpetdata(self.type)
	for name,ratio in pairs(self.zizhi_ratio) do
		local value = math.floor(data[name] * ratio / 100)
		self:setzizhi(name,value)
	end
end

function cpet:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
	self.type = data.type
	self.createtime = data.createtime
	self.pos = data.pos
	self.data = data.data
	self.lv = data.lv
	self.exp = data.exp
	self.status = data.status
	self.relationship = data.relationship
	self.close = data.close
	self.zizhi_ratio = data.zizhi_ratio
	self.skills = data.skills
	self:config()
end

function cpet:save()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.createtime = self.createtime
	data.pos = self.pos
	data.data = self.data
	data.lv = self.lv
	data.exp = self.exp
	data.status =  self.status
	data.relationship = self.relationship
	data.close = self.close
	data.zizhi_ratio = self.zizhi_ratio
	data.skills = self.skills
	return data
end

function cpet:setzizhi(name,value)
	local data = petaux.getpetdata(self.type)
	value = math.max(value,math.floor(data[name] * self.zizhi_minratio / 100))
	value = math.min(value,math.floor(data[name] * self.zizhi_maxratio / 100))
	self.zizhi[name] = value
	return value
end

function cpet:onchangezizhi()
	local data =petaux.getpetdata(self.type)
	for name,value in pairs(self.zizhi) do
		self.zizhi_ratio[name] = value * 100 / data[name]
	end
end

function cpet:pack()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.createtime = self.createtime
	data.pos = self.pos
	data.lv = self.lv
	data.exp = self.exp
	data.relationship = self.relationship
	data.close = self.close
	data.status = self.status
	data.readywar = self.readywar or false
	data.zizhi = self.zizhi
	data.skills = self:getallskills()
	return data
end

function cpet:get(attr)
	local petdata = petaux.getpetdata(self.type)
	return petdata[attr]
end

function cpet:hasskill(skillid)
	local bindskill = petaux.getpetdata(self.type).bind_skills
	if table.find(bindskill,skillid) then
		return -1
	end
	for idx,skill in pairs(self.skills) do
		if skill.id == skillid then
			return idx
		end
	end
	return
end

function cpet:addskill(skillid)
	if self:hasskill(skillid) then
		return
	end
	local skill = {
		id = skillid,
	}
	table.insert(self.skills,skill)
	return skill
end

function cpet:replaceskill(skillid,idx)
	local skill = self.skills[idx]
	if not skill then
		return
	end
	local oldid = skill.id
	skill.id = skillid
	return oldid
end

function cpet:delskill(skillid)
	local idx = self:hasskill(skillid)
	if not idx or idx == -1 then
		return
	end
	table.remove(self.skills,idx)
end

function cpet:getallskills()
	local data = petaux.getpetdata(self.type)
	local skills = {}
	table.extends(skills,data.bind_skills)
	for _,skill in ipairs(self.skills) do
		table.insert(skills,skill.id)
	end
	return skills
end

function cpet:getskillslen()
	local data = petaux.getpetdata(self.type)
	return #data.bind_skills + #self.skills
end

return cpet
