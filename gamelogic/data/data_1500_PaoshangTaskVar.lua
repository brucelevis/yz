--<<data_1500_PaoshangTaskVar 导表开始>>
data_1500_PaoshangTaskVar = {

	TodayDonelimit = 5, 		-- 每天最多能完成几次跑商任务

	TaskGoodsList = {10001,10002,10003,10004,10005,10006,10007,10008,10009,10010,}, 		-- 跑商任务的商品列表

	TaskGoodsMaxNum = 10, 		-- 跑商任务的商品列表内商品数

	TaskGoodsMinNum = 3, 		-- 从商品列表中抽取的商品数

	TaskDoneAward = {[5]=601013,[10]=601013,[25]=601013,}, 		-- 每周完成固定次数时的额外奖励

	Rule = "1、每天可以完成最多5次跑商任务。\n2、每周可以完成最多25次跑商任务。\n3、接受跑商任务后,找到并询问每位商人的出价,与出价最高的商人进行交易。\n4、交易额达标后,跑商任务完成。", 		-- 跑商规则,注意加英文的双引号。

}
return data_1500_PaoshangTaskVar
--<<data_1500_PaoshangTaskVar 导表结束>>