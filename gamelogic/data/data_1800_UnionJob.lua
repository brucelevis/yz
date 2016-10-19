--<<data_1800_UnionJob 导表开始>>
data_1800_UnionJob = {

	[1] = {
		name = "会长",
		limit = 1,
		auth = {
			add = 1,
			del = 1,
			changejob = 1,
			banspeak = 1,
			edit_purpose = 1,
			edit_notice = 1,
			become_leader = 1,
			changename = 1,
			changebadge = 1,
			upgrade_build = 1,
			open_huodong = 1,
			open_fuli = 1,
		},
	},

	[2] = {
		name = "副会长",
		limit = 3,
		auth = {
			add = 1,
			del = 1,
			changejob = 1,
			banspeak = 1,
			edit_purpose = 1,
			edit_notice = 1,
			become_leader = 1,
			changename = 0,
			changebadge = 0,
			upgrade_build = 0,
			open_huodong = 1,
			open_fuli = 1,
		},
	},

	[3] = {
		name = "干部",
		limit = 6,
		auth = {
			add = 1,
			del = 1,
			changejob = 0,
			banspeak = 0,
			edit_purpose = 0,
			edit_notice = 0,
			become_leader = 0,
			changename = 0,
			changebadge = 0,
			upgrade_build = 0,
			open_huodong = 0,
			open_fuli = 0,
		},
	},

	[4] = {
		name = "管事",
		limit = 9,
		auth = {
			add = 1,
			del = 1,
			changejob = 0,
			banspeak = 0,
			edit_purpose = 0,
			edit_notice = 0,
			become_leader = 0,
			changename = 0,
			changebadge = 0,
			upgrade_build = 0,
			open_huodong = 0,
			open_fuli = 0,
		},
	},

	[5] = {
		name = "精英",
		limit = 21,
		auth = {
			add = 0,
			del = 1,
			changejob = 0,
			banspeak = 0,
			edit_purpose = 0,
			edit_notice = 0,
			become_leader = 0,
			changename = 0,
			changebadge = 0,
			upgrade_build = 0,
			open_huodong = 0,
			open_fuli = 0,
		},
	},

	[6] = {
		name = "会员",
		limit = -1,
		auth = {
			add = 0,
			del = 1,
			changejob = 0,
			banspeak = 0,
			edit_purpose = 0,
			edit_notice = 0,
			become_leader = 0,
			changename = 0,
			changebadge = 0,
			upgrade_build = 0,
			open_huodong = 0,
			open_fuli = 0,
		},
	},

}
return data_1800_UnionJob
--<<data_1800_UnionJob 导表结束>>