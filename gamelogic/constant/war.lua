-- war
NOWAR						= 0
INWAR						= 1

WARTYPE = {}

local function addwartype(name,val)
	WARTYPE[name] = val
	WARTYPE[val] = name
end

-- PVP:[1,100)  PVE:[100,1000)
addwartype("PVP_QIECUO",1)					-- 切磋
addwartype("PVP_ARENA_RANK",2)					-- 竞技场排行榜

addwartype("PVE_PERSONAL_TASK",100)			-- 单人任务
addwartype("PVE_CHAPTER",101)				-- 关卡任务
addwartype("PVE_BAOTU",102)					-- 宝图
addwartype("PVE_GUAJI",103)					-- 挂机
addwartype("PVE_SHARE_TASK",104)				-- 多人共享任务战斗（战斗结束后，所有有相同任务的人都能完成)

addwartype("PVE_TEST",1000)					-- 测试战斗
