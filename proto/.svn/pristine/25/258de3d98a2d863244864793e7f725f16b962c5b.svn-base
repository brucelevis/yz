return {
	p = "title",
	si = 6500, --[6500,7000)
	src = [[

# 增加称谓
title_add 6500 {
	request {
		base 0 : basetype
		id  1 : integer		#称谓ID
		exceedtime 2 : integer #过期时间(空表示永久称谓)
	}
}

# 删除称谓
title_del 6501 {
	request {
		base 0 : basetype
		id 1 : integer	  #称谓ID
	}
}

# 更新称谓
title_update 6502 {
	request {
		base 0 : basetype
		id 1 : integer	 #称谓ID
		exceedtime 2 : integer #过期时间(空表示永久称谓)
	}
}

# 同步当前称谓
title_sync_curtitle 6503 {
	request {
		base 0 : basetype
		cur_titleid 1 : integer  #当前称谓ID（空表示隐藏当前称谓)
	}
}
]]
}
