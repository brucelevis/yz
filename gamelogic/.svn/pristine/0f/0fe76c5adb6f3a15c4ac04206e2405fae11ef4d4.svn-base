-- 返回值格式: 使用是否成功,[消耗的物品数]
-- 消耗数量只有在具体消耗和传进来要求消耗的数量不同时才返回
function citem:use_unionitem(player,target,num)
	-- 一次只能使用一个
	num = 1
	local unionid = player:unionid()
	if not unionid then
		net.msg.notify(player.pid,language.format("你没有公会"))
		return false
	end
	local addmoney = self:get("addmoney")
	local addoffer = self:get("addoffer")
	local addexp = self:get("addexp")
	local reason = string.format("use_unionitem.%s",self.id)
	frozen(self)
	if istrue(self:get("canstore")) then
		local packitem = self:save()
		packitem.num = num
		unionaux.unionmethod(unionid,"cangku:additem2",packitem,reason)
	else
	end
	if addmoney > 0 then
		unionaux.addmoney(unionid,addmoney,reason)
	end
	if addoffer > 0 then
		player:addres("union_offer",addoffer,reason,true)
	end
	if addexp > 0 then
		player:addres("exp",addexp,reason,true)
	end
	unfrozen(self)
	return true,1
end

for itemtype in pairs(data_0501_ItemUnion) do
	citem.usefunc[itemtype] = citem.use_unionitem
end
