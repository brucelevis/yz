return {
	p = "friend",
	si = 3000, -- [3000,3500)
	src = [[

friend_apply_addfriend 3000 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

friend_agree_addfriend 3001 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

friend_reject_addfriend 3002 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

friend_delfriend 3003 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

friend_sendmsg 3004 {
	request {
		base 0 : basetype
		pid 1 : integer
		msg 2 : string
	}
}

# 搜索玩家(findplayer:ID或者完整名字)
#friend_search 3005 {
#	request {
#		base 0 : basetype
#		findplayer 1 : string
#	}
#}

# 更换好友推荐
friend_change_recommend 3006 {
	request {
		base 0 : basetype
	}
}

friend_apply_allrecommend 3007 {
	request {
		base 0 : basetype
	}
}

friend_agree_allapply 3008 {
	request {
		base 0 : basetype
	}
}

friend_reject_allapply 3009 {
	request {
		base 0 : basetype
	}
}

# 添加到黑名单
friend_addblack 3010 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

# 解除黑名单
friend_delblack 3011 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

]]
}
