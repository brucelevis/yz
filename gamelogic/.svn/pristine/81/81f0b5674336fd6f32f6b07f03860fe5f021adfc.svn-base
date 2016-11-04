require "gamelogic.item.item"
require "gamelogic.item.itemdb"
require "gamelogic.item.use.drag"
require "gamelogic.item.suitequip"

ItemMainType = {
	EQUIP = 1,				-- 装备
	FASHION_SHOW = 2,		-- 时装
	CARD = 3,				-- 卡片
	MATERIAL = 4,			-- 材料
	DRUG = 5,				-- 药品
	COSTITEM = 6,			-- 消耗品
	TASKITEM = 7,			-- 任务物品
	TREASURE_BOX = 8,		-- 宝箱
}

ItemQuality = {
	GREEE = 1,		-- 绿
	BLUE = 2,		-- 蓝
	PURPLE = 3,		-- 紫
	ORANGE = 4,		-- 橙 
}

function getitemdata(itemtype)
	local maintype = getmaintype(itemtype)
	if maintype == ItemMainType.EQUIP then
	elseif maintype == ItemMainType.FASHION_SHOW then
	elseif maintype == ItemMainType.CARD then
	elseif maintype == ItemMainType.MATERIAL then
		return data_0401_ItemMeterial[itemtype]
	elseif maintype == ItemMainType.DRUG then
		return data_0401_ItemDrug[itemtype]
	elseif maintype == ItemMainType.COSTITEM then
	elseif maintype == ItemMainType.TASKITEM then
	elseif maintype == ItemMainType.TREASURE_BOX then
	else
		error("Unknow MainType Item:" .. tostring(itemtype))
	end
end

-- 物品主类别
function getmaintype(itemtype)
	local typ = math.floor(itemtype/100000)
	return typ
end

-- 物品子类别
function getminortype(itemtype)
	itemtype = itemtype - getmaintype(itemtype) * 100000
	return math.floor(itemtype/1000)
end
