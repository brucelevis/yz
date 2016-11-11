return {
	p = "kuafu",
	si = 1500, -- [1500,2000)
	src = [[

kuafu_gosrv 1500 {
	request {
		base 0 : basetype
		go_srvname 1 : string
	}
}

kuafu_gohome 1501 {
	request {
		base 0 : basetype
	}
}

kuafu_srvlist 1502 {
	request {
		base 0 : basetype
	}
}
]]
}
