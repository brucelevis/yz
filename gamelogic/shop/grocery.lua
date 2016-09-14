-- 杂货店

cgroceryshop = class("cgroceryshop",cshop)

function cgroceryshop:init(conf)
	cshop.init(self,conf)	
end

function cgroceryshop:open(player)
	if self.len == 0 then
		self:_refresh("open")
	end
	self:sync_allgoods(player)
end

function cgroceryshop:_refresh(reason)
	cshop._refresh(self,data_1401_GroceryShop,reason)
end

function cgroceryshop:canbuy(player,id,buynum)
	local isok,errmsg = cshop.canbuy(self,player,id,buynum)
	if isok then
		return true
		--[[
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
		]]
	end
	return false,errmsg
end

function cgroceryshop:buygoods(player,id,buynum)
	self:buy(player,id,buynum)
end

function cgroceryshop:sync_allgoods(player)
	local goodslst = {}
	for id,goods in pairs(self.objs) do
		table.insert(goodslst,goods)
	end
	sendpackage(player.pid,"shop","allgoods",{
		shopname = self.name,
		goodslst = goodslst,
	})
end

function cgroceryshop:onbuy(pid,id,buynum)
	local goods = self:get(id)
	sendpackage(pid,"shop","updategoods",{
		shopname = self.name,
		goods = goods,
	})
end

return cgroceryshop
