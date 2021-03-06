--<<data_1800_UnionVar 导表开始>>
data_1800_UnionVar = {

	CreateUnionCostGold = 1000, 		-- 创建公会消耗的金币

	NoticeMaxChar = 30, 		-- 公告最大字符数

	PurposeMaxChar = 30, 		-- 宗旨最大字符数

	PublishPurposeCost = {money=30,items={type=601001,num=1}}, 		-- 发布公告消耗资金+公会物品

	ApplyerMaxLimit = 30, 		-- 申请列表最大人数

	JoinUnoinCDAfterQuit = 72000, 		-- 20小时(XXX秒)

	ChangeNameCostGold = 500, 		-- 改名消耗金币

	PublishNoticeCD = 5, 		-- 发布公告CD

	RunForLeaderVoteTime = 2, 		-- 竞选会长投票持续天数

	RunForLeaderCD = 7, 		-- 竞选会长CD天数

	RunForLeaderNeedLogoffTime = 5, 		-- 需要会长离线超过多少天才能竞选会长

	FuliExpFormula = "baseexp * playerlv * cangku_addn * job_addn", 		-- 每周福利经验奖励公司(baseexp--基本经验,playerlv--玩家等级,cangku_addn--仓库加成,job_addn--公会职位加成）

	UnionShopRefreshNum = {[0]=10,[1]=12,[2]=14,[3]=16,[4]=18,[5]=20}, 		-- 公会商店刷出物品数量

	QuitUnionCDNeedLv = 25, 		-- 大于/等于指定等级的玩家退出公会玩家才有申请公会CD

	DonateCardMaxNum = 50, 		-- 本周最多捐献卡片数

	DonateCardMaxNumPerSession = 4, 		-- 捐献给同一次集卡最大数量

	CollectCardCD = 32400, 		-- 收集卡片后的CD,秒为单位

	CollectCardSumCnt = 10, 		-- 本周收集卡片最大次数

	HighLevelCardMulti = 3, 		-- 捐献高级相当于多少个低级卡片捐献数量

	CollectCardMaxNumPerTime = {[1]=3,[2]=5}, 		-- 单次收集卡片数量上限,格式：{[卡片品质]=数量上限,}

	CollectCardLifeTime = 28800, 		-- 收集卡片持续时间,秒为单位

	CollectCardNeedUnionLv = 2, 		-- 收集卡片需要的公会等级

	CollectCardCostOffer = {[1]=100,[2]=200}, 		-- 集卡消耗的帮贡,格式:{[卡片品质]=消耗的公会贡献}

	DonateCardAddOffer = {[1]=100,[2]=200}, 		-- 捐献卡片获得帮贡,格式:{[卡片品质]=消耗的公会贡献}

	StudentLv = 30, 		-- 低于此等级,表示可以成为公会学徒

	OldHandLv = 50, 		-- 高于此等级,表示可以领取公会学徒毕业后发放的礼物

	StudentNeedUnionLv = 2, 		-- 开放公会学徒的公会等级

	BuyGiftThinkDay = 7, 		-- 毕业后购买礼物思考时间,天为单位

	GetGiftThinkDay = 7, 		-- 领取礼物思考时间,天为单位

	BuyGiftNeedGold = 60, 		-- 购买礼物需要的金币

	GraduateGiftCostMoney = 1000, 		-- 领取毕业礼包消耗的公会资金

	CollectItemAskForHelpMaxCnt = 3, 		-- 公会收集：最大求助次数

	CollectItemDonateMaxCnt = 5, 		-- 公会收集：最大捐献次数

	UnionNameMaxLen = 6, 		-- 公会名字最长字符个数

	ChangeBadgeCostGold = 500, 		-- 修改公会会长消耗金币

}
return data_1800_UnionVar
--<<data_1800_UnionVar 导表结束>>