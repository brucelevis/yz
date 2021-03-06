cteammgr = class("cteammgr",ccontainer)

function cteammgr:init()
	ccontainer.init(self,{
		name = "cteammgr",
	})
	self.pid_teamid = {}
	self.automatch_pids = {}
	self.automatch_teams = {}
	self.publish_teams = {}
	self.openui_pids = {}
end

function cteammgr:clear()
	ccontainer.clear(self)
	self.pid_teamid = {}
	self.automatch_pids = {}
	self.authmatch_teams = {}
	self.publish_teams = {}
end

function cteammgr:onlogin(player)
	local pid = player.pid
	local team = self:getteambypid(pid)
	if team then
		team:onlogin(player)
	end
end

function cteammgr:onlogoff(player,reason)
	local pid = player.pid
	local team = self:getteambypid(pid)
	if team then
		team:onlogoff(player,reason)
	end
end

function cteammgr:fromsrv(teamid)
	return globalmgr.srvname(teamid)
end

function cteammgr:publishteam(player,param)
	local pid = player.pid
	local team = self:getteambypid(pid)
	if not team or team.captain ~= pid then
		return
	end
	local publish = self.publish_teams[team.id]
	if publish then
		-- 发布队伍过期检查粒度为30s，因此发布的队伍失效最大可能有30s延迟
		local lefttime = publish.time + publish.lifetime - os.time()
		if lefttime <= 0 then
			self:delpublishteam(team.id)
		else
			net.msg.S2C.notify(pid,language.format("还有#<R>{1}秒#才能再次发布",lefttime))
			return
		end
	else
		net.msg.S2C.notify(pid,language.format("成功发布队伍招募信息"))
	end
	team.target = param.target
	team.minlv = param.minlv
	team.maxlv = param.maxlv
	local captain = playermgr.getplayer(team.captain) or resumemgr.getresume(team.captain)
	local publish = {
		teamid = team.id,
		target = team.target,
		minlv = team.minlv,
		maxlv = team.maxlv,
		captain = team:packmember(captain),
		len = team:len(TEAM_STATE_ALL),
		fromsrv = cserver.getsrvname(),
	}
	self:_publishteam(publish)
	cserver.pcall_in_samezone("rpc","teammgr:_publishteam",publish)
end

function cteammgr:_publishteam(publish)
	local now = os.time()
	local data = data_0301_TeamTarget[publish.target]
	local lifetime = data.lifetime or 120
	self.publish_teams[publish.teamid] = {
		time = now,
		lifetime = lifetime,
		fromsrv = publish.fromsrv,
	}
	local package = {
		publishteam = publish,
	}
	playermgr.broadcast(function (obj)
		sendpackage(obj.pid,"team","publishteam",package)
	end)
end

function cteammgr:pack_publishteam(teamid)
	local fromsrv = self:fromsrv(teamid)
	if fromsrv ~= cserver.getsrvname() then
		-- 跨服发布的队伍
		return rpc.call(fromsrv,"rpc","teammgr:pack_publishteam",teamid)
	end
	local publish = self.publish_teams[teamid]
	if not publish then
		return
	end
	local team = self:getteam(teamid)
	if not team then
		return
	end
	local captain = playermgr.getplayer(team.captain)
	if not captain then
		captain = resumemgr.getresume(team.captain)
	end
	local package = {
		teamid = team.id,
		time = publish.time,
		target = team.target,
		minlv = team.minlv,
		maxlv = team.maxlv,
		captain = team:packmember(captain),
		len = team:len(TEAM_STATE_ALL),
		fromsrv = fromsrv,
	}
	return package
end

function cteammgr:delpublishteam(teamid)
	local publish = self.publish_teams[teamid]
	if publish then
		logger.log("info","team",string.format("[delpublishteam] teamid=%d",teamid))
		self.publish_teams[teamid] = nil
		playermgr.broadcast(function (obj)
			sendpackage(obj.pid,"team","delpublishteam",{
				teamid = teamid,
			})
		end)
		local fromsrv = self:fromsrv(teamid)
		if fromsrv == cserver.getsrvname() then
			cserver.pcall_in_samezone("rpc","teammgr:delpublishteam",teamid)
		end
	end
