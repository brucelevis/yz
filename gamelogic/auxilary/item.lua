-- 物品辅助函数
itemaux = itemaux or {}

ItemMainType = {
	EQUIP = 1,				-- 装备
	FASHION_SHOW = 2,		-- 时装
	CARD = 3,				-- 卡片
	MATERIAL = 4,			-- 材料
	DRUG = 5,				-- 药品
	CONSUME = 6,			-- 消耗品
	TASKITEM = 7,			-- 任务物品
	TREASURE_BOX = 8,		-- 宝箱
	PETEQUIP = 9,			-- 宠物装备
	UNION = 10,				-- 公会物品
	PETCONSUME = 11,		-- 宠物消耗品
}

ItemQuality = {
	GREEE = 1,		-- 绿
	BLUE = 2,		-- 蓝
	PURPLE = 3,		-- 紫
	ORANGE = 4,		-- 橙 
}

function itemaux.getitemdata(itemtype)
	local maintype = itemaux.getmaintype(itemtype)
	if maintype == ItemMainType.EQUIP then
		for i,itemtable in ipairs({
			data_0501_ItemHat,
			data_0501_ItemWeapon,
			data_0501_ItemNecklace,
			data_0501_ItemCloth,
			data_0501_ItemCloak,
			data_0501_ItemShield,
			data_0501_ItemShoe,
			data_0501_ItemRing}) do
			local itemdata = itemtable[itemtype]
			if itemdata then
				return itemdata
			end
		end
	elseif maintype == ItemMainType.FASHION_SHOW then
	elseif maintype == ItemMainType.CARD then
		return data_0501_ItemCard[itemtype]
	elseif maintype == ItemMainType.MATERIAL then
		return data_0501_ItemMaterial[itemtype]
	elseif maintype == ItemMainType.DRUG then
		return data_0501_ItemDrug[itemtype]
	elseif maintype == ItemMainType.CONSUME then
		return data_0501_ItemConsume[itemtype]
	elseif maintype == ItemMainType.TASKITEM then
	elseif maintype == ItemMainType.TREASURE_BOX then
		return data_0501_ItemBox[itemtype]
	elseif maintype == ItemMainType.UNION then
		return data_0501_ItemUnion[itemtype]
	elseif maintype == ItemMainType.PETEQUIP then
		return data_0501_ItemPetEquip[itemtype]
	elseif maintype == ItemMainType.PETCONSUME then
		return data_0501_ItemPetConsume[itemtype]
	else
		error("Unknow MainType Item:" .. tostring(itemtype))
	end
end

-- 物品主类别
function itemaux.getmaintype(itemtype)
	local typ = math.floor(itemtype/100000)
	return typ
end

-- 物品子类别
function itemaux.getminortype(itemtype)
	itemtype = itemtype - itemaux.getmaintype(itemtype) * 100000
	return math.floor(itemtype/1000)
end

function itemaux.itemlink(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	-- TODO: modify
	return language.untranslate(itemdata.name)
end


EQUIPTYPE = {
	["短剑"] = 1,
	["单手剑"] = 2,
	["单手矛"] = 3,
	["单手杖"] = 4,
	["锤"] = 5,
	["双手剑" ] = 6,
	["双后矛"] = 7,
	["双手杖"] = 8,
	["拳刃"] = 9,
	["弓"] = 10,
	["头盔"] = 11,
	["帽子"] = 12,
	["披风"] = 13,
	["衣服"] = 14,
	["铠甲"] = 15,
	["法袍"] = 16,
	["鞋子"] = 17,
	["项链"] = 18,
	["戒指"] = 19,
	["盾"] = 20,
}

EQUIPPOS_NAME = {
	[1] = "hat", -- 帽子
	[2] = "weapon", -- 武器
	[3] = "cloth",  -- 衣服
	[4] = "necklace", -- 项链
	[5] = "cloak",    -- 披风
	[6] = "shield",	  -- 盾牌
	[7] = "shoe",	  -- 鞋子
	[8] = "ring",	  -- 戒指
}

-- 武器
function itemaux.isweapon(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "weapon"

end

-- 帽子
function itemaux.ishat(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "hat"
end

-- 披风
function itemaux.iscloak(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "cloak"
end

-- 衣服
function itemaux.iscloth(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "cloth"
end	

-- 鞋子
function itemaux.isshoe(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "shoe"
end

-- 项链
function itemaux.isnecklace(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "necklace"
end

-- 戒指
function itemaux.isring(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "ring"
end

-- 盾
function itemaux.isshield(itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	return EQUIPPOS_NAME[itemdata.equippos] == "shield"
end

-- 缓存的（cardtype_set,lv)->cardsuitid的映射
itemaux.cardtype_lv_cardsuitid =  nil

-- 根据卡片组合类型+等级获取套卡ID
function itemaux.getcardsuitid(cardtype_set,lv)
	if not itemaux.cardtype_lv_cardsuitid then
		itemaux.cardtype_lv_cardsuitid = {}
		for cardsuit_id,data in pairs(data_0501_CardSuitEffect) do
			local cardtype_str = table.concat(data.need_cardtype,",")
			local key = string.format("%s#%d",cardtype_str,data.lv)
			itemaux.cardtype_lv_cardsuitid[key] = cardsuit_id
		end

	end
	local cardtypes = table.keys(cardtype_set)
	table.sort(cardtypes)
	local cardtype_str = table.concat(cardtypes,",")
	local key = string.format("%s#%d",cardtype_str,lv)
	return itemaux.cardtype_lv_cardsuitid[key]
end

function itemaux.fumo_maxval(attrtype,itemtype)
	local itemdata = itemaux.getitemdata(itemtype)
	local equiplv = itemdata.equiplv
	local fumodata = data_0801_Fumo[equiplv]
	local minortype = itemaux.getminortype(itemtype)
	local minortype_name = EQUIPPOS_NAME[minortype]
	local data = data_0801_FumoAttrRatio[attrtype]
	local attr_factor = data[string.format("%s_factor",minortype_name)]
	return math.floor(fumodata[attrtype] * attr_factor)
end

function itemaux.fumo_minval(attrtype,itemtype)
	local maxval = itemaux.fumo_maxval(attrtype,itemtype)
	return math.floor(maxval * 0.2)
end

function __hotfix(oldmod)
	itemaux.cardtype_lv_cardsuitid = nil
end

return itemaux
