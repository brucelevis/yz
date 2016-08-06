return {
	p = "guaji",
	si = 7000, --[7000,7100)
	src = [[

# 设置挂机（原地巡逻）
guaji_guaji 7000 {
	request {
		base 0 : basetype
	}
}

# 取消挂机
guaji_unguaji 7001 {
	request {
		base 0 : basetype
	}
}

]]
}
