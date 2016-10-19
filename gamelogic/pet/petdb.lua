cpetdb = class("cpetdb",ccontainer)

function cpetdb:init(pid)
	ccontainer.init(self,{
		pid = pid,
		name = "cpetdb",
	})
	self.pid = pid
	self.space = 5
	self.expandspace = 0
	self.readywar_petid = nil

	self.pos_id = {}
end

function cpetdb:load(data)
	if not data or not next(data) then
		return
	end
	ccontainer.load(data,function (petdata)
		local pet = self:newpet()
		pet:load(petdata)
		return pet
	end)
	for id,pet in pairs(self.objs) do
		self.pos_id[pet.pos] = id
	end
	self.expandspace = data.expandspace
	self.readywar_petid = data.readywar_petid
	local pet = self:getpet(self.readywar_petid)
	if pet then
		pet.readywar = true
	else
		self.readywar_petid = nil
	end
	return data
end

function cpetdb:newpet()
	local pet = cpet.new({ pid = self.pid, })
	pet:config()
	return pet
end

function cpetdb:save()
	local data = ccontainer.save(self,function (pet)
		return pet:save()
	end)
	data.expandspace = self.expandspace
	data.readywar_petid = self.readywar_petid
	return data
end

function cpetdb:onlogin(player)
	assert(player.pid == self.pid)
	local pets = {}
	for id,pet in pairs(self.objs) do
		table.insert(pets,pet:pack())
	end
	sendpackage(self.pid,"pet","allpet",{
		pets = pets,
	})
end

function cpetdb:getpet(petid)
	return self:get(petid)
end

function cpetdb:addpet(pet,reason)
	local pos = self:getfreepos()
	assert(pos)
	local petid = self:genid()
	logger.log("info","pet",string.format("[addpet] pid=%s petid=%s pettype=%s pos=%s reason=%s",self.pid,petid,pet.type,pos,reason))
	pet.pos = pos
	self:add(pet,petid)
	return pet
end

function cpetdb:delpet(petid,reason)
	local pet = self:getpet(petid)
	if pet then
		logger.log("info","pet",string.format("[delpet] pid=%s petid=%s pettype=%s pos=%s reason=%s",self.pid,petid,pet.type,pet.pos,reason))
		local pos = pet.pos
		local space = self:getspace()
		self:del(petid)
		for i=pos+1,space do
			local id = self.pos_id[i]
			local bbind_pet = self:getpet(id)
			if bbind_pet then
				self:update(id,i-1)
				self.pos_id[i] = nil
			else
				break
			end
		end
		return pet
	end
end