end

function cteammgr:addapplyer(teamid,applyer)
	local team = self:getteam(teamid)
	if not team and teamid ~= 0 then
		local fromsrv = self:fromsrv(teamid)
		if fromsrv ~= cserver.getsrvname() then
			return rpc.call(fromsrv,"rpc","teammgr:addapplyer",teamid,applyer)
		end
		return
	end
	if not team and teamid == 0 then
		return false,language.format("该队伍已解散")
	end
	if team:len(TEAM_STATE_ALL) >= team:maxlen() then
		return false,language.format("该队伍人数已满")
	end
	return team:addapplyer(applyer)
end

function cteammgr:pack_applyer(player)
	return {
		pid = player.pid,
		name = player.name,
		lv = player.lv,
		joblv = player.joblv,
		roletype = player.roletype,
		fromsrv = cserver.getsrvname(),
	}
end

function cteammgr:starttimer_check_publishteam()
	timer.timeout("timer.check_publishteam",30,functor(self.starttimer_check_publishteam,self))
	local now = os.time()
	for teamid,publish in pairs(self.publish_teams) do
		if publish.lifetime and publish.lifetime + publish.time <= now then
			self:delpublishteam(teamid)
		end
	end
end

function cteammgr:createteam(player,param)
	local pid = player.pid
	local teamid = self:teamid(pid)
	if teamid then
		return
	end
	param.captain = pid
	local team = cteam.new(param)
	self:addteam(team)
	logger.log("info","team",format("[createteam] pid=%d teamid=%d param=%s",pid,team.id,param))
	resumemgr.push(pid,{
		teamstate = TEAM_STATE_CAPTAIN,
		teamid = team.id,
	})
	return team
end

-- 该接口已作废
-- 解散队伍接口不应该支持，只会引入复杂性
function cteammgr:dismissteam(player)
	if true then
		return
	end
	local pid = player.pid
	local team = self:getteambypid(pid)
	if not team then
		return
	end
	logger.log("info","team",string.format("[dismissteam] pid=%d teamid=%d",pid,team.id))
	self:delteam(team.id)
	return true
end

function cteammgr:_jointeam(pid,teamid,bquitteam)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	if bquitteam then
		self:quitteam(player)
	end
	local isok,errmsg = self:jointeam(player,teamid)
	if not isok and errmsg then
		net.msg.S2C.notify(player.pid,errmsg)
	end
end

function cteammgr:jointeam(player,teamid)
	local pid = player.pid
	if self:teamid(pid) then
		return
	end
	local fromsrv = self:fromsrv(teamid)
	if fromsrv ~= cserver.getsrvname() then
		playermgr.gosrv(player,fromsrv,pack_function("teammgr:_jointeam",player.pid,teamid))
		return
	end

	local team = self:getteam(teamid)
	if not team then
		return false,language.format("队伍已失效")
	end
	if team:len(TEAM_STATE_ALL) >= team:maxlen() then
		return false,language.format("队伍人数已满")
	end
	logger.log("info","team",string.format("[jointeam] pid=%d teamid=%d",pid,team.id))
	team:join(player)
	self:unautomatch(pid,"jointeam")
	self:onjointeam(player,team.id)
	local captain = playermgr.getplayer(team.captain)
	if teammgr:needbackteam(player,captain) then
		teammgr:backteam(player)
	else
		openui.messagebox(player.pid,{
			type = MB_NOTIFY_BACKTEAM,
			title = language.format("归队提示"),
			content = language.format("是否立即回归队伍"),
			buttons = {
				openui.button("取消"),
				openui.button("归队",5),
			},
			lifetime = 5,
			attach = {},},
			function (uid,request,response)
				local player = playermgr.getplayer(uid)
				if not player then
					return
				end
				if not (response.answer == 2 or openui.istimeout(response.answer)) then
					return
				end
				teammgr:backteam(player)
			end)
	end
	sendpackage(pid,"team","selfteam",{
		team = team:pack(),
	})
	local scene = scenemgr.getscene(player.sceneid)
	local teamstate = team:teamstate(pid)
	scene:set(pid,{
		teamid = team.id,
		teamstate = teamstate,
	})
	return true
