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

return petaux
