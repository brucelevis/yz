
require "gamelogic.friend.frienddb"
require "gamelogic.achieve.achievedb"
require "gamelogic.task.taskmgr"
require "gamelogic.item.itemdb"

cplayer = class("cplayer",cdatabaseable)

function cplayer:init(pid)
	self.flag = "cplayer"
	cdatabaseable.init(self,{
		pid = pid,
		flag = self.flag,
	})
	-- resume
	self.pid = pid
	self.name = nil
	self.account = nil
	self.lv = nil
	self.viplv = nil
	self.roletype = nil
	self.gold = nil
	self.silver = nil
	self.coin = nil

	self.data = {}
	self.frienddb = cfrienddb.new(self.pid)
	self.achievedb = cachievedb.new(self.pid)
	self.today = ctoday.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thistemp = cthistemp.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thisweek = cthisweek.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.thisweek2 = cthisweek2.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.timeattr = cattrcontainer.new{
		today = self.today,
		thistemp = self.thistemp,
		thisweek = self.thisweek,
		thisweek2 = self.thisweek2,
	}
	self.taskmgr = ctaskmgr.new(self.pid)
	self.objid = 0
	-- 一般物品背包
	self.itemdb = citemdb.new({
		pid = self.pid,
		name = "itemdb",
		bagtype = BAG_NORMAL,
	})
	-- 时装背包
	self.fashionshowdb = citemdb.new({
		pid = self.pid,
		name = "fashinoshowdb",
		bagtype = BAG_FASNINOSHOW,
	})
	-- 怪物卡片
	self.carddb = citemdb.new({
		pid = self.pid,
		name = "carddb",
		bagtype = BAG_CARD,
	})
	self.delaytonextlogin = cdelaytonextlogin.new(self.pid)
	self.switch = cswitch.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.suitequip = csuitequip.new(self.pid)
	self.autosaveobj = {
		time = self.timeattr,
		friend = self.frienddb,
		achieve = self.achievedb,
		task = self.taskmgr,
		item = self.itemdb,
		fashiowshow = self.fashowshowdb,
		carddb = self.carddb,
		delaytonextlogin = self.delaytonextlogin,
		switch = self.switch,
		suitequip = self.suitequip,
	}
	self.loadstate = "unload"
end

function cplayer:save()
	local data = {}
	data.data = self.data
	data.resume = self:packresume()
	data.basic = {
		teamid = self.teamid,
		sceneid = self.sceneid,
		pos = self.pos,
		warid = self.warid,
		objid = self.objid,
	}
	return data
end


function cplayer:load(data)
	if not data or not next(data) then
		logger.log("error","error",string.format("[cplayer:load null] pid=%d",self.pid))
		return
	end
	self.data = data.data
	self:unpackresume(data.resume)
	if data.basic then
		self.teamid = data.basic.teamid
		self.sceneid = data.basic.sceneid
		self.pos = data.basic.pos
		self.warid = data.basic.warid
		self.objid = data.basic.objid
	end
end

function cplayer:packresume()
	local resume = {
		gold = self.gold,
		silver = self.silver,
		coin = self.coin,
		viplv = self.viplv,
		account = self.account,
		name = self.name,
		lv = self.lv,
		viplv = self.viplv,
		roletype = self.roletype,
	}
	return resume
end

function cplayer:unpackresume(resume)
	self.gold = resume.gold
	self.silver = resume.silver or 0
	self.coin = resume.coin or 0
	self.account = resume.account
	self.name = resume.name
	self.lv = resume.lv
	self.viplv = resume.viplv
	self.roletype = resume.roletype
end

		
function cplayer:savetodatabase()
	assert(self.pid)
	if self.nosavetodatabase then
		return
	end

	local db = dbmgr.getdb(cserver.getsrvname(self.pid))
	if self.loadstate == "loaded" then
		local data = self:save()
		db:set(db:key("role",self.pid,"data"),data)
	end
	for k,v in pairs(self.autosaveobj) do
		if v.loadstate == "loaded" then
			db:set(db:key("role",self.pid,k),v:save())
		end
	end
	-- 离线对象已超过过期时间则删除
	if self.__state == "offline" and (not self.__activetime or os.time() - self.__activetime > 300) then
		playermgr.unloadofflineplayer(self.pid)
	end

	-- 临时处理方法，agent发现内存占用过高，暂时每次存盘让玩家对应的agent服gc
	if self.__agent then
		skynet.error(self.__agent,"gc")
		skynet.send(self.__agent,"lua","gc")
	end
end

