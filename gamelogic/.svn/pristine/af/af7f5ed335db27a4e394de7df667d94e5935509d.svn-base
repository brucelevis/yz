cunion = class("cunion")

function cunion:init(param)
	self.id = assert(param.id)
	self.money = param.money or 0
	self.name = param.name
	self.purpose = param.purpose
	self.notice = param.notice
	self.badge = param.badge or {
		background = 1,  -- 背景
		maincolor = 1,   -- 主颜色
		minorcolor = 1,  -- 次颜色
		design = 1,	  -- 图案
	}
	self.job_members = {}      -- {[职位ID] = {玩家ID,...}}
	self.members = cunionmembers.new({
		name = "union",
		id = self.id,
	})
	self.applyers = {}		  -- 申请列表
	self.inviters = {}		  -- 邀请列表

	self.cangku = cunioncangku.new({
		name = "union_cangku",
		type = 0,
		pid = self.id,
	})

	-- 帮派建筑
	self.dating_lv = 1
	self.zuofang_lv = 0
	self.jitan_lv = 0
	self.cangku_lv = 0
	self.yingdi_lv = 0
	self.shangdian_lv = 0

	self.thistemp = cthistemp.new({
		pid = self.id,
		flag = "cunion",
	})
	self.today = ctoday.new({
		pid = self.id,
		flag = "cunion",
	})
	self.votemgr = cvotemgr.new()
	self.openui_pids = {}		-- 打开帮派界面的玩家ID
	self.collect_cards = {}
	if param.leader then
		self:add(param.leader)
	end
end

function cunion:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
	self.money = data.money
	self.name = data.name
	self.purpose = data.purpose
	self.notice = data.notice
	self.badge = data.badge
	self.dating_lv = data.dating_lv
	self.zuofang_lv = data.zuofang_lv
	self.jitan_lv = data.jitan_lv
	self.cangku_lv = data.cangku_lv
	self.shangdian_lv = data.shangdian_lv
	self.thistemp:load(data.thistemp)
	self.members:load(data.members)
	for pid,member in pairs(self.members.objs) do
		local jobid = member.jobid
		if not self.job_members[jobid] then
			self.job_members[jobid] = {}
		end
		table.insert(self.job_members[jobid],pid)
	end
	self.votemgr:load(data.votemgr)
	self.cangku:load(data.cangku)
end

function cunion:save()
	local data = {}
	data.id = self.id
	data.money = self.money
	data.name = self.name
	data.purpose = self.purpose
	data.notice = self.notice
	data.badge = self.badge
	data.dating_lv = self.dating_lv
	data.zuofang_lv = self.zuofang_lv
	data.jitan_lv = self.jitan_lv
	data.cangku_lv = self.cangku_lv
	data.shangdian_lv = self.shangdian_lv
	data.thistemp = self.thistemp:save()
	data.members = self.members:save()
	data.votemgr = self.votemgr:save()
	data.cangku = self.cangku:save()
	return data
end

function cunion:loadfromdatabase()
	if not self.loadstate or self.loadstate == "unload" then
		self.loadstate = "loading"
		local db = dbmgr.getdb()
		local data = db:get(db:key("union",self.id))
		assert(data and next(data))
		self:load(data)
		self.loadstate = "loaded"
	end
end

function cunion:savetodatabase()
	if self.loadstate == "loaded" then
		local data = self:save()
		local db = dbmgr.getdb()
		db:set(db:key("union",self.id),data)
	end
end

function cunion:deletefromdatabase()
	local db = dbmgr.getdb()
	db:del(db:key("union",self.id))
end

function cunion:onlogin(player)
end

function cunion:onlogoff(player)
end

function cunion:add(member)
	local pid = assert(member.pid)
	local jobid = assert(member.jobid)
	rpc.callplayer(pid,"playermethod",pid,":onaddtounion",self.id,member)
	self:delapplyer(pid)
	logger.logf("info","union","[add] unionid=%d member=%s",self.id,member)
	self.members:add(member,pid)
	unionmgr.pid_unionid[pid] = self.id
	if not self.job_members[jobid] then
		self.job_members[jobid] = {}
	end
	table.insert(self.job_members[jobid],pid)
	local pids = table.keys(self.openui_pids)
	unionmgr:sendpackage(pids,"union","addmember",{
		member = member,
	})
	if member.jobid ~= unionaux.jobid("会长") then
		mailmgr.sendmail(pid,{
			srcid = SYSTEM_MAIL,
			author = language.format("公会管理员"),
			title = language.format("加入公会通知"),
			content = language.format("恭喜，你加入了【{1}】成为了【{2}】的公会成员",
						language.untranslate(self.name),
						language.untranslate(self.name)),
		})
		local srvname_pids = unionmgr:srvname_pids(pids)
		for srvname,pids in pairs(srvname_pids) do
			skynet.fork(rpc.pcall,srvname,"rpc","net.msg.broadcast",pids,"msg","unionmsg",{
				sender = {
					pid = SENDER.UNION,
				},
				msg = language.format("【{1}】加入公会【热烈欢迎】",
						language.untranslate(self:memberget(pid,"name"))),
			})
		end
	end
