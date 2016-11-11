
netlogin = netlogin or {
	C2S = {},
	S2C = {},
}

local C2S = netlogin.C2S
local S2C = netlogin.S2C


function C2S.register(obj,request)
	local account = assert(request.acct)
	local passwd = assert(request.passwd)
	local channel = request.channel or "inner"
	if not isvalid_accountname(account) then
		netlogin.S2C.register_result(obj,{errcode = STATUS_ACCT_FMT_ERR})
		return
	end
	if not isvalid_passwd(passwd) then
		netlogin.S2C.register_result(obj,{errcode = STATUS_PASSWD_FMT_ERR})
		return
	end
	local url = string.format("/register")
	local request = make_request({
		acct = account,
		passwd = passwd,
		channel = channel,
	})
	local status,response = httpc.postx(cserver.accountcenter(),url,request)
	if status == 200 then
		local errcode,result = unpack_response(response)
		if errcode == STATUS_OK then -- register success
			logger.log("info","register",string.format("[register] account=%s passwd=%s channel=%s ip=%s:%s",account,passwd,channel,obj.__ip,obj.__port))
			-- 统一流程:注册完后不标记“认证通过”一定要登录完后才标记
			--obj.passlogin = true
		end
		netlogin.S2C.register_result(obj,{errcode = errcode})
		return
	else
		netlogin.S2C.register_result(obj,{errcode = status})
		return
	end
end

-- 调试登录模式：只允许登录本服角色
local function debuglogin(obj,request)
	local account = request.acct
	local passwd = request.passwd
	if account:sub(1,1) == "#" then
		local pid = assert(tonumber(account:sub(2,-1)),account)
		if passwd == "1" then
			obj.passlogin = true
			obj.account = account
			obj.channel = "inner"
			local roletype = 10001
			if not playermgr.isroleexist(pid) then
				-- return STATUS_ROLE_NOEXIST
				return STATUS_OK,{}
			else
				return STATUS_OK,{
					{
						roleid = pid,
						name = account,
						lv = 1,
						roletype = 10001,
					}
				}
			end
		end
		return STATUS_PASSWD_NOMATCH
	end
	return false
end

function C2S.login(obj,request)
	local account = assert(request.acct)
	local passwd = assert(request.passwd)
	if skynet.getenv("servermode") == "DEBUG" then
		local errcode,roles = debuglogin(obj,request)	
		if errcode then
			netlogin.S2C.login_result(obj,{errcode = errcode,result = roles})
			return
		end
	end
	local url = string.format("/login")
	local request = make_request({
		acct = account,
		passwd = passwd,
		ip = obj.__ip,
	})
	local status,response = httpc.postx(cserver.accountcenter(),url,request)
	if status == 200 then
		local errcode,result = unpack_response(response)
		if errcode == STATUS_OK then
			obj.passlogin = true
			obj.account = account
			obj.channel = result.channel
			url = string.format("/rolelist")
			local request = make_request({
				gameflag = cserver.gameflag(),
				srvname = cserver.getsrvname(),
				acct = account,
			})
			local status2,response2 = httpc.postx(cserver.accountcenter(),url,request)
			if status2 == 200 then
				local errcode2,result = unpack_response(response2)
				if errcode2 == STATUS_OK then
					netlogin.S2C.login_result(obj,{errcode = STATUS_OK,result = result})
					return
				else
					netlogin.S2C.login_result(obj,{errcode = errcode2,})
					return
				end
			else
				netlogin.S2C.login_result(obj,{errcode = status2})
				return
			end
		else
			netlogin.S2C.login_result(obj,{errcode = errcode})
			return
		end
	else
		netlogin.S2C.login_result(obj,{errcode = status})
		return
	end
end

