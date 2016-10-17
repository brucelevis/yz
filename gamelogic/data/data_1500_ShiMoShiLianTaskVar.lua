--<<data_1500_ShiMoShiLianTaskVar 导表开始>>
data_1500_ShiMoShiLianTaskVar = {

	StartWarNeedNum = 2, 		-- 发起战斗至少需要的成员数

	StartWarNeedLv = 10, 		-- 发起战斗需要的等级

	LookNpcType = 20001002, 		-- 10环时需要跳转到的NPC类型

	GiveItemToMemberAt10Ring = {{type=409001,num=1},{type=409002,num=1},{type=409003,num=1},{type=409004,num=1},{type=409005,num=1},{type=409006,num=1},{type=409007,num=1},}, 		-- 10环给队员的物品

	GiveItemToCaptainAt10Ring = {type=801002,num=1}, 		-- 10环给队长的物品

	QuickFinishNeedLeftCnt = 20, 		-- 快速完成10环任务需要的剩余任务次数

	QuickFinishNeedItem = {type=601044,num=1}, 		-- 快速完成10环任务需要消耗的物品

}
return data_1500_ShiMoShiLianTaskVar
--<<data_1500_ShiMoShiLianTaskVar 导表结束>>