end

function cunion:member(pid)
	local member = self.members:get(pid)
	if member and member.banspeak then
		if member.banspeak < os.time() then
			member.banspeak = nil
		end
	end
	return member
end

function cunion:memberget(pid,key)
	local resume = resumemgr.getresume(pid)
	return resume:get(key)
end

function cunion:del(pid)
	local member = self:member(pid)
	if member then
		rpc.callplayer(pid,"playermethod",pid,":ondelfromunion",self.id)
		logger.logf("info","union","[del] unionid=%d member=%s",self.id,member)
		self.members:del(pid)
		unionmgr.pid_unionid[pid] = nil
		local members = self.job_members[member.jobid]
		if members then
			local pos = table.find(members,pid)
			if pos then
				table.remove(members,pos)
			end
		end

		local pids = table.keys(self.openui_pids)
		unionmgr:sendpackage(pids,"union","delmember",{
			pid = pid,
		})
	end
end

function cunion:addapplyer(pid)
	table.insert(self.applyers,pid)
	local pids = table.keys(self.openui_pids)
	local limit = data_1800_UnionVar.ApplyerMaxLimit
	if #self.applyers >= limit then
		local remove_applyer = table.remove(self.applyers,1)
		self:delapplyer(remove_applyer)
	end
	unionmgr:sendpackage(pids,"union","addapplyer",{
		applyer = pid,
	})
end

function cunion:delapplyer(pid)
	local pids
	if type(pid) == "number" then
		pids = {pid,}
	else
		pids = pid
	end
	local remove_pids = {}
	for i,pid in ipairs(pids) do
		local pos = table.find(self.applyers,pid)
		if pos then
			table.remove(self.applyers,pos)
			table.insert(remove_pids,pid)
		end
	end
	local pids = table.keys(self.openui_pids)
	unionmgr:sendpackage(pids,"union","delapplyer",{
		pids = remove_pids,
	})
end

function cunion:changejob(member,jobid2)
	local pid = member.pid
	local jobid1 = member.jobid
	logger.log("info","union",string.format("[changejob] unionid=%s pid=%s jobid1=%s jobid2=%s",self.id,pid,jobid1,jobid2))
	if self.job_members[jobid1] then
		local pos = table.find(self.job_members[jobid1],pid)
		if pos then
			table.remove(self.job_members[jobid1],pos)
		end
	end
	if not self.job_members[jobid2] then
		self.job_members[jobid2] = {}
	end
	table.insert(self.job_members[jobid2],pid)
	member.jobid = jobid2
	local pids = table.keys(self.openui_pids)
	unionmgr:sendpackage(pids,"union","updatemember",{
		id = self.id,
		member = {
			pid = member.pid,
			jobid = member.jobid,
		}
	})
	unionmgr:sendpackage(member.pid,"union","selfunion",{
		unionid = self.id,
		jobid = member.jobid,
	})

end

function cunion:changename(name)
	self:update({
		name = name,
	})
end

function cunion:changebadge(badge)
	self:update({
		badge = badge,
	})
end

function cunion:edit_purpose(purpose)
	self:update({
		purpose = purpose,
	})
end

function cunion:edit_notice(notice)
	self:update({
		notice = notice,
	})
end

function cunion:addmoney(addval,reason)
	local oldval = self.money
	local newval = oldval + addval
	local maxval = data_1800_UnionCangKu[self.cangku_lv].money_limit
	newval = math.min(newval,maxval)
	self:update({
		money = newval,
	})
	return newval - oldval
end

function cunion:addoffer(pid,offer,reason)
	local member = self:member(pid)
	local newval = member.offer + offer
	assert(newval >= 0)
	member.offer = newval
	if offer > 0 then
		member.sum_offer = member.sum_offer + offer
		member.week_offer = member.week_offer + offer
	end
	local pids = table.keys(self.openui_pids)
	unionmgr:sendpackage(pids,"union","updatemember",{
		id = self.id,
		member = {
			pid = member.pid,
			offer = member.offer,
			sum_offer = member.sum_offer,
			week_offer = member.week_offer,
		}
	})
	return offer
end

