local data_0103_Monster_1 = {
	[500011] = {
		name = "高速度近战", dir = 5, lvt = 1, lv = 1, kind = 1, ATTACKTYPE = 1, HP = 100, WUGONG = 1, WUFANG = 100, FAGONG = 4, FAFANG = 2, SP = 1000, MP = 10, HUIFUMP = 1, FASHUSP = 2, PACC = 0.5, WLDS = 0.5, WLBJ = 0, HUIFUHP = 0, RENXING = 0, stage1_hp = 1, stage1_shape = 10000, stage1_skill = 0, stage2_hp = 0, stage2_shape = 0, stage2_skill = 0, stage3_hp = 0, stage3_shape = 0, stage3_skill = 0, 	},

	[500012] = {
		name = "远攻1", dir = 5, lvt = 1, lv = 1, kind = 1, ATTACKTYPE = 2, HP = 16, WUGONG = 4, WUFANG = 2, FAGONG = 4, FAFANG = 2, SP = 15, MP = 10, HUIFUMP = 1, FASHUSP = 2, PACC = 0.5, WLDS = 0.5, WLBJ = 0, HUIFUHP = 0, RENXING = 0, stage1_hp = 1, stage1_shape = 10000, stage1_skill = 0, stage2_hp = 0, stage2_shape = 0, stage2_skill = 0, stage3_hp = 0, stage3_shape = 0, stage3_skill = 0, 	},

	[500013] = {
		name = "近战2", dir = 5, lvt = 2, lv = 1, kind = 1, ATTACKTYPE = 1, HP = 16, WUGONG = 4, WUFANG = 2, FAGONG = 4, FAFANG = 2, SP = 20, MP = 10, HUIFUMP = 1, FASHUSP = 2, PACC = 0.5, WLDS = 0.5, WLBJ = 0, HUIFUHP = 0, RENXING = 0, stage1_hp = 1, stage1_shape = 10000, stage1_skill = 0, stage2_hp = 0, stage2_shape = 0, stage2_skill = 0, stage3_hp = 0, stage3_shape = 0, stage3_skill = 0, 	},

	[500014] = {
		name = "巴比伦王", dir = 5, lvt = 2, lv = 1, kind = 3, ATTACKTYPE = 1, HP = 16, WUGONG = 4, WUFANG = 2, FAGONG = 4, FAFANG = 2, SP = 2, MP = 10, HUIFUMP = 1, FASHUSP = 2, PACC = 0.5, WLDS = 0.5, WLBJ = 0, HUIFUHP = 0, RENXING = 0, stage1_hp = 1, stage1_shape = 10001, stage1_skill = 0, stage2_hp = 0.5, stage2_shape = 10002, stage2_skill = 0, stage3_hp = 0, stage3_shape = 0, stage3_skill = 0, 	},

	[500016] = {
		name = "低速高血近战", dir = 5, lvt = 2, lv = 1, kind = 1, ATTACKTYPE = 1, HP = 1000, WUGONG = 5, WUFANG = 1, FAGONG = 4, FAFANG = 2, SP = 1, MP = 10, HUIFUMP = 1, FASHUSP = 2, PACC = 100, WLDS = 0.5, WLBJ = 0, HUIFUHP = 0, RENXING = 0, stage1_hp = 1, stage1_shape = 10000, stage1_skill = 0, stage2_hp = 0, stage2_shape = 0, stage2_skill = 0, stage3_hp = 0, stage3_shape = 0, stage3_skill = 0, 	},

	[500017] = {
		name = "低速高血远攻", dir = 5, lvt = 2, lv = 1, kind = 1, ATTACKTYPE = 2, HP = 1000, WUGONG = 5, WUFANG = 1, FAGONG = 4, FAFANG = 2, SP = 1, MP = 10, HUIFUMP = 1, FASHUSP = 2, PACC = 100, WLDS = 0.5, WLBJ = 0, HUIFUHP = 0, RENXING = 0, stage1_hp = 1, stage1_shape = 10000, stage1_skill = 0, stage2_hp = 0, stage2_shape = 0, stage2_skill = 0, stage3_hp = 0, stage3_shape = 0, stage3_skill = 0, 	},

}

if data_0103_Monster == nil then data_0103_Monster = {} end
for k,v in pairs(data_0103_Monster_1) do
    data_0103_Monster[k] = v
end
return 1