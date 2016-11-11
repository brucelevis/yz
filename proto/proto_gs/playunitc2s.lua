return {
	p = "playunit",
	si = 7200, --[7200,7300)
	src = [[

# 派发红包
playunit_new_redpacket 7200 {
	request {
		base 0 : basetype
		num 1 : integer		# 红包份数
		money 2 : integer	# 金额（铜币数)
		type 3 : integer	# 1--世界红包,2--公会红包
	}
}

# 领取红包(拼手气)
playunit_spell_luck 7201 {
	request {
		base 0 : basetype
		id 1 : integer		# 红包ID
	}
}

# 查看红包排名
playunit_redpacket_lookranks 7202 {
	request {
		base 0 : basetype
		id 1 : integer
	}
}

# 分享红包
playunit_share_redpacket 7203 {
	request {
		base 0 : basetype
		id 1 : integer
	}
}
]]
}
