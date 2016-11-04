-- 消耗品

-- 宝图分两次使用，第一次使用会生成奖励，第二次使用(点击停止转盘）会发放奖励,如果没有收到第二次使用
-- 第二次使用的效果在定时到后会自动触发
function citem:useitem_baotu(player,target,num)
	huodongmgr.playunit.baotu.use(player,self)
	return false		-- 不删除物品,第二次使用/定时到后才删除物品
end

-- 双倍丹
function citem:useitem_601002(player,target,num)
	local itemdata = itemaux.getitemdata(self.type)
	local addvalue = itemdata.special_value or 20
	addvalue = addvalue * num
	player.thisweek:add("dexppoint",addvalue)
	sendpackage(player.pid,"player","resource",{
		dexppoint = player.thisweek:query("dexppoint") or 0
	})
	net.msg.S2C.notify(player.pid,language.format("使用成功,双倍点+{1}",addvalue))
	return true
end

citem.usefunc[601001] = citem.useitem_baotu
citem.usefunc[601002] = citem.useitem_601002
