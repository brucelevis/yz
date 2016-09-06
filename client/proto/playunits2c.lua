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
		cnt 3 : integer			#当前题数
		maxcnt 4 : integer		#总题数
		exceedtime 5 : integer	#答题时间
		npcname 6 : string
		npcshape 7 : integer	#造型
		questionbank 8 : string #题库表名
	}
}
]]
}
