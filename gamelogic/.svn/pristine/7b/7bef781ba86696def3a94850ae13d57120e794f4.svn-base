cplayer = class("cplayer",cdatabaseable)

function cplayer:init(pid)
	self.flag = "cplayer"
	cdatabaseable.init(self,{
		pid = pid,
		flag = self.flag,
	})
	self.pid = pid
	
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
	self.taskdb = ctaskdb.new(self.pid)
	-- 一般物品背包
	self.itemdb = citemdb.new({
		pid = self.pid,
		name = "itemdb",
		type = BAGTYPE.NORMAL,
	})
	-- 时装背包
	self.fashionshowdb = citemdb.new({
		pid = self.pid,
		name = "fashinoshowdb",
		type = BAGTYPE.FASHION_SHOW,
	})
	-- 怪物卡片
	self.carddb = ccarddb.new({
		pid = self.pid,
		name = "carddb",
		type = BAGTYPE.CARD,
	})
	self.delaytonextlogin = cdelaytonextlogin.new(self.pid)
	self.switch = cswitch.new{
		pid = self.pid,
		flag = self.flag,
	}
	self.suitequip = csuitequip.new(self.pid)
	self.privatemsg = cprivatemsg.new(self.pid)

	self.titledb = ctitledb.new({
		pid = self.pid,
		name = "titledb",
	})

	-- 签到容器
	self.signindb = csignindb.new(self.pid)
	-- 关卡容器
	self.chapterdb = cchapterdb.new({
		pid = self.pid,
		name = "chapterdb",
	})
	self.warskilldb = cwarskilldb.new({
		pid = self.pid,
		name = "warskill",
	})

	self.shopdb = cshopdb.new(self.pid)

	self.autosaveobj = {
		time = self.timeattr,
		friend = self.frienddb,
		achieve = self.achievedb,
		task = self.taskdb,
		item = self.itemdb,
		fashiowshow = self.fashowshowdb,
		carddb = self.carddb,
		delaytonextlogin = self.delaytonextlogin,
		switch = self.switch,
		suitequip = self.suitequip,
		privatemsg = self.privatemsg,
		signin = self.signindb,
		chapter = self.chapterdb,
		warskill = self.warskilldb,
		shop = self.shopdb,
	}
	self.loadstate = "unload"
end

function cplayer:save()
	local data = {}
	data.data = self.data
	data.basic = {
		gold = self.gold,
		silver = self.silver,
		coin = self.coin,
		viplv = self.viplv,
		account = self.account,
		channel = self.channel,
		name = self.name,
		lv = self.lv,
		exp = self.exp,
		roletype = self.roletype,
		sex = self.sex,
		jobzs = self.jobzs,
		joblv = self.joblv,
		jobexp = self.jobexp,

		teamid = self.teamid,
		sceneid = self.sceneid,
		pos = self.pos,
		warid = self.warid,
		watch_warid = self.watch_warid,
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
	if data.basic then
		self.gold = data.basic.gold
		self.silver = data.basic.silver
		self.coin = data.basic.coin
		self.viplv = data.basic.viplv
		self.account = data.basic.account
		self.channel = data.basic.channel
		self.name = data.basic.name
		self.lv = data.basic.lv
		self.exp = data.basic.exp
		self.roletype = data.basic.roletype
		self.sex = data.basic.sex or 1
		self.jobzs = data.basic.jobzs or 0
		self.joblv = data.basic.joblv
		self.jobexp = data.basic.jobexp

		self.teamid = data.basic.teamid
		self.sceneid = data.basic.sceneid
		self.pos = data.basic.pos
		self.warid = data.basic.warid
		self.watch_warid = data.basic.watch_warid
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
		roletype = self.roletype,
		jobzs = self.jobzs,
		joblv = self.joblv,
	}
	return resume
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
		--skynet.send(self.__agent,"lua","gc")
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
		-- pprintf("role:data=>%s",data)
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
	local sex = assert(conf.sex)
	logger.log("info","createrole",string.format("[createrole] account=%s pid=%s name=%s roletype=%s ip=%s:%s",account,self.pid,name,roletype,conf.__ip,conf.__port))

	self.loadstate = "loaded"

	self.account = account
	self.name = name
	self.roletype = roletype		-- 角色类型(职业类型)
	self.sex = sex					-- 性别(1--男,2--女)
	self.gold = conf.gold or 0
	self.silver = conf.silver or 0
	self.coin = conf.coin or 0
	self.lv = conf.lv or 1
	self.exp = conf.exp or 0
	self.jobzs = conf.jobzs or 0
	self.joblv = conf.joblv or 1
	self.jobexp = conf.jobexp or 0
	self.viplv = conf.viplv or 0
	self.objid = 100
	-- 素质点
	self:set("qualitypoint",{
		sum = 48,
		expand = 0,
		liliang = 1,
		minjie = 1,
		tili = 1,
		lingqiao = 1,
		zhili = 1,
		xingyun = 1,
	})

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

