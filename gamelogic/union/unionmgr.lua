cunionmgr = class("cunionmgr",ccontainer)

function cunionmgr:init()
	ccontainer.init(self,{
		name = "cunionmgr",
	})
	self.id = {}
	self.savename = "cunionmgr"
	autosave(self)

	-- cache
	self.pid_unionid = {}
end

-- unionmgr只负责自身属性存盘，其管理的union自身负责存盘逻辑
function cunionmgr:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
end

function cunionmgr:save()
	local data = {}
	data.id = self.id
	data.unions = table.keys(self.objs)
	return data
end

function cunionmgr:loadfromdatabase()
	if not self.loadstate or self.loadstate == "unload" then
		self.loadstate = "loading"
		local db = dbmgr.getdb()
		local data = db:get("unionmgr")
		self:load(data)
		local toload_union = {}
		if data and data.unions then
			for i,unionid in pairs(data.unions) do
				toload_union[unionid] = true
			end
		end
		if next(toload_union) then
			local co = coroutine.running()
			local function toloadunion(unionid)
				local union = cunion.new({
					id = unionid
				})
				union:loadfromdatabase()
				toload_union[unionid] = nil
				self:_addunion(union,unionid)
				if not next(toload_union) then
					skynet.wakeup(co)
				end
			end
			for unionid in pairs(toload_union) do
				skynet.fork(toloadunion,unionid)
			end
			skynet.wait(co)
		end
		self.loadstate = "loaded"
	end
end

function cunionmgr:savetodatabase()
	if self.loadstate == "loaded" then
		local data = self:save()
		local db = dbmgr.getdb()
		db:set("unionmgr",data)
	end
end

function cunionmgr:clear()
	logger.log("info","union","clearall")
	for unionid,union in pairs(self.objs) do
		for pid,member in pairs(union.members.objs) do
			union:del(pid)
		end
	end
	for unionid,union in pairs(self.objs) do
		self:delunion(unionid)
	end
	ccontainer.clear(self)
	self.pid_unionid = {}
end

function cunionmgr:genid(srvname)
	if not self.id[srvname] then
		self.id[srvname] = 0
	end
	local maxid = 100000
	self.id[srvname] = self.id[srvname] + 1
	if self.id[srvname] >= maxid then
		self.id[srvname] = 1
	end
	local srv = data_RoGameSrvList[srvname]
	return srv.srvno * maxid + self.id[srvname]
end

function cunionmgr:srvname(id)
	return globalmgr.srvname(id,100000)
end

function cunionmgr:broadcast_srvnames(srvname)
	return table.keys(data_RoGameSrvList)
end

function cunionmgr:samezone_srvnames(srvname)
	return cserver.samezone_srvnames(srvname)
end

function cunionmgr:unionid(pid)
	if not self.pid_unionid[pid] then
		local srvname = globalmgr.home_srvname(pid)
		local srvnames = self:samezone_srvnames(srvname)
		for unionid,union in pairs(self.objs) do
			local srvname = self:srvname(unionid)
			if table.find(srvnames,srvname) then
				if union:member(pid) then
					
					self.pid_unionid[pid] = unionid
				end
			end
		end
	end
	return self.pid_unionid[pid]
end

function cunionmgr:getunion(id)
	return self:get(id)
end

-- 创建公会
function cunionmgr:addunion(param)
	local srvname = assert(param.srvname)
	local id = self:genid(srvname)
	param.id = id
	local union = cunion.new(param)
	logger.log("info","union",string.format("[addunion] id=%s name=%s",union.id,union.name))
	self:_addunion(union,id)
	self:clear_scan_unions()
	return union
end

function cunionmgr:_addunion(union,id)
	self:add(union,id)
	union.loadstate = "loaded"
	union.savename = string.format("union#%d",union.id)
	autosave(union)
end

function cunionmgr:delunion(unionid)
	local union = self:getunion(unionid)
	if union then
		for pid,member in pairs(union.members.objs) do
			union:del(pid)
		end
		logger.log("info","union",string.format("[delunion] id=%s name=%s",union.id,union.name))
		self:del(union.id)
		closesave(union)
		union:deletefromdatabase()
		self:clear_scan_unions()
		return true
	end
	return false
end

function cunionmgr:addmember(unionid,member)
	local union = self:getunion(unionid)
	if not union then
		return false,language.format("公会不存在")
	end
	return union:addmember(member)
end

function cunionmgr:delmember(unionid,member)
	local union = self:getunion(unionid)
	if not union then
		return false,language.format("公会不存在")
	end
	return union:delmember(member)
end

function cunionmgr:unionmethod(unionid,methodname,...)
	local modname,sep,funcname = string.match(methodname,"(.*)([.:])(.+)$")
	if not sep then
		modname = ""
		sep = "."
		funcname = methodname
	end

	if not (modname and sep and funcname) then
		error("[unionmethod] Invalid methodname:" .. tostring(methodname))
	end
	local union = self:getunion(unionid)
	assert(union,"Not found unionid:" .. tostring(unionid))
	local mod = union
	if modname ~= "" then
		for attr in string.gmatch(modname,"([^.]+)") do
			mod = mod[attr]
		end
	end
	local func = assert(mod[funcname],"[unionmethod] Unknow methodname:" .. tostring(methodname))
	if type(func) ~= "function" then
		assert(sep == ".")
		return func
	end
	if sep == "." then
		return func(...)
	elseif sep == ":" then
		return func(mod,...)
	else
		error("Invalid function seperator:" .. tostring(sep))
	end
end

