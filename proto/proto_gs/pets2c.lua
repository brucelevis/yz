return {
	p = "pet",
	si = 7300, --[7300,7400)
	src = [[
pet_allpet 7301 {
	request {
		base 0 : basetype
		pets 1 : *PetType
		space 2 : integer	# 可携带宠物数量
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

pet_updatespace 7306 {
	request {
		base 0 : basetype
		space 1 : integer	# 可携带宠物数目
	}
}

.PetCommentType {
	id 0 : integer
	pid 1 : integer		# 评论玩家id
	name 2 : string		# 作者名字
	msg 3 : string		# 点评内容
	likecnt 4 : integer # 点赞数
	time 5 : integer	# 发表时间
	ishot 6 : boolean	# 是否为热评
	islike 7 : boolean	# 当前玩家是否点赞过
}

# 宠物点评数据
pet_sendcomments 7307 {
	request {
		base 0 : basetype
		comments 1 : *PetCommentType
		excedtime 2 : integer # 客户端缓存截至有效时间
	}
}

# 宠物评论点赞结果
pet_likeresult 7308 {
	request {
		base 0 : basetype
		isok 1 : boolean
	}
}

# 增加宠物技能
pet_addskill 7309 {
	request {
		base 0 : basetype
		petid 1 : integer
		skill 2 : SkillType
	}
}

# 删除宠物技能
pet_delskill 7310 {
	request {
		base 0 : basetype
		petid 1 : integer
		skillid 2 : integer
	}
}

# 增加宠物装备
pet_addequip 7311 {
	request {
		base 0 : basetype
		petid 1 : integer
		equip 2 : ItemType
	}
}

# 删除宠物装备
pet_delequip 7312 {
	request {
		base 0 : basetype
		petid 1 : integer
		equipid 2 : integer
	}
}

# 更新宠物装备
pet_updateequip 7313 {
	request {
		base 0 : basetype
		petid 1 :integer
		equip 2 : ItemType
	}
}

]]
}
