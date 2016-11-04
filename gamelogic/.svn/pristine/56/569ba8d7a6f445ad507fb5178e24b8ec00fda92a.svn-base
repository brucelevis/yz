-- 杂货店

cgroceryshop = class("cgroceryshop",cshop)

function cgroceryshop:init(conf)
	cshop.init(self,conf)	
end

function cgroceryshop:onlogin(player)
	if self.len == 0 then
		self:_refresh("onlogin")
	else
		self:sync_allgoods()
	end
end

function cgroceryshop:_refresh(reason)
	local group_ids = {}
	for id,v in pairs(data_1401_GroceryShop) do
		if v.sumnum ~= 0 then
			local group = v.group
			if not group_ids[group] then
				group_ids[group] = {}
			end
			table.insert(group_ids[group],id)
		end
	end
	local pos_ids = {}
	for group,ids in pairs(group_ids) do
		local id = randlist(ids)
		local data = data_1401_GroceryShop[id]
		local pos = data.pos
		if not pos_ids[pos] then
			pos_ids[pos] = {}
		end
		table.insert(pos_ids[pos],id)
	end
	local goodslst = {}
	for pos,ids in pairs(pos_ids) do
		local id_ratio = {}
		for _,id in pairs(ids) do
			local data = data_1401_GroceryShop[id]
			id_ratio[id] = data.ratio
		end
		local id = choosekey(id_ratio)
		local data = data_1401_GroceryShop[id]
		table.insert(goodslst,{
			id = id,
			pos = data.pos,
			itemtype = data.itemtype,
			num = data.num,
			sumnum = data.sumnum,
			price = data.price,
			restype = data.restype,
			need_itemtype = data.need_itemtype,
			need_itemnum = data.need_itemnum,
			bind = data.bind == 1 and 1 or nil,
		})
	end
	logger.log("info","shop",format("[%s] [refresh] goodslst=%s reason=%s",self.name,goodslst,reason))
	self:clear()
	self:gen_goods(goodslst)
	self:sync_allgoods()
end

function cgroceryshop:refresh()
	self:_refresh("refresh")
end

function cgroceryshop:canbuy(player,id,buynum)
	local isok,errmsg = cshop.canbuy(self,player,id,buynum)
	if isok then
		local data = data_1401_GroceryShop[id]
		local achieve_id = data.achieve_id
		if achieve_id == "" then
			return true
		end
		local data_achieve = data_achievement[achieve_id]
		local achieve = player.achievedb:getachieve(data_achieve.id)
		if not achieve then
			return false,language.format("未达成成就<{1}>",data_achieve.name)
		end
		if achieve.progress == data_achieve.target then
			return true
		end
	end
	return false,errmsg
end

function cgroceryshop:buygoods(player,id,buynum)
	local isok,errmsg = self:buy(player,id,buynum)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return
	end

end

function cgroceryshop:sync_allgoods()
	local goodslst = {}
	for id,goods in pairs(self.objs) do
		table.insert(goodslst,goods)
	end
	sendpackage(self.pid,"shop","allgoods",{
		shopname = self.name,
		goodslst = goodslst,
	})
end

function cgroceryshop:onupdate(id,attrs)
	attrs.id = id
	sendpackage(self.pid,"shop","updategoods",{
		shopname = self.name,
		goods = attrs,
	})
end

return cgroceryshop

