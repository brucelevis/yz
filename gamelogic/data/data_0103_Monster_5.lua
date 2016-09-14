local data_0103_Monster_5 = {
	[500104] = {
		name = "使魔", dir = 5, lvt = 0, lv = 1, kind = 1, ATTACKTYPE = 1, RACE = 2, HP = 68, WUGONG = 17, WUFANG = 8.5, FAGONG = 17, FAFANG = 8.5, SP = 3.5, MP = 37.5, HUIFUMP = 0, FASHUSP = 3.5, PACC = 51.75, WLDS = 51.75, WLBJ = 0, HUIFUHP = 0, RENXING = 10, stage1_hp = 1, stage1_shape = 10004, stage1_skill = 0, stage2_hp = 4, stage2_shape = 4, stage2_skill = 4, stage3_hp = 4, stage3_shape = 4, stage3_skill = 4, 	},

}

if data_0103_Monster == nil then data_0103_Monster = {} end
for k,v in pairs(data_0103_Monster_5) do
    data_0103_Monster[k] = v
end
return 1