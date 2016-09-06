return {
	p = "test",
	si = 500, --[500,1000)
	src = [[

test_echo 500 {
	request {
		base 0 : basetype
		echostr 1 : string
	}
}

]]
}
