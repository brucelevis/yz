
cresume = class("cresume",cdatabaseable)

function cresume:init(pid)
	self.flag = "cresume"
	cdatabaseable.init(self,{
		pid = pid,
		flag = self.flag,
	})
	self.pid_ref = {}
	self.srvname_ref = {}
	self.data = {}
	if not cserver.isdatacenter() then
		self.nosavetodatabase = true
	end
end

function cresume:load(data)
	if not data or not next(data) then
		return
	end
	self.data = data
end

function cresume:save()
	return self.data
end

function cresume:loadfromdatabase()
	local data
	if not self.loadstate or self.loadstate == "unload" then
		self.loadstate = "loading"
		if cserver.isdatacenter() then
			local db = dbmgr.getdb()
			data = db:get(db:key("resume",self.pid))
		else
			data = rpc.call(cserver.datacenter(),"resumemgr","query",self.pid,"*")
		end
		if not data or not next(data) then
			self.loadstate = "loadnull"
			self:onloadnull()
		else
			self.loadstate = "loaded"
			self:load(data)
		end
	end
end

function cresume:savetodatabase()
	if self.nosavetodatabase then
		return
	end
	if self.loadstate == "loaded" then
		if self:isdirty() then
			local data = self:save()
			local db = dbmgr.getdb()
			db:set(db:key("resume",self.pid),data)
		end
	end
end

function cresume:deletefromdatabase()
	if cserver.isdatacenter() then
		local db = dbmgr.getdb()
		db:del(db:key("resume",self.pid))
	end
end

function cresume:onloadnull()
	if cserver.isgamesrv() then
		local home_srvname = globalmgr.home_srvname(self.pid)
		local self_srvname = cserver.getsrvname()
		if home_srvname ~= self_srvname then
			logger.log("error","error",string.format("[from datacenter loadnull] home_srvname=%s pid=%s",home_srvname,self.pid))
			return
		end
		local player = playermgr.getplayer(self.pid)
		if player then
		else
			player = playermgr.loadofflineplayer(self.pid)
		end
		local data = player:packresume()
		data.home_srvname = home_srvname
		data.now_srvname = self_srvname
		self:create(data)
	elseif cserver.isdatacenter() then
	end
end

function cresume:create(resume)
	assert(resume)
	logger.log("info","resume",format("[create] pid=%d resume=%s",self.pid,resume))
	self.loadstate = "loaded"
	self:set(resume,true)
	--self.data = resume
	if cserver.isgamesrv() then
		rpc.pcall(cserver.datacenter(),"resumemgr","create",self.pid,self:save())
	elseif cserver.isdatacenter() then
		self:savetodatabase()
	end
end

function cresume:addref(pid)
	if type(pid) == "number" then
		self.pid_ref[pid] = (self.pid_ref[pid] or 0) + 1
	else
		local srvname = pid
		self.srvname_ref[srvname] = 1
	end
end

function cresume:delref(pid)
	if type(pid) == "number" then
		self.pid_ref[pid] = (self.pid_ref[pid] or 0) - 1
		if self.pid_ref[pid] <= 0 then
			self.pid_ref[pid] = nil
		end
	else
		local srvname = pid
		self.srvname_ref[srvname] = nil
	end
	if not next(self.pid_ref) and not next(self.srvname_ref) then
		resumemgr.delresume(self.pid)
	end
end

function cresume:set(attrs,nosync_todc)
	for k,v in pairs(attrs) do
		cdatabaseable.set(self,k,v)
	end
	self:sync(attrs,nosync_todc)
end

function cresume:sync(data,nosync_todc)
	for pid,_ in pairs(self.pid_ref) do
		if pid ~= self.pid then
			local player = playermgr.getplayer(pid)
			if player then
				data.pid = self.pid
				sendpackage(pid,"player","updateresume",{ resume = data, })
			end
		end
	end
	if nosync_todc then
		return
	end
	rpc.pcall(cserver.datacenter(),"resumemgr","sync",self.pid,data)
end

function cresume:pack()
	return {
		pid = self.pid,
		name = self:query("name"),
		lv = self:query("lv"),
		roletype = self:query("roletype"),
		now_srvname = self:query("now_srvname"),
		online = self:query("online"),
		fightpoint = self:query("fightpoint"),
		joblv = self:query("joblv"),
		jobzs = self:query("jobzs"),
		teamstate = self:query("teamstate"),
		teamid = self:query("teamid"),
		logofftime = self:query("logofftime"),
		unionid = self:query("unionid"),
	}
end

return cresume
