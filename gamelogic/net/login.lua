
netlogin = netlogin or {
	C2S = {},
	S2C = {},
}

local C2S = netlogin.C2S
local S2C = netlogin.S2C

function C2S.register(obj,request)
	local account = assert(request.acct)
	local passwd = assert(request.passwd)
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
	})
	local status,response = httpc.post(cserver.accountcenter.host,url,request)
	if status == 200 then
		local errcode,result = unpack_response(response)
		if errcode == STATUS_OK then -- register success
			logger.log("info","register",string.format("[register] account=%s passwd=%s ip=%s:%s",account,passwd,obj.__ip,obj.__port))
			-- 统一流程:注册完后不标记“认证通过”，已定要登录完后才标记
			--obj.passlogin = true
		end
		netlogin.S2C.register_result(obj,{errcode = errcode})
		return
	else
		netlogin.S2C.register_result(obj,{errcode = errcode})
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
			local isroleexist = false
			local player = playermgr.getplayer(pid)
			if not player then
				player = playermgr.loadofflineplayer(pid)
			end
			if not player then
				-- return STATUS_ROLE_NOEXIST
				return STATUS_OK,{}
			else
				obj.account = assert(player.account)
				return STATUS_OK,{
					{
						roleid = player.pid,
						name = player.name,
						lv = player.lv,
						roletype = player.roletype,
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
	obj.account = account
	obj.passwd = passwd
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
	local status,response = httpc.post(cserver.accountcenter.host,url,request)
	if status == 200 then
		local errcode,result = unpack_response(response)
		if errcode == STATUS_OK then
			obj.passlogin = true
			url = string.format("/rolelist")
			local request = make_request({
				gameflag = cserver.gameflag,
				srvname = cserver.getsrvname(),
				acct = account,
			})
			local status2,response2 = httpc.post(cserver.accountcenter.host,url,request)
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
	local name = assert(request.name)
	if not obj.passlogin then
		netlogin.S2C.createrole_result(obj,{errcode = STATUS_UNAUTH})
		return
	end
	if not isvalid_roletype(roletype) then
		netlogin.S2C.createrole_result(obj,{errcode = STATUS_ROLETYPE_INVALID})
		return
	end
	if not isvalid_name(name) then
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
		netlogin.S2C.createrole_result(obj,{result = STATUS_OVERLIMIT,})
		return
    end
	local newrole = {
		roleid = pid,
		roletype = roletype,
		name = name,
		lv = 0,
		gold = 0,
	}

	local data = cjson.encode(newrole)
	local url = string.format("/createrole")
	local request = make_request({
		gameflag = cserver.gameflag,
		srvname = cserver.getsrvname(),
		acct = account,
		roleid = pid,
		role = data,
	})
	local status,response = httpc.post(cserver.accountcenter.host,url,request)
	if status == 200 then
		local errcode = unpack_response(response)
		if errcode == STATUS_OK then	
			local player = playermgr.createplayer(pid,{
				account = account,
				roletype = roletype,
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
	local token = request.token
	if not playermgr.isroleexist(roleid) then
		netlogin.S2C.entergame_result(obj,{errcode = STATUS_ROLE_NOEXIST,})
		return
	end
	local token_cache
	if not obj.passlogin then
		-- token auth
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
	if not token then -- token认证登录不排队
		local server = globalmgr.server
		if playermgr.onlinenum >= server.onlinelimit then
			loginqueue.push({fd=obj.__fd,roleid=roleid})
			netlogin.S2C.queue(obj,{waitnum=loginqueue.len()})
			netlogin.S2C.entergame_result(obj,{errcode = STATUS_OVERLIMIT,})
			return
		end
	end
	if oldplayer then	-- 顶号
		local go_srvname
		-- token认证登录不检查：是否可以自动跳到跨服
		if not token and oldplayer.__state == "kuafu" and oldplayer.go_srvname then
			go_srvname = oldplayer.go_srvname
		end
		if oldplayer.__agent then -- 连线对象才提示，非连线对象可能有：离线对象/跨服对象
			net.msg.S2C.notify(oldplayer,string.format("您的帐号被%s替换下线",gethideip(obj.__ip)))
			net.msg.S2C.notify(obj,string.format("%s的帐号已被你替换下线",gethideip(oldplayer.__ip)))
		end
		netlogin.S2C.kick(oldplayer,"replace")
		-- kick will delobject
		--playermgr.delobject(oldplayer.pid,"replace")
		if go_srvname then
			playermgr.gosrv(obj,go_srvname)
			netlogin.S2C.entergame_result(obj,{errcode = STATUS_REDIRECT_SERVER,})
			return
		end
	end
	local player = playermgr.recoverplayer(roleid)
	if token_cache then
		local home_srvname = assert(token_cache.home_srvname)
		player.home_srvname = home_srvname
		player.player_data = token_cache.player_data
		local now_srvname = cserver.getsrvname()
		rpc.call(home_srvname,"rpc","playermgr.set_go_srvname",roleid,now_srvname)
		playermgr.deltoken(token)
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
		gameflag = cserver.gameflag,
		acct = acct,
		roleid = roleid,
	})
	local status,response = httpc.post(cserver.accountcenter.host,url,request)
	if status == 200 then
		local errcode = unpack_response(response)
		if errcode == STATUS_OK then -- delrole success
			logger.log("info","playermgr",string.format("[delrole] acct=%s roleid=%s",acct,roleid))
		end
		netlogin.S2C.delrole_result(obj,{errcode = errcode})
		return
	else
		netlogin.S2C.delrole_result(obj,{errcode = errcode})
		return
	end
end

function C2S.checktoken(obj,request)
	local token = assert(request.token)
	local account = assert(request.acct)
	local channel = assert(request.channel)
	local url = string.format("/checktoken")
	local request = make_request({
		token = token,
		acct = account,
		channel = channel,
	})
	local status,response = httpc.post(cserver.accountcenter.host,url,request)
	if status == 200 then
		local errcode,result = unpack_response(response)
		if errcode == STATUS_OK then
			obj.passlogin = true
		end
		netlogin.S2C.checktoken_result(obj,{errcode=errcode,result=result})
	else
		netlogin.S2C.checktoken_result(obj,{errcode = status})
	end
end

-- S2C
function S2C.kick(obj)
	sendpackage(obj,"login","kick")
	playermgr.kick(obj)
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

function S2C.checktoken_result(obj,request)
	sendpackage(obj,"login","checktoken_result",request)
end

return netlogin