local function debugcreaterole(obj,request)
	local account = assert(obj.account or request.acct)
	local roletype = assert(request.roletype)
	local sex = assert(request.sex)
	local name = assert(request.name)
	if account:sub(1,1) == "#" then
		local pid = assert(tonumber(account:sub(2,-1)),account)
		local newrole = {
			roleid = pid,
			roletype = roletype,
			name = name,
			lv = 0,
			gold = 0,
		}
		local player = playermgr.createplayer(pid,{
			account = account,
			roletype = roletype,
			sex = sex,
			name = name,
			__ip = obj.__ip,
			__port = obj.__port,
		})
		return STATUS_OK,newrole
	end
	return false
end

function C2S.createrole(obj,request)
	local account = assert(obj.account or request.acct)
	local roletype = assert(request.roletype)
	local sex = assert(request.sex)
	local name = assert(request.name)
	if not obj.passlogin then
		netlogin.S2C.createrole_result(obj,{errcode = STATUS_UNAUTH})
		return
	end
	if not isvalid_roletype(roletype) then
		netlogin.S2C.createrole_result(obj,{errcode = STATUS_ROLETYPE_INVALID})
		return
	end
	if not isvalid_sex(sex) then
		netlogin.S2C.createrole_result(obj,{errcode = STATUS_SEX_INVALID})
		return
	end
	local debugmode = skynet.getenv("servermode") == "DEBUG"
	if debugmode and string.sub(name,1,1) == "#" then
		-- debugcreaterole,名字格式一般是:#玩家ID
	else
		local isok,errmsg = isvalid_name(name)
		if not isok then
			if errmsg then
				net.msg.S2C.notify(obj,errmsg)
			end
			netlogin.S2C.createrole_result(obj,{errcode = STATUS_NAME_INVALID})
			return
		end
	end
	-- 调试模式下允许不经过帐号中心直接创建角色
	if skynet.getenv("servermode") == "DEBUG" then
		local errcode,newrole = debugcreaterole(obj,request)
		if errcode then
			netlogin.S2C.createrole_result(obj,{errcode = errcode,result = newrole})
			return
		end
	end
	local newrole = {
		roletype = roletype,
		sex = sex,
		name = name,
		lv = 1,
		gold = 0,
	}
	local data = cjson.encode(newrole)
	local url = string.format("/createrole")
	local request = make_request({
		gameflag = cserver.gameflag(),
		srvname = cserver.getsrvname(),
		acct = account,
		role = data,
		genroleid = 1,		-- 帐号中心统一生成角色ID
	})
	local status,response = httpc.postx(cserver.accountcenter(),url,request)
	if status == 200 then
		local errcode,result = unpack_response(response)
		if errcode == STATUS_OK then	
			local roleid = assert(result.roleid)
			newrole.roleid = roleid
			local player = playermgr.createplayer(roleid,{
				account = account,
				roletype = roletype,
				sex = sex,
				name = name,
				lv = 1,
				gold = 0,
				__ip = obj.__ip,
				__port = obj.__port,
			})
			netlogin.S2C.createrole_result(obj,{errcode = errcode,result = newrole})
			return
		else
			netlogin.S2C.createrole_result(obj,{errcode = errcode})
			return
		end
	else
		netlogin.S2C.createrole_result(obj,{errcode = status})
		return
	end
end

