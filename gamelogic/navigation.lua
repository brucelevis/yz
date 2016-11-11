navigation = navigation or {}

g_activityname2hid = {
	shimoshilian = 10001,
	shimen = 10002,
	guaji = 10003,
	babatuosi = 10004,
}

function navigation.isintime(hid,now)
	now = now or getsecond()
	if not data_1100_Navigation[hid] then
		return false
	end
	local activity = data_1100_Navigation[hid]
	if not istrue(activity.isopen) then
		return false
	end
	--frequence_type 1-日常活动 2-限时活动
	if activity.frequence_type == 2 then
		local weekday = getweekday(now)
		if next(activity.weekday) and not table.find(activity.weekday,weekday) then
			return false
		end
		if #activity.startdate == 3 and #activity.enddate == 3 then
			local startdate = mktime(table.unpack(activity.startdate),0,0,0)
			local enddate = mktime(table.unpack(activity.enddate),0,0,0)
			if now < startdate or now > enddate then
				return false
			end
		end
		if #activity.starttime == 3 and #activity.endtime == 3 then
			local starttime = mktime(nil,nil,nil,table.unpack(activity.starttime))
			local endtime = mktime(nil,nil,nil,table.unpack(activity.endtime))
			if now < starttime or now > endtime then
				return false
			end
		end
	end
	return true
end

function navigation.getnavigation(player)
	local navigatedata = player.today:get("navigatedata")
	if not navigatedata then
		navigatedata = {
			activities = {},	--各个玩法的奖励/进度情况 { hid = 900, progress = 1, awarded = false}
			liveness = 0,		--活跃度
			awardrecord = {},	--活跃度奖励领取记录
		}
		player.today:set("navigatedata",navigatedata)
	end
	return navigatedata
end

function navigation.getactivity(player,hid)
	local navigatedata = navigation.getnavigation(player)
	local activity
	for _,value in ipairs(navigatedata.activities) do
		if value.hid == hid then
			activity = value
			break
		end
	end
	if not activity then
		activity = {
			hid = hid,
			progress = 0,
			awarded = false,
		}
		table.insert(navigatedata.activities,activity)
	end
	return activity
end

function navigation.addprogress(pid,name,cnt)
	local player = playermgr.getplayer(pid)
	local hid = g_activityname2hid[name]
	if not navigation.isintime(hid) then
		return
	end
	cnt = cnt or 1
	local activity = navigation.getactivity(player,hid)
	local data = data_1100_Navigation[hid]
	if activity.progress >= data.progress then
		return
	end
	activity.progress = math.min(activity.progress + cnt,data.progress)
	if activity.progress == data.progress then
		net.navigation.S2C.showredpoint(pid)
	end
	logger.log("info","navigation",format("[addprogress] pid=%d hid=%d progress=%d",pid,hid,activity.progress))
	if not player.navigation_updated then
		net.navigation.S2C.needupdate(player)
		player.navigation_updated = true
	end
end

function navigation.onlogin(player)
	net.navigation.S2C.needupdate(player)
	player.navigation_updated = true
	local needshowred
	local navigatedata = navigation.getnavigation(player)
	for _,activity in ipairs(navigatedata.activities) do
		if not activity.awarded and data_1100_Navigation[activity.hid].progress <= activity.progress then
			needshowred = true
			break
		end
	end
	for awardid,data in pairs(data_1100_LivenessAward) do
		if not table.find(navigatedata.awardrecord,awardid) and navigatedata.liveness >= data.needliveness then
			needshowred = true
			break
		end
	end
	if needshowred then
		net.navigation.S2C.showredpoint(player.pid)
	end
end

function navigation.onfivehourupdate(player)
	if not player.navigation_updated then
		net.navigation.S2C.needupdate(player)
		player.navigation_updated = true
	end
end

function navigation.open_navigationui(player)
	if not player.navigation_updated then
		return
	end
	local navigatedata = navigation.getnavigation(player)
	net.navigation.S2C.sendactivitydata(player,navigatedata)
end

function navigation.do_livenessaward(player,awardid)
	local navigatedata = navigation.getnavigation(player)
	if table.find(navigatedata.awardrecord,awardid) then
		return
	end
	local data = data_1100_LivenessAward[awardid]
	if not data then
		return
	end
	if navigatedata.liveness < data.needliveness then
		net.msg.S2C.notify(player.pid,language.format("活跃度不足，无法领取该奖励。"))
		return
	end
	logger.log("info","navigation",format("[livenessaward] pid=%d awardid=%d",player.pid,awardid))
	table.insert(navigatedata.awardrecord,awardid)
	local item,num = data.item,data.num
	player:additembytype(item,num,nil,"livenessaward",true)
	net.navigation.S2C.sendactivitydata(player,navigatedata)
end

function navigation.addliveness(player,num)
	logger.log("info","navigation",string.format("[addliveness] pid=%d add=%d",player.pid,num))
	local navigatedata = navigation.getnavigation(player)
	navigatedata.liveness = navigatedata.liveness + num
	for awardid,data in pairs(data_1100_LivenessAward) do
		if not table.find(navigatedata.awardrecord,awardid) and navigatedata.liveness >= data.needliveness then
			net.navigation.S2C.showredpoint(player.pid)
			break
		end
	end
	return num
end

function navigation.do_activityaward(player,hid)
	local data = data_1100_Navigation[hid]
	if not data then
		return
	end
	local navigatedata = navigation.getnavigation(player)
	local activity = navigation.getactivity(player,hid)
	if activity.awarded then
		return
	end
	if activity.progress < data.progress then
		net.msg.S2C.notify(player.pid,language.format("进度不足，无法领取奖励"))
		return
	end
	logger.log("info","navigation",format("[actaward] pid=%d,hid=%d",player.pid,hid))
	activity.awarded = true
	if istrue(data.liveness) then
		navigation.addliveness(player,data.liveness)
	end
	doaward("player",player.pid,data.award,"navigation",true)
	net.navigation.S2C.sendactivitydata(player,navigatedata)
end

function navigation.lookstat(player)
	local stats = {}
	for id,data in pairs(data_1100_DailyStat) do
		if player.lv >= data.needlv and player.jobzs >= data.needzs then
			local cnt,limit
			if player.taskdb[data.flag] then
				local taskcontainer = player.taskdb[data.flag]
				if taskcontainer.getdailystat then
					cnt,limit = taskcontainer:getdailystat()
				else
					cnt = taskcontainer:getdonecnt()
					limit = taskcontainer:getdonelimit()
				end
			elseif huodongmgr.gethuodong(data.flag) then
				local huodong = huodongmgr.gethuodong(data.flag)
				if huodong.getdailystat then
					cnt,limit = huodong:getdailystat(player)
				end
			elseif huodongmgr.playunit[data.flag] then
				local playunit = huodongmgr.playunit[data.flag]
				if playunit.getdailystat then
					cnt,limit = playunit.getdailystat(player)
				end
			end
			if cnt and limit then
				table.insert(stats,{
					id = id,
					cnt = cnt,
					limit = limit,
				})
			end
		end
	end
	sendpackage(player.pid,"navigation","dailystat",{
		stats = stats,
	})
end

return navigation
