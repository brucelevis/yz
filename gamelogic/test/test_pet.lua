local function test(pid)
	local player = playermgr.getplayer(pid)
	player.petdb:clear()
	local pet = petaux.newpet(20002)
	player.petdb:addpet(pet,"gm")
	local petid = pet.id
	assert(player.petdb:getpet(petid))
	local net = net.pet.C2S
	net.delpet(player,{ id = petid, })
	assert(not player.petdb:getpet(petid))
	pet = petaux.newpet(20002)
	player.petdb:addpet(pet,"gm")
	petid = pet.id
	net.war_or_rest(player,{ id = petid, })
	assert(pet.readywar)
	net.war_or_rest(player,{ id = petid, })
	assert(not pet.readywar)
	player.itemdb:clear()
	local itemtype = 601014
	player:additembytype(itemtype,1,0,"gm")
	local item = player.itemdb:getitemsbytype(itemtype)[1]
	net.feed(player,{ id = petid, itemid = item.id, })
	assert(player.itemdb:getnumbytype(itemtype) == 0)
	assert(pet.close == 20,string.format("%d",pet.close))
	player.petdb:addclose(petid,900,"gm")
	net.changestatus(player,{ id = petid, })
	net.changestatus(player,{ id = petid, status = 1, })
	itemtype = 601029
	player:additembytype(itemtype,1,0,"gm")
	net.changestatus(player,{ id = petid, status = 1, })
	assert(player.itemdb:getnumbytype(itemtype) == 0)
	net.train(player,{ id = petid, })
	itemtype = 601050
	player:additembytype(itemtype,1,0,"gm")
	net.train(player,{ id = petid, })
	player:additembytype(itemtype,1,0,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	local skillid = 10001
	net.learnskill(player,{ id = petid, skillid = skillid, itemid = item.id, }) 
	assert(pet:hasskill(skillid))
	net.forgetskill(player,{ id = petid, skillid = skillid, })
	assert(not pet:hasskill(skillid))
	itemtype = 902001
	player:additembytype(itemtype,1,1,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	net.wieldequip(player,{ id = petid, itemid = item.id, })
	assert(item.pos == 2)
	net.unwieldequip(player,{ id = petid, itemid = item.id, })
	assert(item.pos ~= 2)
	net.rename(player,{ id = petid, name = "gmpet", })
	net.setchat(player,{ id = petid, case = 2, chat = "test", })
	local pet2 = petaux.newpet(20004)
	pet.lv = 30
	pet2.lv = 30
	player.petdb:addpet(pet2,"gm")
	assert(player.petdb:getpet(pet2.id))
	net.combine(player,{ masterid = petid, subid = pet2.id, })
	assert(not player.petdb:getpet(pet2.id))
	local itemtype = 601050
	player:additembytype(itemtype,1,1,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	net.expandspace(player,{ itemid = item.id, })
	player:additembytype(itemtype,1,1,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	player.petdb:catchpet(player,20002,1,item.id)
end

return test