return {
	p = "war",
	si = 6000,  --[6000,6200)
	src = [[

war_warresult 6000 {
	request {
		base 0 : basetype
		warid 1 : integer
		result 2 : integer		#空--强制结束的战斗,<0--负，==0--平，>0--胜
	}
}

war_sethpmp 6001 {
	request {
		base 0 : basetype
		pid 1 : integer			#玩家ID/宠物ID
		type 2 : integer		#1--玩家,2--宠物	
		hp 3 : integer			#剩余血量
		mp 4 : integer			#剩余魔法
	}
}

war_quitwar 6002 {
	request {
		base 0 : basetype
		warid 1 : integer
	}
}
]]
}