end

function cteammgr:quitteam(player)
	local pid = player.pid
	local team = self:getteambypid(pid)
	if not team then
		return
	end
	logger.log("info","team",string.format("[quitteam] pid=%d teamid=%d",pid,team.id))
	team:quit(player.pid)
	team:say(language.format("【{1}】离开了队伍",language.untranslate(player.name)))
	net.msg.S2C.notify(pid,language.format("成功退出队伍"))
	self:onquitteam(player.pid,team.id)
	return true
end

function cteammgr:kickmember(player,targetid)
	local pid = player.pid
	local team = teammgr:getteambypid(pid)
	if not team or team.captain ~= pid then
		return
	end
	logger.log("info","team",string.format("[kickmember] pid=%d teamid=%d targetid=%d",pid,team.id,targetid))
	team:quit(targetid)
	local target_name = resumemgr.get(targetid,"name")
	team:say(language.format("【{1}】被请离了队伍",language.untranslate(target_name)))
	net.msg.S2C.notify(targetid,language.format("你已被队长请离队伍"))
	self:onquitteam(targetid,team.id)
end

-- 暂离队伍
function cteammgr:leaveteam(player)
	local pid = player.pid
	local team = self:getteambypid(pid)
	if not team or team.captain == pid then
		return
	end
	if team.leave[pid] then
		return
	end
	logger.log("info","team",string.format("[leaveteam] pid=%d teamid=%d",pid,team.id))
	team:leaveteam(player)
	self:onleaveteam(player,team.id)
	return true
end

function cteammgr:backteam(player)
	local pid = player.pid
	local team = self:getteambypid(pid)
	if not team then
		return
	end
	if not team.leave[pid] then
		return
	end
	local captain = playermgr.getplayer(team.captain)
	if not captain then
		return false
	end
	local isok,errmsg = self:canbackteam(player)
	if not isok then
		net.msg.S2C.notify(player.pid,errmsg)
		return false
	end
	if not player:jumpto(captain.sceneid,captain.pos) then
		return
	end
	logger.log("info","team",string.format("[backteam] pid=%d teamid=%d",pid,team.id))
	team:back(player)
	self:onbackteam(player,team.id)
	return true
end

function cteammgr:teamid(pid)
	return self.pid_teamid[pid]
end

function cteammgr:getteam(teamid)
	return self:get(teamid)
end

function cteammgr:getteambypid(pid)
	local teamid = self:teamid(pid)
	if not teamid then
		return
	end
	local team = self:getteam(teamid)
	if not team then
		self.pid_teamid[pid] = nil
	end
	return team
end

-- 全服共享队伍ID
function cteammgr:genid()
	return globalmgr.genid("team")
end

function cteammgr:addteam(team,id)
	id = id or self:genid()
	self:add(team,id)
	return team.id
end

function cteammgr:onadd(team)
	team.channel = string.format("team#%d",team.id)
	channel.add(team.channel)
	channel.subscribe(team.channel,team.captain)
	self.pid_teamid[team.captain] = team.id
	local captain = playermgr.getplayer(team.captain)
	local scene = scenemgr.getscene(captain.sceneid)
	scene:set(captain.pid,{
		teamid = team.id,
		teamstate = team:teamstate(captain.pid),
	})
	sendpackage(captain.pid,"team","selfteam",{
		team = team:pack(),
	})
	self:unautomatch(team.captain,"createteam")
	self:oncreateteam(team)
end


function cteammgr:delteam(teamid)
	local team = self:getteam(teamid)
	if team then
		logger.log("info","team",string.format("[delteam] teamid=%d",teamid))
		self:del(teamid)
		return team
	end
end

function cteammgr:ondel(team)
	for pid,_ in pairs(team.leave) do
		team:quit(pid)
	end
	for pid,_ in pairs(team.follow) do
		team:quit(pid)
	end
	if team.captain then
		team:quit(team.captain)
	end
	channel.del(team.channel)
	self:team_unautomatch(team.id,"delteam")
	self:delpublishteam(team.id)
end