function cunion:addwarcnt(pid,cnt)
	cnt = cnt or 1
	local member = self:member(pid)
	member.warcnt = member.warcnt + cnt
	local pids = table.keys(self.openui_pids)
	unionmgr:sendpackage(pids,"union","updatemember",{
		id = self.id,
		member = {
			pid = member.pid,
			warcnt = member.warcnt,
		}
	})
end

function cunion:update(attrs)
	for k,v in pairs(attrs) do
		self[k] = v
	end
	local pids = table.keys(self.openui_pids)
	attrs.id = self.id
	unionmgr:sendpackage(pids,"union","update_union",{
		union = attrs
	})
end

function cunion:reachlimit()
	local data = data_1800_UnionYingDi[self.yingdi_lv]
	return self.members.len >= data.limit,data.limit
end

function cunion:getlv()
	return self.dating_lv
end

function cunion:leader()
	local pids = self.job_members[unionaux.jobid("会长")]
	local pid = pids[1]
	return self:member(pid)
end

function cunion:packleader(pid)
	local resume = resumemgr.getresume(pid)
	return {
		pid = pid,
		name = resume:get("name"),
		lv = resume:get("lv"),
		joblv = resume:get("joblv"),
		jobid = resume:get("jobid"),
		roletype = resume:get("roletype"),
	}
end

function cunion:pack(isresume)
	local leader = self:leader()
	local leader_resume = resumemgr.getresume(leader.pid)
	local data = {
		id = self.id,
		name = self.name,
		money = self.money,
		purpose = self.purpose,
		badge = self.badge,
		dating_lv = self.dating_lv,
		zuofang_lv = self.zuofang_lv,
		jitan_lv = self.jitan_lv,
		cangku_lv = self.cangku_lv,
		yingdi_lv = self.yingdi_lv,
		shangdian_lv = self.shangdian_lv,
		len = self.members.len,
	}
	data.leader = self:packleader(leader.pid)
	data.fu_leaders = {}
	local pids = self.job_members[unionaux.jobid("副会长")] or {}
	for i,pid in ipairs(pids) do
		table.insert(data.fu_leaders,self:packleader(pid))
	end
	if not isresume then
		data.notice = self.notice
	end
	return data
end

function cunion:getvote(typ)
	local id_vote = self.votemgr.type_id_vote[typ]
	if id_vote then
		local id,vote = next(id_vote)
		return id,vote
	end
end

function cunion:can_banspeak(pid,tid)
	local member1 = self:member(pid)
	local member2 = self:member(tid)
	if not member2 then
		return false,language.format("对方不是本公会成员")
	end
	local cando,jobids = unionaux.cando(member1.jobid,"banspeak")
	if not cando then
		return false,language.format("你没有权限进行此项操作")
	end
	if not table.find(jobids,member2.jobid) then
		return false,language.format("你没有权限进行此项操作")
	end
	return true
end

function cunion:banspeak(pid)
	local member = self:member(pid)
	member.banspeak = os.time() + 1800
	local pids = table.keys(self.openui_pids)
	unionmgr:sendpackage(pids,"union","updatemember",{
		id = self.id,
		member = {
			pid = member.pid,
			banspeak = member.banspeak,
		}
	})
end

function cunion:unbanspeak(pid)
	local member = self:member(pid)
	member.banspeak = nil
	local pids = table.keys(self.openui_pids)
	unionmgr:sendpackage(pids,"union","updatemember",{
		id = self.id,
		member = {
			pid = member.pid,
			banspeak = 0,
		}
	})
end

function cunion:pack_collect_card(session)
	local pid = session.creater
	local resume = resumemgr.getresume(pid)
	return {
		id = session.id,
		cardtype = session.cardtype,
		num = session.num,
		has_donate = session.has_donate,
		createtime = session.createtime,
		lifetime = session.lifetime,
		creater = {
			pid = pid,
			name = resume:get("name"),
		},
	}
end

function cunion:collect_card(pid,cardtype,num)
	local needlv = data_1800_UnionVar.CollectCardNeedUnionLv
	if self:getlv() < needlv then
		return false,language.format("需要#<R>{1}#级以上公会才开放此功能",needlv)
	end
	local member = self:member(pid)
	assert(member)
	local carddata = itemaux.getitemdata(cardtype)
	local costoffer = data_1800_UnionVar.CollectCardCostOffer[carddata.quality]
	if member.offer < costoffer then
		return false,language.format("公会贡献不足{1}",costoffer)
	end
	self:addoffer(pid,-costoffer,"collect_card")
	local session = {
		cardtype = cardtype,
		num = num,
		has_donate = 0,
		createtime = os.time(),
		lifetime = data_1800_UnionVar.CollectCardLifeTime,
		creater = pid,
		donater = {
		},
	}
	local id = globalmgr.genid("collect_card")
	session.id = id
	self.collect_cards[id] = session
	local pids = table.keys(self.members.objs)
	unionmgr:sendpackage(pids,"union","collect_card",{
		session = self:pack_collect_card(session),
	})
	return true
