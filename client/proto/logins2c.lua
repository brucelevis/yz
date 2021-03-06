return {
	p = "login",
	si = 1000, -- [1000,1500)
	src = [[
login_kick 1000 {
	request {
		base 0 : basetype
		reason 1 : string
	}
}

# 排队信息
login_queue 1001 {
	request {
		base 0 : basetype
		waitnum 1 : integer
	}
}

login_reentergame 1002 {
	request {
		base 0 : basetype
		token 1 : string
		go_srvname 2 : string
	}
}

# 注册帐号结果. 0--成功，其他--错误码(错误码后续服务端和客户端公用一份错误码表)
login_register_result 1003 {
	request {
		base 0 : basetype
		errcode 1 : integer
	}
}

# 创建角色结果
login_createrole_result 1004 {
	request {
		base 0 : basetype
		errcode 1 : integer
		result 2 : RoleType # errcode=0有效,新建角色简介数据
	}
}

# 登录帐号结果
login_login_result 1005 {
	request {
		base 0 : basetype
		errcode 1 : integer
		result 2 : *RoleType  # errcode=0有效，帐号已有角色列表
	}
}

# 进入游戏结果
login_entergame_result 1006 {
	request {
		base 0 : basetype
		errcode 1 : integer
	}
}

# 删除角色结果
login_delrole_result 1007 {
	request {
		base 0 : basetype
		errcode 1 : integer
	}
}

# token认证结果
login_tokenlogin_result 1008 {
	request {
		base 0 : basetype
		errcode 1 : integer
	}
}
]]
}
