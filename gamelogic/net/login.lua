
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
			-- 统一流程:注册完后不标记“认证通过”，已定要登录完后才标记
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
	local isok,errmsg = isvalid_name(name)
	if not isok then
		if errmsg then
			net.msg.S2C.notify(obj,errmsg)
		end
		netlogin.S2C.createrole_result(obj,{errcode = STATUS_NAME_INVALID})
		return
	end
	-- 调试模式下允许不经过帐号中心直接创建角色
	if skynet.getenv("servermode") == "DEBUG" then
		local errcode,newrole = debugcreaterole(obj,request)
		if errcode then
			netlogin.S2C.createrole_result(obj,{errcode = errcode,result = newrole})
			return
		end
	end

	local pid = playermgr.genpid()
    if not pid then
		netlogin.S2C.createrole_result(obj,{errcode = STATUS_OVERLIMIT,})
		return
    end
	local newrole = {
		roleid = pid,
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
		roleid = pid,
		role = data
	})
	local status,response = httpc.postx(cserver.accountcenter(),url,request)
	if status == 200 then
		local errcode = unpack_response(response)
		if errcode == STATUS_OK then	
			local player = playermgr.createplayer(pid,{
				account = account,
				roletype = roletype,
				sex = sex,
				name = name,
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
	local kuafuplayer = playermgr.getkuafuplayer(roleid)
	if kuafuplayer then		-- 进入原服时自动跳转到跨服
		local go_srvname = assert(kuafuplayer.go_srvname)
		obj.pid = roleid
		local home_srvname = kuafuplayer.home_srvname or cserver.getsrvname()
		playermgr.gosrv(obj,go_srvname,home_srvname)
		netlogin.S2C.entergame_result(obj,{errcode = STATUS_REDIRECT_SERVER,})
		return
	end
	if not token then -- token认证进入游戏不排队
		local server = globalmgr.server
		if playermgr.onlinenum >= server.onlinelimit then
			loginqueue.push({fd=obj.__fd,roleid=roleid})
			netlogin.S2C.queue(obj,{waitnum=loginqueue.len()})
			netlogin.S2C.entergame_result(obj,{errcode = STATUS_OVERLIMIT,})
			return
		end
	end

	local player
	if oldplayer then	-- 顶号
		if oldplayer.__agent and not oldplayer:isdisconnect() then -- 连线对象才提示，非连线对象可能有：离线对象/跨服对象
			net.msg.S2C.notify(oldplayer,string.format("您的帐号被%s替换下线",gethideip(obj.__ip)))
			net.msg.S2C.notify(obj,string.format("%s的帐号已被你替换下线",gethideip(oldplayer.__ip)))
		end
		playermgr.kick(oldplayer,"replace")
		-- 只有顶替“在线”玩家才忽略走“重新载入玩家”逻辑，因为非在线玩家(如玩家在原服对应的离线玩家
		-- 其维持的数据可能是过时的副本数据
		if oldplayer.__state == "online" then
			player = oldplayer
		else
			player = playermgr.recoverplayer(roleid)
		end
	else
		player = playermgr.recoverplayer(roleid)
	end
	-- token认证登录成功后，通知原服将玩家标记成跨服
	if token_cache then
		playermgr.deltoken(token)
		local home_srvname = token_cache.home_srvname
		-- 去跨服认证通过，通知原服，将玩家标记成跨服
		if home_srvname then
			player.home_srvname = home_srvname
			player.player_data = token_cache.player_data
			player.kuafu_onlogin = token_cache.kuafu_onlogin
			local now_srvname = cserver.getsrvname()
			rpc.call(home_srvname,"rpc","playermgr.addkuafuplayer",{
				pid = roleid,
				go_srvname = now_srvname,
			})
		end
	end

	player.kuafu_onlogin = pack_function("logger.log","debug","test","ok")
	-- 时序: C2S.entergame -> 中途阻塞 -> 连线对象断开连接 -> 阻塞完毕
	-- 此时: 对象身上无连线信息
	if not obj.__agent then
		logger.log("warning","playermgr",string.format("[no agent when C2S.entergame,may be block in C2S.entergame] id=%s",obj.pid))
		return
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

function C2S.tokenlogin(obj,request)
	local token = assert(request.token)
	local account = assert(request.acct)
	local channel = assert(request.channel)
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