end

function cunion:donate_card(id,pid,cardtype,num)
	local needlv = data_1800_UnionVar.CollectCardNeedUnionLv
	if self:getlv() < needlv then
		return false,language.format("需要#<R>{1}#级以上公会才开放此功能",needlv)
	end
	local session = self:get_collect_card(id)
	if not session then
		return false,language.format("该集卡已失效")
	end
	if session.cardtype ~= cardtype then
		return false,language.format("捐献的卡片类型错误")
	end
	if session.has_donate + num > session.num then
		return false,language.format("捐献的卡片数量将超出本次集卡上限")
	end
	local carddata = itemaux.getitemdata(cardtype)
	local quality = carddata.quality
	local donate_maxnum = data_1800_UnionVar.DonateCardMaxNumPerSession
	local fake_num = quality == 2 and num * data_1800_UnionVar.HighLevelCardMulti or num
	if session.donater[pid] and session.donater[pid] >= donate_maxnum then
		return false,language.format("捐献给本次集卡的数量过多")
	end
	session.has_donate = session.has_donate + num
	if not session.donater[pid] then
		session.donater[pid] = 0
		session.donater[pid] = session.donater[pid] + fake_num
	end
	local addoffer = data_1800_UnionVar.DonateCardAddOffer[quality]
	self:addoffer(pid,addoffer,"donate_card")
	-- 同步进度
	local pids = table.keys(self.members.objs)
	unionmgr:sendpackage(pids,"union","collect_card",{
		session = self:pack_collect_card(session),
	})
	local resume = resumemgr.getresume(pid)
	mailmgr.sendmail(session.creater,{
		srcid = SYSTEM_MAIL,
		author = language.format("公会管理员"),
		title = language.format("公会集卡"),
		content = language.format("【{1}】向你捐献了{2}个【{3}】",
					language.untranslate(resume:get("name")),
					language.untranslate(num),
					carddata.name),
		attach = {
			items = {
				{type=cardtype,num=num,},
			}
		},
	})
	return true
end

function cunion:get_collect_card(id)
	local session = self.collect_cards[id]
	if session then
		local now = os.time()
		if session.createtime + session.lifetime < now then
			self.collect_cards[id] = nil

			local date = os.date("*t",session.createtime)
			local carddata = itemaux.getitemdata(session.cardtype)
			mailmgr.sendmail(session.creater,{
				srcid = SYSTEM_MAIL,
				author = language.format("公会管理员"),
				title = language.format("公会集卡"),

				content = language.format("你在{1}月{2}日{3}时{4}分发起的【{5}】集卡已经过期",
							language.untranslate(date.month),
							language.untranslate(date.day),
							language.untranslate(date.hour),
							language.untranslate(date.min),
							carddata.name),
			})
			return nil
		end
	end
	return session
end

function cunion:all_collect_card()
	local sessions = {}
	for id in pairs(self.collect_cards) do
		local session = self:get_collect_card(id)
		if session then
			table.insert(sessions,self:pack_collect_card(session))
		end
	end
	return sessions
end

function cunion:get_collect_item(pid)
	local key = string.format("collect_item.%s",pid)
	local tasks = self.today:query(key)
	if not tasks then
		local cnt = 10
		local show_ids = {}
		while cnt > 0 do
			local id = choosekey(data_1800_UnionCollectItem,function (k,v)
				if show_ids[k] then
					return 0
				end
				return v.ratio
			end)
			show_ids[id] = true
			cnt = cnt - 1
			local task = data_1800_UnionCollectItem[id]
			table.insert(tasks,{
				id = id,
				itemtype = task.itemtype,
				neednum = task.neednum,
				hasnum = 0,
				donater = {},
			})
		end
		self.today:set(key,tasks)
	end
	return tasks
end

function cunion:broadcast(typ,protoname,subprotoname,request)
	local pids
	if typ == "openui_pids" then
		pids = table.keys(self.openui_pids)
	elseif typ == "members" then
		pids = table.keys(self.members.objs)
	else
		error("[cunion:broadcast] Error Type:" .. tostring(typ))
	end
	unionmgr:sendpackage(pids,protoname,subprotoname,request)
end

function cunion:onfivehourupdate()
	local weekday = getweekday()
	if weekday == 1 then
		for pid,member in pairs(self.members.objs) do
			member.week_warcnt = 0
			member.week_offer = 0
		end
	end
end


return cunion
