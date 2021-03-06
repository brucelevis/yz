--<<data_GlobalVar 导表开始>>
data_GlobalVar = {

	ResetDexpPoint = 800, 		-- 每周5点重置的双倍经验点

	MaxLv = 100, 		-- 最大等级

	MaxSrvLv = 100, 		-- 最大服务器等级

	MaxJobZs = 3, 		-- 最大职业转数

	CostHornNum = {[0]=1,[21]=2,[31]=3,[41]=4,[51]=5}, 		-- 消耗喇叭数量,格式{[使用次数]=消耗数量,}

	MaxHornMsgLen = 26, 		-- 喇叭消息长度

	NewRedPacketNeedLv = 15, 		-- 发放红包需要的等级

	MaxMsgLen = 50, 		-- 普通消息长度

	UnionNewRedPacketNeedDatingLv = 1, 		-- 发放公会红包需要的大厅等级

	RedPacketMinMoney = 1, 		-- 单个红包最低限额

	RedPacketMaxMoney = 1000000, 		-- 单个红包最高限额

}
return data_GlobalVar
--<<data_GlobalVar 导表结束>>