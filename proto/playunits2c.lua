return {
	p = "playunit",
	si = 7200, --[7200,7300)
	src = [[

# 呼出答题玩法界面(回复用msg.respondanswer协议)
playunit_opendati 7200 {
	request {
		base 0 : basetype
		questionid 1 : integer
		respondid 2 : integer
	}
}
]]
}
