local data_0103_Monster_2 = {
	[500015] = {
		name = "支线", dir = 5, lvt = 0, lv = 1, kind = 1, ATTACKTYPE = 1, RACE = 2, HP = 16, WUGONG = 4, WUFANG = 2, FAGONG = 4, FAFANG = 2, SP = 2, MP = 10, HUIFUMP = 1, FASHUSP = 2, PACC = 0.5, WLDS = 0.5, WLBJ = 0, HUIFUHP = 0, RENXING = 0, stage1_hp = 1, stage1_shape = 10001, stage1_skill = 0, stage2_hp = 0.5, stage2_shape = 10002, stage2_skill = 0, stage3_hp = 0, stage3_shape = 0, stage3_skill = 0, 	},

}

if data_0103_Monster == nil then data_0103_Monster = {} end
for k,v in pairs(data_0103_Monster_2) do
    data_0103_Monster[k] = v
end
return 1