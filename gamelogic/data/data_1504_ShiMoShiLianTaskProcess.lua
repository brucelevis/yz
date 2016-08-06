--<<data_1504_ShiMoShiLianTaskProcess 导表开始>>
data_1504_ShiMoShiLianTaskProcess = {

	[10000102] = {
		type = 3,
		name = "战斗测试1",
		accept = {
			{ cmd = 'addnpc', args = { nid = 1003, }, },
		},
		execution = {
			{ cmd = 'raisewar', args = { warid = -1, }, },
		},
		finishbyclient = 0,
		acceptnpc = 0,
		submitnpc = 1003,
		cangiveup = 0,
		needlv = 0,
		needjob = {nil},
		exceedtime = nil,
		pretask = {nil},
		ratio = 1,
		award = -1,
		nexttask = 10000102,
		chapterid = 10001,
		icon_id = 0,
		desc = "战斗测试1",
		accepted_desc = "消灭怪物1",
		executed_desc = "回去交任务",
	},

}
return data_1504_ShiMoShiLianTaskProcess
--<<data_1504_ShiMoShiLianTaskProcess 导表结束>>