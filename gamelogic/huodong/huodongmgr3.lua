huodongmgr = huodongmgr or {
	-- 简单玩法单元,如挖宝
	playunit = {}
}

function huodongmgr.init()
	huodongmgr.huodongs = {}
	huodongmgr.loadstate = "unload"
	huodongmgr.loadfromdatabase()

	huodongmgr.savename = "huodongmgr"
	autosave(huodongmgr)
end


function huodongmgr.load(data)
	if not data or not next(data) then
		for hid,huodong_data in pairs(data_Huodong) do
			local obj = huodongmgr.newhuodong(hid)
			huodongmgr.addhuodong(obj)
		end
		return
	end
	for hid,huodong_data in pairs(data_Huodong) do
		local obj = huodongmgr.newhuodong(hid)
		local name = obj.name
		local d = data.huodongs[name]
		if d then
			obj:load(d)
		else
		end
		huodongmgr.addhuodong(obj)
	end
end

function huodongmgr.save()
	local data = {}
	local huodongs = {}
	for name,obj in pairs(huodongmgr.huodongs) do
		huodongs[name] = obj:save()
	end
	data.huodongs = huodongs
	return data
end

function huodongmgr.clear()
	local huodongs = huodongmgr.huodongs
	for name,huodong in pairs(huodongs) do
		huodong:clear()
	end
	huodongmgr.huodongs = {}
end

function huodongmgr.onlogin(player)
	for name,huodong in pairs(huodongmgr.huodongs) do
		if huodong.onlogin then
			huodong:onlogin(player)
		end
	end
	for name,playunit in pairs(huodongmgr.playunit) do
		if playunit.onlogin then
			playunit.onlogin(player)
		end
	end
end

function huodongmgr.onlogoff(player)
	for name,huodong in pairs(huodongmgr.huodongs) do
		if huodong.onlogoff then
			huodong:onlogoff(player)
		end
	end
	for name,playunit in pairs(huodongmgr.playunit) do
		if playunit.onlogoff then
			playunit.onlogoff(player)
		end
	end
end

function huodongmgr.onfiveminuteupdate()
	for name,huodong in pairs(huodongmgr.huodongs) do
		if huodongmgr.isopen(huodong.id) then
			huodong:checkhuodong()
		end
	end
end

function huodongmgr.onhalfhourupdate()
end

function huodongmgr.onhourupdate()
end

function huodongmgr.newhuodong(hid)
	require "gamelogic.huodong.huodongmodule"
	local huodong_data = assert(data_Huodong[hid],"Invalid hid:" .. tostring(hid))
	local cls = assert(huodongmodule[hid],"Invalid hid:" .. tostring(hid))
	local conf = huodongmgr.new_time_conf(huodong_data)
	conf.id = hid
	conf.name = cls.name
	return cls.new(conf)
end

function huodongmgr.new_time_conf(huodong_data)
	local conf = {}
	local starttime = huodong_data.StartTime[1] * HOUR_SECS + huodong_data.StartTime[2] * 60
	local endtime = huodong_data.EndTime[1] * HOUR_SECS + huodong_data.EndTime[2] * 60
	conf.starttime = starttime
	conf.endtime = endtime
	if huodong_data.JoinStartTime then
		conf.join_starttime = huodong_data.JoinStartTime[1] * HOUR_SECS + huodong_data.JoinStartTime[2]*60
	end
	if huodong_data.JoinEndTime then
		conf.join_endtime = huodong_data.JoinEndTime[1] * HOUR_SECS + huodong_data.JoinEndTime[2] * 60
	end
	if huodong_data.ReadyTime then
		conf.readytime = huodong_data.ReadyTime[1] * HOUR_SECS + huodong_data.ReadyTime[2] * 60
	end
	if huodong_data.EndReadyTime then
		conf.end_readytime = huodong_data.EndReadyTime[1] * HOUR_SECS + huodong_data.EndReadyTime[2] * 60
	end
	return conf
end

-- 今日该活动是否开启
function huodongmgr.isopen(id)
	local huodong_data = data_Huodong[id]
	if not huodong_data then
		return false
	end
	local weekday = getweekday()
	weekday = (weekday == 0) and 7 or weekday
	for i,dayno in ipairs(huodong_data.WeekDay) do
		if dayno == weekday then
			return true
		end
	end
	return false
end

function huodongmgr.gethuodong(name)
	return huodongmgr.huodongs[name]
end

function huodongmgr.delhuodong(name)
	local huodong = huodongmgr:gethuodong(name)
	if huodong then
		huodongmgr.huodongs[name] = nil
	end
end

function huodongmgr.addhuodong(huodong)
	local name = assert(huodong.name)
	assert(not huodongmgr.gethuodong(name),"repeat huodong name:" .. tostring(name))
	huodongmgr.huodongs[name] = huodong
end

function huodongmgr.loadfromdatabase()
	if not huodongmgr.loadstate or huodongmgr.loadstate == "unload" then
		huodongmgr.loadstate = "loading"
		local db = dbmgr.getdb()
		local data = db:get(db:key("global","huodong"))
		huodongmgr.load(data)
		huodongmgr.loadstate = "loaded"
	end
end

-- just adpater for autosave
-- function huodongmgr:savetodatabase() is ok
function huodongmgr.savetodatabase()
	if huodongmgr.loadstate ~= "loaded" then
		return
	end
	local data = huodongmgr.save()
	local db = dbmgr.getdb()
	db:set(db:key("global","huodong"),data)
end

function huodongmgr.startgame()
	huodongmgr.init()
end

return huodongmgr
