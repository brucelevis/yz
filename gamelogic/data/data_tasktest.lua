

--<<npc导表开始>>
local npcinfo = {
	[1001] = {
		name = "路人甲",
		shape = 101,
		location = {scene = 1001,x = 100,y = 80,},
		clientnpc = 0,
	},
	[1002] = {
		name = "路人乙",
		shape = 101,
		location = {scene = 1001,x = 100,y = 80,},
		clientnpc = 0,
	},
	[1003] = {
		name = "路人丙",
		shape = 101,
		location = {scene = 1001,x = 100,y = 80,},
		clientnpc = 0,
	},
}

--<<npc导表结束>>


--<<场景导表开始>>
local sceneinof = {
}
--<<场景导表结束


--<<奖励导表开始>>
local rewardinfo = {
	[1001] = {
		exp = "$lv*1000",
		gold = "100",
		silver = "100",
		item = {{type = 1001,num = 1},}
	},
	[1002] = {
		exp = "$lv*2000",
		gold = "$lv*100",
	}
}
--<<奖励导表结束>>


--<<对白导表开始>>
local textinfo = {
	[1001] = "去$target找到$npc",
	[1002] = "找到$needitem，交给$target的$npc",
	[1003] = "这并不是我要的$needitem",
	[1004] = "去$target挑战$npc",
	[1005] = "再接再厉",
}
--<<对白导表结束>>



--<<任务导表开始>>
local taskinfo = {
	[10001] = {
		type = 1,
		name = "测试找人",
		accept = {
			{ sc = "npc", arg = 1001,},
			{ sc = "find", arg = 1001,},
			{ sc = "talk", arg = 1001,},
		},
		execution = {
			{ sc = "verify", arg = 1,},
		},
		submit = {
			{ sc = "reward", arg = 1001,},
		},
		fail = {
		},
		finishbyclient = 1,
		submitnpc = 0,
		cangiveup = 1,
		lvlimit = 0,
		joblimit = {},
		exceedtime = 0,
		pretask = {},
		donelimit = {},
		starttime = 0,
		endtime = 0,
	},
	[10002] = {
		type = 1,
		name = "测试寻物",
		accept = {
			{ sc = "item", arg = { type = 501001, num = 1,},},
			{ sc = "npc", arg = 1002,},
			{ sc = "find", arg = 1002,},
			{ sc = "talk", arg = 1002,},
		},
		execution = {
			{ sc = "verify", arg = 1,},
			{ sc = "handin", arg = 1,},
		},
		submit = {
			{ sc ="reward", arg = 1001,},
		},
		fail = {
			{ sc ="talk", arg = 1003,},
		},
		finishbyclient = 0,
		submitnpc = 0,
		cangiveup = 1,
	},
	[10003] = {
		type = 1,
		name = "测试战斗",
		accept = {
			{ sc = "npc", arg = 1003,},
			{ sc = "find", arg = 1003,},
			{ sc = "talk", arg = 1004,},
		},
		execution = {
			{ sc = "verify", arg = 1,},
			{ sc = "war", arg = 1001,},
		},
		submit = {
			{ sc = "reward", arg = 1002,},
		},
		fail = {
			{ sc = "talk", arg = 1005,},
		},
		finishbyclient = 0,
		submitnpc = 1001,
		cangiveup = 1,
	},
}
--<<任务导表结束>>

data_tasktest = {
	npcinfo = npcinfo,
	sceneinfo = sceneinfo,
	rewardinfo = rewardinfo,
	textinfo = textinfo,
	taskinfo = taskinfo,
}

return data_tasktest

