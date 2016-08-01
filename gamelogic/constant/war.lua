-- war
NOWAR						= 0
INWAR						= 1

WARTYPE = {}

local function addwartype(name,val)
	WARTYPE[name] = val
	WARTYPE[val] = name
end

addwartype("PVP_QIECUO",1)				-- 切磋
addwartype("PERSONAL_TASK",2)			-- 单人任务
addwartype("PVE_CHAPTER",3)				-- 关卡任务
addwartype("PVE_BAOTU",4)				-- 宝图
addwartype("PVE_GUAJI",5)				-- 挂机
