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

# 驯养
pet_changestatus 7303 {
	request {
		base 0 : basetype
		id 1 : integer
	}
}

# 训练
pet_train 7304 {
	request {
		base 0 : basetype
		id 1 : integer
	}
}

# 卸装备
pet_unwieldequip 7305 {
	request {
		base 0 : basetype
		id 1 : integer
		itemid 2 : integer
	}
}

pet_combine 7306 {
	request {
		base 0 : basetype
		masterid 1 : integer	# 主宠id
		subid 2 : integer		# 副宠id
	}
}

pet_rename 7307 {
	request {
		base 0 : basetype
		id 1 : integer
		name 2 : string
	}
}

pet_setchat 7308 {
	request {
		base 0 : basetype
		id 1 : integer
		case 2 : integer		#1.进入战斗 2.释放技能 3.使用药物 4.主角倒地 5.队友到底 6.敌人阵亡
		chat 3 : string
	}
}

#扩展可携带宠物数目
pet_expandspace 7309 {
	request {
		base 0 : basetype
		itemid 1 : integer
	}
}

#遗忘技能
pet_forgetskill 7310 {
	request {
		base 0 : basetype
		id 1 : integer
		skillid 2 : integer
	}
}

#点评宠物
pet_commenton 7311 {
	request {
		base 0 : basetype
		pettype 1 : integer
		msg 2 : string
	}
}

#获取某类宠物评论
pet_getcomments 7312 {
	request {
		base 0 : basetype
		pettype 1 : integer
	}
}

#点赞宠物评论
pet_likecomment 7313 {
	request {
		base 0 : basetype
		pettype 1 : integer
		id 2 : integer # 评论id
	}
}

]]
}
