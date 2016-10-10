

return {
	p = "msg",
	si = 4500, -- [4500,5000)
	src = [[
# 世界消息
msg_worldmsg 4501 {
	request {
		base 0 : basetype
		msg 1 : string
		id 2 : integer		# 客户端生成的消息唯一ID
	}
}

# 场景消息(当地频道消息)
msg_scenemsg 4502 {
	request {
		base 0 : basetype
		msg 1 : string
		id 2 : integer		# 客户端生成的消息唯一ID
	}
}

# 队伍消息
msg_teammsg 4503 {
	request {
		base 0 : basetype
		msg 1 : string
		id 2 : integer		# 客户端生成的消息唯一ID
	}
}

# 工会消息
msg_unionmsg 4504 {
	request {
		base 0 : basetype
		msg 1 : string
		id 2 : integer		# 客户端生成的消息唯一ID
	}
}

# 喇叭消息
msg_hornmsg 4505 {
	request {
		base 0 : basetype
		msg 1 : string
		id 2 : integer		# 客户端生成的消息唯一ID
	}
}

# 私信
msg_sendmsgto 4506 {
	request {
		base 0 : basetype
		msg 1 : string
		targetid 2 : integer  #发给谁
		id 3 : integer		# 客户端生成的消息唯一ID
	}
}

# 应答模式响应接口
msg_respondanswer 4507 {
	request {
		base 0 : basetype
		id 1 : integer # 服务端发起应答时携带的回调id
		answer 2 : integer # 选择项id(空/-1表示关闭了窗口)
	}
}

]]
}
