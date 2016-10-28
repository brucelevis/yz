return {
	p = "friend",
	si = 3000, -- [3000,3500)
	src = [[
#同步好友关系数据
friend_sync_frddata 3001 {
	request {
		base 0 : basetype
		pid 1 : integer
		frdship 2 : integer #好友度
		addfrdtime 3 : integer #加好友时间
	}
}

# 新增部分关系:好友/申请者/关注列表/推荐列表/黑名单
friend_addlist 3002 {
	request {
		base 0 : basetype
		pids 1 : *integer
		# 0--applayer; 1--friend; 2--toapply; 3--recommend; 4--black
		type 2 : integer
		# true--新增的列表，false--原有列表；上线时会发送原有列表，新增列表，后续增加关系都是发新增列表
		newflag 3 : boolean
	}
}

# 删除部分关系:好友/申请者/关注列表
friend_dellist 3003 {
	request {
		base 0 : basetype
		pids 1 : *integer
		# 0--applayer; 1--friend; 2--toapply; 3--recommend; 4--black
		type 2 : integer
	}
}

.MessageType {
	sender 0 : integer
	msg 1 : string
	sendtime 2 : integer
	receiver 3 : integer
}

# 好友间私聊消息
friend_addmsgs 3004 {
	request {
		base 0 : basetype
		msgs 1 : *MessageType
	}
}

]]
}
