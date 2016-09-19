return {
	p = "player",
	si = 5000, -- [5000,5500)
	src = [[
# gm指令
player_gm 5000 {
	request {
		base 0 : basetype
		cmd 1 : string  #gm指令
	}
}

# 分配素质点
player_alloc_qualitypoint 5001 {
	request {
		base 0 : basetype
		liliang 1 : integer		# 分配的力量点(未分配则不发--传nil)
		minjie 2 : integer		# 分配的敏捷点
		tili 3 : integer		# 分配的体力点
		lingqiao 4 : integer	# 分配的灵巧点
		zhili 5 : integer		# 分配的智力点
		xingyun 6 : integer		# 分配的幸运点
	}
}

# 重置素质点
player_reset_qualitypoint 5002 {
	request {
		base 0 : basetype
	}
}

# 设置玩家自身开关状态
player_switch 5003 {
	request {
		base 0 : basetype
		switchs 1 : *SwitchType
	}
}

# 改名
player_rename 5004 {
	request {
		base 0 : basetype
		name 1 : string		#新的名字
	}
}

# 临时一键更改职业
player_changejob 5005 {
	request {
		base 0 : basetype
		jobid 1 : integer	#新的职业ID
	}
}
]]
}
