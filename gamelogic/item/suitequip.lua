
csuitequip = class("csuitequip")

function csuitequip:init(pid)
	self.pid = pid
	self.suitlst = {[1] = {},[2] = {},[3] = {}}
	self.cursuitno = 0
	self.loadstate = "unload"
end

function csuitequip:save()
	local data = {}
	data.suitlst = self.suitlst
	data.cursuitno = self.cursuitno
	return data
end

function csuitequip:load(data)
	if not data or not next(data) then
		return
	end
	self.suitlst = data.suitlst
	self.cursuitno = data.cursuitno
end

function csuitequip:setsuit(suitno)
	if self.suitlst[suitno] == nil then
		return
	end
	local player = playermgr.getplayer(self.pid)
	local suitlst = {}
	for pos = 1,player.itemdb.beginpos - 1 do
		local equip = player.itemdb:getitembypos(pos)
		if equip then
			table.insert(suitlst,equip.id)
		end
	end
	self.suitlst[suitno] = suitlst
end


function csuitequip:changesuit(suitno)
	local suitlst = self.suitlst[suitno]
	if suitlst == nil then
		return
	end
	local player = playermgr.getplayer(self.pid)
	for _,equipid in ipairs(suitlst) do
		local equip = player:getitem(equipid)
		if equip then
			player:wield(equip)
		end
	end
	self.cursuitno = suitno
end

return csuitequip
