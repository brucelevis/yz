netshop = netshop or {
	C2S = {},
	S2C = {},
}

local C2S = netshop.C2S
local S2C = netshop.S2C

function C2S.buygoods(player,request)
	local shopname = assert(request.shopname)
	local goods_id = assert(request.goods_id)
	local buynum = assert(request.num)
	local shop = player.shopdb[shopname]
	if shop then
		if shop.buygoods then
			shop:buygoods(player,goods_id,buynum)
		end
	elseif globalmgr.shop[shopname] then
		shop = globalmgr.shop[shopname]
		if shop.buygoods then
			shop:buygoods(player,goods_id,buynum)
		end
	end
end

function C2S.refresh(player,request)
	local shopname = assert(request.shopname)
	local shop = player.shopdb[shopname]
	if shop then
		if shop.refresh then
			shop:refresh(player)
		end
	elseif globalmgr.shop[shopname] then
		shop = globalmgr.shop[shopname]
		if shop.refresh then
			shop:refresh(player)
		end
	end
end

function C2S.open(player,request)
	local shopname = assert(request.shopname)
	local shop = player.shopdb[shopname]
	if shop then
		if shop.open then
			shop:open(player)
		end
	elseif globalmgr.shop[shopname] then
		shop = globalmgr.shop[shopname]
		if shop.open then
			shop:open(player)
		end
	end
end

-- s2c

return netshop
