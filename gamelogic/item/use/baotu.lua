-- 宝图分两次使用，第一次使用会生成奖励，第二次使用(点击停止转盘）会发放奖励,如果没有收到第二次使用
-- 第二次使用的效果在定时到后会自动触发
function citem:useitem_baotu(player,target,num)
	huodongmgr.playunit.baotu.use(player,self)
	return false		-- 不删除物品,第二次使用/定时到后才删除物品
end

citem.usefunc[601001] = citem.useitem_baotu
