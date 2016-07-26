-- 跟随玩家的商店容器
cshopdb = class("cshopdb")

function cshopdb:init(pid)
	self.pid = pid
	self.secret = csecretshop.new({
		pid = pid,
		name = "secret",
	})
end

function cshopdb:load(data)
	if not data or not next(data) then
		return
	end
	self.secret:load(data.secret)
end

function cshopdb:save()
	local data = {}
	data.secret = self.secret:save()
	return data
end

function cshopdb:onlogin(player)
	for name in pairs(data_1401_PlayerShopCtrl) do
		local shop = self[name]
		if shop and shop.onlogin then
			shop:onlogin(player)
		end
	end
end

function cshopdb:onlogoff(player)
	for name in pairs(data_1401_PlayerShopCtrl) do
		local shop = self[name]
		if shop and shop.onlogoff then
			shop:onlogoff(player)
		end
	end
end

function cshopdb:onhourupdate()
	local weekday = getweekday()
	weekday = weekday == 0 and 7
	local hour = getdayhour()
	local reason = "onhourupdate"
	for name,data in pairs(data_1401_PlayerShopCtrl) do
		local shop = self[name]
		if shop then
			if table.isempty(data.refresh_weekdays) or
				table.find(data.refresh_weekdays,weekday) then
				if table.isempty(data.refresh_hours) or
					table.find(data.refresh_hours,hour) then
					if shop._refresh then
						shop:_refresh(reason)
					end
				end
			end
		end
	end
end

return cshopdb
