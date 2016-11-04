-- 武器店

cweaponshop = class("cweaponshop",cshop)

function cweaponshop:init(conf)
	cshop.init(self,conf)	
end

function cweaponshop:open(player)
	if self.len == 0 then
		self:_refresh("open")
	end
	self:sync_allgoods(player)
end

function cweaponshop:_refresh(reason)
	cshop._refresh(self,data_1401_WeaponShop,reason)
end

function cweaponshop:canbuy(player,id,buynum)
	local isok,errmsg = cshop.canbuy(self,player,id,buynum)
	if isok then
		return true
		--[[
		local data = data_1401_WeaponShop[id]
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

function cweaponshop:buygoods(player,id,buynum)
	self:buy(player,id,buynum)
end

function cweaponshop:sync_allgoods(player)
	local goodslst = {}
	for id,goods in pairs(self.objs) do
		table.insert(goodslst,goods)
	end
	sendpackage(player.pid,"shop","allgoods",{
		shopname = self.name,
		goodslst = goodslst,
	})
end

function cweaponshop:onbuy(pid,id,buynum)
	local goods = self:get(id)
	sendpackage(pid,"shop","updategoods",{
		shopname = self.name,
		goods = goods,
	})
end

return cweaponshop
