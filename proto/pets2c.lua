return {
	p = "pet",
	si = 7300, --[7300,7400)
	src = [[
pet_allpet 7301 {
	request {
		base 0 : basetype
		pets 1 : *PetType
	}
}

pet_addpet 7302 {
	request {
		base 0 : basetype
		pet 1 : PetType
	}
}

pet_delpet 7303 {
	request {
		base 0 : basetype
		id 1 : integer		# 宠物ID
	}
}

pet_updatepet 7304 {
	request {
		base 0 : basetype
		pet 1 : PetType
	}
}

pet_catch_result 7305 {
	request {
		base 0 : basetype
		result 1 : integer	# 1--succuess;0--fail
	}
}
]]
}
