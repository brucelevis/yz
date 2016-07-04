return {
	p = "player",
	si = 5000, -- [5000,5500)
	src = [[
test_gm 5000 {
	request {
		base 0 : basetype
		cmd 1 : string  #gm指令
	}
}
]]
}
