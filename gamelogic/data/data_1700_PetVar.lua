--<<data_1700_PetVar 导表开始>>
data_1700_PetVar = {

	PetFeedFoods = {1102061,1102062,1102063,1102064,1102065,1102066,1102067,1102068,1102069,1102070}, 		-- 可以喂养宠物的食物类型

	OptimalFeedCnt = 5, 		-- 每天最优喂养次数,小于或等于该次数时效果翻倍

	FeedAddClose = 10, 		-- 单次喂养增加的亲密度

	NormalTrainItem = {item=1102091,num=1}, 		-- 普通宠物训练物品

	RareTrainItem = {item=1102091,num=2}, 		-- 稀有宠物训练物品

	HolyTrainItem = {item=1102091,num=3}, 		-- 魔神宠物训练物品

	NormalSkillForgetCost = 50, 		-- 遗忘普通技能消耗的亲密度

	RareSkillForgetCost = 100, 		-- 遗忘稀有技能消耗的亲密度

	EpicSkillForgetCost = 150, 		-- 遗忘史诗技能消耗的亲密度

	LegendSkillForgetCost = 200, 		-- 遗忘传说技能消耗的亲密度

	CombineSkillMinRatio = 0.6, 		-- 宠物合成时副宠技能数参数

	CombineSkillMaxRatio = 0.8, 		-- 宠物合成时副宠技能数参数

	NormalFix = 0, 		-- 品阶修正

	RareFix = 0.95, 		-- 

	HolyFix = 1.45, 		-- 

}
return data_1700_PetVar
--<<data_1700_PetVar 导表结束>>