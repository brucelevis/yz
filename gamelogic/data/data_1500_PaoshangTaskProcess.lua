--<<data_1500_PaoshangTaskProcess 导表开始>>
data_1500_PaoshangTaskProcess = {

	[10700101] = {
		id = 10700101,
		type = 1,
		name = "公会跑商",
		accept = {
			{ cmd = 'findnpc', args = { nid = { 20003001,20003002,20003003,20003004 }, respond = 1, both = 1, }, },
		},
		execution = {
			{ cmd = 'paoshang', args = {}, },
		},
		finishbyclient = 0,
		autoexec = 0,
		acceptnpc = 20018001,
		submitnpc = 20018001,
		recommendteam = 3,
		cangiveup = 1,
		needlv = 15,
		needjob = {nil},
		exceedtime = "today",
		pretask = {nil},
		ratio = 1,
		award = -1,
		nexttask = "nil",
		chapterid = 0,
		icon_id = 0,
		desc = "代表#<Y>公会商人#与其他商人达成协议,为每件供货订单单找到出价最高的商人,若交易额低于预期目标则任务失败。",
		accepted_desc = "完成交易额",
		executed_desc = "回复#<Y>公会商人#",
	},

}
return data_1500_PaoshangTaskProcess
--<<data_1500_PaoshangTaskProcess 导表结束>>