function C2S.entergame(obj,request)
	local roleid = assert(request.roleid)
	local token = request.token -- 跨服进入游戏会带token标记
	local banlogin,detail = globalmgr.ban.login(roleid)
	if banlogin then
		local msg
		if detail and detail.exceedtime and detail.exceedtime ~= "" then
			msg = language.format("角色已被禁止登录,截止时间:{1}",detail.exceedtime)
		else
			msg = language.format("角色已被禁止登录")
		end
		net.msg.S2C.notify(obj,msg)
		netlogin.S2C.entergame_result(obj,{errcode = STATUS_BAN_ROLE})
		return
	end
	if not token and not playermgr.isroleexist(roleid) then
		netlogin.S2C.entergame_result(obj,{errcode = STATUS_ROLE_NOEXIST,})
		return
	end
	local token_cache
	if not obj.passlogin then
		-- token认证
		if token then
			token_cache = playermgr.gettoken(token)
			if not token_cache or token_cache.pid ~= roleid then
				netlogin.S2C.entergame_result(obj,{errcode = STATUS_UNAUTH})
				return
			end
		else
			netlogin.S2C.entergame_result(obj,{errcode = STATUS_UNAUTH})
			return
		end
		obj.passlogin = true
	end
	
	local oldplayer = playermgr.getplayer(roleid) 
	if obj == oldplayer then
		netlogin.S2C.entergame_result(obj,{errcode = STATUS_REPEAT_LOGIN,})
		return
	end

	if oldplayer and not oldplayer:isloaded() then
		net.msg.S2C.notify(obj,language.format("进入游戏过于频繁，请稍候再试"))
		netlogin.S2C.entergame_result(obj,{errcode = STATUS_REPEAT_LOGIN,})
		return
	end
	-- 获取玩家当前所在服有两种方式：1. 从玩家原服获取，2. 从数据中心获取（这样登录依赖于数据中心)
	local self_srvname = cserver.getsrvname()
	local home_srvname = globalmgr.home_srvname(roleid)
	if not home_srvname then	-- invalid roleid
		netlogin.S2C.entergame_result(obj,{errcode = STATUS_ROLE_NOEXIST})
		return
	end

	local now_srvname,isonline = globalmgr.now_srvname(roleid)
	if now_srvname ~= self_srvname then
		if isonline and clustermgr.nodown(now_srvname) then
			obj.pid = roleid
			playermgr.gosrv(obj,now_srvname)
			netlogin.S2C.entergame_result(obj,{errcode = STATUS_REDIRECT_SERVER,})
			return
		end
	end
	if not token then -- token认证进入游戏不排队
		if playermgr.onlinenum >= globalmgr.server.onlinelimit then
			loginqueue.push({fd=obj.__fd,roleid=roleid})
			local waitnum = loginqueue.len()
			local waittime = waitnum * (2 + math.floor(skynet.mqlen()/100))
			netlogin.S2C.queue(obj,{
				waitnum = waitnum,
				waittime = waittime,
			})
			netlogin.S2C.entergame_result(obj,{errcode = STATUS_OVERLIMIT,})
			return
		end
	end
	-- 恢复数据前就让原服标记跨服，保证玩家跨服载入数据的同时，发给原服的rpc操作能转发到当前服
	if home_srvname ~= self_srvname then
		rpc.pcall(home_srvname,"rpc","playermgr.addkuafuplayer",{
			pid = roleid,
			go_srvname = self_srvname,
			after_gosrv = token_cache and token_cache.after_gosrv,
		})
	end

	local player
	if oldplayer then	-- 顶号
		if oldplayer.__agent and not oldplayer:isdisconnect() then -- 连线对象才提示，非连线对象可能有：离线对象/跨服对象
			net.msg.S2C.notify(oldplayer,string.format("您的帐号被%s替换下线",gethideip(obj.__ip)))
			net.msg.S2C.notify(obj,string.format("%s的帐号已被你替换下线",gethideip(oldplayer.__ip)))
		end
		playermgr.kick(oldplayer,"replace")
		-- 只有顶替“在线”玩家才忽略走“重新载入玩家”逻辑，因为非在线可能是只读对象
		if oldplayer.__state == "online" then
			player = oldplayer
		else
			player = playermgr.recoverplayer(roleid)
		end
	else
		player = playermgr.recoverplayer(roleid)
	end
	assert(player)
	
	-- 时序: C2S.entergame -> 中途阻塞 -> 连线对象断开连接 -> 阻塞完毕
	-- 此时: 对象身上无连线信息
	if not obj.__agent then
		logger.log("warning","playermgr",string.format("[no agent when C2S.entergame,may be block in C2S.entergame] id=%s",obj.pid))
		return
	end

	-- token认证登录成功后，通知原服将玩家标记成跨服
	if token_cache then
		playermgr.deltoken(token)
		player.player_data = token_cache.player_data
		player.kuafu_onlogin = token_cache.kuafu_onlogin
		if home_srvname ~= self_srvname then
			player.home_srvname = home_srvname
		end
	end

	playermgr.transfer_mark(obj,player)
	playermgr.nettransfer(obj,player)
	player:entergame()
	netlogin.S2C.entergame_result(obj,{errcode = STATUS_OK,})
