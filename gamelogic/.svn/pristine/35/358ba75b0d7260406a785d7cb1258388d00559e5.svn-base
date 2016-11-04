local function test1(pid)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local reason = "test"
	player.itemdb:clear()
	player:addgold(-player.gold,reason)
	player:addsilver(-player.silver,reason)
	player:addcoin(-player.coin,reason)
	local itemtype = 501001
	player.itemdb:additembytype(itemtype,1,nil,reason)
	local hasnum = player.itemdb:getnumbytype(itemtype)
	assert(hasnum == 1)
	local itemdata = itemaux.getitemdata(itemtype)
	player.itemdb:additembytype(itemtype,itemdata.maxnum,nil,reason)
	local hasnum = player.itemdb:getnumbytype(itemtype)
	assert(hasnum == 1 + itemdata.maxnum)
	local items = player.itemdb:getitemsbytype(itemtype)
	assert(#items == 2)
	local item = items[1].num == itemdata.maxnum and items[1] or items[2]
	local isok = pcall(player.itemdb.additembyid,player.itemdb,item.id,1,reason)
	assert(not isok)
	local request = net.item.C2S
	request.useitem(player,{
		itemid = item.id,
		num = 2,
	})
	assert(item.num == itemdata.maxnum-2)
	local itemdata = itemaux.getitemdata(item.type)
	local hasnum = item.num
	request.sellitem(player,{
		itemid = item.id,
		num = hasnum,
	})
	assert(player.coin == itemdata.coin_price * hasnum)
	local oldnum = player.itemdb:getnumbytype(itemtype)
	player.itemdb:additembytype(itemtype,5,nil,reason)
	local hasnum = player.itemdb:getnumbytype(itemtype)
	assert(hasnum == 5+oldnum)
	local items = player.itemdb:getitemsbytype(itemtype)
	local item = items[1]
	request.destroyitem(player,{
		itemid = item.id,
	})
	assert(player.itemdb:getitem(item.id) == nil)
	local item1 = player.itemdb:newitem({
		type = itemtype,
		num = 1,
	})
	local item1 = player.itemdb:additem(item1,reason)
	local item2 = player.itemdb:newitem({
		type = itemtype,
		num = 2,
	})
	local item2 = player.itemdb:additem(item2,reason)
	request.mergeto(player,{
		from_itemid = item1.id,
		to_itemid = item2.id,
	})
	assert(player.itemdb:getitem(item1.id)==nil)
	assert(item2.num == 3)
	print("ok")
end

data_test_equip = {
	[100001] = {
		name = "手里箭",
		wieldpos = 1,
		atk = 100,
		maxnum = 1,
	},
	[100002] = {
		name = "黑石项链",
		wieldpos = 3,
		magic = 200,
		maxnum = 1,
	},
}

local function test2(pid)
	pid = tonumber(pid)
	local player = playermgr.getplayer(pid)
	player:additembytype(100001,1,nil,"test")
	player:additembytype(100002,1,nil,"test")
	local itemobj1 = player.itemdb:getitemsbytype(100001)[1]
	local itemobj2 = player.itemdb:getitemsbytype(100002)[1]
	player:wield(itemobj1)
	player:wield(itemobj2)
	player:wield(itemobj1)
	player.suitequip:setsuit(1)
	player:unwield(itemobj1)
	player:unwield(itemobj2)
	player:unwield(itemobj2)
	player.suitequip:changesuit(1)
	player:additembytype(100001,1,nil,"test")
	player:additembytype(100002,1,nil,"test")
	local itemobj1 = player.itemdb:getitemsbytype(100001)[2]
	local itemobj2 = player.itemdb:getitemsbytype(100002)[2]
	player:wield(itemobj1)
	player:wield(itemobj2)
	player:wield(itemobj1)
	player.suitequip:setsuit(2)
	player:unwield(itemobj1)
	player:unwield(itemobj2)
	player:unwield(itemobj2)
	player.suitequip:changesuit(1)
	player.suitequip:changesuit(2)

end

local function test3(pid)
	pid = tonumber(pid)
	local player = playermgr.getplayer(pid)
	player.itemdb:clear()
end

local function test(pid)
	test1(pid)
	test2(pid)
	test3(pid)
end

return test

