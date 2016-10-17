netpet = netpet or {
	C2S = {},
	S2C = {},
}

local C2S = netpet.C2S
local S2C = netpet.S2C

function C2S.delpet(player,request)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	player.petdb:delpet(id,"c2s")
end

function C2S.war_or_rest(player,request)
	local id = assert(request.id)
	local pet = self.petdb:getpet(id)
	if pet then
		if pet.readywar then
			player.petdb:unreadywar(id)
		else
			player.petdb:readywar(id)
		end
	end
end

function C2S.feed(player,request)
	local id = assert(request.id)
	local itemid = assert(request.itemid)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	local item = player.itemdb:getitem(itemid)
	if not item then
		return
	end
	local foods = data_1700_PetVar.PetFeedFoods
	if not table.find(foods,item.type) then
		net.msg.S2C.notify(player.pid,language.format("该食物无法喂养宠物"))
		return
	end
	local petdata = petaux.getpetdata(pet.type)
	local likeit = table.find(petdata.like_foods,item.type)
	local key = string.format("feedcnt.%s",pet.id)
	local cnt = player.today:query(key,0)
	local optimal_feed_cnt = data_1700_PetVar.OptimalFeedCnt
	local optimal_feed = cnt < optimal_feed_cnt
	if optimal_feed or likeit then
		addclose = 2 * data_1700_PetVar.FeedAddClose
	else
		addclose = data_1700_PetVar.FeedAddClose
	end
	player.itemdb:costitembyid(item.id,1,string.format("feed#%s",pet.id))
	player.today:add(key,1)
	player.petdb:addclose(pet.id,addclose,"feed")
	if optimal_feed then
		net.msg.S2C.notify(player.pid,language.format("今天已喂食【{1}】{2}/{3},每天前{4}次喂食获得亲密度翻倍",pet.name,cnt,optimal_feed_cnt,optimal_feed_cnt))
	else
		net.msg.S2C.notify(player.pid,language.format("今天已喂食【{1}】{2}次",pet.name,cnt))
	end
	net.msg.S2C.notify(player.pid,language.format("获得亲密度{1}",addclose))
end

function C2S.changestatus(player,request)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	local status = request.status
	local reason
	if status then
		local itemtype = data_1700_PetStatus[status]
		if not itemtype then
			return
		end
		local items = player.itemdb:getitemsbytype(itemtype)
		if table.isempty(items) then
			net.msg.S2C.notify(player.pid,language.format("身上没有该状态转换道具"))
			return
		end
		player.itemdb:costitembytype(itemtype,1,"change_petstatus")
		reason = "useitem"
	else
		local costclose = data_1700_PetChangeStatusCost[pet.lv].costclose
		if pet.close < costclose then
			net.msg.S2C.notify(player.pid,language.format("亲密度不足"))
			return
		end
		player.petdb:addclose(id,-costclose,"changestatus")
		status = randlist(table.keys(data_1700_PetStatus))
		reason = "useclose"
	end
	player.petdb:change_petstatus(id,status,reason)
end

function C2S.train(player,request)
	local id = assert(request.id)
	local pet = player.petdb:getpet(id)
	if not pet then
		return
	end
	local quality = pet:get("quality")
	local needitem
	if quality == 1 then
		needitem = data_1700_PetVar.NormalTrainItem
	elseif quality == 2 then
		needitem = data_1700_PetVar.RareTrainItem
	else
		needitem = data_1700_PetVar.HolyTrainItem
	end
	if player.itemdb:getnumbytype(needitem.item) < needitem.num then
		net.msg.S2C.notify(player.pid,language.format("所需训练物品不足"))
		return
	end
	player.itemdb:costitembytype(needitem.item,needitem.num,"trainpet")
	player.petdb:trainpet(id)
end

function C2S.learnskill(player,request)
	local skillid = assert(request.skillid)
	local id = assert(request.id)
end

function C2S.forgetskill(player,request)
	local skillid = assert(request.skillid)
	local id = assert(request.id)
	
end

function C2S.catch(player,request)
end

-- s2c

return netpet
