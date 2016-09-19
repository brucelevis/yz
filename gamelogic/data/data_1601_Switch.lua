--<<data_1601_Switch 导表开始>>
data_1601_Switch = {

	[1001] = {
		name = "gm",
		flag = "gm",
		default = 0,
		setbyclient = 0,
		mutex = {},
	},

	[1002] = {
		name = "加好友验证",
		flag = "friend",
		default = 0,
		setbyclient = 0,
		mutex = {},
	},

	[1003] = {
		name = "消耗双倍点",
		flag = "costdexp",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1004] = {
		name = "默认允许同意申请队长",
		flag = "team.agreetocaptain",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1100] = {
		name = "抓鬼",
		flag = "automatch.zhuagui",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1101] = {
		name = "宝图怪",
		flag = "automatch.baotu",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1102] = {
		name = "主线任务",
		flag = "automatch.zhuxian",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1103] = {
		name = "职业任务",
		flag = "automatch.zhiye",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1104] = {
		name = "单人PK",
		flag = "automatch.singlepk",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1105] = {
		name = "多人PK",
		flag = "automatch.multipk",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1106] = {
		name = "工会战",
		flag = "automatch.orgpk",
		default = 1,
		setbyclient = 1,
		mutex = {},
	},

	[1150] = {
		name = "默认站位",
		flag = "zhanwei.default",
		default = 1,
		setbyclient = 1,
		mutex = {1151,1152},
	},

	[1151] = {
		name = "前排站位",
		flag = "zhanwei.front",
		default = 0,
		setbyclient = 1,
		mutex = {1150,1152},
	},

	[1152] = {
		name = "后排站位",
		flag = "zhanwei.back",
		default = 0,
		setbyclient = 1,
		mutex = {1150,1151},
	},

	[1201] = {
		name = "频道选择#队伍频道",
		flag = "channel.listen.team",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1202] = {
		name = "频道选择#世界频道",
		flag = "channel.listen.world",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1203] = {
		name = "频道选择#公会频道",
		flag = "channel.listen.union",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1204] = {
		name = "频道选择#当前频道",
		flag = "channel.listen.scene",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1205] = {
		name = "频道选择#系统信息",
		flag = "channel.listen.sys",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1206] = {
		name = "自动播放语音#队伍频道",
		flag = "channel.playchat.team",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1207] = {
		name = "自动播放语音#世界频道",
		flag = "channel.playchat.world",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1208] = {
		name = "自动播放语音#公会频道",
		flag = "channel.playchat.union",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

	[1209] = {
		name = "自动播放语音#当前频道",
		flag = "channel.playchat.scene",
		default = 0,
		setbyclient = 1,
		mutex = {},
	},

}
return data_1601_Switch
--<<data_1601_Switch 导表结束>>