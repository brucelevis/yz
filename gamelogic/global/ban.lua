-- 禁言/禁止登录
-- 角色禁言在逻辑服存数据库
-- IP禁止登录/帐号禁止登录在帐号中心存数据库
-- IP禁言/帐号禁言/角色ID禁止登录读策划填好的配置表
globalmgr.ban = globalmgr.ban or {}
local ban = globalmgr.ban

function ban.exist_and_notimeout(dict,key,now)
	key = tostring(key)
	now = now or os.time()
	local detail = dict[key]
	if not detail then
		return false,detail
	end
	if not detail.exceedtime or detail.exceedtime == "" then
		return true,detail
	end
	local time = string.totime(detail.exceedtime)
	if now < time then
		return true,detail
	end
	return false
end

function ban.speak(player)
	local acct = player.acct
	local ip = player.ip
	local roleid = player.roleid
	local inblack,detail = ban.exist_and_notimeout(speak_acct_blacklist,acct)
	if inblack then
		return true,detail
	end
	inblack,detail = ban.exist_and_notimeout(speak_ip_blacklist,ip)
	if inblack then
		return true,detail
	end
	local player = playermgr.getplayer(roleid)
	if player and player:query("banspeak") then
		return true,player:query("banspeak")
	end
	return false
end

function ban.login(roleid)
	-- 禁止所有登录
	if ban.alllogin then
		return true
	end
	local inblack,detail = ban.exist_and_notimeout(login_roleid_blacklist,roleid)
	if inblack then
		return true,detail
	end
	-- 禁止普通玩家登录
	if ban.playerlogin then
		local inwhite,detail = ban.exist_and_notimeout(login_roleid_whitelist,roleid)
		if not inwhite then
			return true
		end
	end
	return false
end

return ban
