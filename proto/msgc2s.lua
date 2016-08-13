

return {
	p = "msg",
	si = 4500, -- [4500,5000)
	src = [[
msg_onmessagebox 4500 { # 回复messgebox
	request {
		base 0 : basetype
		id 1 : integer
		buttonid 2 : integer
	}
}

# 世界消息
msg_worldmsg 4501 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

# 场景消息(当地频道消息)
msg_scenemsg 4502 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

# 队伍消息
msg_teammsg 4503 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

# 帮派消息
msg_orgmsg 4504 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

# 喇叭消息
msg_hornmsg 4505 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

# 私信
msg_sendmsgto 4506 {
	request {
		base 0 : basetype
		msg 1 : string
		targetid 2 : integer  #发给谁
	}
}

# npc对话响应
msg_onnpcsay 4507 {
	request {
		base 0 : basetype
		respondid 1 : integer # npcsay中对应的应答id
		answer 2 : integer # 选项序号
	}
}

]]
}