function cteammgr:changecaptain(teamid,tid)
	local team = self:getteam(teamid)
	if not team then
		return
	end
	logger.log("info","team",string.format("[changecaptain] teamid=%d captain=%d->%d",team.id,team.captain,tid))
	team:changecaptain(tid)
	self:onchangecaptain(team.id,tid)
	return true
end

function cteammgr:team_changetarget(player,target,minlv,maxlv)
	local pid = player.pid
	local team = self:getteambypid(pid)
	if not team or team.captain ~= pid then
		return
	end
	logger.log("info","team",string.format("[team_changetarget] teamid=%s target=%s minlv=%s maxlv=%s",team.id,target,minlv,maxlv))
	team.target = target
	team.minlv = minlv
	team.maxlv = maxlv
	team:broadcast(function (uid)
		sendpackage(uid,"team","updateteam",{
			team = {
				teamid = team.id,
				target = team.target,
				minlv = team.minlv,
				maxlv = team.maxlv,
			}
		})
	end)
end

function cteammgr:automatch_changetarget(player,target,minlv,maxlv)
	local pid = player.pid
	local teamid = self:teamid(pid)
	if teamid then
		return
	end
	local automatch = self.automatch_pids[pid]
	if not automatch then
		return
	end
	logger.log("info","team",string.format("[automatch_changetarget] pid=%s target=%s minlv=%s maxlv=%s",pid,target,minlv,maxlv))
	automatch.target = target
	automatch.minlv = minlv
	automatch.maxlv = maxlv
end

function cteammgr:sync_automatch()
	local nowtime = os.time()
	local lasttime = self.lasttime or 0
	if nowtime == lasttime then
		if not self.isdelay then
			timer.timeout("timer.sync_automatch",1,functor(self.sync_automatch,self))
			self.isdelay = true
		end
		return
	end
	local waiting_num = table.count(teammgr.automatch_pids)
	for pid,_ in pairs(self.openui_pids) do
		local player = playermgr.getplayer(pid)
		if player then
			sendpackage(pid,"team","sync_automatch",{
				waiting_num = waiting_num
			})
		end
	end
	self.lasttime = nowtime
	self.isdelay = nil
end

function cteammgr:automatch(player,target,minlv,maxlv)
	local pid = player.pid
	logger.log("info","team",string.format("[automatch] pid=%d target=%s minlv=%s maxlv=%s",pid,target,minlv,maxlv))
	local automatch = {
		automatch = true,
		time = os.time(),
		pid = pid,
		name = player.name,
		minlv = minlv,
		maxlv = maxlv,
		roletype = player.roletype,
		target = target,
	}
	self.automatch_pids[pid] = automatch
	self:sync_automatch()
end

function cteammgr:unautomatch(pid,reason)
	local matchdata = self.automatch_pids[pid]
	if matchdata then
		logger.log("info","team",string.format("[unautomatch] pid=%d reason=%s",pid,reason))
		self.automatch_pids[pid] = nil
	end
	self:sync_automatch()
end

function cteammgr:team_automatch(teamid)
	local team = self:getteam(teamid)
	if not team then
		return
	end
	logger.log("info","team",string.format("[team_automatch] teamid=%s",teamid))
	self.automatch_teams[teamid] = {
		time = os.time(),
	}
	team:broadcast(function (uid)
		sendpackage(uid,"team","updateteam",{
			team = {
				teamid = team.id,
				automatch = true,
			}
		})
	end)

end

function cteammgr:team_unautomatch(teamid,reason)
	local matchdata = self.automatch_teams[teamid]
	if matchdata then
		logger.log("info","team",string.format("[team_unautomatch] teamid=%d reason=%s",teamid,reason))
		self.automatch_teams[teamid] = nil
	end
end

