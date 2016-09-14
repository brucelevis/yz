return {
	p = "friend",
	si = 3000, -- [3000,3500)
	src = [[

# 全量更新简介数据(简介数据可以用于好友列表，申请列表等)
friend_sync 3000 {
	request {
		base 0 : basetype
		srvname 1 : string
		pid 2 : integer
		name 3 : string
		roletype 4 : integer
		lv 5 : integer
		online 6 : boolean	#是否在线
		fightpoint 7 : integer #战力
		frdship 8 : integer #好友度(仅好友列表中的玩家有)
	}
}

# 新增部分关系:好友/申请者/关注列表
friend_addlist 3001 {
	request {
		base 0 : basetype
		pids 1 : *integer
		# 0--applayer; 1--friend; 2--toapply; 3--recommend
		type 2 : integer
		# true--新增的列表，false--原有列表；上线时会发送原有列表，新增列表，后续增加关系都是发新增列表
		newflag 3 : boolean
	}
}

#删除部分关系:好友/申请者/关注列表
friend_dellist 3002 {
	request {
		base 0 : basetype
		pids 1 : *integer
		# 0--applayer; 1--friend; 2--toapply; 3--recommend
		type 2 : integer
	}
}

# 好友间私聊消息
friend_addmsgs 3003 {
	request {
		base 0 : basetype
		pid 1 : integer
		msgs 2 : *string
	}
}

]]
}
