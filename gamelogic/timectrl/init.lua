timectrl = {}
local INTERVAL = 5 --5 minute

function timectrl.next_fiveminute(now)
	now = now or getsecond()
	local secs = now + INTERVAL * 60
	local min = gethourminute(secs)	
	min = math.floor(min/INTERVAL) * INTERVAL
	local tm = {year=getyear(secs),month=getyearmonth(secs),day=getmonthday(secs),hour=getdayhour(secs),min=min,sec=0,}
	print(mytostring(tm),min)
	return os.time(tm)
end

function timectrl.starttimer()
	local now = getsecond()
	local next_time = timectrl.next_fiveminute(now)	
	assert(next_time > now,string.format("%d > %d",next_time,now))
	print(next_time,now,next_time-now)
	timer.timeout("timectrl.timer",next_time-now,timectrl.fiveminute_update)
end

function timectrl.init(...)
	logger.log("info","timectrl","timectrl.init")
	timectrl.starttimer()
end

function timectrl.fiveminute_update()
	timectrl.starttimer() 
	timectrl.onfiveminuteupdate()
	now = getsecond()
	local min = gethourminute(now)
	if min % 10 == 0 then
		timectrl.tenminute_update()
	end
end

function timectrl.tenminute_update(now)
	timectrl.ontenminuteupdate()
	local min = gethourminute(now)
	if min == 0 or min == 30 then
		timectrl.halfhour_update()
	end
end

function timectrl.halfhour_update(now)
	timectrl.onhalfhourupdate()
	local min = gethourminute(now)
	if min == 0 then
		timectrl.hour_update(now)
	end
end

function timectrl.hour_update(now)
	timectrl.onhourupdate()
	local hour = getdayhour(now)
	if hour == 0  then
		timectrl.day_update(now)
	elseif hour == 5 then
		timectrl.fivehourupdate(now)
	end
end

function timectrl.day_update(now)
	timectrl.ondayupdate()
	local weekday = getweekday(now)
	if weekday == 0 then
		timectrl.sunday_update(now)
	elseif weekday == 1 then
		timectrl.monday_update(now)
	end
	local day = getmonthday(now)
	if day == 1 then
		timectrl.month_update()
	end
end

function timectrl.monday_update(now)
	timectrl.onmondayupdate()
end

function timectrl.sunday_update(now)
	timectrl.onsundayupdate()
end

function timectrl.month_update(now)
	timectrl.onmonthupdate()
end

function timectrl.fivehourupdate(now)
	timectrl.onfivehourupdate()
	local weekday = getweekday(now)
	if weekday == 0 then			-- 星期天
		timectrl.sunday_update_infivehour(now)
	elseif weekday == 1 then		-- 星期一 
		timectrl.monday_update_infivehour(now)
	end
end

function timectrl.monday_update_infivehour(now)
	timectrl.onmondayupdate_infivehour()
end

function timectrl.sunday_update_infivehour(now)
	timectrl.onsundayupdate_infivehour()
end

function timectrl.error_handle(...)
	local args = {...}
	logger.log("error","timectrl",string.format("[ERROR] %s",mytostring(args)))
	error("timectrl error")
end

function timectrl.onfiveminuteupdate()
	logger.log("info","timectrl","onfiveminuteupdate")
	maintain.onfiveminuteupdate()
end

function timectrl.ontenminuteupdate()
	logger.log("info","timectrl","ontenminuteupdate")
end

function timectrl.onhalfhourupdate()
	logger.log("info","timectrl","onhalfhourupdate")
end


function timectrl.onhourupdate()
	logger.log("info","timectrl","onhourupdate")
	globalmgr.onhourupdate()
	playermgr.broadcast(cplayer.onhourupdate)
end

function timectrl.ondayupdate()
	logger.log("info","timectrl","ondayupdate")
	playermgr.broadcast(cplayer.ondayupdate)
end

function timectrl.onmondayupdate()
	logger.log("info","timectrl","onmondayupdate")
end

function timectrl.onsundayupdate()
	logger.log("info","timectrl","onsundayupdate")
end

function timectrl.onmonthupdate()
	logger.log("info","timectrl","onmonthupdate")
end

function timectrl.onfivehourupdate()
	logger.log("info","timectrl","onfivehourupdate")
	globalmgr.onfivehourupdate()
	playermgr.broadcast(cplayer.onfivehourupdate)
end

function timectrl.onmondayupdate_infivehour()
	logger.log("info","timectrl","onmondayupdate_infivehour")
	playermgr.broadcast(cplayer.onmondayupdate_infivehour)
end

function timectrl.onsundayupdate_infivehour()
	logger.log("info","timectrl","onsundayupdate_infivehour")
end

return timectrl
