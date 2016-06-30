netitem = netitem or {
	C2S = {},
	S2C = {},
}

local C2S = netitem.C2S
local S2C = netitem.S2C


--[[
-- 使用物品步骤:
-- 1. 判断物品是否存在
-- 2. 判断目标是否存在
-- 3. 判断是否可以对目标使用物品（如物品数量不足，其他条件)
-- 4. 使用物品
-- 5. 扣除物品
--]]
function C2S.useitem(player,request)
	local itemid = assert(request.itemid)
	local targetid = request.targetid
	local num = request.num
	local item = player:getitem(itemid)
	if not item then
		net.msg.S2C.notify(player.pid,language.format("物品不存在"))
		return
	end
	local target
	if targetid then
		local target = player:gettarget(targetid)
		if not target then
			net.msg.S2C.notify(player.pid,language.format("未知目标"))
			return
		end
	end
	item:use(player,target,num)
end

function C2S.sellitem(player,request)
	local itemid = assert(request.itemid)
	local num = request.num or 1
	local item,itemdb = player:getitem(itemid)
	if not item then
		return
	end
	if item.num < num then
		net.msg.S2C.notify(player.pid,language.format("物品数量不足#<R>%d#个",num))
		return
	end
	local reason = "sellitem"
	itemdb:costitembyid(itemid,num,reason)
	local itemdata = getitemdata(item.type)
	local addcoin = itemdata.coin_price * num
	player:addcoin(addcoin,reason)
end

function C2S.produceitem(player,request)
end

function C2S.destroyitem(player,request)
	local itemid = assert(request.itemid)
	local item,itemdb = player:getitem(itemid)
	if item then
		itemdb:delitemobj(itemid,"destroyitem")
	end
end

function C2S.mergeto(player,request)
	local from_itemid = assert(request.from_itemid)
	local to_itemid = assert(request.to_itemid)
	local num = request.num
	local fromitem,fromitemdb = player:getitem(from_itemid)
	if not fromitem then
		return
	end
	local toitem,toitemdb = player:getitem(to_itemid)
	if not toitem then
		return
	end
	if fromitemdb ~= toitemdb then
		return
	end
	local itemdata = getitemdata(toitem.type)
	assert(itemdata)
	num = num or fromitem.num
	local itemdb = fromitemdb
	if not itemdb:canmerge(fromitem,toitem) then
		return
	end
	if toitem.num >= itemdata.maxnum then
		return
	end
	local addnum = itemdata.maxnum - toitem.num
	addnum = math.min(num,addnum)
	local reason = string.format("%s_mergeto_%s",from_itemid,to_itemid)
	itemdb:costitembyid(from_itemid,addnum,reason)
	itemdb:additembyid(to_itemid,addnum,reason)
end

function C2S.wield(player,request)
	local equipid = assert(request.itemid)
	local equip = player:getitem(equipid)
	if not equip then
		return
	end
	local itemtype = getmaintype(equip.type)
	if itemtype ~= ItemMainType.EQUIP then
		return
	end
	player:wield(equip)
end

function C2S.unwield(player,request)
	local equipid = assert(request.itemid)
	local equip = player:getitem(equipid)
	if not equip then
		return
	end
	local itemtype = getmaintype(equip.type)
	if itemtype ~= ItemMainType.EQUIP then
		return
	end
	player:unwield(equip)
end

function C2S.changesuit(player,request)
	local suitno = assert(request.suitno)
	player.suitequip:changesuit(suitno)
end

function C2S.setsuit(player,request)
	local suitno = assert(request.suitno)
	player.suitequip:setsuit(suitno)
end

-- s2c
function S2C.syncitem(pid,bagtype,item)
	local param = {
		bagtype = bagtype,
		pos = item.pos,
		item = {
			id = item.id,
			type = item.type,
			num = item.num,
			bind = item.bind,
			createtime = item.createtime,
		}
	}
	sendpackage(pid,"item","syncitem",param)
end

function S2C.delitem(pid,itemid)
	sendpackage(pid,"item","delitem",{
		id = itemid,
	})
end

function S2C.detail(pid,item)
	local param = {
		id = item.id,
	}
	sendpackage(pid,"item","detail",param)
end

return netitem