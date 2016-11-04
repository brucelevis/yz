playermgr = playermgr or {}

--/*
-- 所有与玩家相关对象均置入id_obj中，其中包括
-- 连线对象（link)/离线玩家(offline)/在线玩家（online):来跨服的玩家带.home_srvname属性
-- 连线对象/在线对象，有连接ID，同时在fd_id中作标记
--*/
function playermgr.init()
	logger.log("info","playermgr","[init]")
	playermgr.num = 0 -- playermgr.num == playermgr.onlinenum + playermgr.offlinenum + playermgr.linknum
	playermgr.onlinenum = 0
	playermgr.kuafunum = 0		--过来跨服的玩家数，数量已经包含在playermgr.onlinenum中
	playermgr.offlinenum = 0
	playermgr.linknum = 0
	playermgr.id_obj = {}
	playermgr.fd_id = {}

	-- 跨服对象相关
	playermgr.tokens = {}
	playermgr.starttimer_checktoken()
end


function playermgr.getobject(pid)
	return playermgr.id_obj[pid]
end

function playermgr.getplayer(pid)
	local player = playermgr.getobject(pid)
	if player then
		if player.__state == "offline" then
			player.__activetime = os.time()
		end
	end
	return player
end

function playermgr.unloadofflineplayer(pid)
	local player = playermgr.getplayer(pid)
	if player then
		if player.__state == "offline" then
			playermgr.delobject(pid,"unloadofflineplayer")
			return player
		end
	end
end

function playermgr.loadofflineplayer(pid)
	local player = playermgr.getplayer(pid)
	if player then
		return player
	end
	local player = playermgr.recoverplayer(pid)
	if player then
		assert(player:isloaded())
		player.__state = "offline"
		local self_srvname = cserver.getsrvname()
		local home_srvname = globalmgr.home_srvname(pid)
		if home_srvname ~= self_srvname then
			player.nosavetodatabase = true
		elseif playermgr.getkuafuplayer(pid) then
			player.nosavetodatabase = true
		end
		playermgr.addobject(player,"loadofflineplayer")
		return player
	end
end

function playermgr.getobjectbyfd(fd)
	local id = playermgr.fd_id[fd]
	if id then
		return playermgr.getobject(id)
	end
end

function playermgr.allobject(state)
	local list = {}
	for pid,obj in pairs(playermgr.id_obj) do
		local mystate = obj.__state
		if not state or mystate == state then
			table.insert(list,pid)
		end
	end
	return list
end

-- 返回所有在线玩家ID列表
function playermgr.allplayer()
	local list = {}
	for pid,obj in pairs(playermgr.id_obj) do
		local mystate = obj.__state
		if mystate == "online" then
			table.insert(list,pid)
		end
	end
	return list
end

function playermgr.addobject(obj,reason)
	local pid = obj.pid
	logger.log("info","playermgr",string.format("[addobject] pid=%s agent=%s fd=%s state=%s reason=%s",pid,obj.__agent,obj.__fd,obj.__state,reason))
	assert(playermgr.id_obj[pid] == nil,"repeat object pid:" .. tostring(pid))
	playermgr.id_obj[pid] = obj
	if obj.__fd then
		playermgr.fd_id[obj.__fd] = pid
	elseif obj.__state ~= "offline" then
		logger.log("warning","playermgr",string.format("[addobject but no fd] pid=%s agent=%s fd=%s state=%s reason=%s",pid,obj.__agent,obj.__fd,obj.__state,reason))
	end
	playermgr.num = playermgr.num + 1
	if obj.__state == "link" then
		playermgr.linknum = playermgr.linknum + 1
	elseif obj.__state == "offline" then
		playermgr.offlinenum = playermgr.offlinenum + 1
	else
		assert(obj.__state == "online")
		if obj.home_srvname then  -- 跨服过来的玩家
			playermgr.kuafunum = playermgr.kuafunum + 1
		end
		playermgr.onlinenum = playermgr.onlinenum + 1
	end
	if obj.__state ~= "link" then
		obj.savename = string.format("%s.%s",obj.flag,obj.pid)
		autosave(obj)
	end
end

