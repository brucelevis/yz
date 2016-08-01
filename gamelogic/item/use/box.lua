-- 返回值格式: 使用是否成功,[消耗的物品数]
-- 消耗数量只有在具体消耗和传进来要求消耗的数量不同时才返回
function citem:useitem_box(player,target,num)
	local itemdata = itemaux.getitemdata(self.type)
	local bonus = award.getaward(data_0501_ItemBox_Award,itemdata.awardid,itemdata.ratiotype)
	doaward("player",player.pid,bonus,"useitem_box",true)
	return true
end

citem.usefunc[801001] = citem.useitem_box
