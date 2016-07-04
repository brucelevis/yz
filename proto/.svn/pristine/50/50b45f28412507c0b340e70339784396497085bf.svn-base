return {
	p = "msg",
	si = 4500, -- [4500,5000)
	src = [[
msg_notify 4500 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

msg_messagebox 4501 {
	request {
		base 0 : basetype
		id 1 : integer # 0--no callback
		title 2 : string
		content 3 : string
		attach 4 : string # jsontype
		buttons 5 : *string
		type 6 : integer
	}
}

msg_worldmsg 4502 {
	request {
		sender 0 : SendMsgPlayerType
		msg 1 : string
	}
}

msg_scenemsg 4503 {
	request {
		sender 0 : SendMsgPlayerType
		msg 1 : string
	}
}

msg_teammsg 4504 {
	request {
		sender 0 : SendMsgPlayerType
		msg 1 : string
	}
}

msg_orgmsg 4505 {
	request {
		sender 0 : SendMsgPlayerType
		msg 1 : string
	}
}

msg_hornmsg 4506 {
	request {
		sender 0 : SendMsgPlayerType
		msg 1 : string
	}
}

msg_privatemsg 4507 {
	request {
		sender 0 : SendMsgPlayerType
		msg 1 : string
	}
}

# 快讯
msg_quickmsg 4508 {
	request {
		msg 0 : string
	}
}

#个人信息（一般用于提示个人资源获取信息)
msg_info 4509 {
}
]]
}