function cplayer:loadfromdatabase(loadall)
	if loadall == nil then
		loadall = true
	end
	assert(self.pid)
	if not self.loadstate or self.loadstate == "unload" then
		self.loadstate = "loading"
		local db = dbmgr.getdb(cserver.getsrvname(self.pid))
		local data = db:get(db:key("role",self.pid,"data"))
		--pprintf("role:data=>%s",data)
		-- 正常角色至少会有基本数据
		if not data or not next(data) then
			self.loadstate = "loadnull"
		else
			self:load(data)
			self.loadstate = "loaded"
		end
	end
	if loadall then
		for k,v in pairs(self.autosaveobj) do
			if not v.loadstate or v.loadstate == "unload" then
				v.loadstate = "loading"
				local db = dbmgr.getdb(cserver.getsrvname(self.pid))
				local data = db:get(db:key("role",self.pid,k))
				v:load(data)
				v.loadstate = "loaded"
			end
		end
	end
end

function cplayer:isloaded()
	if self.loadstate == "loaded" then
		for k,v in pairs(self.autosaveobj) do
			if v.loadstate ~= "loaded" then
				return false
			end
		end
		return true
	end
	return false
end

function cplayer:create(conf)
	local name = assert(conf.name)
	local roletype =assert(conf.roletype)
	local account = assert(conf.account)
	logger.log("info","createrole",string.format("[createrole] account=%s pid=%s name=%s roletype=%s ip=%s:%s",account,self.pid,name,roletype,conf.__ip,conf.__port))

	self.loadstate = "loaded"
	self.account = account
	self.name = name
	self.roletype = roletype
	self.gold = conf.gold or 0
	self.silver = conf.silver or 0
	self.coin = conf.coin or 0
	self.lv = conf.lv or 25
	self.viplv = conf.viplv or 0
	-- scene
	self.sceneid = BORN_SCENEID
	self.pos = randlist(ALL_BORN_LOCS)
	self.warid = nil
	self.scene_strategy = STRATEGY_SEE_ALL
	self.createtime = getsecond()
	local db = dbmgr.getdb()
    db:hset(db:key("role","list"),self.pid,1)
    route.addroute(self.pid)
	self:oncreate(conf)
end

function cplayer:entergame()
	-- 确保登录第一个执行
	self.delaytonextlogin:entergame()
	self:onlogin()
	--xpcall(self.onlogin,onerror,self)
end


-- 正常退出游戏
function cplayer:exitgame()
	xpcall(self.onlogoff,onerror,self)
	self:savetodatabase()
end


-- 客户端主动掉线处理
function cplayer:disconnect(reason)
	self:exitgame()
	self:ondisconnect(reason)
end


-- 跨服前处理流程
function cplayer:ongosrv(srvname)
end

-- 回到原服前处理流程
function cplayer:ongohome()
end


function cplayer:synctoac()
	local role = {
		roleid = self.pid,
		name = self.name,
		gold = self.gold,
		lv = self.lv,
		roletype = self.roletype,
	}
	local url = string.format("/sync")
	local request = make_request({
		gameflag = cserver.gameflag,
		srvname = cserver.getsrvname(),
		acct = self.account,
		roleid = self.pid,
		role = cjson.encode(role),
	})
	httpc.post(cserver.accountcenter.host,url,request)
end


local function heartbeat(pid)
	local player = playermgr.getplayer(pid)
	if player then
		local interval = 120
		timer.timeout("player.heartbeat",interval,functor(heartbeat,pid))
		sendpackage(pid,"player","heartbeat",{})
	end
end

