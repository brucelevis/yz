-- 返回值格式: 使用是否成功,[消耗的物品数]
-- 消耗数量只有在具体消耗和传进来要求消耗的数量不同时才返回
function citem:useitem_501001(player,target,num)
	return true
end

citem.usefunc[501001] = citem.useitem_501001