function playermgr.__delobject(obj,reason)
	if obj then
		local pid = obj.pid
		logger.log("info","playermgr",string.format("[delobject] pid=%d agent=%s fd=%s state=%s reason=%s",pid,obj.__agent,obj.__fd,obj.__state,reason))
		assert(obj.__state)
		playermgr.num = playermgr.num - 1
		if obj.__state == "link" then
			playermgr.linknum = playermgr.linknum - 1
		elseif obj.__state == "offline" then
			playermgr.offlinenum = playermgr.offlinenum - 1
		else
			assert(obj.__state == "online")
			if obj.home_srvname then  -- 跨服过来的玩家
				playermgr.kuafunum = playermgr.kuafunum - 1
			end
			playermgr.onlinenum = playermgr.onlinenum - 1
		end
		playermgr.id_obj[pid] = nil
		if obj.__fd then
			playermgr.fd_id[obj.__fd] = nil
		end
		if obj.__state ~= "link" then
			closesave(obj)
			xpcall(obj.savetodatabase,onerror,obj)
		end

		-- 这里是残留代码,最初设计，连线对象也纳入了管理，连线对象可能在排队
		-- 其掉线后，应该从排队中删除。总之，加上这句只会更安全
		loginqueue.remove(pid)

		-- 在线玩家变少时，尝试让排队玩家进入游戏
		if obj.__state == "online" then
			loginqueue.pop()
		end
	end
end

function playermgr.delobject(pid,reason)
	local obj = playermgr.getobject(pid)
	if obj then
		playermgr.__delobject(obj,reason)
	end
end

function playermgr.checkonline(pid)
	local player = playermgr.getplayer(pid)
	if player and player.__state == "online" then
		return true
	else
		return false
	end
end

-- 服务端主动踢下线
function playermgr.kick(pid,reason,callback)
	local obj
	if type(pid) == "table" then
		obj = pid
	else
		obj = playermgr.getobject(pid)
	end
	if obj then
		logger.log("info","playermgr",string.format("[kick] pid=%d agent=%s fd=%s state=%s reason=%s",obj.pid,obj.__agent,obj.__fd,obj.__state,reason))
		obj.bforce_exitgame = true
		if obj.__state == "online" then
			-- disconnect will raise exitgame + delobject
			obj:disconnect(reason)
		else
			playermgr.delobject(obj.pid,reason)
		end
		-- 踢下线并且存盘完毕后执行的回调逻辑
		if callback then
			callback(obj)
		end
		-- 这个协议必须放到disconnect之后!
		net.login.S2C.kick(obj)
		local linkobj = playermgr.getlinkobjbyfd(obj.__fd)
		if linkobj then
			linkobj.passlogin = nil -- 标记为未认证
			g_gamenet:disconnect(linkobj,"kick")
		end
		obj.bforce_exitgame = nil
	end
end

function playermgr.kickall(reason)
	for _,pid in ipairs(playermgr.allobject()) do
		playermgr.kick(pid,reason)
	end
end

function playermgr.newplayer(pid)
	playermgr.unloadofflineplayer(pid)
	return cplayer.new(pid)
end

-- 仅在注册时创建临时玩家
function playermgr.createplayer(pid,conf)
	logger.log("info","playermgr",format("[createplayer] pid=%d player=%s",pid,conf))
	local db = dbmgr.getdb()
	local maxpid = db:get(db:key("role","maxroleid")) or 0
	maxpid = tonumber(maxpid)
	if pid > maxpid then
		db:set(db:key("role","maxroleid"),pid)
	end
	local player = playermgr.newplayer(pid)
	player:create(conf)
	player:savetodatabase()
	return player
end

function playermgr.isroleexist(pid)
	assert(pid)
	local db = dbmgr.getdb()
	return db:hget(db:key("role","list"),pid)
end