function cplayer:oncreate(conf)
	logger.log("info","createrole",string.format("[createrole end] account=%s pid=%d name=%s roletype=%d lv=%s gold=%d ip=%s:%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,conf.__ip,conf.__port))
	for k,obj in pairs(self.autosaveobj) do
		if obj.oncreate then
			obj:oncreate(self)
		end
	end
end

function cplayer:comptible_process()
	if not self.scene_strategy then
		self.scene_strategy = STRATEGY_SEE_ALL
	end
end

function cplayer:onlogin()
	logger.log("info","login",string.format("[login] account=%s pid=%s name=%s roletype=%s lv=%s gold=%s ip=%s:%s agent=%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,self:ip(),self:port(),self.__agent))
	self:comptible_process()
	local server = globalmgr.server
	heartbeat(self.pid)
	sendpackage(self.pid,"player","resource",{
		gold = self.gold,
	})
	sendpackage(self.pid,"player","switch",self.switch:allswitch())
	mailmgr.onlogin(self)
	for k,obj in pairs(self.autosaveobj) do
		if obj.onlogin then
			obj:onlogin(self)
		end
	end
	if not self.sceneid then
		self.sceneid = BORN_SCENEID
		self.pos = randlist(ALL_BORN_LOCS)
	end
	self:enterscene(self.sceneid,self.pos)
	self:synctoac()
end

function cplayer:onlogoff()
	logger.log("info","login",string.format("[logoff] account=%s pid=%s name=%s roletype=%s lv=%s gold=%s ip=%s:%s agent=%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,self:ip(),self:port(),self.__agent))
	mailmgr.onlogoff(self)
	for k,obj in pairs(self.autosaveobj) do
		if obj.onlogoff then
			obj:onlogoff(self)
		end
	end
	self:leavescene(self.sceneid)
	self:synctoac()
end

function cplayer:ondisconnect(reason)

	logger.log("info","login",string.format("[disconnect] account=%s pid=%s name=%s roletype=%s lv=%s gold=%s ip=%s:%s reason=%s",self.account,self.pid,self.name,self.roletype,self.lv,self.gold,self:ip(),self:port(),reason))
	loginqueue.pop()
end

function cplayer:ondayupdate()
end

function cplayer:onweekupdate()
end

function cplayer:onweek2update()
end

function cplayer:validpay(typ,num,notify)
	local hasnum
	if typ == "gold" then
		hasnum = self.gold
	elseif typ == "silver" then
		hasnum = self.silver
	elseif typ == "coin" then
		hasnum = self.coin
	else
		error("invalid resource type:" .. tostring(typ))
	end
	if hasnum < num then
		if notify then
			local RESNAME = {
				gold = "金币",
				silver = "银币",
				coin = "铜币",
			}
			net.msg.S2C.notify(self.pid,string.format("%s不足%d",RESNAME[typ],num))
		end
		return false
	end
	return true
end

function cplayer:setlv(val,reason)
	local oldval = self.lv
	logger.log("info","lv",string.format("[setlv] pid=%d lv=%d->%d reason=%s",self.pid,oldval,val,reason))
	self.lv = val
end

function cplayer:addlv(val,reason)
	local oldval = self.lv
	local newval = oldval + val
	logger.log("info","lv",string.format("[addlv] pid=%d lv=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.resume:set("lv",newval)
end

function cplayer:addgold(val,reason)
	val = math.floor(val)
	local oldval = self.gold
	local newval = oldval + val
	logger.log("info","resource/gold",string.format("[addgold] pid=%d gold=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	assert(newval >= 0,string.format("not enough gold:%d+%d=%d",oldval,val,newval))
	self.gold = newval
	local addgold = newval - oldval
	if addgold > 0 then
		event.playerdo(self.pid,"金币增加",addgold)
	end
	return addgold
end

function cplayer:addsilver(val,reason)
	val = math.floor(val)
	local oldval = self.silver
	local newval = oldval + val
	logger.log("info","resource/silver",string.format("[addsilver] pid=%d silver=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	assert(newval >= 0,string.format("not enough silver:%d+%d=%d",oldval,val,newval))
	self.silver = newval
	return val
end

function cplayer:addcoin(val,reason)
	val = math.floor(val)
	local oldval = self.coin
	local newval = oldval + val
	logger.log("info","resource/coin",string.format("[addcoin] pid=%d coin=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	assert(newval >= 0,string.format("not enough coin:%d+%d=%d",oldval,val,newval))
	self.coin = newval
	return val
end

function cplayer:genid()
	if self.objid > MAX_NUMBER then
		self.objid = 0
	end
	self.objid = self.objid + 1
	return self.objid
end

function cplayer:additembytype(itemtype,num,bind,reason)
	local itemdb = self:getitemdb(itemtype)
	return itemdb:additembytype(itemtype,num,bind,reason)
end

function cplayer:getitemdb(itemtype)
	local maintype = getmaintype(itemtype)
	if maintype == ItemMainType.FASHION_SHOW then
		return self.fashowshowdb
	elseif maintype == ItemMainType.CARD then
		return self.carddb
	else
		return self.itemdb
	end
end

function cplayer:getitem(itemid)
	local item = self.itemdb:getitemobj(itemid)
	if item then
		return item,self.itemdb
	end
	item = self.carddb:getitemobj(itemid)
	if item then
		return item,self.carddb
	end
	item = self.fashionshowdb:getitemobj(itemid)
	if item then
		return item,self.fashionshowdb
	end
end

function cplayer:wield(equip)
	local itemdata = getitemdata(equip.type)
	if equip.pos == itemdata.wieldpos then
		return
	end
	self.itemdb:moveitem(equip.id,itemdata.wieldpos)
	self:refreshequip()
end

function cplayer:unwield(equip)
	local itemdata = getitemdata(equip.type)
	if equip.pos ~= itemdata.wieldpos then
		return
	end
	local newpos = self.itemdb:getfreepos()
	if newpos == nil then
		net.msg.S2C.notify(self.pid,"背包已满")
		return
	end
	self.itemdb:moveitem(equip.id,newpos)
	self:refreshequip()
end

function cplayer:refreshequip()
	for pos = 1,self.itemdb.itempos_begin - 1 do
		local equip = self.itemdb:getitembypos(pos)
		if equip then
		end
	end
end

function cplayer:addres(typ,num,reason,btip)
	if typ == RESTYPE.GOLD or string.lower(typ) == "gold" then
		num = self:addgold(num,reason)
	elseif typ == RESTYPE.SILVER or string.lower(typ) == "silver" then
		num = self:addsilver(num,reason)
	elseif typ == RESTYPE.COIN or string.lower(typ) == "coin" then
		num = self:addcoin(num,reason)
	else
		error("Invlid restype:" .. tostring(typ))
	end
	if btip then
		local msg = string.format("%s #<type=%s># X%d",num > 0 and "获取" or "花费",typ,num)
		net.msg.S2C.notify(self.pid,msg)
	end
	return num
end

-- getter
function cplayer:authority()
	if skynet.getenv("servermode") == "DEBUG" then
		return 100
	end
	return self:query("auth",0)
end

function cplayer:ip()
	return self.__ip
end

function cplayer:port()
	return self.__port
end

function cplayer:teamstate()
	local teamid = self.teamid
	if not teamid then
		return NO_TEAM
	end
	local team = teammgr:getteam(teamid)
	if not team then
		logger.log("info","team",string.format("[teamstate] pid=%s teamid->nil",self.pid))
		self.teamid = nil
		return NO_TEAM 
	end
	return team:teamstate(self.pid)
end

function cplayer:getteamid()
	if self.teamid then
		local team = teammgr:getteam(self.teamid)
		if not team then
			logger.log("error","team",string.format("[getteamid but no team] pid=%d teamid=%d",self.pid,self.teamid))
			sendpackage(self.pid,"team","delmember",{
				teamid = self.teamid,
				pid = self.pid,
			})
			self.teamid = nil
		elseif not team:ismember(self.pid) then
			logger.log("error","team",string.format("[getteamid but not a member] pid=%d teamid=%d",self.pid,self.teamid))
			sendpackage(self.pid,"team","delmember",{
				teamid = self.teamid,
				pid = self.pid,
			})
			self.teamid = nil
		end
	end
	return self.teamid
end

-- 组对成员
function cplayer:packmember()
	return {
		pid = self.pid,
		name = self.name,
		lv = self.lv,
		roletype = self.roletype,
		state = self:teamstate(),
	}
end

-- 场景信息
function cplayer:packscene(sceneid)
	sceneid = sceneid or self.sceneid
	local scene = scenemgr.getscene(sceneid)
	return {
		pid = self.pid,
		name = self.name,
		lv = self.lv,
		roletype = self.roletype,
		teamid = self:getteamid() or 0,
		teamstate = self:teamstate(),
		warid = self.warid,
		pos = self.pos,
		scene_strategy = self.scene_strategy,
		agent = self.__agent,
		sceneid = sceneid,
		mapid = scene.mapid,
	}
end

-- setter
function cplayer:setauthority(auth)
	self:set("auth",auth)
end

function cplayer:canmove()
	local teamstate = self:teamstate()
	if teamstate == TEAM_STATE_FOLLOW then
		return false
	end
	if self.warid and self.warid ~= 0 then
		return false
	end
	return true
end

function cplayer:move(package)
	assert(package)
	if not self:canmove() then
		return
	end
	local pid = self.pid
	assert(self.sceneid)
	local scene = scenemgr.getscene(self.sceneid)
	if scene then
		scene:move(self,package)
		self:setpos(self.sceneid,package.srcpos)
		return true
	end
end

function cplayer:leavescene(sceneid)
	sceneid = sceneid or self.sceneid
	assert(sceneid)
	if sceneid then
		local scene = scenemgr.getscene(sceneid)
		if scene then
			scene:leave(self)
		end
	end
end

function cplayer:enterscene(sceneid,pos)
	assert(sceneid)
	assert(pos)
	local pid = self.pid
	self:leavescene(self.sceneid)
	local newscene = scenemgr.getscene(sceneid)
	if not newscene then
		return
	end
	self:setpos(sceneid,pos)
	newscene:enter(self)
end

-- 强制跳转到指定坐标
cplayer.jumpto = cplayer.enterscene

function cplayer:setpos(sceneid,pos)
	self.sceneid = sceneid
	self.pos = pos
	local teamstate = self:teamstate()
	if teamstate == TEAM_STATE_CAPTAIN then
		local team = teammgr:getteam(self.teamid)
		if team then
			for pid,_ in pairs(team.follow) do
				if pid ~= self.pid then
					local member = playermgr.getplayer(pid)
					if member then
						member.pos = {
							x = self.pos.x,
							y = self.pos.y,
							dir = self.pos.dir,
						}
					end
				end
			end
		end
	end
end

function cplayer:gettarget(targetid)
	if targetid == 1 then
		return self
	else
		-- pet ?
	end
end

return cplayer