local function test(pid)
	local reason = "test"
	local player = playermgr.getplayer(pid)
	player.itemdb:clear()
	player.carddb:clear()
	player.fashionshowdb:clear()
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
	-- 升级材料不足
	net.item.C2S.upgradeitem(player,{
		itemid = item.id,
	})
	local item = assert(itemdb:getitem(item.id))
	-- 增加材料
	local itemdata = itemaux.getitemdata(itemtype)
	local costitem = itemdata.upgrade_costitem
	local costcoin = itemdata.upgrade_costcoin
	for itemtype,num in pairs(costitem) do
		player:additembytype(itemtype,num,nil,reason)
	end
	player:addcoin(costcoin,reason)
	local next_itemtype = item.type + 1
	assert(itemdb:getnumbytype(next_itemtype) == 0)
	net.item.C2S.upgradeitem(player,{
		itemid = item.id,
	})
	assert(item.type == next_itemtype)
	for itemtype,num in pairs(costitem) do
		assert(itemdb:getnumbytype(itemtype) == 0)
	end
	assert(player.coin == 0)

	-- 测试精炼
	local item = items[2]
	assert(table.isempty(item.refine))
	-- 精炼材料不足
	net.item.C2S.refineitem(player,{
		itemid = item.id,
	})
	assert(player.coin == 0)
	assert(table.isempty(item.refine))
	-- 增加材料
	local cnt = 1  -- 首次精炼：100%成功
	local refinedata = data_0801_Refine[cnt]
	local costitem = refinedata.weapon_costitem
	local costcoin = refinedata.costcoin
	for itemtype,num in pairs(costitem) do
		player:additembytype(itemtype,num,nil,reason)
	end
	player:addcoin(costcoin,reason)
	net.item.C2S.refineitem(player,{
		itemid = item.id
	})
	for itemtype,num in pairs(costitem) do
		assert(itemdb:getnumbytype(itemtype) == 0)
	end
	assert(player.coin == 0)
	assert(not table.isempty(item.refine))
	assert(item.refine.cnt == 1)

	-- 测试附魔
	local item = items[3]
	assert(table.isempty(item.fumo))
	-- 附魔材料不足
	net.item.C2S.fumoitem(player,{
		itemid = item.id,
	})
	if not table.isempty(item.tmpfumo) then
		net.item.C2S.confirm_fumoitem(player,{
			itemid = item.id
		})
	end
	assert(player.coin == 0)
	assert(table.isempty(item.fumo))
	-- 增加材料
	local equiplv = item:get("equiplv")
	local data = data_0801_Fumo[equiplv]
	local costitem = data.costitem
	local costcoin = data.costcoin
	for itemtype,num in pairs(costitem) do
		player:additembytype(itemtype,num,nil,reason)
	end
	player:addcoin(costcoin,reason)
	net.item.C2S.fumoitem(player,{
		itemid = item.id
	})
	if not table.isempty(item.tmpfumo) then
		net.item.C2S.confirm_fumoitem(player,{
			itemid = item.id
		})
	end
	for itemtype,num in pairs(costitem) do
		assert(itemdb:getnumbytype(itemtype) == 0)
	end
	assert(player.coin == 0)
	assert(not table.isempty(item.fumo))

	-- TODO: 测试插入卡片
end

return test
