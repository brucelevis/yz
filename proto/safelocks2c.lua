return {
	p = "safelock",
	si = 6600, --[6600,6700)
	src = [[

# 同步安全锁信息(全量更新,上线/变化时发)
safelock_sync 6600 {
	request {
		base 0 : basetype
		islock 1 : integer  # 0/空--解锁状态;其他--锁定状态
		passwd 2 : integer  # 0/空--未设定密码,其他--已经设定密码
		unlock_exceedtime 3 : integer #强行解锁过期时间(未处于强行解锁状态下为空）
	}
}

# 弹出安全锁输入密码界面
safelock_popui_enterpasswd 6601 {
	request {
		base 0 : basetype
	}
}
]]
}
