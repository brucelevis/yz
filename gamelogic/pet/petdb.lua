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
	self:update(pet.id,{
		readywar = false,
	})
	return pet
end

function cpetdb:addclose(petid,addclose)
	local pet = self:getpet(petid)
	if not pet then
		return 0
	end
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
		lv = self.lv + addlv,
		close = newval,
	})
	return addclose
end

function cpetdb:change_petstatus(petid,status)
	local pet = self:getpet(petid)
	if not pet then
		return
	end
	self:update(petid,{
		status = status,
	})
	return status
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

return cpetdb
