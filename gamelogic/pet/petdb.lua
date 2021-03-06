cpetdb = class("cpetdb",ccontainer)

function cpetdb:init(pid)
	ccontainer.init(self,{
		name = "cpetdb",
	})
	self.pid = pid
	self.space = 4
	self.expandspace = 0
	self.readywar_petid = nil
end

function cpetdb:load(data)
	if not data or not next(data) then
		return
	end
	local pid = self.pid
	ccontainer.load(self,data,function(petdata)
		local pet = petaux.newpet()
		pet:load(petdata)
		pet:config()
		pet.pid = pid
		return pet
	end)
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

function cpetdb:save()
	local data = ccontainer.save(self,function(pet)
		return pet:save()
	end)
	data.expandspace = self.expandspace
	data.readywar_petid = self.readywar_petid
	return data
end

function cpetdb:onlogin(player)
	assert(player.pid == self.pid)
	sendpackage(self.pid,"pet","allpet",{
		pets = self:getallpets(),
		space = self:getspace(),
	})
end

function cpetdb:genid()
	local player = playermgr.getplayer(self.pid)
	return player:genid()
end

function cpetdb:clear()
	ccontainer.clear(self)
	self.expandspace = 0
	self.readywar_petid = nil
end

function cpetdb:getallpets()
	local pets = {}
	for id,pet in pairs(self.objs) do
		table.insert(pets,pet:pack())
	end
	return pets
end

function cpetdb:getpet(petid)
	return self:get(petid)
end

function cpetdb:addpet(pet,reason)
	local petid = self:genid()
	logger.log("info","pet",string.format("[addpet] pid=%s petid=%s pettype=%s reason=%s",self.pid,petid,pet.type,reason))
	pet.pid = self.pid
	self:add(pet,petid)
	return pet
end

function cpetdb:delpet(petid,reason)
	local pet = self:getpet(petid)
	if pet then
		logger.log("info","pet",string.format("[delpet] pid=%s petid=%s pettype=%s reason=%s",self.pid,petid,pet.type,reason))
		self:del(petid)
		return pet
	end
end

