--<<data_1500_ZhiyinTaskProcess 导表开始>>
data_1500_ZhiyinTaskProcess = {

	[10500101] = {
		id = 10500101,
		type = 1,
		name = "迦南的召唤",
		accept = {
			{ cmd = 'addnpc', args = { nid = 101015, }, },
			{ cmd = 'findnpc', args = { nid = 101015, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1011, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {nil},
		ratio = 1,
		award = 10500101,
		nexttask = "10500102",
		chapterid = 0,
		icon_id = 0,
		desc = "初到迦南的勇者大人吗？在这个陌生的世界是否感到有些茫然呢？没关系,来听听大祭司#<Y>米利暗#大人怎么说吧~",
		accepted_desc = "找到#<Y>米利暗#",
		executed_desc = "与#<Y>米利暗#对话",
	},

	[10500102] = {
		id = 10500102,
		type = 1,
		name = "防具与武器",
		accept = {
			{ cmd = 'addnpc', args = { nid = 102015, }, },
			{ cmd = 'findnpc', args = { nid = 102015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1021, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500101},
		ratio = 1,
		award = 10500102,
		nexttask = "10500103",
		chapterid = 0,
		icon_id = 0,
		desc = "迦南王国危难之际,正式需要勇者大人的时候。快#<Y>穿上米利暗大人赠与的装备#,准备战斗吧！",
		accepted_desc = "找到#<Y>米利暗#",
		executed_desc = "与#<Y>米利暗#对话",
	},

	[10500103] = {
		id = 10500103,
		type = 3,
		name = "基础战斗",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 103015,103025 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 103025, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100101, }, },
			{ cmd = 'talkto', args = { textid = 1032, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500102},
		ratio = 1,
		award = 10500103,
		nexttask = "10500104",
		chapterid = 0,
		icon_id = 0,
		desc = "身为即将拯救迦南的勇者大人,必然要经历激烈的战斗。根据米利暗大人的指引,#<Y>熟悉基本的战斗操作#吧。",
		accepted_desc = "击倒#<Y>格斗木靶#",
		executed_desc = "与#<Y>米利暗#对话",
	},

	[10500104] = {
		id = 10500104,
		type = 5,
		name = "护法艾格娅",
		accept = {
			{ cmd = 'addnpc', args = { nid = 104015, }, },
			{ cmd = 'setcollect', args = { posid = 21001003,  name = "叙述事情经过", }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1042, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500103},
		ratio = 1,
		award = 10500104,
		nexttask = "10500105",
		chapterid = 0,
		icon_id = 0,
		desc = "艾格娅是一位非常优秀的导师,她会帮助勇者大人熟悉战斗技能,不过好像有些难缠呢。",
		accepted_desc = "找到#<Y>艾格娅#",
		executed_desc = "与#<Y>艾格娅#对话",
	},

	[10500105] = {
		id = 10500105,
		type = 3,
		name = "学以致用",
		accept = {
			{ cmd = 'addnpc', args = { nid = 105015, }, },
			{ cmd = 'findnpc', args = { nid = 105015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100102, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500104},
		ratio = 1,
		award = 10500105,
		nexttask = "10500106",
		chapterid = 0,
		icon_id = 0,
		desc = "#<Y>战胜艾格娅#,勇者大人的实力是不容置疑的！",
		accepted_desc = "找到#<Y>艾格娅#",
		executed_desc = "战胜#<Y>艾格娅#",
	},

	[10500106] = {
		id = 10500106,
		type = 1,
		name = "初级战斗技能1",
		accept = {
			{ cmd = 'addnpc', args = { nid = 106015, }, },
			{ cmd = 'findnpc', args = { nid = 106015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1061, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500105},
		ratio = 1,
		award = 10500106,
		nexttask = "10500107",
		chapterid = 0,
		icon_id = 0,
		desc = "战斗技能的学习是勇者们冒险中非常重要的一部分,仔细听听艾格娅怎么说吧。",
		accepted_desc = "找到#<Y>艾格娅#",
		executed_desc = "与#<Y>艾格娅#对话",
	},

	[10500107] = {
		id = 10500107,
		type = 3,
		name = "实战演练",
		accept = {
			{ cmd = 'addnpc', args = { nid = 107015, }, },
			{ cmd = 'findnpc', args = { nid = 107015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100103, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500106},
		ratio = 1,
		award = 10500107,
		nexttask = "10500108",
		chapterid = 0,
		icon_id = 0,
		desc = "在实战中演戏是学习技能最有效的方式,那么请勇者大人试一试吧。",
		accepted_desc = "找到#<Y>艾格娅#",
		executed_desc = "战胜#<Y>艾格娅#",
	},

	[10500108] = {
		id = 10500108,
		type = 1,
		name = "初级战斗技能2",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 108015,108025 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1081, }, },
			{ cmd = 'findnpc', args = { nid = 108025, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1082, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500107},
		ratio = 1,
		award = 10500108,
		nexttask = "10500109",
		chapterid = 0,
		icon_id = 0,
		desc = "根据艾格娅的指引,到莱伦处学习技能2。听说莱伦大人以前也是非常优秀的用着呢。",
		accepted_desc = "找到#<Y>莱伦#",
		executed_desc = "与#<Y>莱伦#对话",
	},

	[10500109] = {
		id = 10500109,
		type = 3,
		name = "实战演练",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 109015,109025 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 109025, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100104, }, },
			{ cmd = 'talkto', args = { textid = 1092, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 109015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500108},
		ratio = 1,
		award = 10500109,
		nexttask = "10500110",
		chapterid = 0,
		icon_id = 0,
		desc = "战胜莱伦的帮手缔诺,在实战中体验技能2的力量。",
		accepted_desc = "击败#<Y>缔诺#",
		executed_desc = "与#<Y>莱伦#对话",
	},

	[10500110] = {
		id = 10500110,
		type = 1,
		name = "初级战斗技能3",
		accept = {
			{ cmd = 'addnpc', args = { nid = 110015, }, },
			{ cmd = 'findnpc', args = { nid = 110015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1101, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500109},
		ratio = 1,
		award = 10500110,
		nexttask = "10500111",
		chapterid = 0,
		icon_id = 0,
		desc = "前往布洛姆处,向他学习技能3。",
		accepted_desc = "找到#<Y>布洛姆#",
		executed_desc = "与#<Y>布洛姆#对话",
	},

	[10500111] = {
		id = 10500111,
		type = 3,
		name = "实战演练",
		accept = {
			{ cmd = 'addnpc', args = { nid = 111015, }, },
			{ cmd = 'findnpc', args = { nid = 111015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100105, }, },
			{ cmd = 'talkto', args = { textid = 1112, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500110},
		ratio = 1,
		award = 10500111,
		nexttask = "10500112",
		chapterid = 0,
		icon_id = 0,
		desc = "战胜布洛姆,在实战中体验技能3的力量。",
		accepted_desc = "战胜#<Y>布洛姆#",
		executed_desc = "与#<Y>布洛姆#对话",
	},

	[10500112] = {
		id = 10500112,
		type = 1,
		name = "初级战斗技能4",
		accept = {
			{ cmd = 'addnpc', args = { nid = 112015, }, },
			{ cmd = 'findnpc', args = { nid = 112015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1121, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 112015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500111},
		ratio = 1,
		award = 10500112,
		nexttask = "10500113",
		chapterid = 0,
		icon_id = 0,
		desc = "前往赫塞尔处,向他学习技能4。",
		accepted_desc = "找到#<Y>赫塞尔#",
		executed_desc = "与#<Y>赫塞尔#对话",
	},

	[10500113] = {
		id = 10500113,
		type = 3,
		name = "实战演练",
		accept = {
			{ cmd = 'addnpc', args = { nid = 113015, }, },
			{ cmd = 'findnpc', args = { nid = 113015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100106, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500112},
		ratio = 1,
		award = 10500113,
		nexttask = "10500114",
		chapterid = 0,
		icon_id = 0,
		desc = "战胜赫塞尔,在实战中体验技能4的力量。",
		accepted_desc = "找到#<Y>赫塞尔#",
		executed_desc = "战胜#<Y>赫塞尔#",
	},

	[10500114] = {
		id = 10500114,
		type = 5,
		name = "撒克里",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 114015,114025 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1141, }, },
			{ cmd = 'setcollect', args = { posid = 21001001,  name = "叙述事情经过", }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1142, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500113},
		ratio = 1,
		award = 10500114,
		nexttask = "10500115",
		chapterid = 0,
		icon_id = 0,
		desc = "赫塞尔有礼物要送给勇者大人呢！不知道是怎样的礼物呢,真是让人期待啊！不过在这之前,还要先找到一个叫做撒克里的男人,真是麻烦啊。",
		accepted_desc = "找到#<Y>撒克里#",
		executed_desc = "与#<Y>撒克里#对话",
	},

	[10500115] = {
		id = 10500115,
		type = 3,
		name = "撒克里的考验",
		accept = {
			{ cmd = 'addnpc', args = { nid = 115015, }, },
			{ cmd = 'findnpc', args = { nid = 115015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100107, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500114},
		ratio = 1,
		award = 10500115,
		nexttask = "10500116",
		chapterid = 0,
		icon_id = 0,
		desc = "接受撒克里的考验,真正的勇者是不怕任何艰险的！呃,不过作为大祭司首席护法的撒克里似乎不怎么好对付呢。请勇者大人将学到的本领通通展现出来吧。",
		accepted_desc = "找到#<Y>撒克里#",
		executed_desc = "战胜#<Y>撒克里#",
	},

	[10500116] = {
		id = 10500116,
		type = 1,
		name = "忠诚的伙伴",
		accept = {
			{ cmd = 'addnpc', args = { nid = 116015, }, },
			{ cmd = 'findnpc', args = { nid = 116015, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1161, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 116015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500115},
		ratio = 1,
		award = 10500116,
		nexttask = "10500117",
		chapterid = 0,
		icon_id = 0,
		desc = "哈~赫塞尔所说的礼物原来是一只可爱的宠物！不过可别小看它,在未来的战斗中,它也是勇者大人重要的伙伴哦~",
		accepted_desc = "与#<Y>撒克里对话#",
		executed_desc = "nil",
	},

	[10500117] = {
		id = 10500117,
		type = 1,
		name = "宠物出战",
		accept = {
			{ cmd = 'addnpc', args = { nid = 117015, }, },
			{ cmd = 'findnpc', args = { nid = 117015, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1171, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500116},
		ratio = 1,
		award = 10500117,
		nexttask = "10500118",
		chapterid = 0,
		icon_id = 0,
		desc = "根据撒克里的指引,召唤宠物出战。",
		accepted_desc = "进行#<Y>宠物出战#操作",
		executed_desc = "#<Y>#",
	},

	[10500118] = {
		id = 10500118,
		type = 3,
		name = "与主人并肩",
		accept = {
			{ cmd = 'addnpc', args = { nid = 118015, }, },
			{ cmd = 'findnpc', args = { nid = 118015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100108, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500117},
		ratio = 1,
		award = 10500118,
		nexttask = "10500119",
		chapterid = 0,
		icon_id = 0,
		desc = "在战斗中宠物是勇者大人可靠地帮手,至于它的实力,嘿嘿,请勇者大人亲自感受一下吧！",
		accepted_desc = "找到#<Y>撒克里#",
		executed_desc = "战胜#<Y>撒克里#",
	},

	[10500119] = {
		id = 10500119,
		type = 1,
		name = "战略换位",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 119015,119025 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1191, }, },
			{ cmd = 'findnpc', args = { nid = 119025, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1192, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 119015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500118},
		ratio = 1,
		award = 10500119,
		nexttask = "10500120",
		chapterid = 0,
		icon_id = 0,
		desc = "按照撒克里的指示,前往丛林向隐居在那里的勇者前辈讨教吧,此行一定会有收获的。",
		accepted_desc = "找到#<Y>勇者前辈#",
		executed_desc = "与#<Y>勇者前辈#对话",
	},

	[10500120] = {
		id = 10500120,
		type = 3,
		name = "换位实战",
		accept = {
			{ cmd = 'addnpc', args = { nid = 120015, }, },
			{ cmd = 'talkto', args = { textid = 1201, }, },
			{ cmd = 'findnpc', args = { nid = 120015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100109, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500119},
		ratio = 1,
		award = 10500120,
		nexttask = "10500121",
		chapterid = 0,
		icon_id = 0,
		desc = "通过实战演练前辈传授的战斗技巧。",
		accepted_desc = "找到#<Y>勇者前辈#",
		executed_desc = "战胜#<Y>勇者前辈#",
	},

	[10500121] = {
		id = 10500121,
		type = 5,
		name = "前辈的嘱托",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 121015,121025 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1211, }, },
			{ cmd = 'setcollect', args = { posid = 21001002,  name = "叙述事情经过", }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1212, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500120},
		ratio = 1,
		award = 10500121,
		nexttask = "10500122",
		chapterid = 0,
		icon_id = 0,
		desc = "回到撒克里处向他汇报此行的收获,说起来,撒克里很器重勇者大人呢！",
		accepted_desc = "找到撒克里#<Y>#",
		executed_desc = "与#<Y>撒克里#对话",
	},

	[10500122] = {
		id = 10500122,
		type = 3,
		name = "学习成果",
		accept = {
			{ cmd = 'addnpc', args = { nid = 122015, }, },
			{ cmd = 'findnpc', args = { nid = 122015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100110, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500121},
		ratio = 1,
		award = 10500122,
		nexttask = "10500123",
		chapterid = 0,
		icon_id = 0,
		desc = "像撒克里展示学习的成果。",
		accepted_desc = "找到#<Y>撒克里#",
		executed_desc = "战胜#<Y>撒克里#",
	},

	[10500123] = {
		id = 10500123,
		type = 1,
		name = "职业简介",
		accept = {
			{ cmd = 'addnpc', args = { nid = 123015, }, },
			{ cmd = 'talkto', args = { textid = 1231, }, },
			{ cmd = 'findnpc', args = { nid = 20002006, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1232, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 20002006,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500122},
		ratio = 1,
		award = 10500123,
		nexttask = "10500124",
		chapterid = 0,
		icon_id = 0,
		desc = "根据撒克里的指引,到士长官约翰处了解转职相关事宜。",
		accepted_desc = "找到#<Y>士长官约翰#",
		executed_desc = "与#<Y>士长官约翰#对话",
	},

	[10500124] = {
		id = 10500124,
		type = 1,
		name = "职业测试",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20002006, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1241, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500123},
		ratio = 1,
		award = 10500124,
		nexttask = "10500125",
		chapterid = 0,
		icon_id = 0,
		desc = "进行选职测试。",
		accepted_desc = "填写#<Y>测试问卷#",
		executed_desc = "#<Y>#",
	},

	[10500125] = {
		id = 10500125,
		type = 1,
		name = "职业选择",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20002006, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1251, }, },
		},
		execution = {
			{ cmd = 'openui', args = { buttonid = 1010, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500124},
		ratio = 1,
		award = 10500125,
		nexttask = "10500126",
		chapterid = 0,
		icon_id = 0,
		desc = "选择职业。",
		accepted_desc = "#<Y>选择职业#",
		executed_desc = "#<Y>#",
	},

	[10500126] = {
		id = 10500126,
		type = 3,
		name = "实战演练",
		accept = {
			{ cmd = 'addnpc', args = { nid = 126025, }, },
			{ cmd = 'talkto', args = { textid = 1261, }, },
			{ cmd = 'findnpc', args = { nid = 126025, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100111, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500125},
		ratio = 1,
		award = 10500126,
		nexttask = "10500127",
		chapterid = 0,
		icon_id = 0,
		desc = "相信勇者大人已经知道不同职业各自发挥着不同的作用,现在请在实战中体会一下吧。",
		accepted_desc = "与#<Y>士长官约翰#对话",
		executed_desc = "战胜#<Y>约翰助理#",
	},

	[10500127] = {
		id = 10500127,
		type = 1,
		name = "新的技能",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20002006, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1271, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500126},
		ratio = 1,
		award = 10500127,
		nexttask = "10500128",
		chapterid = 0,
		icon_id = 0,
		desc = "根据职业测评师的指导,学习新的职业技能。",
		accepted_desc = "找到#<Y>士长官约翰#",
		executed_desc = "与#<Y>士长官约翰#对话",
	},

	[10500128] = {
		id = 10500128,
		type = 3,
		name = "实战演练",
		accept = {
			{ cmd = 'addnpc', args = { nid = 128025, }, },
			{ cmd = 'findnpc', args = { nid = 128025, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100112, }, },
			{ cmd = 'talkto', args = { textid = 1282, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 20002006,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500127},
		ratio = 1,
		award = 10500128,
		nexttask = "10500129",
		chapterid = 0,
		icon_id = 0,
		desc = "在战斗中运用并掌握新技能的使用方法。",
		accepted_desc = "战胜#<Y>约翰助理#",
		executed_desc = "与#<Y>是脏官约翰#对话",
	},

	[10500129] = {
		id = 10500129,
		type = 1,
		name = "自我修养",
		accept = {
			{ cmd = 'addnpc', args = { nid = 129015, }, },
			{ cmd = 'findnpc', args = { nid = 129015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1291, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 129015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500128},
		ratio = 1,
		award = 10500129,
		nexttask = "10500130",
		chapterid = 0,
		icon_id = 0,
		desc = "根据米利暗大人的指引进行配点。",
		accepted_desc = "找到#<Y>米利暗#",
		executed_desc = "与#<Y>米利暗#对话",
	},

	[10500130] = {
		id = 10500130,
		type = 3,
		name = "实战演练",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 130015,130025 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1301, }, },
			{ cmd = 'findnpc', args = { nid = 130025, respond = 0, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100113, }, },
			{ cmd = 'talkto', args = { textid = 1302, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 130015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500129},
		ratio = 1,
		award = 10500130,
		nexttask = "10500131",
		chapterid = 0,
		icon_id = 0,
		desc = "战胜艾格娅,感受与之前的区别。",
		accepted_desc = "与#<Y>米利暗#对话",
		executed_desc = "战胜#<Y>艾格娅#",
	},

	[10500131] = {
		id = 10500131,
		type = 1,
		name = "登记命名",
		accept = {
			{ cmd = 'addnpc', args = { nid = 131015, }, },
			{ cmd = 'findnpc', args = { nid = 131015, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1311, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500130},
		ratio = 1,
		award = 10500131,
		nexttask = "10500132",
		chapterid = 0,
		icon_id = 0,
		desc = "勇者大人在登记处进行登记后就是迦南王国的认证勇者啦！快去找登记官吧。",
		accepted_desc = "#<Y>给角色命名#",
		executed_desc = "#<Y>#",
	},

	[10500132] = {
		id = 10500132,
		type = 4,
		name = "粗心的勇者",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 132015,132025 }, both = 1, }, },
			{ cmd = 'talkto', args = { textid = 1321, }, },
			{ cmd = 'setpatrol', args = { posid = 21001003, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100114, }, },
			{ cmd = 'talkto', args = { textid = 1322, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 132025,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500131},
		ratio = 1,
		award = 10500132,
		nexttask = "10500133",
		chapterid = 0,
		icon_id = 0,
		desc = "登记官遇到麻烦了呢,请大人帮他把那位粗心的勇者请回来吧~",
		accepted_desc = "找到并战胜#<Y>粗心勇者#",
		executed_desc = "与#<Y>粗心勇者对话#",
	},

	[10500133] = {
		id = 10500133,
		type = 1,
		name = "寻找战友",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 133015,133025 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 133015, respond = 0, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 1331, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 133015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500132},
		ratio = 1,
		award = 10500133,
		nexttask = "10500134",
		chapterid = 0,
		icon_id = 0,
		desc = "“冒险从来不是一个人的故事”,在踏上冒险之旅之前,先结识一些可靠的朋友吧！",
		accepted_desc = "与#<Y>登记官#对话",
		executed_desc = "#<Y>#",
	},

	[10500134] = {
		id = 10500134,
		type = 3,
		name = "战斗吧勇者",
		accept = {
			{ cmd = 'addnpc', args = { nid = { 134015,134025 }, both = 1, }, },
			{ cmd = 'findnpc', args = { nid = 134025, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1341, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = 100115, }, },
			{ cmd = 'talkto', args = { textid = 1342, }, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 134015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500133},
		ratio = 1,
		award = 10500134,
		nexttask = "10500135",
		chapterid = 0,
		icon_id = 0,
		desc = "王都发生的不小的骚动,许多勇者大人们都参与到了战斗当中,千万当心啊！",
		accepted_desc = "战胜#<Y>阴影巨魔#",
		executed_desc = "与#<Y>伊菲#对话",
	},

	[10500135] = {
		id = 10500135,
		type = 1,
		name = "新的旅程",
		accept = {
			{ cmd = 'addnpc', args = { nid = 135015, }, },
			{ cmd = 'findnpc', args = { nid = 135015, respond = 0, }, },
			{ cmd = 'talkto', args = { textid = 1351, }, },
		},
		execution = {

		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 135015,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500134},
		ratio = 1,
		award = 10500135,
		nexttask = "10000101",
		chapterid = 0,
		icon_id = 0,
		desc = "如此恶劣的事情绝对不能姑息！一定要告诉米利暗大人才行。",
		accepted_desc = "找到#<Y>米利暗#",
		executed_desc = "#<Y>#",
	},

	[10500201] = {
		id = 10500201,
		type = 1,
		name = "协会任务指引",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001001, respond = 1, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 2012, }, },
		},
		finishbyclient = 1,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500115},
		ratio = 1,
		award = 10500201,
		nexttask = "10500202",
		chapterid = 0,
		icon_id = 0,
		desc = "根据任务指引前往#<Y>协会公告板#处",
		accepted_desc = "前往#<Y>协会公告板#处",
		executed_desc = "提交任务",
	},

	[10500202] = {
		id = 10500202,
		type = 1,
		name = "协会任务指引",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001001, respond = 1, }, },
		},
		execution = {

		},
		finishbyclient = 1,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 10,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500201},
		ratio = 1,
		award = 10500202,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 0,
		desc = "根据任务指引前往#<Y>协会公告板#处",
		accepted_desc = "完成一次#<Y>协会请援#任务",
		executed_desc = "提交任务",
	},

	[10500203] = {
		id = 10500203,
		type = 1,
		name = "使魔任务指引",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001002, respond = 1, }, },
		},
		execution = {
			{ cmd = 'talkto', args = { textid = 2022, }, },
		},
		finishbyclient = 1,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 15,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500202},
		ratio = 1,
		award = 10500203,
		nexttask = "10500204",
		chapterid = 0,
		icon_id = 0,
		desc = "根据任务指引前往#<Y>猎魔人#处",
		accepted_desc = "与#<Y>猎魔人#对话",
		executed_desc = "提交任务",
	},

	[10500204] = {
		id = 10500204,
		type = 1,
		name = "使魔任务指引",
		accept = {
			{ cmd = 'findnpc', args = { nid = 20001002, respond = 1, }, },
		},
		execution = {

		},
		finishbyclient = 1,
		autoexec = 0,
		acceptnpc = 0,
		submitnpc = 0,
		recommendteam = 3,
		cangiveup = 0,
		needlv = 15,
		needjob = {nil},
		exceedtime = "nil",
		pretask = {10500203},
		ratio = 1,
		award = 10500204,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 0,
		desc = "根据任务指引前往#<Y>猎魔人#处",
		accepted_desc = "完成一次#<Y>使魔试炼#任务",
		executed_desc = "提交任务",
	},

}
return data_1500_ZhiyinTaskProcess
--<<data_1500_ZhiyinTaskProcess 导表结束>>