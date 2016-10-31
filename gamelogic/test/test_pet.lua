local function test(pid)
	local player = playermgr.getplayer(pid)
	player.petdb:clear()
	local pet = petaux.newpet(20002)
	player.petdb:addpet(pet,"gm")
	local petid = pet.id
	assert(player.petdb:getpet(petid))
	local net = net.pet.C2S
	net.delpet(player,{ id = petid, })
	pet = petaux.newpet(20002)
	player.petdb:addpet(pet,"gm")
	petid = pet.id
	net.war_or_rest(player,{ id = petid, })
	assert(pet.readywar)
	net.war_or_rest(player,{ id = petid, })
	assert(not pet.readywar)
	player.itemdb:clear()
	local itemtype = 601014
	player:additembybytype(itemtype,1,true,"gm")
	local item = player.itemdb:getitemsbytype(itemtype)[1]
	net.feed(player,{ id = petid, itemid = item.id, })
	assert(table.isempty(player.itemdb:getitemsbytype(itemtype)))
	assert(pet.close > 0)
	net.changestatus(player,{ id = petid, })
	net.changestatus(player,{ id = petid, status = 1, })
	player:additembytype(601029,1,true,"gm")
	net.changestatus(player,{ id = petid, status = 1, })
	assert(player.itemdb:getnumbytype(601029) == 0)
	net.train(player,{ id = petid, })
end

return test
