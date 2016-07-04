return {
	p = "login",
	si = 1000, -- [1000,1500)
	src = [[
# 已作废,客户端直接连帐号中心注册
login_register 1000 {
	request {
		base 0 : basetype
		acct 1 : string
		passwd 2 : string
		srvname 3 : string
	}
}


login_createrole 1001 {
	request {
		base 0 : basetype
		acct 1 : string
		roletype 2 : integer
		name 3 : string
	}
}


# 已作废,客户端直接连帐号中心登录
login_login 1002 {
	request {
		base 0 : basetype
		acct 1 : string
		passwd 2 : string
	}
}

login_entergame 1003 {
	request {
		base 0 : basetype
		roleid 1 : integer
		token 2 : string
	}
}

login_exitgame 1004 {
	request {
		base 0 : basetype
	}
}

login_delrole 1005 {
	request {
		base 0 : basetype
		roleid 1 : integer
	}
}

login_tokenlogin 1006 {
	request {
		base 0 : basetype
		token 1 : string	#token认证
		acct 2 : string  #对于渠道，即渠道返回的uid
		channel 3 : string  #渠道名
	}
}
]]
}

