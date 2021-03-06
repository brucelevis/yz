petaux = petaux or {}

function petaux.getpetdata(pettype)
	return data_1700_PetHandBook[pettype]
end

function petaux.status(name)
	if not petaux.status_name_id then
		petaux.status_name_id = {}
		for id,data in pairs(data_1700_PetStatus) do
			petaux.status_name_id[data.name] = id
		end
	end
	return petaux.status_name_id[name]
end

function petaux.relationship(name)
	if not petaux.relationship_name_id then
		petaux.relationship_name_id = {}
		for id,data in pairs(data_1700_PetRelationShip) do
			petaux.relationship_name_id[data.name] = id
		end
	end
	return petaux.relationship_name_id[name]
end

function petaux.newpet(typ)
	local pet = cpet.new({
		pid = 0,
		flag = "pet",
		type = typ,
	})
	if pet.type then
		pet:config()
	end
	return pet
end

function petaux.bianyifix(pet)
	local quality = pet:get("quality")
	if quality == 1 then
		return data_1700_PetVar.NormalFix
	elseif quality == 2 then
		return data_1700_PetVar.RareFix
	elseif quality == 3 then
		return data_1700_PetVar.HolyFix
	else
		return 0
	end
end

function petaux.forgetskillcost(skillid)
	local quality = data_0201_PetSkill[skillid].quality
	if quality == 1 then
		return data_1700_PetVar.NormalSkillForgetCost
	elseif quality == 2 then
		return data_1700_PetVar.RareSkillForgetCost
	elseif quality == 3 then
		return data_1700_PetVar.EpicSkillForgetCost
	else
		return data_1700_PetVar.LegendSkillForgetCost
	end
end

function petaux.getskillvalue(skillid,attr)
	return data_0201_PetSkill[skillid][attr]
end

return petaux
