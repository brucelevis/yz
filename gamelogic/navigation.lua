navigation = navigation or {}

function navigation.init()
	navigation.activities = {}
	for hid,data in pairs(data_1100_Navigation) do
	end
end

function navigation.get_navigatedata(player)
	local navigatedata = player.today:get("navigatedata")
	if not navigatedata then
		navigatedata = {
			activities = {},	--各个玩法的奖励/进度情况 { id = 900, progress = 1, awarded = 0}
			liveness = 0,		--活跃度
			awardrecord = {},	--活跃度奖励领取记录
		}
		player.today.set("navigatedata",navigatedata)
	end
	return navigatedata
end

function navigation.set_navigatedata(player,navigatedata)
	player.today:set("navigatedata",navigatedata)
end

function navigation.getactivity(navigatedata,hid)
	local activity
	for _,value in ipairs(navigatedata.activities) do
		if value.id == hid then
			activity = value
			break
		end
	end
	if not activity then
		activity = {
			id = hid,
			progress = 0,
			awarded = false,
		}
		table.insert(navigatedata.activities,activity)
	end
	return activity
end

function navigation.addprogress(player,hid)
	local data = data_1103_Navigation[hid]
	if not data then
		return
	end
	local navigatedata = self:get_navigatedata(player)
	local actity = self:getactivity(navigatedata,hid)
end

function navigation.onlogin(player)
end

function navigation.ondayupdate()
end

function navigation.onhourupdate()
end

function navigation.onweekupdate()
end

function navigation.askfor_activitydata(player)
end

function navigation.do_livenessaward(player,awardid)
	local navigatedata = navigation.get_navigatedata(player)
	if table.find(navigatedate.awardrecord,awardid) then
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
	navigation.set_navigatedata(player,navigatedata)
	local item,num = data.item,data.num
	player:additembytype(item,num,nil,"livenessaward")
end

function navigation.do_activityaward(player,hid)
	local data = data_1100_Navigation[hid]
	if not data then
		return
	end
	local navigatedata = navigation.get_navigatedata(player)
	local activity = navigation.getactivity(navigatedata,hid)
	if activity.awarded then
		return
	end
	if activity.progress < data.progress then
		net.msg.S2C.notify(player,pid,language.format("进度不足，无法领取奖励"))
		return
	end
	logger.log("info","navigation",format("[actaward] pid=%d,hid=%d",player.pid,hid))
	activity.awarded = true
	navigation.set_navigatedata(player,navigatedata)
	local item,num = data.item,data.num
	player:additembytype(item,num,nil,"actaward")
	if data.coin ~= 0 then
		player:addcoin(data.coin,"actaward")
	end
	if data.sliver ~= 0 then
		player:addsilver(data.silver,"actaward")
	end
end

return navigation
