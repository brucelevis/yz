return {
	p = "pet",
	si = 7300, --[7300,7400)
	src = [[
pet_delpet 7301 {
	request {
		base 0 : basetype
		id 1 : integer		# 宠物ID
	}
}

# 出战/休息
pet_war_or_rest 7302 {
	request {
		base 0 : basetype
		id 1 : integer
	}
}

# 喂食
pet_feed 7303 {
	request {
		base 0 : basetype
		id 1 : integer
		itemid 2 : integer	# 喂养的食物（同一时间只能唯一一个数量)
	}
}

# 改变状态
pet_changestatus 7304 {
	request {
		base 0 : basetype
		id 1 : integer
		status 2 : integer	# 1--兴奋；2--懒惰；3--好奇
	}
}

# 驯养
pet_train 7305 {
	request {
		base 0 : basetype
		id 1 : integer
	}
}

pet_catch 7306 {
	request {
		base 0 : basetype
		id 1 : integer		# 一场战斗中宠物/怪物的ID
	}
}
]]
}
