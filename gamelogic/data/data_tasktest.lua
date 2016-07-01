

--<<npc导表开始>>
local npcinfo = {
	[1001] = {
		name = "路人甲",
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
	[1001] = {
		name = "测试找人",
		accept = {
			{ npc = 1001,},{ find = 1001,},{ talk = 1001,},
		}
		submit = {
			{ done = 1,},
		}
		done = {
	t		{ reward = 1001,},
		}
		fail = {
		},
	},
	[1002] = {
		name = "测试寻物",
		accept = {
			{ item = { type = 1000,num = 1,},},{ find = 1002,},{ talk = 1002,},
		},
		submit = {
			{ handin = 1,},
		},
		done = {
			{ reward = 1001,},
		},
		fail = {
			{ talk = 1003,},
		},
	},
	[1003] = {
		name = "测试战斗",
		accept = {
			{ find = 1003,},{ talk = 1004,},
		},
		submit = {
			{ war = 1001,},
		},
		done = {
			{ reward = 1002,},
		},
		fail = {
			{ talk = 1005,},
		},
	},
}
--<<任务导表结束>>

data_testtask = {
	npcinfo = npcinfo,
	sceneinfo = sceneinfo,
	rewardinfo = rewardinfo,
	textinfo = textinfo,
	taskinfo = taskinfo,
}

return data_testtask

