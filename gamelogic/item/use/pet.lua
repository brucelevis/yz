function citem:use_feed(player,pet,num)
	assert(pet)
	local foods = data_1700_PetVar.PetFeedFoods
	if not table.find(foods,self.type) then
		net.msg.S2C.notify(player.pid,language.format("该食物无法喂养宠物"))
		return false
	end
	local petdata = petaux.getpetdata(pet.type)
	local likeit = table.find(petdata.like_foods,self.type)
	local key = string.format("feedcnt.%s",pet.id)
	local cnt = player.today:query(key,0)
	local optimal_feed_cnt = data_1700_PetVar.OptimalFeedCnt
	local optimal_feed = cnt < optimal_feed_cnt
	local addclose
	if optimal_feed or likeit then
		addclose = 2 * data_1700_PetVar.FeedAddClose
	else
		addclose = data_1700_PetVar.FeedAddClose
	end
	player.today:add(key,1)
	player.petdb:addclose(pet.id,addclose,"feed")
	if optimal_feed then
		net.msg.S2C.notify(player.pid,language.format("今天已喂食【{1}】{2}/{3},每天前{4}次喂食获得亲密度翻倍",pet.name,cnt,optimal_feed_cnt,optimal_feed_cnt))
	else
		net.msg.S2C.notify(player.pid,language.format("今天已喂食【{1}】{2}次",pet.name,cnt))
	end
	net.msg.S2C.notify(player.pid,language.format("获得亲密度{1}",addclose))
	return true,1
end

function citem:use_changestatus(player,pet,num)
	assert(pet)
	local status = self:get("status")
	player.petdb:change_petstatus(pet.id,status,"useitem")
	net.msg.S2C.notify(player.pid,language.format("{1}变为了{2}状态",pet:getname(),data_1700_PetStatus[status].name))
	return true,1
end

function citem:use_learnskill(player,pet,num)
	assert(pet)
	local skillid = self:get("skillid")
	local isok,errmsg = player.petdb:can_learn(pet,skillid)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(player.pid,errmsg)
		end
		return false
	end
	player.petdb:learnskill(pet.id,skillid)
	return true,1
end

function citem:use_wieldequip(player,pet,num)
	assert(pet)
	local errmsg = player.petdb:wieldequip(pet.id,self.id)
	if errmsg then
		net.msg.S2C.notify(player.pid,errmsg)
	end
	-- 需要先删除身上物品,再放入宠物装备栏,所以返回false,不用统一的扣物流程
	return false
end

for _,itemtype in pairs(data_1700_PetVar.PetFeedFoods) do
	citem.usefunc[itemtype] = citem.use_feed
end

for status,data in pairs(data_1700_PetStatus) do
	data_0501_ItemPetConsume[data.item].status = status
	citem.usefunc[data.item] = citem.use_changestatus
end

for skillid,data in pairs(data_0201_PetSkill) do
	data_0501_ItemPetConsume[data.item].skillid = skillid
	citem.usefunc[data.item] = citem.use_learnskill
end

for itemtype,_ in pairs(data_0501_ItemPetEquip) do
	citem.usefunc[itemtype] = citem.use_wieldequip
end

