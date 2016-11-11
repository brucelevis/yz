cpet = class("cpet",cdatabaseable,{
	zizhi_minratio = 50,	--最小资质比
	zizhi_maxratio = 100,	--最大资质比
	skilllimit = 15,		--宠物最多拥有技能数
})

function cpet:init(param)
	param = param or { pid = 0, flag = "pet", }
	cdatabaseable.init(self,param)
	self.id = param.id
	self.type = param.type
	self.createtime = param.createtime
	-- 位置一般是放入容器后才有的属性
	self.data = {}
	self.lv = 1
	self.exp = 0
	self.name = nil
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
	self.skills = ccontainer.new({
		name = "petskills",
	})
	self.equipments = cposcontainer.new({
		name = "petequips",
		initspace = 6,
	})
	self.chats = {"","","","","","",}
	self.bianyi_type = 0
end

function cpet:config()
	local data = petaux.getpetdata(self.type)
	for name,ratio in pairs(self.zizhi_ratio) do
		self.zizhi[name] = math.floor(data[name] * ratio / 100)
	end
end

function cpet:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
	self.type = data.type
	self.createtime = data.createtime
	self.data = data.data
	self.lv = data.lv
	self.exp = data.exp
	self.name = data.name
	self.status = data.status
	self.relationship = data.relationship
	self.close = data.close
	self.zizhi_ratio = data.zizhi_ratio
	self.skills:load(data.skills)
	self.equipments:load(data.equipments,function(itemdata)
		local item = citem.new()
		item:load(itemdata)
		return item
	end)
	self.chats = data.chats
	self.bianyi_type = data.bianyi_type
end

function cpet:save()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.createtime = self.createtime
	data.data = self.data
	data.lv = self.lv
	data.name = self.name
	data.exp = self.exp
	data.status =  self.status
	data.relationship = self.relationship
	data.close = self.close
	data.zizhi_ratio = self.zizhi_ratio
	data.skills = self.skills:save()
	data.equipments = self.equipments:save(function(item)
		return item:save()
	end)
	data.chats = self.chats
	data.bianyi_type = self.bianyi_type
	return data
end

function cpet:setzizhi(name,value)
	local data = petaux.getpetdata(self.type)
	value = math.max(value,math.floor(data[name] * self.zizhi_minratio / 100))
	value = math.min(value,math.floor(data[name] * self.zizhi_maxratio / 100))
	self.zizhi[name] = value
	self.zizhi_ratio[name] = value * 100 /  data[name]
	return value
end

function cpet:getzizhilimit(name)
	if not self.zizhi[name] then
		return 0
	end
	local basezizhi = self:get(name)
	return math.floor(basezizhi * self.zizhi_maxratio / 100)
end

function cpet:pack()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.name = self:getname()
	data.createtime = self.createtime
	data.lv = self.lv
	data.exp = self.exp
	data.relationship = self.relationship
	data.close = self.close
	data.status = self.status
	data.readywar = self.readywar or false
	data.zizhi = self.zizhi
	data.bindskills = self:getbindskills()
	data.skills = self:getunbindskills()
	data.equips = self:getallequips()
	data.chats = self.chats
	data.bianyi_type = self.bianyi_type
	return data
end

function cpet:get(attr)
	local petdata = petaux.getpetdata(self.type)
	return petdata[attr]
end

function cpet:getname()
	if self.name then
		return self.name
	end
	return self:get("name")
end

function cpet:hasskill(skillid)
	local bindskill = petaux.getpetdata(self.type).bind_skills
	if table.find(bindskill,skillid) or skillid == self:getbianyiskill() then
		return true
	end
	local skill = self.skills:get(skillid)
	if not skill then
		return false
	end
	return true
end

function cpet:addskill(skillid)
	if self:hasskill(skillid) then
		return
	end
	local skill = {
		id = skillid,
		time = os.time(),
	}
	self.skills:add(skill,skillid)
	sendpackage(self.pid,"pet","addskill",{
		petid = self.id,
		skill = skill,
	})
	return skill
end

function cpet:delskill(skillid)
	local idx = self:hasskill(skillid)
	if not idx or idx == -1 then
		return
	end
	self.skills:del(skillid)
	sendpackage(self.pid,"pet","delskill",{
		petid = self.id,
		skillid = skillid,
	})
end

function cpet:addequip(equip)
	self.equipments:add(equip,equip.id)
	sendpackage(self.pid,"pet","addequip",{
		petid = self.id,
		equip = equip:pack(),
	})
	return equip
end

function cpet:delequip(equipid)
	local equip = self.equipments:del(equipid)
	sendpackage(self.pid,"pet","delequip",{
		petid = self.id,
		equipid = equipid,
	})
	return equip
end

function cpet:isbianyi()
	return self.bianyi_type ~= 0
end

function cpet:getbindskills()
	local skills = {}
	local data = self:get("bind_skills")
	for _,skillid in ipairs(data) do
		table.insert(skills,{
			id = skillid,
		})
	end
	local bianyiskill = self:getbianyiskill()
	if bianyiskill then
		table.insert(skills,{
			id = bianyiskill,
		})
	end
	return skills
end

function cpet:getunbindskills()
	local skills = {}
	for _,skill in pairs(self.skills.objs) do
		table.insert(skills,{
			id = skill.id,
		})
	end
	return skills
end

function cpet:getbianyiskill()
	if not self:isbianyi() then
		return
	end
	return data_1700_PetBianyi[self.type][self.bianyi_type].skills[1]
end

function cpet:getskillslen()
	local data = petaux.getpetdata(self.type)
	local len = #data.bind_skills + self.skills.len
	if self:isbianyi() then
		len = len + 1
	end
	return len
end

function cpet:getallequips()
	local equips = {}
	for _,equip in pairs(self.equipments.objs) do
		table.insert(equips,equip:pack())
	end
	return equips
end

return cpet
