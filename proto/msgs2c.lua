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
# 响应用msg.respondanswer协议
#消息弹框类型:
#MB_TEST		  = 0					-- 测试弹框
#MB_INVITE_QIECUO = 1					-- 邀请切磋
#MB_RECALLMEMBER = 2					-- 召回队员
#MB_APPLY_BECOME_CAPTAIN = 3			-- 申请称谓队长
#MB_INVITE_JOINTEAM = 4					-- 邀请入队
#MB_SHIMOSHILIAN_REACHLIMIT = 5			-- 使魔试炼次数达到上限
#MB_SHIMOSHILIAN_10_RING = 6			-- 使魔试炼达到10环
#MB_INVITE_BECOME_CAPTAIN = 7			-- 邀请成为队长
#MB_NOTIFY_BACKTEAM		= 8				-- 通知归队

#MB_LACK_CONDITION		= 9				-- 条件不足,
# 对于MB_LACK_CONDITION:attach格式:{lackres=缺少的资源,costgold=消耗的金币}
# lackres格式统一为:
#{
#	items={
#		{type=物品类型,num=物品数量},
#	},
#	#具体资源命名见data_ResType#flag字段
#	gold = xxx,
#	silver = xxx,
#	coin = xxx,
#	...
#}

msg_messagebox 4501 {
	request {
		base 0 : basetype
		id 1 : integer			#消息ID，回应服务器时转发,如果为0，表示该消息无须回应
		title 2 : string		#标题(空--不显示)
		content 3 : string		#内容(空--不显示)
		attach 4 : string		#json打包的字符串，不同类型弹框消息有不同含义
		buttons 5 : *ButtonType #按钮信息
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

# 工会消息
msg_unionmsg 4505 {
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

#npc对话消息 (响应用msg.respondanswer协议)
msg_npcsay 4510 {
	request {
		base 0 : basetype
		name 1 : string
		shape 2 : integer
		msg 3 : string
		options 4 : *string		#按钮信息,按顺序显示选项
		respondid 5 : integer # 应答id,无选项时为nil
	}
}

# 频道发言CD间隔（上线时发送给客户端)
.ChannelCDType {
	type 0 : string  # 见data_MsgChannel
	cd 1 : integer	 # cd
}

msg_channel_cd 4511 {
	request {
		base 0 : basetype
		cds 1 : *ChannelCDType
	}
}

# 发言成功，只有收到该协议，客户端才进入对应消息的频道CD
msg_sendmsg_succ 4512 {
	request {
		base 0 : basetype
		id 1 : integer		# 客户端生成的唯一消息ID
	}
}
]]
}