function cpetdb:readywar(petid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	if self.readywar_petid == petid then
		return
	end
	if self.readywar_petid then
		self:update(self.readywar_petid,{
			readywar = false,
		})
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
	for lv=pet.relationship+1,maxlv do
		local data = data_1700_PetRelationShip[lv]
		if newval >= data.needclose then
			newval = newval - data.needclose
			addlv = addlv + 1
		else
			break
		end
	end
	local new_relationship
	if addlv ~= 0 then
		new_relationship = pet.relationship + addlv
	end
	self:update(petid,{
		relationship = new_relationship,
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

function cpetdb:trainpet(petid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	local data = petaux.getpetdata(pet.type)
	-- 处理技能
	pet.skills:clear()
	for _,skillid in pairs(data.study_skills) do
		if ishit(50,100) then
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
			local max = data[name] * pet.zizhi_maxratio / 100
			local addition_downratio = math.floor(10 * value / max)
			local newvalue
			if ishit(basic_downratio + addition_downratio,100) then
				local add = math.random(1,9)
				newvalue = pet:setzizhi(name,value + add)
			else
				local reduce = math.random(1,9)
				newvalue = pet:setzizhi(name,value - reduce)
			end
			if newvalue < max then
				fullzizhi[name] = nil
			else
				fullzizhi[name] = true
			end
		end
	end
	pet:set("fullzizhi",fullzizhi)
	logger.log("info","pet",format("[trainpet] pid=%d petid=%d oldzz=%s newzz=%s",self.pid,petid,oldzizhi,pet.zizhi))
	self:onupdate(petid,{
		zizhi = pet.zizhi,
	})
end

function cpetdb:comprehendskill(petid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	local limit = pet.skilllimit
	if pet:getskillslen() >= limit then
		return
	end
	local ratio = (limit - pet:getskillslen() - 3) * 5 + pet.lv
	if ratio <= 0 or not ishit(ratio,1000000) then
		return
	end
	local tmp = {}
	for skillid,skilldata in pairs(data_0201_PetSkill) do
		if skilldata.comprehend_ratio ~= 0 and self:can_learn(pet,skillid) then
			tmp[skillid] = skilldata.comprehend_ratio
		end
	end
	local skillid = choosekey(tmp)
	local player = playermgr.getplayer(self.pid)
	logger.log("info","pet",string.format("[comprehendskill] pid=%d petid=%d skillid=%d",self.pid,petid,skillid))
	pet:addskill(skillid)
	net.msg.sendquickmsg(language.format("恭喜{1}的{2}领悟了{3}！",player.name,pet:get("name"),data_0201_PetSkill[skillid].name))
end

function cpetdb:learnskill(petid,skillid)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	local replaceskill
	local skillslen = pet:getskillslen()
	if skillslen > 5 then
		local ratio = math.max(0,math.floor((pet.skills.len - 2) / 3))
		if skillslen >= pet.skilllimit or ishit(ratio,100) then
			replaceskill = randlist(table.keys(pet.skills.objs))
			pet:delskill(replaceskill)
		end
	end
	pet:addskill(skillid)
	local msg
	if not replaceskill then
		msg = language.format("{1}学习成功",data_0201_PetSkill[skillid].name)
	else
		msg = language.format("{1}替换了{2}",data_0201_PetSkill[skillid].name,data_0201_PetSkill[replaceskill].name)
	end
	net.msg.S2C.notify(self.pid,msg)
	logger.log("info","pet",string.format("[learnskill] pid=%d petid=%d skillid=%d replacesk=%d",self.pid,pet.id,skillid,replaceskill or 0))
end

function cpetdb:can_learn(pet,skillid)
	if pet:hasskill(skillid) then
		return false,language.format("已经学习过该技能了")
	end
	local skilldata = data_0201_PetSkill[skillid]
	if istrue(skilldata.relation_limit) and pet.relationship < skilldata.relation_limit then
		return false,language.format("宠物关系达不到{1}，无法学习本技能",data_1700_PetRelationShip[skilldata.relation_limit].name)
	end
	if istrue(skilldata.lv_limit) and pet.lv < skilldata.lv_limit then
		return false,language.format("宠物等级达不到{1}，无法学习本技能",skilldata.lv_limit)
	end
	if istrue(skilldata.lv_limit) and pet:get("quality") < skilldata.quality_limit then
		return false,language.format("宠物品质达不到{1}，无法学习本技能",PET_QUALITY[skilldata.quality_limit])
	end
	if istrue(skilldata.race_limit) and pet:get("RACE") ~= skilldata.race_limit then
		return false,language.format("宠物不是{1}种族，无法学习本技能",PET_RACE[skilldata.race_limit])
	end
	if istrue(skilldata.category_limit) and pet:get("category") ~= skilldata.category_limit then
		return false,language.format("宠物不是{1}类别，无法学习本技能",PET_CATEGORY[skilldata.category_limit])
	end
	if istrue(skilldata.type_limit) and pet:get("type") ~= skilldata.type_limit then
		return false,language.format("宠物不是{1}类型，无法学习本技能",PET_TYPE[skilldata.type_limit])
	end
	for name,value in pairs(pet.zizhi) do
		if istrue(value) and skilldata[name] > value then
			return false,language.format("{1}的{2}资质达不到{3}，无法学习本技能",pet:get("name"),PET_ZIZHI[name],skilldata[name])
		end
	end
	return true
end

function cpetdb:wieldequip(petid,itemid)
	local pet = self:getpet(petid)
	if not pet then
		return false
	end
	local isok,errmsg = self:can_wieldequip(pet,itemid)
	if not isok then
		return isok,errmsg
	end
	local player = playermgr.getplayer(self.pid)
	local equip = player.itemdb:delitem(itemid,"wield_petequip")
	local equippos = equip:get("equippos")
	local item = pet.equipments:getbypos(equippos)
	if item then
		pet:delequip(item.id)
		player.itemdb:additem(item,"unwield_petequip")
	end
	logger.log("info","pet",string.format("[wieldequip] pid=%d petid=%d itemid=%d",self.pid,petid,itemid))
	equip.pos = equippos
	pet:addequip(equip)
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
	if itemaux.getitemdata(item.type).equippos > pet.equipments:getspace() then
		return false
	end
	return true
end

function cpetdb:unwieldequip(petid,itemid)
	local pet = self:getpet(petid)
	if not pet then
		return false
	end
	local player = playermgr.getplayer(self.pid)
	if not pet.equipments:get(itemid) then
		return
	end
	logger.log("info","pet",string.format("[unwieldequip] pid=%d petid=%d itemid=%d",self.pid,petid,itemid))
	local item = pet:delequip(itemid)
	if player.itemdb:getfreespace() > 0 then
		player.itemdb:additem(item,"unwield_petequip")
	else
		mailmgr.sendmail(self.pid,{
			srcid = SYSTEM_MAIL,
			author = "系统",
			title = "宠物装备",
			content = string.format("由于背包已满，宠物%s身上的装备以邮件形式退发给您",pet:getname()),
			attach = {
				items = {item:save(),},
			},
		})
	end
end

function cpetdb:combine(masterid,subid)
	local isok,errmsg = self:can_combine(masterid,subid)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(self.pid,errmsg)
		end
		return
	end
	local masterpet,subpet = self:getpet(masterid),self:getpet(subid)
	logger.log("info","pet",string.format("[combinepet] pid=%d masterid=%d subid=%d",self.pid,masterid,subid))
	for itemid,_ in pairs(subpet.equipments.objs) do
		self:unwieldequip(subid,itemid)
	end
	self:delpet(subid,"combine")
	--资质调整
	for name,_ in pairs(masterpet.zizhi) do
		local zizhi = math.floor((masterpet.zizhi[name] / masterpet:getzizhilimit(name) + subpet.zizhi[name] / subpet:getzizhilimit(name)) / 2 * masterpet:getzizhilimit(name))
		masterpet:setzizhi(name,zizhi)
	end
	--技能调整
	local lstskill = {}
	for _,skill in pairs(masterpet.skills.objs) do
		table.insert(lstskill,skill.id)
	end
	local lstskill2 = {}
	for _,skill in pairs(subpet.skills.objs) do
		if not masterpet:hasskill(skill.id) then
			table.insert(lstskill2,skill.id)
		end
	end
	local rand = math.random(data_1700_PetVar.CombineSkillMinRatio * 100,data_1700_PetVar.CombineSkillMaxRatio * 100) / 100
	local skillnum = #lstskill + math.floor(#lstskill2 * rand)
	skillnum = math.min(skillnum,masterpet.skilllimit - #masterpet:get("bind_skills"))
	table.extend(lstskill,lstskill2)
	lstskill = shuffle(lstskill,false,skillnum)
	masterpet.skills:clear()
	for _,skillid in ipairs(lstskill) do
		masterpet:addskill(skillid)
	end
	self:onupdate(masterid,{
		zizhi = masterpet.zizhi,
	})
	--变异
	if not masterpet:isbianyi() then
		local ratio = masterpet:get("bianyi_ratio") - (petaux.bianyifix(masterpet) - petaux.bianyifix(subpet)) ^ 2
		if ishit(ratio,100) then
			self:bianyi(masterid,"combine")
			local player = playermgr.getplayer(self.pid)
			local skillid = masterpet:getbianyiskill()
			local skillname = data_0201_PetSkill[skillid].name
			net.msg.sendquickmsg(language.format("{1}的{2}在合成时产生了变异，获得了变异技能{3}",player.name,masterpet:name(),skillname))
		end
	end
	net.msg.S2C.notify(self.pid,language.format("合成宠物成功"))
end

function cpetdb:can_combine(masterid,subid)
	local player = playermgr.getplayer(self.pid)
	if player.lv < 30 then
		return false,language.format("玩家到达30级才能合成宠物")
	end
	local masterpet,subpet = self:getpet(masterid),self:getpet(subid)
	if not masterpet or not subpet then
		return false
	end
	if masterpet.lv < 30 or subpet.lv < 30 then
		return false,language.format("宠物到达30级才能作为合成材料")
	end
	if subpet:isbianyi() then
		return false,language.format("变异宠物不能作为副宠")
	end
	if masterpet.readywar or subpet.readywar then
		return false,language.format("出战宠不能进行合成")
	end
	return true
end

function cpetdb:rename(petid,name)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	local isok,errmsg = self:validtext(name)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(self.pid,errmsg)
		end
		return
	end
	self:update(petid,{
		name = name,
	})
end

function cpetdb:setchat(petid,case,chat)
	local pet = self:getpet(petid)
	if not pet or case <= 0  or case > #pet.chats then
		return
	end
	local isok,errmsg = self:validtext(chat)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(self.pid,errmsg)
		end
		return
	end
	local chats = pet.chats
	chats[case] = chat
	self:update(petid,{
		chats = chats,
	})
end

function cpetdb:validtext(str)
	local isok,filter_name = wordfilter.filter(str)
	if not isok then
		return false,language.format("文本非法")
	end
	for ban_name in pairs(INVALID_NAMES) do
		if string.find(str,ban_name,1,true) then
			return false,language.format("文本包含非法单词")
		end
	end
	return true
end

function cpetdb:bianyi(petid,reason,bianyi_type)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	if not bianyi_type then
		local bianyidata = data_1700_PetBianyi[pet.type]
		bianyi_type = choosekey(bianyidata,function(key,data)
			return data.weight
		end)
	end
	logger.log("info","pet",string.format("[bianyi] pid=%d petid=%d type=%d reason=%s",self.pid,petid,bianyi_type,reason))
	pet.bianyi_type = bianyi_type
	self:onupdate(petid,{
		bindskills = pet:getbindskills(),
		bianyi_type = pet.bianyi_type,
	})
end

function cpetdb:expand(addspace,reason)
	logger.log("info","pet",string.format("[expandspace] pid=%d add=%d reason=%s",self.pid,addspace,reason))
	self.expandspace = self.expandspace + addspace
	sendpackage(self.pid,"pet","updatespace",{
		space = self:getspace(),
	})
end

function cpetdb:catchpet(player,pettype,bianyi_type,itemid)
	if self:getspace() - self.len <= 0 then
		return
	end
	local item = player:getitem(itemid)
	if not item then
		return
	end
	local catchdata = data_1700_CatchPet[pettype]
	assert(catchdata)
	if item.type ~= catchdata.need_itemtype then
		return
	end
	if player:query("huoli") or 0 < catchdata.cost_huoli then
		return
	end
	logger.log("info","pet",string.format("[catchpet] pid=%d pettype=%d bianyi=%d",self.pid,pettype,bianyi_type))
	player.itemdb:costitembyid(itemid,1,"catchpet")
	player:addres("huoli",-catchdata.cost_huoli,"catchpet",true)
	local pet = petaux.newpet(pettype)
	self:addpet(pet,"catch")
	if istrue(bianyi_type) then
		self:bianyi(pet.id,"catch",bianyi_type)
	end
end

function cpetdb:addexp(petid,addexp,reason)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	logger.log("info","pet",string.format("[addexp] pid=%d petid=%d add=%d reason=%s",self.pid,petid,addexp,reason))
	local newval = pet.exp + addexp
	local addlv = 0
	local maxlv = #data_1700_PetLvExp
	for lv = pet.lv + 1,maxlv do
		local data = data_1700_PetLvExp[lv]
		if newval >= data.exp then
			newval = newval - data.exp
			addlv = addlv + 1
		else
			break
		end
	end
	local newlv
	if addlv ~= 0 then
		newlv = pet.lv + addlv
	end
	self:update(petid,{
		lv = newlv,
		exp = newval,
	})
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

function cpetdb:getspace()
	return self.expandspace + self.space
end

function cpetdb:onadd(pet)
	sendpackage(self.pid,"pet","addpet",{
		pet = pet:pack()
	})
end

function cpetdb:ondel(pet)
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

function cpetdb:onchangelv(player)
	local oldspace = self:getspace()
	if oldspace >= #data_1700_PetUnlockSpace then
		return
	end
	for num = oldspace + 1,#data_1700_PetUnlockSpace do
		local openlv = data_1700_PetUnlockSpace[num].openlv
		if openlv == -1 or player.lv < openlv then
			break
		end
		self:expand(1,"onchangelv")
	end
end

return cpetdb