function cteammgr:check_match_team(player)
	local pid = player.pid
	local matchdata = self.automatch_pids[pid]
	if not matchdata then
		return
	end
	local match_teams = {}
	for teamid,v in pairs(self.automatch_teams) do
		local team = self:getteam(teamid)
		if team then
			if team:len(TEAM_STATE_ALL) < team:maxlen() then
				-- 目标: 0 -- 无目标；1001 -- 不限
				if team.target == 1001 or matchdata.target == 1001 or team.target == matchdata.target then
					--if team.minlv <= matchdata.minlv and matchdata.minlv <= team.maxlv or
					--	team.minlv <= matchdata.maxlv and matchdata.maxlv <= team.maxlv then
					--	table.insert(match_teams,teamid)
					--end
					if team.minlv <= player.lv and player.lv <= team.maxlv then
						table.insert(match_teams,teamid)
					end
				end
			end
		else
			self:team_unautomatch(teamid,"invalid_team")
		end
	end
	if not next(match_teams) then
		return
	end
	-- 优先规则: 队伍人数 >  自动匹配时间
	table.sort(match_teams,function (teamid1,teamid2)
		local match1 = self.automatch_teams[teamid1]
		local match2 = self.automatch_teams[teamid2]
		local team1 = self:getteam(teamid1)
		local team2 = self:getteam(teamid2)
		local len1 = team1:len(TEAM_STATE_ALL)
		local len2 = team2:len(TEAM_STATE_ALL)
		if len1 > len2 then
			return true
		end
		if len1 == len2 and 
			match1.time < match2.time then
			return true
		end
		return false
	end)
	local teamid = match_teams[1]
	self:jointeam(player,teamid)
end


function cteammgr:starttimer_automatch()
	timer.timeout("timer.automatch",10,functor(self.starttimer_automatch,self))
	local cnt = 0
	for pid,v in pairs(self.automatch_pids) do
		local player = playermgr.getplayer(pid)
		if player then
			cnt = cnt + 1
			self:check_match_team(player)
			if cnt >= 20 then
				break
			end
		end
	end
end

function cteammgr:packteam(teamid)
	local team = self:getteam(teamid)
	return team:pack()
end

function cteammgr:transfer_team(packteam)
	local captain = playermgr.getplayer(packteam.captain)
	if not captain then
		return
	end
	local team = self:createteam(captain,{
		target = packteam.target,
		minlv = packteam.minlv,
		maxlv = packteam.maxlv,
		captain = packteam.captain,
		createtime = packteam.createtime,
	})
	if not team then
		return
	end
	for i,pid in ipairs(packteam.members) do
		skynet.fork(rpc.pcall,packteam.srvname,"rpc","teammgr:_jointeam",pid,team.id,true)
	end
end

function cteammgr:gosrv(teamid,srvname)
	local team = self:getteam(teamid)
	if not team then
		return
	end
	local captain = playermgr.getplayer(team.captain)
	if not captain then
		return
	end
	local members = team:members(TEAM_STATE_FOLLOW)
	--for i,pid in ipairs(members) do
	--	local member = playermgr.getplayer(pid)
	--	self:quitteam(member)
	--end
	local packteam = {
		srvname = cserver.getsrvname(),
		teamid = teamid,
		target = team.target,
		minlv = team.minlv,
		maxlv = team.maxlv,
		createtime = team.createtime,
		captain = captain.pid,
		members = members,
	}
	playermgr.gosrv(captain,srvname,pack_function("teammgr:transfer_team",packteam))
end

function cteammgr:oncreateteam(player,teamid)
end


function cteammgr:onjointeam(player,teamid)
end

function cteammgr:onleaveteam(player,teamid)
	huodongmgr.onleaveteam(player,teamid)
end

function cteammgr:onbackteam(player,teamid)
	huodongmgr.onbackteam(player,teamid)
end

function cteammgr:onchangecaptain(teamid,pid)
end


-- 踢出成员也会走这里接口
function cteammgr:onquitteam(pid,teamid)
	local player = playermgr.getplayer(pid)
	if player then
		huodongmgr.onquitteam(player,teamid)
	end
end

function cteammgr:needbackteam(player,captain)
	if captain and player.sceneid == captain.sceneid then
		-- 大约同屏大小
		if getdistance(captain.pos,player.pos) < 1000 then
			return true
		end
	end
end

function cteammgr:canbackteam(player)
	local isok,errmsg = huodongmgr.canbackteam(player)
	if not isok then
		return false,errmsg
	end
	if player:warid() then
		return false,language.format("战斗中无法归队")
	end
	return true
end


function cteammgr.startgame()
	teammgr = cteammgr.new()
	teammgr:starttimer_automatch()
	teammgr:starttimer_check_publishteam()
end

return cteammgr
