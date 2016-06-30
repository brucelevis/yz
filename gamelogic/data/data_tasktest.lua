
data_tasktest = {}

--<<npc导表开始>>
local npcinfo = {
	[1001] = {
		name = "路人甲",
		shape = "101",
		pos = "1001,10,20",
	},
}
--<<npc导表结束>>


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
		type = TASK_NORMAL,
		accept = "npc1001;find1001;talk1001",
		submit = "done",
		done = "reward1001",
		fail = "",
	},
	[1002] = {
		name = "测试寻物",
		type = TASK_NORMAL,
		accept = "item(1001,1);find1002;talk1002",
		submit = "handin",
		done = "reward1001",
		fail = "talk1003",
	},
	[1003] = {
		name = "测试战斗",
		type = TASK_WAR,
		accept = "find1003;talk1004",
		submit = "war1001",
		done = "reward1002",
		fail = "talk1005",
	},
}
--<<任务导表结束>>






















