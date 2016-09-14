--<<data_1500_MainTaskProcess 导表开始>>
data_1500_MainTaskProcess = {

	[10000101] = {
		id = 10000101,
		type = 3,
		name = "探险之路由此始",
		accept = {
			{ cmd = 'talkto', args = { textid = 1011, }, },
			{ cmd = 'addnpc', args = { nid = { 101010,101020 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 101020, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100201, }, },
			{ cmd = 'talkto', args = { textid = 1012, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 101010,
		recommendteam = 2,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500110},
		ratio = 1,
		award = 10000101,
		nexttask = "10000102",
		chapterid = 10000101,
		icon_id = 0,
		desc = "伊菲的钱袋被偷了,帮他抢回来！",
		accepted_desc = "击败吉祥物",
		executed_desc = "与伊菲对话",
	},

	[10000102] = {
		id = 10000102,
		type = 3,
		name = "失窃还要被索赔",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 102010,102020 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 102020, respond = 1, }, },
			{ cmd = 'talkto', args = { textid = 1021, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100202, }, },
			{ cmd = 'talkto', args = { textid = 1022, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000101},
		ratio = 1,
		award = 10000102,
		nexttask = "10000103",
		chapterid = 10000102,
		icon_id = 0,
		desc = "无理取闹的熊孩子纠缠不清,教训他一顿。",
		accepted_desc = "击败熊孩子",
		executed_desc = "与熊孩子对话",
	},

	[10000103] = {
		id = 10000103,
		type = 3,
		name = "论熊孩子的养成",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 103010,103020,103030,103040 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 103020, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100203, }, },
			{ cmd = 'addnpc', args = { nid = 103050, }, },
			{ cmd = 'talkto', args = { textid = 1032, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 103050,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000102},
		ratio = 1,
		award = 10000103,
		nexttask = "10000104",
		chapterid = 10000103,
		icon_id = 0,
		desc = "村中聚集了许多不讲理的村民,别被他们欺负了。",
		accepted_desc = "击败村民",
		executed_desc = "与女勇者对话",
	},

	[10000104] = {
		id = 10000104,
		type = 3,
		name = "路见不平一声吼",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 104010,104020,104030,104040,104050 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 104030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100204, }, },
			{ cmd = 'talkto', args = { textid = 1042, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000103},
		ratio = 1,
		award = 10000104,
		nexttask = "10000105",
		chapterid = 10000104,
		icon_id = 0,
		desc = "原来村民们早已投靠了魔神,战胜他们！",
		accepted_desc = "击败村民",
		executed_desc = "与女勇者对话",
	},

	[10000105] = {
		id = 10000105,
		type = 3,
		name = "有理也得拳头硬",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 105010,105020,105030,105040,105050 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 105030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100205, }, },
			{ cmd = 'talkto', args = { textid = 1052, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 105020,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000104},
		ratio = 1,
		award = 10000105,
		nexttask = "10000106",
		chapterid = 10000105,
		icon_id = 0,
		desc = "赫麦村的事得以平息,踏上寻找魔神的旅程吧。",
		accepted_desc = "击败村长",
		executed_desc = "与女勇者对话",
	},

	[10000106] = {
		id = 10000106,
		type = 3,
		name = "这个世界我不懂",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 106010,106020,106030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 106030, respond = 1, }, },
			{ cmd = 'talkto', args = { textid = 1061, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100206, }, },
			{ cmd = 'talkto', args = { textid = 1062, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000105},
		ratio = 1,
		award = 10000106,
		nexttask = "10000107",
		chapterid = 10000106,
		icon_id = 0,
		desc = "在丛林里遇到了诡异的蘑菇,快去帮伊菲一把。",
		accepted_desc = "击败蘑菇",
		executed_desc = "与伊菲对话",
	},

	[10000107] = {
		id = 10000107,
		type = 3,
		name = "要不要这么夸张",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 107010,107020,107030,107040 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 107030, respond = 1, }, },
			{ cmd = 'talkto', args = { textid = 1071, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100207, }, },
			{ cmd = 'talkto', args = { textid = 1072, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000106},
		ratio = 1,
		award = 10000107,
		nexttask = "10000108",
		chapterid = 10000107,
		icon_id = 0,
		desc = "似乎有一位士兵被怪物包围了,把他救出来。",
		accepted_desc = "击败士兵",
		executed_desc = "与士兵对话",
	},

	[10000108] = {
		id = 10000108,
		type = 3,
		name = "兄弟咱是一伙的",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 108010,108020,108030,108040 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 108030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100208, }, },
			{ cmd = 'addnpc', args = { nid = 108050, }, },
			{ cmd = 'talkto', args = { textid = 1082, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 108050,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000107},
		ratio = 1,
		award = 10000108,
		nexttask = "10000109",
		chapterid = 10000108,
		icon_id = 0,
		desc = "士兵神智错乱了,向你发起进攻,保护好自己。",
		accepted_desc = "击败士兵",
		executed_desc = "与剑士对话",
	},

	[10000109] = {
		id = 10000109,
		type = 3,
		name = "原来是想吃独食",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 109010,109020,109030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 109030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100209, }, },
			{ cmd = 'talkto', args = { textid = 1092, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000108},
		ratio = 1,
		award = 10000109,
		nexttask = "10000110",
		chapterid = 10000109,
		icon_id = 0,
		desc = "施以援手的剑士居然也是魔神的爪牙,决不能姑息！",
		accepted_desc = "击败剑士",
		executed_desc = "与剑士对话",
	},

	[10000110] = {
		id = 10000110,
		type = 3,
		name = "好人真是不太多",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 110010,110020,110030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 110030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100210, }, },
			{ cmd = 'talkto', args = { textid = 1102, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 1,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000109},
		ratio = 1,
		award = 10000110,
		nexttask = "10000201",
		chapterid = 10000110,
		icon_id = 0,
		desc = "赢得胜利的勇者们,向丛林的深处进发吧！",
		accepted_desc = "击败剑士",
		executed_desc = "与爱拉忒对话",
	},

	[10000201] = {
		id = 10000201,
		type = 3,
		name = "口味不能这么重",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 201010,201020,201030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 201030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 2011, }, },
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2012, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 201010,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000110},
		ratio = 1,
		award = 10000201,
		nexttask = "10000202",
		chapterid = 10000201,
		icon_id = 0,
		desc = "来到丛林深处,赫麦村长为何会在这里？",
		accepted_desc = "击败村长",
		executed_desc = "与伊菲对话",
	},

	[10000202] = {
		id = 10000202,
		type = 3,
		name = "分不清就一起打",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 202010,202020,202030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 202030, respond = 1, }, },
			{ cmd = 'talkto', args = { textid = 2021, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2022, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 202010,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000201},
		ratio = 1,
		award = 10000202,
		nexttask = "10000203",
		chapterid = 10000202,
		icon_id = 0,
		desc = "眼前出现两个伊菲,到底哪个才是真的？",
		accepted_desc = "击败神秘人",
		executed_desc = "与伊菲对话",
	},

	[10000203] = {
		id = 10000203,
		type = 3,
		name = "哪里来的爱拉忒",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 203010,203020,203030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 203030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2032, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 203010,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000202},
		ratio = 1,
		award = 10000203,
		nexttask = "10000204",
		chapterid = 10000203,
		icon_id = 0,
		desc = "虚假的小伙伴现出了本来面目,居然是魔神但他林！",
		accepted_desc = "击败爱拉忒幻象",
		executed_desc = "与伊菲对话",
	},

	[10000204] = {
		id = 10000204,
		type = 3,
		name = "英雄来过美人关",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 204010,204020,204030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 204030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2042, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 204010,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000203},
		ratio = 1,
		award = 10000204,
		nexttask = "10000205",
		chapterid = 10000204,
		icon_id = 0,
		desc = "狡猾的但他林变成了美女,企图魅惑勇者们。",
		accepted_desc = "击败但他林的化身",
		executed_desc = "与伊菲对话",
	},

	[10000205] = {
		id = 10000205,
		type = 3,
		name = "总有一款适合你",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 205010,205020,205030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 205030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2052, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 205020,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000204},
		ratio = 1,
		award = 10000205,
		nexttask = "10000206",
		chapterid = 10000205,
		icon_id = 0,
		desc = "狡猾的但他林变成了帅哥,企图震慑勇者们。",
		accepted_desc = "击败但他林的化身",
		executed_desc = "与伊菲对话",
	},

	[10000206] = {
		id = 10000206,
		type = 3,
		name = "找茬游戏加载中",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 206010,206020,206030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 206030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2062, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 206010,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000205},
		ratio = 1,
		award = 10000206,
		nexttask = "10000207",
		chapterid = 10000206,
		icon_id = 0,
		desc = "狡猾的但他林化作幻化成勇者曾经的敌人,不要怕,真正的勇者是无畏的！",
		accepted_desc = "击败但他林的化身",
		executed_desc = "与伊菲对话",
	},

	[10000207] = {
		id = 10000207,
		type = 3,
		name = "使魔陪你走两步",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 207010,207020,207030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 207030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2072, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 207020,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000206},
		ratio = 1,
		award = 10000207,
		nexttask = "10000208",
		chapterid = 10000207,
		icon_id = 0,
		desc = "但他林派出一支使魔队伍出战,杀杀他们的锐气！",
		accepted_desc = "击败但他林的使魔",
		executed_desc = "与伊菲对话",
	},

	[10000208] = {
		id = 10000208,
		type = 3,
		name = "使魔也会不及格",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 208010,208020,208030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 208030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2082, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 208010,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000207},
		ratio = 1,
		award = 10000208,
		nexttask = "10000209",
		chapterid = 10000208,
		icon_id = 0,
		desc = "但他林派出使魔队伍再战,给他们点颜色瞧瞧。",
		accepted_desc = "击败但他林的使魔",
		executed_desc = "与伊菲对话",
	},

	[10000209] = {
		id = 10000209,
		type = 3,
		name = "强将手下无弱兵",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 209010,209020,209030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 209030, respond = 1, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2092, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 209020,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000208},
		ratio = 1,
		award = 10000209,
		nexttask = "10000210",
		chapterid = 10000209,
		icon_id = 0,
		desc = "但他林派出最强的使魔,让它尝尝勇者大人的厉害。",
		accepted_desc = "击败但他林的使魔",
		executed_desc = "与爱拉忒对话",
	},

	[10000210] = {
		id = 10000210,
		type = 3,
		name = "话痨也是没救了",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 210010,210020,210030 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 210030, respond = 1, }, },
			{ cmd = 'talkto', args = { textid = 2101, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100000, }, },
			{ cmd = 'talkto', args = { textid = 2102, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 210010,
		recommendteam = 1,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10000209},
		ratio = 1,
		award = 10000210,
		nexttask = "nil",
		chapterid = 10000210,
		icon_id = 0,
		desc = "狡猾的但他林挑起爱拉忒心中的愤恨,保护她,不要让她受到魔神的伤害。",
		accepted_desc = "击败但他林",
		executed_desc = "与爱拉忒对话",
	},

}
return data_1500_MainTaskProcess
--<<data_1500_MainTaskProcess 导表结束>>