function cpetdb:readywar(petid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	self.readywar_petid = petid
	self:update(pet.id,{
		readywar = true,
	})
	return pet
end

function cpetdb:unreadywar(petid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	self.readywar_petid = nil
	self:update(pet.id,{
		readywar = false,
	})
	return pet
end

function cpetdb:addclose(petid,addclose,reason)
	local pet = self:getpet(petid)
	if not pet then
		return 0
	end
	logger.log("info","pet",string.format("[addclose] pid=%d petid=%s close=%d reason=%s",self.pid,petid,addclose,reason))
	local newval = pet.close + addclose
	local addlv = 0
	local maxlv = #data_1700_PetRelationShip
	for lv=self.relationship+1,maxlv do
		local data = data_1700_PetRelationShip[lv]
		if newval >= data.needclose then
			newval = newval - data.needclose
			addlv = addlv + 1
		else
			break
		end
	end
	self:update(petid,{
		relationship = self.relationship + addlv,
		close = newval,
	})
	return addclose
end

function cpetdb:change_petstatus(petid,status,reason)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	logger.log("info","pet",string.format("[changestatus] pid=%d petid=%s status=%s reason=%s",self.pid,petid,status,reason))
	self:update(petid,{
		status = status,
	})
	return status
end

function cpetdb:traindpet(petid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	local data = petaux.getpetdata(self.type)
	-- 处理技能
	local oldskills = pet:getallskills()
	pet.skills = {}
	for _,skillid in pairs(data.study_skills) do
		if ishit(50) then
			pet:addskill(skillid)
		end
	end
	-- 处理资质
	local fullzizhi = pet:query("fullzizhi",{})
	local basic_downratio = 5
	local oldzizhi = pet.zizhi
	pet.zizhi = {}
	for name,value in pairs(oldzizhi) do
		-- 洗出满资质后，下一次训练不变
		if not fullzizhi[name] then
			local fullzizhi = data[name] * pet.zizhi_maxratio / 100
			local addition_downratio = math.floor(10 * value / fullzizhi)
			local newvalue
			if ishit(basic_downratio + addition_downratio) then
				local add = math.random(1,9)
				newvalue = pet:setzizhi(name,value + add)
			else
				local reduce = math.random(1,9)
				newvalue = pet:setzizhi(name,value - reduce)
			end
			if newvalue < fullzizhi then
				fullzizhi[name] = nil
			else
				fullzizhi[name] = true
			end
		end
	end
	pet:set("fullzizhi",fullzizhi)
	pet:onchangezizhi()
	local newskills = pet:getallskills()
	logger.log("info","pet",format("[trainpet] pid=%d petid=%d oldzz=%s newzz=%s oldsk=%s newsk=%s",self.pid,petid,oldzizhi,pet.zizhi,oldskills,newskills))
	self:onupdate(petid,{
		skills = newskills,
		zizhi = pet.zizhi,
	})
end

function cpetdb:comprehendskill(petid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	if pet:getskillslen() >= pet.skillslimit then
		return
	end
	local ratio = (pet.skillslimit - pet:getskillslen() - 3) * 5 + pet.lv
	if ratio <= 0 or not ishit(ratio,1000000) then
		return
	end
	local tmp = {}
	for skillid,skilldata in pairs(data_1700_PetSkill) do
		if skilldata.comprehend_ratio ~= 0 and self:can_learn(pet,skillid) then
			tmp[skillid] = skilldata.comprehend_ratio
		end
	end
	local skillid = choosekey(tmp)
	local player = playermgr.getplayer(self.pid)
	logger.log("info","pet",string.format("[comprehendskill] pid=%d petid=%d skillid=%d",self.pid,petid,skillid))
	pet:addskill(skillid)
	netmsg.sendquickmsg(language.format("恭喜{1}的{2}领悟了{3}！",player.name,pet:get("name"),data_1700_PetSkill[skillid].name))
	self:onupdate(petid,{
		skills = pet:getallskills(),
	})
end

function cpetdb:learnskill(petid,skillid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	local replaceskill
	if pet:getskillslen() > 5 then
		local ratio = math.max(0,math.floor((#pet.skills - 2) / 3))
		if ishit(ratio) then
			local idx = math.random(1,#pet.skills)
			replaceskill = pet:replaceskill(skillid,idx)
		end
	end
	local msg
	if not replaceskill then
		pet:addskill(skillid)
		msg = language.format("{1}学习成功",data_1700_PetSkill[skillid].name)
	else
		msg = language.format("{1}替换了{2}",data_1700_PetSkill[skillid].name,data_1700_PetSkill[replaceskill].name)
	end
	net.msg.S2C.notify(self.pid,msg)
	logger.log("info","pet",string.format("[learnskill] pid=%d petid=%d skillid=%d replacesk=%d",self.pid,pet.id,skillid,replaceskill or 0))
	self:onupdate(petid,{
		skills = pet:getallskills(),
	})
end

function cpetdb:can_learn(pet,skillid)
	if pet:hasskill(skillid) then
		return false,language.format("已经学习过该技能了")
	end
	local skilldata = data_1700_PetSkill[skillid]
	if pet.relationship < skilldata.relation_limit then
		return false,language.format("宠物关系达不到{1}，无法学习本技能",data_1700_PetRelationShip[skilldata.relation_limit].name)
	end
	if pet.lv < skilldata.lv_limit then
		return false,language.format("宠物等级达不到{1}，无法学习本技能",skilldata.lv_limit)
	end
	if pet:get("quality") <= skilldata.quality_limit then
		return false,language.format("宠物品质达不到{1}，无法学习本技能",PET_QUALITY[skilldata.quality_limit])
	end
	if pet:get("race") ~= skilldata.race_limit then
		return false,language.format("宠物不是{1}种族，无法学习本技能",PET_RACE[skilldata.race_limit])
	end
	if pet:get("category") ~= skildata.category_limit then
		return false,language.format("宠物不是{1}类别，无法学习本技能",PET_CATEGORY[skilldata.category_limit])
	end
	if pet:get("type") ~= skilldata.type_limit then
		return false,language.format("宠物不是{1}类型，无法学习本技能",PET_TYPE[skilldata.type_limit])
	end
	for name,value in pairs(pet.zizhi) do
		if skilldata[name] > value then
			return false,language.format("{1}的{2}资质达不到{3}，无法学习本技能",pet:get("name"),PET_ZIZHI[name],skilldata[name])
		end
	end
	return ture
end

function cpetdb:wieldequip(petid,itemid)
end

function cpetdb:can_wieldequip(pet,itemid)
	local player = playermgr.getplayer(self.pid)
	local item = player:getitem(itemid)
	if not item then
		return false,language.format("背包中没有找到该装备")
	end
	if itemaux.getmaintype(item.type) ~= ItemMainType.PETEQUIP then
		return false,language.format("该物品无法给宠物装备")
	end
	return true
end

function cpetdb:unwieldequip(petid,itemid)
end

function cpetdb:getpetsbytype(pettype)
	local pets = {}
	for id,pet in pairs(self.objs) do
		if pet.type == pettype then
			table.insert(pets,pet)
		end
	end
	return pets
end

function cpetdb:getnumbytype(pettype)
	local pets = self:getpetsbytype(pettype)
	return #pets
end

function cpetdb:getfreespace()
	return elf:getspace() - self:getusespace()
end

function cpetdb:getspace()
	return self.expandspace + self.space
end

function cpetdb:getusespace()
	return self.len
end

function cpetdb:getfreepos()
	local space = self:getspace()
	for pos = 1,space do
		if not self.pos_id[pos] then
			return pos
		end
	end
end

function cpetdb:onadd(pet)
	local pos = pet.pos
	self.pos_id[pos] = pet.id
	sendpackage(self.pid,"pet","addpet",{
		pet = pet:pack()
	})
end

function cpetdb:ondel(pet)
	local petid = pet.id
	local pos = pet.pos
	self.pos_id[pos] = nil
	sendpackage(self.pid,"pet","delpet",{
		id = pet.id,
	})
end

function cpetdb:onupdate(id,attrs)
	attrs.id = id
	sendpackage(self.pid,"pet","updatepet",{
		pet = attrs,
	})
end

function cpetdb:onfivehourupdate(player)
	for id,pet in pairs(self.objs) do
		local status = randlist(table.keys(data_1700_PetStatus))
		self:change_petstatus(id,status,"onfivehourupdate")
	end
end

return cpetdb
