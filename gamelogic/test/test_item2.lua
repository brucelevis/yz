local function test(pid)
	local reason = "test"
	local player = playermgr.getplayer(pid)
	player.itemdb:clear()
	player.carddb:clear()
	player.fashionshowdb:clear()
	player.equipposdb:clear()
	player:addcoin(-player.coin,reason)

	local itemtype = 102002			-- 10级短剑
	player:additembytype(itemtype,4,nil,reason)
	local itemdb = player:getitemdb(itemtype)
	local num = itemdb:getnumbytype(itemtype)
	assert(num == 4)
	local items = itemdb:getitemsbytype(itemtype)
	-- 装备最大折叠都是1
	assert(#items == 4)
	local item = items[1]
	local produce_itemtype = 102003
	-- 打造装备: 材料不足
	net.item.C2S.produceitem(player,{
		itemtype = produce_itemtype,
		num = 1,
	})
	local item = assert(itemdb:getitem(item.id))
	-- 增加材料
	local itemdata = itemaux.getitemdata(produce_itemtype)
	local costitem = itemdata.produce_costitem
	local costcoin = itemdata.produce_costcoin
	for itemtype,num in pairs(costitem) do
		player:additembytype(itemtype,num,nil,reason)
	end
	player:addcoin(costcoin,reason)
	net.item.C2S.produceitem(player,{
		itemtype = produce_itemtype,
		num = 1
	})
	for itemtype,num in pairs(costitem) do
		assert(itemdb:getnumbytype(itemtype) == 0)
	end
	assert(player.coin == 0)

	-- 测试精炼
	local item = items[2]
	player:wield(item)
	assert(table.isempty(item.refine))
	-- 精炼材料不足
	net.item.C2S.refineequip(player,{
		itemid = item.id,
	})
	assert(player.coin == 0)
	local equippos = player.equipposdb:get(item:get("equippos"))
	assert(table.isempty(equippos.refine))
	-- 增加材料
	local cnt = 1  -- 首次精炼：100%成功
	local refinedata = data_0801_Refine[cnt]
	local costitem = EQUIPPOS_NAME[equippos.id] == "weapon" and refinedata.weapon_costitem or refinedata.costitem
	local costcoin = refinedata.costcoin
	for itemtype,num in pairs(costitem) do
		player:additembytype(itemtype,num,nil,reason)
	end
	player:addcoin(costcoin,reason)
	net.item.C2S.refineequip(player,{
		itemid = item.id
	})
	for itemtype,num in pairs(costitem) do
		assert(itemdb:getnumbytype(itemtype) == 0)
	end
	assert(player.coin == 0)
	assert(not table.isempty(equippos.refine))
	assert(equippos.refine.cnt == 1)

	-- 测试顶替附魔
	local item1 = items[1]
	local item2 = items[2]
	-- just test
	item1.fumo.maxhp = 100
	item2.fumo.maxhp = 1
	net.item.C2S.replacefumo(player,{
		from_itemid = item1.id,
		to_itemid = item2.id,
		attrtype = "maxhp",
	})
	
	assert(item2.fumo.maxhp == 100)
	-- TODO: 测试插入卡片
end

return test
