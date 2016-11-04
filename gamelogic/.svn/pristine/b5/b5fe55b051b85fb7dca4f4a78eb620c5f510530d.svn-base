cserver = class("cserver",cdatabaseable)

function cserver:init()
	logger.log("info","server","[init]")
	self.flag = "cserver"
	cdatabaseable.init(self,{
		pid = 0,
		flag = self.flag,
	})
	self.data = {}
	self.onlinelimit = tonumber(skynet.getenv("maxclient")) or 10240

	self.loadstate = "unload"
	self.savename = string.format("%s.%s",self.flag,self.pid)
	autosave(self)
end

function cserver:create()
	logger.log("info","server","[create]")
	self:set("createday",getdayno())
end

function cserver:save()
	local data = {}
	data.data = self.data
	return data
end

function cserver:load(data)
	if not data or not next(data) then
		return
	end
	self.data = data.data
end

function cserver:savetodatabase()
	if self.loadstate ~= "loaded" then
		return
	end
	local data = self:save()
	local db = dbmgr.getdb()
	db:set(db:key("global","server"),data)
end

function cserver:loadfromdatabase()
	if self.loadstate ~= "unload" then
		return
	end
	self.loadstate = "loading"
	local db = dbmgr.getdb()
	local data = db:get(db:key("global","server"))
	if data == nil then
		self:create()
	else
		self:load(data)
	end
	self.loadstate = "loaded"
end



-- getter
function cserver:getopenday()
	if not self:query("createday") then
		self:set("createday",getdayno())
	end
	return getdayno() - self:query("createday") + self:query("openday",0)
end

function cserver:addopenday(val,reason)
	logger.log("info","server",string.format("[addopenday] val=%d reason=%s",val,reason))
	self:add("openday",val)
end

function cserver:getsrvlv(openday)
	openday = openday or self:getopenday()
	local srvinfo = data_SrvLv[openday]
	if not srvinfo then
		return data_GlobalVar.MaxSrvLv
	end
	return srvinfo.srvlv
end


function cserver:isopen(typ)
	if typ == "friend" then
		if not cserver.isgamesrv() then
			return false
		end
		if not clustermgr.isconnect(cserver.datacenter()) then	
			return false
		end
		return true
	end
end

function cserver.starttimer_logstatus()
	local interval = skynet.getenv("servermode") == "DEBUG" and 5 or 60
	timer.timeout("timer.logstatus",interval,cserver.starttimer_logstatus)
	logger.log("info","status",string.format("onlinenum=%s linknum=%s offlinenum=%s kuafunum=%s gokuafunum=%s num=%s task=%s mqlen=%s",playermgr.onlinenum,playermgr.linknum,playermgr.offlinenum,playermgr.kuafunum,playermgr.gokuafunum,playermgr.num,skynet.task(),skynet.mqlen()))
end

-- class method
function cserver.isdatacenter(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"datacenter") ~= nil
end

function cserver.datacenter()
	return skynet.getenv("datacenter") or "datacenter"
end

function cserver.accountcenter()
	return skynet.getenv("accountcenter") or "192.168.1.244:80"
end

function cserver.warsrv()
	return skynet.getenv("warsrv")
end

function cserver.gameflag()
	return skynet.getenv("gameflag") or "ro"
end

function cserver.isgamesrv(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"gamesrv") ~= nil
end

function cserver.iswarsrv(srvname)
	srvname = srvname or cserver.getsrvname()
	if srvname == "warsrvmgr" then
		return false
	end
	return string.find(srvname,"warsrv") ~= nil
end

function cserver.iswarsrvmgr(srvname)
	srvname = srvname or cserver.getsrvname()
	return string.find(srvname,"warsrvmgr") ~= nil
end


-- 仅对游戏服有效
function cserver.isinnersrv(srvname)
	srvname = srvname or cserver.getsrvname()
	local data = data_RoGameSrvList[srvname]
	if data.zonename == "inner" then
		return true
	end
	return false
end

function cserver.isvalidsrv(srvname)
	local data = data_RoGameSrvList[srvname]
	if data then
		return true,data
	else
		return false
	end
end

-- 得到自身服务器名
function cserver.getsrvname()
	return skynet.getenv("srvname")
end

-- 同区广播
function cserver.call_in_samezone(protoname,cmd,...)
	local self_srvname = cserver.getsrvname()
	local srv = data_RoGameSrvList[self_srvname]
	for srvname,data in pairs(data_RoGameSrvList) do
		if srvname ~= self_srvname and data.zonename == srv.zonename and clustermgr.isconnect(srvname) then
			rpc.call(srvname,protoname,cmd,...)
		end
	end
end

function cserver.pcall_in_samezone(protoname,cmd,...)
	local self_srvname = cserver.getsrvname()
	local srv = data_RoGameSrvList[self_srvname]
	for srvname,data in pairs(data_RoGameSrvList) do
		if srvname ~= self_srvname and data.zonename == srv.zonename and clustermgr.isconnect(srvname) then
			rpc.pcall(srvname,protoname,cmd,...)
		end
	end
end

return cserver
