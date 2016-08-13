-- war
NOWAR						= 0
INWAR						= 1

WARTYPE = {}

local function addwartype(name,val)
	WARTYPE[name] = val
	WARTYPE[val] = name
end

addwartype("PVP_QIECUO",1)					-- 切磋
addwartype("PVE_PERSONAL_TASK",2)			-- 单人任务
addwartype("PVE_CHAPTER",3)					-- 关卡任务
addwartype("PVE_BAOTU",4)					-- 宝图
addwartype("PVE_GUAJI",5)					-- 挂机

addwartype("PVE_SHARE_TASK",6)				-- 多人共享任务战斗（战斗结束后，所有有相同任务的人都能完成)
addwartype("PVE_TEST",1000)					-- 测试战斗