-- 返回空的情况可能由:1. 非法角色ID
function playermgr.recoverplayer(pid)
	assert(tonumber(pid),"invalid pid:" .. tostring(pid))
	if not playermgr.id_obj[pid] then
		local player = playermgr.newplayer(pid)
		player.waitloaded = {}
		playermgr.id_obj[pid] = player
		-- may block
		pcall(player.loadfromdatabase,player)
		local waitloaded = player.waitloaded
		player.waitloaded = nil
		playermgr.id_obj[pid] = nil
		if player:isloaded() then
			playermgr.id_obj[pid] = player
		end
		if waitloaded and next(waitloaded) then
			--print("recoverplayer#wakeup",pid,table.dump(waitloaded))
			for i,co in ipairs(waitloaded) do
				skynet.wakeup(co)
			end
		end
	end
	local player = playermgr.id_obj[pid]
	if player and player.waitloaded then
		local co = coroutine.running()
		table.insert(player.waitloaded,co)

		--print("recoverplayer#wait",pid,co,player.loadstate)
		skynet.wait(co)
	end
	-- 返回的player由上层决定是否加入玩家管理器
	playermgr.id_obj[pid] = nil
	if player and player.loadstate == "loaded" then
		return player
	else
		-- player non exist
		return
	end
end

--/*
-- 转移网络标记
--*/
function playermgr.nettransfer(obj1,obj2)
	--obj1一般为连线对象，连线对象存在conmanager.connectIdMapPlayerObj中
	local id1,id2 = obj1.pid,obj2.pid
	logger.log("info","playermgr",string.format("[nettransfer] id1=%s fd1=%s agent1=%s id2=%s fd2=%s agent2=%s",id1,obj1.__fd,obj1.__agent,id2,obj2.__fd,obj2.__agent))
	local agent = assert(obj1.__agent,"link object havn't agent,pid:" .. tostring(id1))
	obj2.m_agent = obj1.m_agent
	obj2.m_connectionId = obj1.m_connectionId
	obj2.m_ID = obj1.m_ID
	obj2.m_addr = obj1.m_addr
	
	-- __agent == m_agent; __fd == m_connectionId; pid == m_ID
	obj2.__agent = agent
	obj2.__fd = obj1.__fd
	obj2.__ip = obj1.__ip
	obj2.__port = obj1.__port
	obj2.__state = "online"	
	-- 由于连线对象现在由框架管理，此处调用delobject理论上是没有效果的
	playermgr.delobject(id1,"nettransfer")
	playermgr.addobject(obj2,"nettransfer")
end

--/*
-- 转移标记
--*/
function playermgr.transfer_mark(obj1,obj2)
	-- 防止obj1中无帐号/渠道信息，把obj2中的帐号密码信息覆盖掉
	-- obj1中无帐号/渠道信息的典型情况是：跨服登录
	obj2.account = obj1.account or obj2.account
	obj2.channel = obj1.channel or obj2.channel		-- 渠道
	obj2.passlogin = obj1.passlogin
end

function playermgr.broadcast(func)
	for pid,player in pairs(playermgr.id_obj) do
		if player then
			xpcall(func,onerror,player)
			--func(player)
		end
	end
end

-- token auth
function playermgr.addtoken(token,ext)
	local v = playermgr.tokens[token]
	if v then
		logger.log("error","kuafu",format("[addtoken] token=%s ext=%s",token,ext))
	end
	if ext.exceedtime then
		ext.exceedtime = os.time() + ext.exceedtime
	else
		ext.exceedtime = os.time() + 60
	end
	logger.log("debug","kuafu",format("[addtoken] token=%s ext=%s",token,ext))
	playermgr.tokens[token] = ext
end

function playermgr.gettoken(token)
	return playermgr.tokens[token]
end

function playermgr.deltoken(token)
	logger.log("debug","kuafu",format("[deltoken] token=%s",token))
	playermgr.tokens[token] = nil
end

function playermgr.starttimer_checktoken()
	timer.timeout("timer.starttimer_checktoken",30,playermgr.starttimer_checktoken)
	local now = os.time()
	for token,v in pairs(playermgr.tokens) do
		if v.exceedtime then
			if v.exceedtime < now then
				playermgr.deltoken(token)
			end
		end
	end
end

-- 适配框架
function playermgr.getlinkobjbyfd(fd)
	return g_connectionmanger.connectIdMapPlayerObj.IdMapObj[fd]
end

return playermgr