function cplayer.__exitgame(pid)
	local player = playermgr.getplayer(pid)
	if player then
		player:exitgame()
	end
end


-- 正常退出游戏
function cplayer:exitgame()
	local can_tuoguan,tuoguan_time = self:can_tuoguan()
	--print(">>>",self.pid,can_tuoguan,self.tuoguan_timerid,self.bforce_exitgame,self.warid)
	if can_tuoguan and not self.tuoguan_timerid then
		local timerid = timer.timeout("exitgame.tuoguan",tuoguan_time,functor(cplayer.__exitgame,self.pid))	

		self.tuoguan_timerid = timerid  -- 托管标志
		return
	end
	-- 战斗中延迟下线(顶号时会设置强制下线标志:bforce_exitgame)
	if not self.bforce_exitgame and self.warid then
		local timerid = timer.timeout("exitgame.inwar",60,functor(cplayer.__exitgame,self.pid))
		self.inwar_timerid = timerid
		return
	end
	if self.tuoguan_timerid then
		-- 托管玩家被顶号会走到这里
		timer.deltimerbyid(self.tuoguan_timerid)
	end
	if self.inwar_timerid then
		timer.deltimerbyid(self.inwar_timerid)
	end
	xpcall(self.onlogoff,onerror,self)
	-- playermgr.delobject 会触发存盘
	playermgr.delobject(self.pid,"exitgame")
	self.tuoguan_timerid = nil
	self.inwar_timerid = nil
end


-- 客户端主动掉线处理
function cplayer:disconnect(reason)
	-- 已经在托管/战斗延迟下线的玩家，不做disconnect日志了，上次下线已经做过一次!
	if not self.tuoguan_timerid and not self.inwar_timerid then
		self:ondisconnect(reason)
	end
	self:exitgame()
end


-- 跨服前处理流程
function cplayer:ongosrv(srvname)
end

-- 回到原服前处理流程
function cplayer:ongohome()
end

-- 是否可以离线托管
function cplayer:can_tuoguan()
	if globalmgr.server.closetuoguan then
		return false
	end
	if self.closetuoguan then
		return false
	end
	if self.bforce_exitgame then
		return false
	end
	return true,60 -- test
	--return true,1200
end


