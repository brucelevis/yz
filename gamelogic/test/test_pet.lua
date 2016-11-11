local function test(pid)
	local player = playermgr.getplayer(pid)
	player.petdb:clear()
	local pet = petaux.newpet(20002)
	player.petdb:addpet(pet,"gm")
	local petid = pet.id
	assert(player.petdb:getpet(petid))
	net.pet.C2S.delpet(player,{ id = petid, })
	assert(not player.petdb:getpet(petid))
	pet = petaux.newpet(20002)
	player.petdb:addpet(pet,"gm")
	petid = pet.id
	net.pet.C2S.war_or_rest(player,{ id = petid, })
	assert(pet.readywar)
	net.pet.C2S.war_or_rest(player,{ id = petid, })
	assert(not pet.readywar)
	player.itemdb:clear()
	local itemtype = 1102061	--食物道具
	player:additembytype(itemtype,1,0,"gm")
	local item = player.itemdb:getitemsbytype(itemtype)[1]
	net.item.C2S.useitem(player,{ itemid = item.id, targetid = petid })
	assert(player.itemdb:getnumbytype(itemtype) == 0)
	assert(pet.close == 20,string.format("%d",pet.close))
	player.petdb:addclose(petid,900,"gm")
	net.pet.C2S.changestatus(player,{ id = petid, })
	itemtype = 1102076	--心情道具
	player:additembytype(itemtype,1,0,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	net.item.C2S.useitem(player,{ itemid = item.id, targetid = petid })
	assert(player.itemdb:getnumbytype(itemtype) == 0)
	net.pet.C2S.train(player,{ id = petid, })
	itemtype = 1102091		--训练道具
	player:additembytype(itemtype,1,0,"gm")
	net.pet.C2S.train(player,{ id = petid, })
	itemtype = 1102002		--技能书道具
	player:additembytype(itemtype,1,0,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	net.item.C2S.useitem(player,{ itemid = item.id, targetid = petid })
	local skillid = 400002
	assert(pet:hasskill(skillid))
	net.pet.C2S.forgetskill(player,{ id = petid, skillid = skillid, })
	assert(not pet:hasskill(skillid))
	itemtype = 902001		--装备道具
	player:additembytype(itemtype,1,1,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	net.item.C2S.useitem(player,{ itemid = item.id, targetid = petid })
	assert(item.pos == 2)
	net.pet.C2S.unwieldequip(player,{ id = petid, itemid = item.id, })
	assert(item.pos ~= 2)
	net.pet.C2S.rename(player,{ id = petid, name = "gmpet", })
	net.pet.C2S.setchat(player,{ id = petid, case = 2, chat = "test", })
	local pet2 = petaux.newpet(20004)
	pet.lv = 30
	pet2.lv = 30
	player.petdb:addpet(pet2,"gm")
	assert(player.petdb:getpet(pet2.id))
	net.pet.C2S.combine(player,{ masterid = petid, subid = pet2.id, })
	assert(not player.petdb:getpet(pet2.id))
	itemtype = 1102092
	player:additembytype(itemtype,10,1,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	net.pet.C2S.expandspace(player,{ itemid = item.id, })
	itemtype = 1102052
	player:additembytype(itemtype,1,1,"gm")
	item = player.itemdb:getitemsbytype(itemtype)[1]
	player.petdb:catchpet(player,20002,1,item.id)
	net.pet.C2S.commenton(player,{ pettype = 20002, msg = "aaaaaaa", })
	net.pet.C2S.getcomments(player,{ pettype = 20002, })
	local _,comments = rpc.call(cserver.datacenter(),"rpc","net.pet.C2S._getcomments",player.pid,20002)
	net.pet.C2S.likecomment(player,{ pettype = 20002, id = comments[1].id, })
	net.pet.C2S.getcomments(player,{ pettype = 20002, })
end

return test
