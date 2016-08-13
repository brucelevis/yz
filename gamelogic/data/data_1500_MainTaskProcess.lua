--<<data_1500_MainTaskProcess 导表开始>>
data_1500_MainTaskProcess = {

	[10000101] = {
		id = 10000101,
		type = 3,
		name = "探险之路由此始",
		accept = {
			{ cmd = 'talkto', args = { textid = 1011, }, },
			{ cmd = 'addnpc', args = { nid = { 10101,10102 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 10102, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1012, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10101,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 1,
		award = 101,
		nexttask = 10000102,
		chapterid = 10001,
		icon_id = 0,
		desc = "主线测试1",
		accepted_desc = "击败吉祥物",
		executed_desc = "与伊菲对话",
	},

	[10000102] = {
		id = 10000102,
		type = 3,
		name = "失窃还要被索赔",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10102,10103 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1021, }, },
			{ cmd = 'findnpc', args = { nid = 1003, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1022, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10103,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000101},
		ratio = 1,
		award = 102,
		nexttask = 10000103,
		chapterid = 10002,
		icon_id = 0,
		desc = "主线测试2",
		accepted_desc = "击败熊孩子",
		executed_desc = "与熊孩子对话",
	},

	[10000103] = {
		id = 10000103,
		type = 3,
		name = "论熊孩子的养成",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10104,10105,10106 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 10104, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'addnpc', args = { nid = 10107, }, },
			{ cmd = 'talkto', args = { textid = 1032, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10104,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000102},
		ratio = 1,
		award = 103,
		nexttask = 10000104,
		chapterid = 10003,
		icon_id = 0,
		desc = "主线测试3",
		accepted_desc = "击败村民",
		executed_desc = "与村民对话",
	},

	[10000104] = {
		id = 10000104,
		type = 3,
		name = "路见不平一声吼",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10104,10105,10106,10107 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 10104, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1042, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10107,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000103},
		ratio = 1,
		award = 104,
		nexttask = 10000105,
		chapterid = 10004,
		icon_id = 0,
		desc = "主线测试4",
		accepted_desc = "击败村民",
		executed_desc = "与女勇者对话",
	},

	[10000105] = {
		id = 10000105,
		type = 3,
		name = "有理也得拳头硬",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10107,10108 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 10108, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1052, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10108,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000104},
		ratio = 1,
		award = 105,
		nexttask = 10000106,
		chapterid = 10005,
		icon_id = 0,
		desc = "主线测试5",
		accepted_desc = "击败村长",
		executed_desc = "与村长对话",
	},

	[10000106] = {
		id = 10000106,
		type = 3,
		name = "这个世界我不懂",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10107,10109 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1061, }, },
			{ cmd = 'findnpc', args = { nid = 10109, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1062, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10107,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000105},
		ratio = 1,
		award = 106,
		nexttask = 10000107,
		chapterid = 10006,
		icon_id = 0,
		desc = "主线测试6",
		accepted_desc = "击败蘑菇",
		executed_desc = "与女勇者对话",
	},

	[10000107] = {
		id = 10000107,
		type = 3,
		name = "要不要这么夸张",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10107,10110 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1071, }, },
			{ cmd = 'findnpc', args = { nid = 10110, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1072, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10110,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000106},
		ratio = 1,
		award = 107,
		nexttask = 10000108,
		chapterid = 10007,
		icon_id = 0,
		desc = "主线测试7",
		accepted_desc = "击败士兵",
		executed_desc = "与士兵对话",
	},

	[10000108] = {
		id = 10000108,
		type = 3,
		name = "兄弟咱是一伙的",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10107,10110 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 10110, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'addnpc', args = { nid = 10111, }, },
			{ cmd = 'talkto', args = { textid = 1082, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10111,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000107},
		ratio = 1,
		award = 108,
		nexttask = 10000109,
		chapterid = 10008,
		icon_id = 0,
		desc = "主线测试8",
		accepted_desc = "击败士兵",
		executed_desc = "与剑士对话",
	},

	[10000109] = {
		id = 10000109,
		type = 3,
		name = "原来是想吃独食",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10107,10111 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 10111, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1092, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10111,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000108},
		ratio = 1,
		award = 109,
		nexttask = 10000110,
		chapterid = 10009,
		icon_id = 0,
		desc = "主线测试9",
		accepted_desc = "击败剑士",
		executed_desc = "与剑士对话",
	},

	[10000110] = {
		id = 10000110,
		type = 3,
		name = "好人真是不太多",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 10101,10107,10111 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 10111, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 1102, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 10111,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {10000109},
		ratio = 1,
		award = 110,
		nexttask = nil,
		chapterid = 10010,
		icon_id = 0,
		desc = "主线测试10",
		accepted_desc = "击败剑士",
		executed_desc = "与爱拉忒对话",
	},

}
return data_1500_MainTaskProcess
--<<data_1500_MainTaskProcess 导表结束>>