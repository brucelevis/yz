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

# 搜索玩家(pid或者完整名字)
friend_search 3005 {
	request {
		base 0 : basetype
		pid 1 : integer
		name 2 : string
	}
}

# 更换好友推荐
friend_change_recommend 3006 {
	request {
		base 0 : basetype
	}
}

]]
}
