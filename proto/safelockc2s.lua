return {
	p = "safelock",
	si = 6600, --[6600,6700)
	src = [[

# 设置密码
safelock_setpaswd 6600 {
	request {
		base 0 : basetype
		passwd 1 : string		#密码
		checkpasswd 2 : string  #确认密码
	}
}

# 解锁
safelock_unlock 6601 {
	request {
		base 0 : basetype
		passwd 1 : string
	}
}

# 修改密码
safelock_modifypasswd 6602 {
	request {
		base 0 : basetype
		oldpasswd 1 : string	#旧密码
		passwd 2 : string		#新密码
		checkpasswd 3 : string	#确认密码
	}
}

# 重置密码
safelock_unsetpasswd 6603 {
	request {
		base 0 : basetype
		passwd 1 : string
	}
}

# 强制解锁
safelock_forceunlock 6604 {
	request {
		base 0 : basetype
		passwd 1 : string  #已处于强行解锁期间，需要发密码，否则不发
	}
}
]]
}
