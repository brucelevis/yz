

data_TaskTest = {
	[900001] = {
		type = 1,
		name = "测试找人",
		accept = {
			{ cmd = "addnpc", args = { nid = 1001,},},
			{ cmd = "findnpc", args = { nid = 1001,},},
			{ cmd = "talkto", args = { nid = 1001, textid = 1001,},},
		},
		execution = {
		},
		finishbyclient = 1,
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {},
		exceedtime = "forever",
		pretask = {},
		ratio = 10,
		award = {[1001] = 10,[1002] = 10,},
	},
	[900002] = {
		type = 2,
		name = "测试寻物",
		accept = {
			{ cmd = "needitem", args = { type = 501001, num = 1 },},
			{ cmd = "addnpc", args = { nid = 1002,},},
			{ cmd = "delnpc", args = { nid = 1002,},},
			{ cmd = "addnpc", args = { nid = 1002,},},
			{ cmd = "talkto", args = { nid = 1002, textid = 1002,},},
		},
		execution = {
			{ cmd = "handinitem", args= { nid = 1002,},},
		},
		finishbyclient = 1,
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {},
		exceedtime = "forever",
		pretask = {},
		ratio = 10,
		award = {[1001] = 5,[1002] = 15,},
	},
	[900003] = {
		type = 3,
		name = "测试战斗",
		accept = {
			{ cmd = "addnpc", args = { nid = 1003,},},
			{ cmd = "findnpc", args = { nid = 1003,},},
			{ cmd = "talkto", args = { nid = 1003, textid = 1004,},},
			{ cmd = "setpatrol", args = { mapid = 1001,pos = {x = 10,y = 10},},},
			{ cmd = "progressbar", args = { time = 3,},},
		},
		execution = {
			{ cmd = "raisewar", args = { warid = 1001,},},
		},
		finishbyclient = 0,
		submitnpc = 1001,
		cangiveup = 1,
		needlv = 0,
		needjob = {},
		exceedtime = "forever",
		pretask = {},
		ratio = 10,
		award = {[1003] = 1,},
		nexttask = "other",
	},
}

return data_TaskTest

