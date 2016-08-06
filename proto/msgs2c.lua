return {
	p = "msg",
	si = 4500, -- [4500,5000)
	src = [[
# 从下向上冒泡的提示消息
msg_notify 4500 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

# 弹框消息
#消息弹框类型:1--邀请切磋
msg_messagebox 4501 {
	request {
		base 0 : basetype
		id 1 : integer			#消息ID，回应服务器时转发,如果为0，表示该消息无须回应
		title 2 : string		#标题
		content 3 : string		#内容
		attach 4 : string		#json打包的字符串，不同类型弹框消息有不同含义
		buttons 5 : *string     #按钮文字
		type 6 : integer		#消息弹框类型
	}
}

# 世界频道消息
msg_worldmsg 4502 {
	request {
		base 0 : basetype
		sender 1 : SendMsgPlayerType
		msg 2 : string
	}
}

# 场景消息/当地频道消息
msg_scenemsg 4503 {
	request {
		base 0 : basetype
		sender 1 : SendMsgPlayerType
		msg 2 : string
	}
}

# 队伍消息
msg_teammsg 4504 {
	request {
		base 0 : basetype
		sender 1 : SendMsgPlayerType
		msg 2 : string
	}
}

# 帮派消息
msg_orgmsg 4505 {
	request {
		base 0 : basetype
		sender 1 : SendMsgPlayerType
		msg 2 : string
	}
}

# 喇叭消息
msg_hornmsg 4506 {
	request {
		base 0 : basetype
		sender 1 : SendMsgPlayerType
		msg 2 : string
	}
}

# 私人消息
msg_privatemsg 4507 {
	request {
		base 0 : basetype
		sender 1 : SendMsgPlayerType
		msg 2 : string
	}
}

# 快讯
msg_quickmsg 4508 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

#个人信息（一般用于提示个人资源获取信息)
msg_info 4509 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

#npc对话消息
msg_npcsay 4510 {
	request {
		base 0 : basetype
		name 1 : string
		type 2 : integer
		msg 3 : string
	}
}
]]
}
