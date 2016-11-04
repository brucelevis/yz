-- 全局的商店容器
cglobalshopdb = class("cglobalshopdb")

function cglobalshopdb:init()
	self.grocery = cgroceryshop.new({
		pid = 0,
		name = "grocery",
	})
	self.weapon = cweaponshop.new({
		pid = 0,
		name = "weapon",
	})
	self.armor = carmorshop.new({
		pid = 0,
		name = "armor",
	})
	self.loadstate = "unload"
	self.savename = "globalshop"
	autosave(self)
end

function cglobalshopdb:loadfromdatabase()
	if not self.loadstate or self.loadstate == "unload" then
		self.loadstate = "loading"
		local db = dbmgr.getdb()
		local data = db:get(db:key("global","shop"))
		self:load(data)
		self.loadstate = "loaded"
	end
end

function cglobalshopdb:savetodatabase()
	if self.loadstate ~= "loaded" then
		return
	end
	local data = self:save()
	local db = dbmgr.getdb()
	db:set(db:key("global","shop"),data)
end

function cglobalshopdb:load(data)
	if not data or not next(data) then
		return
	end
	--self.grocery:load(data.grocery)
	--self.weapon:load(data.weapon)
	--self.armor:load(data.armor)
end

function cglobalshopdb:save()
	local data = {}
	--data.grocery = self.grocery:save()
	--data.weapon = self.weapon:save()
	--data.armor = self.armor:save()
	return data
end

function cglobalshopdb:onfivehourupdate()
	local weekday = getweekday()
	local hour = getdayhour()
	local reason = "onhourupdate"
	for name,data in pairs(data_1401_GlobalShopCtrl) do
		local shop = self[name]
		if shop then
			if not table.isempty(data.refresh_weekdays) or
				table.find(data.refresh_weekdays,weekday) then
				if not table.isempty(data.refresh_hours) or
					table.find(data.refresh_hours,hour) then
					if shop._refresh then
						shop:_refresh(reason)
					end
				end
			end
		end
	end
end

return cglobalshopdb