function cunionmgr:srvname_pids(pids)
	local srvname_pids = {}
	for i,pid in ipairs(pids) do
		local now_srvname,isonline = globalmgr.now_srvname(pid)
		local srvname
		if not isonline then
			srvname = globalmgr.home_srvname(pid)
		else
			srvname = now_srvname
		end
		if not srvname_pids[srvname] then
			srvname_pids[srvname] = {}
		end
		table.insert(srvname_pids[srvname],pid)
	end
	return srvname_pids
end

function cunionmgr:sendpackage(pids,protoname,subprotname,request)
	if cserver.isunionsrv() then
		if type(pids) == "number" then
			pids = {pids,}
		end
		local srvname_pids = self:srvname_pids(pids)
		for srvname,pids in pairs(srvname_pids) do
			skynet.fork(rpc.pcall,srvname,"rpc","cunionmgr:sendpackage",pids,protoname,subprotname,request)
		end
	else
		for i,pid in ipairs(pids) do
			local player = playermgr.getplayer(pid)
			if player then
				sendpackage(pid,protoname,subprotname,request)
			end
		end
	end
end

function cunionmgr.packmember(pid,jobid)
	return {
		pid = pid,
		jobid = jobid or unionaux.jobid("会员"),
		offer = 0,
		sum_offer = 0,
		week_offer = 0,
		week_warcnt = 0,
	}
end

function cunionmgr:isvalid_name(name,srvname)
	local isok,errmsg = _isvalid_name(name)
	if not isok then
		return false,errmsg
	end
	local maxlen = data_1800_UnionVar.UnionNameMaxLen
	if string.utf8len(name) > maxlen then
		return false,language.format("公会名字过长")
	end
	local srv = data_RoGameSrvList[srvname]
	for unionid,union in pairs(self.objs) do
		local srvname2 = self:srvname(unionid)
		local srv2 = data_RoGameSrvList[srvname2]
		if srv.zonename == srv2.zonename then
			if union.name == name then
				return false,language.format("公会重名")
			end
		end
	end
	return true
end

function cunionmgr:clear_scan_unions()
	self.sort_unions = nil
	self.sort_exceedtime = nil
end

function cunionmgr:scan_unions()
	local now = os.time()
	if not self.sort_unions or self.sort_exceedtime < now then
		self.sort_exceedtime = now + 120
		self.sort_unions = {}
		for unionid,union in pairs(self.objs) do
			table.insert(self.sort_unions,{
				lv = union:getlv(),
				len = union.members.len,
				id = unionid,
			})
		end
		table.sort(self.sort_unions,function (lhs,rhs)
			if lhs.lv > rhs.lv then
				return true
			end
			if (lhs.lv == rhs.lv) and
				(lhs.len > rhs.len) then
				return true
			end
			if (lhs.lv == rhs.lv) and
				(lhs.len == rhs.len) and
				(lhs.id < rhs.id) then
				return true
			end
			return false
		end)
	end
	return self.sort_unions
end


-- 竞选会长采取：投反对票形式
function cunionmgr:onendvote(vote,state,id)
	local unionid = vote.unionid
	local union = self:getunion(unionid)
	if not union then
		return
	end
	local leader = union:leader()
	local pids = {leader.pid}
	table.extend(pids,union.job_members[unionaux.jobid("副会长")] or {})
	table.extend(pids,union.job_members[unionaux.jobid("干事")] or {})
	table.extend(pids,union.job_members[unionaux.jobid("管事")] or {})
	local pid = vote.creater
	-- 反对：通过
	if state == "pass" then
		mailmgr.sendmails(pids,{
			srcid = SYSTEM_MAIL,
			author = language.format("公会管理员"),
			title = language.format("公会会长竞选"),
			content = language.format([[#<R>{1}#竞选会长失败]],union:memberget(pid,"name")),
		})
	else
		local member = union:member(pid)
		if member then
			union:changeleader(member)
			mailmgr.sendmails(pids,{
				srcid = SYSTEM_MAIL,
				author = language.format("公会管理员"),
				title = language.format("公会会长竞选"),
				content = language.format([[#<R>{1}#竞选会长成功，正式接任#<R>{2}#会长一职。]],union:memberget(pid,"name"),union.name),
			})
		end
	end
end

function cunionmgr:onlogin(pid,srvname)
	local unionid = self:unionid(pid)
	if not unionid then
		return
	end
	local union = self:getunion(unionid)
	if not union then
		return
	end
	local member = union:member(pid)
	-- 这里不能用self:sendpackage来转发数据，因为多节点resume同步有时序问题，
	-- 保存的now_srvname可能是副本
	skynet.fork(function ()
		rpc.pcall(srvname,"rpc","sendpackage",pid,"union","selfunion",{
			unionid = unionid,
			jobid = member.jobid,
			badge = union.badge,
			offer = member.offer,
		})
		rpc.pcall(srvname,"rpc","sendpackage",pid,"union","sync_union",{
			union = union:pack(),
		})
		if union.notice then
			local msg = language.format("公会公告：{1} 编辑人:{2} {3} {4}",
							language.untranslate(union.notice.msg),
							language.untranslate(union.notice.changer.name),
							unionaux.jobname(union.notice.changer.jobid),
							os.date("%m/%d",union.notice.changer.time))
			rpc.pcall(srvname,"rpc","net.msg.broadcast",{pid,},"msg","unionmsg",{
				sender = {
					pid = SENDER.UNION,
				},
				msg = msg,
			})
		end
	end)
	if member.jobid == unionaux.jobid("会长") then
		local id = union:getvote("竞选会长")
		if id then
			union.votemgr:delvote(id)
		end
	end
end

function cunionmgr:onfivehourupdate()
	for unionid,union in pairs(self.objs) do
		xpcall(union.onfivehourupdate,onerror,union)
	end
end

return cunionmgr