function cplayer:synctoac()
	local role = {
		roleid = self.pid,
		name = self.name,
		gold = self.gold,
		lv = self.lv,
		roletype = self.roletype,
		jobzs = self.jobzs,
		joblv = self.joblv,
		sex = self.sex,
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
	logger.log("info","createrole",string.format("[createrole end] account=%s pid=%d name=%s roletype=%d sex=%s lv=%s gold=%d ip=%s:%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,conf.__ip,conf.__port))
	for k,obj in pairs(self.autosaveobj) do
		if obj.oncreate then
			obj:oncreate(self)
		end
	end
end

function cplayer:comptible_process()
	-- 部分旧号无等级字段（先兼容下，后续删除这里代码）
	if not self.lv then
		self.lv = 1
	end
	if self:query("runno") ~= globalmgr.server:query("runno") then
		self:set("runno",globalmgr.server:query("runno"))
		self.teamid = nil
		self.warid = nil
		self.watch_warid = nil
	end
	if not self.scene_strategy then
		self.scene_strategy = STRATEGY_SEE_ALL
	end

	local scene = scenemgr.getscene(self.sceneid)
	if not scene or not self:canenterscene(self.sceneid,self.pos) then
		if scene then
			self:leavescene(self.sceneid)
		end
		local born_sceneid = BORN_SCENEID
		local born_pos = randlist(ALL_BORN_LOCS)
		self:setpos(born_sceneid,born_pos)
	end
	-- 防止地图大小变后，玩家所在位置超出地图界限
	local scene = scenemgr.getscene(self.sceneid)
	if not scene:isvalidpos(self.pos) then
		self:setpos(self.sceneid,scene:fixpos(self.pos))
	end
end

function cplayer:onlogin()
	logger.log("info","login",string.format("[login] account=%s pid=%s name=%s roletype=%s sex=%s lv=%s gold=%s ip=%s:%s agent=%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,self:ip(),self:port(),self.__agent))
	self:comptible_process()
	if not self.thistemp:query("onfivehourupdate") then
		self:onfivehourupdate()
	end
	route.onlogin(self)
	local server = globalmgr.server
	heartbeat(self.pid)
	--  玩家基本/简介信息
	sendpackage(self.pid,"player","sync",{
		roletype = self.roletype,
		sex = self.sex,
		name = self.name,
		lv = self.lv,
		exp = self.exp,
		jobzs = self.jobzs,
		joblv = self.joblv,
		jobexp = self.jobexp,
		viplv = self.viplv,
		qualitypoint = self:query("qualitypoint"),
		huoli = self:query("huoli") or 0,
		storehp = self:query("storehp") or 0,
	})
	sendpackage(self.pid,"player","resource",{
		gold = self.gold,
	})
	sendpackage(self.pid,"player","switch",self.switch:allswitch())
	-- 放到teammgr:onlogin之前
	self:enterscene(self.sceneid,self.pos,true)
	mailmgr.onlogin(self)
	huodongmgr.onlogin(self)
	for k,obj in pairs(self.autosaveobj) do
		if obj.onlogin then
			obj:onlogin(self)
		end
	end
	teammgr:onlogin(self)
	warmgr.onlogin(self)
	gm.onlogin(self)
	channel.subscribe("world",self.pid)
	self:synctoac()
end

function cplayer:onlogoff()
	logger.log("info","login",string.format("[logoff] account=%s pid=%s name=%s roletype=%s sex=%s lv=%s gold=%s ip=%s:%s agent=%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,self:ip(),self:port(),self.__agent))
	mailmgr.onlogoff(self)
	huodongmgr.onlogoff(self)
	for k,obj in pairs(self.autosaveobj) do
		if obj.onlogoff then
			obj:onlogoff(self)
		end
	end
	warmgr.onlogoff(self)
	teammgr:onlogoff(self)
	-- 放到teammgr:onlogoff之后
	self:leavescene(self.sceneid)
	channel.unsubscribe("world",self.pid)
	self:synctoac()
end

function cplayer:ondisconnect(reason)

	logger.log("info","login",string.format("[disconnect] account=%s pid=%s name=%s roletype=%s sex=%s lv=%s gold=%s ip=%s:%s agent=%s reason=%s",self.account,self.pid,self.name,self.roletype,self.sex,self.lv,self.gold,self:ip(),self:port(),self.__agent,reason))
end

function cplayer:ondayupdate()
end

function cplayer:onweekupdate()
end

function cplayer:onweek2update()
end

function cplayer:validpay(typ,num,notify)
	local hasnum
	if typ == RESTYPE.GOLD or string.lower(typ) == "gold" then
		hasnum = self.gold
	elseif typ == RESTYPE.SILVER or string.lower(typ) == "silver" then
		hasnum = self.silver
	elseif typ == RESTYPE.COIN or string.lower(typ) == "coin" then
		hasnum = self.coin
	else
		error("invalid resource type:" .. tostring(typ))
	end
	if hasnum < num then
		if notify then
			local resname = getresname(typ)
			net.msg.S2C.notify(self.pid,language.format("{1}不足{2}",resname,num))
		end
		return false
	end
	return true
end

function cplayer:setlv(val,reason)
	local oldval = self.lv
	assert(val <= playeraux.getmaxlv())
	logger.log("info","lv",string.format("[setlv] pid=%d lv=%d->%d reason=%s",self.pid,oldval,val,reason))
	self.lv = val
end

function cplayer:addlv(val,reason)
	local oldval = self.lv
	local newval = oldval + val
	assert(newval <= playeraux.getmaxlv())
	logger.log("info","lv",string.format("[addlv] pid=%d lv=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.lv = newval
	sendpackage(self.pid,"player","update",{lv=self.lv})
	self:onaddlv(val,reason)
end

function cplayer:onaddlv(val,reason)
	local add_qualitypoint = math.floor(self.lv / 5 + 3)
	self:add_qualitypoint(add_qualitypoint,"onaddlv")
end


function cplayer:addexp(val,reason)
	local oldval = self.exp
	local newval = oldval + val
	logger.log("debug","lv",string.format("[addexp] pid=%d addexp=%d reason=%s",self.pid,val,reason))
	local addlv = 0
	for lv=self.lv,playeraux.getmaxlv()-1 do
		local maxexp = playeraux.getmaxexp(lv)
		if newval >= maxexp then
			newval = newval - maxexp
			addlv = addlv + 1
		else
			break
		end
	end
	self.exp = newval
	sendpackage(self.pid,"player","update",{exp=self.exp})
	if addlv > 0 then
		self:addlv(addlv,reason)
	end
end

-- 增加职业转生等级
function cplayer:addjobzs(val,reason)
	local oldval = self.jobzs
	local newval = oldval + val
	assert(newval <= MAX_JOBZS)
	logger.log("info","lv",string.format("[addjobzs] pid=%s jobzs=%d+%d=%d reason=%s",self.pid,oldval,newval,reason))
	self.jobzs = newval
	sendpackage(self.pid,"player","update",{jobzs=self.jobzs})
end

function cplayer:setjoblv(val,reason)
	local oldval = self.joblv
	assert(val <= playeraux.getmaxjoblv(self.jobzs))
	logger.log("info","lv",string.format("[setjoblv] pid=%d joblv=%d->%d reason=%s",self.pid,oldval,val,reason))
	self.joblv = val
	sendpackage(self.pid,"player","update",{jobzs=self.jobzs})
end

function cplayer:addjoblv(val,reason)
	local oldval = self.joblv
	local newval = oldval + val
	assert(newval <= playeraux.getmaxjoblv(self.jobzs))
	logger.log("info","lv",string.format("[addjoblv] pid=%d joblv=%d+%d=%d reason=%s",self.pid,oldval,val,newval,reason))
	self.joblv = newval
	sendpackage(self.pid,"player","update",{joblv=self.joblv})
end

function cplayer:addjobexp(val,reason)
	local oldval = self.jobexp
	local newval = oldval + val
	logger.log("debug","lv",string.format("[addjobexp] pid=%d addjobexp=%d reason=%s",self.pid,val,reason))
	local addlv = 0
	for lv=self.joblv,playeraux.getmaxjoblv(self.jobzs)-1 do
		local maxexp = playeraux.getmaxjobexp(self.jobzs,lv)
		if newval >= maxexp then
			newval = newval - maxexp
			addlv = addlv + 1
		else
			break
		end
	end
	self.jobexp = newval
	sendpackage(self.pid,"player","update",{jobexp=self.jobexp})
	if addlv > 0 then
		self:addjoblv(addlv,reason)
	end
end

-- 转职(职业ID,就是角色类型ID)
function cplayer:changejob(tojobid)
	if not isvalid_roletype(tojobid) then
		net.msg.S2C.notify(self.pid,language.format("非法职业ID"))
		return
	end
	-- TODO: check more
	local jobdata = data_0101_Hero[self.roletype]
	if jobdata.NEXT_JOB ~= tojobid then
		net.msg.S2C.notify(self.pid,language.format("你无法转成该职业"))
		return
	end
	self.roletype = tojobid
	sendpackage(self.pid,"player","update",{roletype=self.roletype})
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

-- 增加素质点
function cplayer:add_qualitypoint(val,reason)
	self:add("qualitypoint.sum",val)
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
end

-- 获取消耗的素质点
function cplayer:get_cost_qualitpoint(typ,val)
	local key = string.format("qualitypoint.%s",typ)
	local hasnum = self:query(key,0)
	local costnum = 0
	for i=0,val-1 do
		costnum = costnum + math.floor((hasnum+i-1)/10+2)
	end
	return  costnum
end

function cplayer:can_alloc_qualitypoint_to(typ,val)
	assert(val > 0)
	if not data_1001_PlayerVar.ValidQualityPointType[typ] then
		return false,language.format("非法素质点类型")
	end
	local maxnum = data_1001_PlayerVar.MaxUseQualityPoint[self.jobzs]
	local costnum = self:get_cost_qualitpoint(typ,val)
	local hasnum = self:query("qualitypoint." .. typ) or 0
	local sumnum = self:query("qualitypoint.sum",0) + self:query("qualitypoint.expand",0)
	if costnum >= sumnum then
		return false,language.format("可分配点不足#<R>{1}#点",costnum)
	end
	if val + hasnum > maxnum then
		return false,language.format("分配的单项素质点无法超过#<R>{1}#点",maxnum)
	end
	return true
end

-- 分配指定素质点
function cplayer:alloc_qualitypoint_to(typ,val)
	assert(val > 0)
	local key = string.format("qualitypoint.%s",typ)
	local costnum = self:get_cost_qualitpoint(typ,val)
	self:add("qualitypoint.sum",-costnum)
	self:add(key,val)
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
end

-- 分配素质点
function cplayer:alloc_qualitypoint(tbl)
	-- 忽略未改变的素质类型
	for typ,val in pairs(tbl) do
		if val == 0 then
			tbl[typ] = nil
		end
	end
	local maxnum = data_1001_PlayerVar.MaxUseQualityPoint[self.jobzs]
	local costnum = 0
	for typ,val in pairs(tbl) do
		local isok,errmsg = self:can_alloc_qualitypoint_to(typ,val)
		if not isok then
			return isok,errmsg
		end
		costnum = costnum + self:get_cost_qualitpoint(typ,val)
	end
	local sumnum = self:query("qualitypoint.sum",0) + self:query("qualitypoint.expand",0)
	if costnum >= sumnum then
		return false,language.format("可分配点不足#<R>{1}#点",costnum)
	end
	self:add("qualitypoint.sum",-costnum)
	for typ,val in pairs(tbl) do
		self:add("qualitypoint." .. typ,val)
	end
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
	return true
end

function cplayer:reset_qualitypoint()
	local addnum = 0
	for typ in pairs(data_1001_PlayerVar.ValidQualityPointType) do
		local hasnum = self:query("qualitypoint." .. typ,0)
		for i=1,hasnum-1 do
			addnum = addnum + math.floor((i-1)/10+2)
		end
	end
	self:add("qualitypoint.sum",addnum)
	for typ in pairs(data_1001_PlayerVar.ValidQualityPointType) do
		self:set("qualitypoint." .. typ,1)
	end
	sendpackage(self.pid,"player","update",{
		qualitypoint = self:query("qualitypoint"),
	})
end

function cplayer:genid()
	if self.objid > MAX_NUMBER then
		self.objid = 100
	end
	self.objid = self.objid + 1
	return self.objid
end

function cplayer:additembytype(itemtype,num,bind,reason)
	local itemdb = self:getitemdb(itemtype)
	return itemdb:additembytype(itemtype,num,bind,reason)
end

function cplayer:getitemdb(itemtype)
	local maintype = itemaux.getmaintype(itemtype)
	if maintype == ItemMainType.FASHION_SHOW then
		return self.fashowshowdb
	elseif maintype == ItemMainType.CARD then
		return self.carddb
	else
		return self.itemdb
	end
end

-- 返回的也是itemdb，只是是根据背包类型获取
function cplayer:getitembag(bagtype)
	if bagtype == BAGTYPE.NORMAL or bagtype == "itemdb" then
		return self.itemdb
	elseif bagtype == BAGTYPE.FASHION_SHOW or bagtype == "fashionshowdb" then
		return self.fashionshowdb
	else
		assert(bagtype == BAGTYPE.CARD or bagtype == "carddb")
		return self.carddb
	end
end

function cplayer:getitem(itemid)
	local item = self.itemdb:getitem(itemid)
	if item then
		return item,self.itemdb
	end
	item = self.carddb:getitem(itemid)
	if item then
		return item,self.carddb
	end
	item = self.fashionshowdb:getitem(itemid)
	if item then
		return item,self.fashionshowdb
	end
end

function cplayer:wield(equip)
	local itemdata = itemaux.getitemdata(equip.type)
	if equip.pos == itemdata.wieldpos then
		return
	end
	self.itemdb:moveitem(equip.id,itemdata.wieldpos)
	self:refreshequip()
end

function cplayer:unwield(equip)
	local itemdata = itemaux.getitemdata(equip.type)
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
		local hasteam = true
		if not team then
			logger.log("error","team",string.format("[getteamid but no team] pid=%d teamid=%d",self.pid,self.teamid))
			hasteam = false
		elseif not team:ismember(self.pid) then
			logger.log("error","team",string.format("[getteamid but not a member] pid=%d teamid=%d",self.pid,self.teamid))
			hasteam = false
		end
		if not hasteam then
			sendpackage(self.pid,"team","delmember",{})
			self.teamid = nil
			local scene = scenemgr.getscene(self.sceneid)
			if scene then
				scene:set(self.pid,{
					teamid = 0,
					teamstate = NO_TEAM,
				})
			end
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
		sex = self.sex,
		state = self:teamstate(),
	}
end

-- 场景信息
function cplayer:packscene(sceneid,pos)
	sceneid = sceneid or self.sceneid
	pos = pos or self.pos
	local scene = scenemgr.getscene(sceneid)
	return {
		pid = self.pid,
		name = self.name,
		lv = self.lv,
		roletype = self.roletype,
		sex = self.sex,
		jobzs = self.jobzs,
		joblv = self.joblv,
		teamid = self:getteamid() or 0,
		teamstate = self:teamstate(),
		warid = self.warid or 0,
		scene_strategy = self.scene_strategy,
		agent = self.__agent,
		mapid = scene.mapid,
		sceneid = sceneid,
		pos = pos,
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
	if self:inwar() then
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
			return true
		end
	end
	return false
end

-- 上线进入场景时notleave为真
function cplayer:enterscene(sceneid,pos,notleave)
	assert(sceneid)
	assert(pos)
	
	local newscene = scenemgr.getscene(sceneid)
	if not newscene then
		return false
	end
	if not newscene:isvalidpos(pos) then
		pos = newscene:fixpos(pos)
	end
	local isok,errmsg = self:canenterscene(sceneid,pos)
	if not isok then
		net.msg.S2C.notify(self.pid,errmsg)
		return false
	end
	local pid = self.pid
	if not notleave then
		self:leavescene(self.sceneid)
	end
	newscene:enter(self,pos)
	return true
end

-- 强制跳转到指定坐标
cplayer.jumpto = cplayer.enterscene

function cplayer:canenterscene(sceneid,pos)
	local scene = scenemgr.getscene(sceneid)
	if not scene then
		return false,language.format("场景不存在")
	end

	local isok,errmsg = huodongmgr.canenterscene(self,sceneid,pos)
	if not isok then
		return false,errmsg
	end
	return true
end

function cplayer:setpos(sceneid,pos)
	local scene = scenemgr.getscene(sceneid)
	if not scene:isvalidpos(pos) then
		pos = scene:fixpos(pos)
	end
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

function cplayer:onhourupdate()
	self.shopdb:onhourupdate()
end

function cplayer:onfivehourupdate()
	local now = os.time()
	local today_zerotime = getdayzerotime(now)
	local next_five_hour = today_zerotime + 5 * 3600
	if next_five_hour <= now then
		next_five_hour = next_five_hour + DAY_SECS
	end
	local lefttime = next_five_hour - now
	self.thistemp:set("onfivehourupdate",lefttime)
	-- dosomething()

	local monthno = getyearmonth()
	if self:query("monthno") ~= monthno then
		self:onmonthupdate()
	end
end

-- 每个月第一天的5点时更新
function cplayer:onmonthupdate()
	self:set("monthno",getyearmonth())
end

function cplayer:gettarget(targetid)
	if targetid == 1 then
		return self
	else
		-- pet ?
	end
end

function cplayer:isgm()
	if skynet.getenv("servermode") == "DEBUG" then
		return  true
	end
	if self:query("gm") then
		return true
	end
	return false
end

function cplayer:getskilldb(skillid)
	--TODO 按照编号范围区分
	if data_0201_Skill[skillid] then
		return self.warskilldb
	end
end

function cplayer:getlanguage()
	return self:query("lang") or language.language_to
end

function cplayer:getfighters()
	local fighters = nil
	local errmsg
	local teamstate = player:teamstate()
	if teamstate == NO_TEAM then
		fighters = {self.pid}
	elseif teamstate == TEAM_STATE_CAPTAIN then
		fighters = {self.pid}
		local team = teammgr:getteam(self.teamid)
		table.extend(fighters,team:members(TEAM_STATE_FOLLOW))
	elseif teamstate == TEAM_STATE_LEAVE then
		fighters = {self.pid,}
	else
		assert(teamstate == TEAM_STATE_FOLLOW)
		fighters = nil
		errmsg = language.format("跟随队员无法进行此操作")
	end
	return fighters,errmsg
end

function cplayer:inwar()
	if self.warid and self.warid ~= 0 then
		return true
	end
	return false
end

return cplayer