end

function C2S.exitgame(player,request)
	player:exitgame()
end

function C2S.delrole(obj,request)
	if not obj.passlogin then
		netlogin.S2C.delrole_result(obj,{errcode = STATUS_UNAUTH})
		return
	end
	local acct = assert(obj.account)
	local roleid = assert(request.roleid)
	local url = string.format("/delrole")
	local request = make_request({
		gameflag = cserver.gameflag(),
		acct = acct,
		roleid = roleid,
	})
	local status,response = httpc.postx(cserver.accountcenter(),url,request)
	if status == 200 then
		local errcode = unpack_response(response)
		if errcode == STATUS_OK then -- delrole success
			logger.log("info","playermgr",string.format("[delrole] acct=%s roleid=%s",acct,roleid))
		end
		netlogin.S2C.delrole_result(obj,{errcode = errcode})
		return
	else
		netlogin.S2C.delrole_result(obj,{errcode = status})
		return
	end
end

function netlogin.checkversion(version)
	if not netlogin.version then
		netlogin.version = "0.1.2"
	end
	local list1 = string.split(netlogin.version)
	local list2 = string.split(version)
	local len = #list1
	for i=1,len do
		local ver1 = list1[i]
		local ver2 = list1[i]
		if not ver2 then
			return false
		end
		if ver2 < ver1 then
			return false
		elseif ver2 > ver1 then
			return true
		end
	end
	return true
end

function C2S.tokenlogin(obj,request)
	local token = assert(request.token)
	local account = assert(request.acct)
	local channel = assert(request.channel)
	local version = request.version
	if version and netlogin.checkversion(version) then
		netlogin.S2C.tokenlogin_result(obj,{errcode = STATUS_LOW_VERSION,})
		return
	end
	local url = string.format("/tokenlogin")
	local request = make_request({
		token = token,
		acct = account,
		channel = channel,
	})
	local status,response = httpc.postx(cserver.accountcenter(),url,request)
	if status == 200 then
		local errcode,result = unpack_response(response)
		if errcode == STATUS_OK then
			obj.passlogin = true
			obj.account = account
			obj.channel = channel
		end
		netlogin.S2C.tokenlogin_result(obj,{errcode=errcode,result=result})
	else
		netlogin.S2C.tokenlogin_result(obj,{errcode = status})
	end
end

-- S2C
function S2C.kick(obj)
	sendpackage(obj,"login","kick",{})
end

function S2C.queue(obj,request)
	sendpackage(obj,"login","queue",request)
end

function S2C.reentergame(obj,request)
	sendpackage(obj,"login","reentergame",request)
end

function S2C.register_result(obj,request)
	sendpackage(obj,"login","register_result",request)
end

function S2C.createrole_result(obj,request)
	sendpackage(obj,"login","createrole_result",request)
end

function S2C.login_result(obj,request)
	sendpackage(obj,"login","login_result",request)
end

function S2C.entergame_result(obj,request)
	sendpackage(obj,"login","entergame_result",request)
end

function S2C.delrole_result(obj,request)
	sendpackage(obj,"login","delrole_result",request)
end

function S2C.tokenlogin_result(obj,request)
	sendpackage(obj,"login","tokenlogin_result",request)
end

return netlogin
