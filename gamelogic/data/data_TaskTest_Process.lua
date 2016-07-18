--<<data_TaskTest_Process 导表开始>>
data_TaskTest_Process = {

	[900001] = {
		type = 1,
		name = "测试找人",
		accept = {
			{ cmd = 'addnpc', args = { nid = 101, }, },
			{ cmd = 'findnpc', args = { nid = 101, }, },
			{ cmd = 'talkto', args = { textid = 101, }, },
		},
		execution = {

		},
		finishbyclient = 1,
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = {[101]=10},
		nexttask = nil,
	},

	[900002] = {
		type = 2,
		name = "测试寻物",
		accept = {
			{ cmd = 'needitem', args = { type = 501001, num = 1, }, },
			{ cmd = 'addnpc', args = { nid = 102, }, },
			{ cmd = 'talkto', args = { textid = 102, }, },
		},
		execution = {
			{ cmd = 'handinitem', args = { nid = 102, }, },
		},
		finishbyclient = 0,
		submitnpc = 0,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = {[101]=10,[102]=10},
		nexttask = nil,
	},

	[900003] = {
		type = 3,
		name = "测试战斗",
		accept = {
			{ cmd = 'setpatrol', args = { mapid = 1001, pos = { x = 10, y = 10, }, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 101, }, },
		},
		finishbyclient = 0,
		submitnpc = 1001,
		cangiveup = 1,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 10,
		award = {[103]=10},
		nexttask = "other",
	},

}
return data_TaskTest_Process
--<<data_TaskTest_Process 导表结束>>