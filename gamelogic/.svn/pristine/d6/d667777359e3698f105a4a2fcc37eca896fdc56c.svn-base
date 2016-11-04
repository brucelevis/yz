safelock = safelock or {}

safelock.ERRCNT_LIMIT = 5
safelock.FROZEN_TIME = 1800 -- 30min
safelock.FORCE_UNLOCK_WAITDAY = 5

function safelock.onlogin(player)
	-- 每次重新上线都锁住
	local sflock = player:query("safelock")
	if sflock then
		sflock.islock = true
	end
	safelock.refresh(player)
end

function safelock.isvalidpasswd(passwd,checkpasswd)
	if checkpasswd and passwd ~= checkpasswd then
		return false,language.format("两次输入的密码不一致，请重新输入")
	end
	local len = #passwd
	if not (6 <= len and len <= 8) then
		return false,language.format("需要输入6~8位的数字密码")
	end
	if not string.match(passwd,"^%d+$") then
		return false,language.format("需要输入6~8位的数字密码")
	end
	return true
end

function safelock.setpasswd(player,passwd,checkpasswd)
	local pid = player.m_ID
	local isok,msg = safelock.isvalidpasswd(passwd,checkpasswd)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	local sflock = player:query("safelock")
	if sflock and sflock.passwd then
		net.msg.S2C.notify(player.pid,language.format("你已经设置安全锁密码了"))
		return
	end
	sflock = {
		passwd = passwd,
		islock = true,
	}
	logger.log("info","safelock",string.format("setpasswd,pid=%d passwd=%s",pid,passwd))
	player:set("safelock",sflock)
	safelock.refresh(player)
end

function safelock.modifypasswd(player,oldpasswd,newpasswd,new_checkpasswd)
	if not safelock.checkfrozen(player) then
		return
	end
	local pid = player.m_ID
	local sflock = player:query("safelock")
	if not sflock or not sflock.passwd then
		net.msg.S2C.notify(player.pid,language.format("你尚未设置安全锁密码"))
		return
	end
	if sflock.passwd ~= oldpasswd then
		safelock.on_error_passwd(player)
		return
	else
		player.thistemp:delete("safelock.errcnt")
	end
	if sflock.passwd == newpasswd then
		net.msg.S2C.notify(player.pid,language.format("新旧密码一样，请重新输入"))
		return
	end
	local isok,msg = safelock.isvalidpasswd(newpasswd,new_checkpasswd)
	if not isok then
		net.msg.S2C.notify(player.pid,msg)
		return
	end
	logger.log("info","safelock",string.format("modifypasswd,pid=%d passwd=%s newpasswd=%s",pid,sflock.passwd,newpasswd))
	net.msg.S2C.notify(player.pid,"成功修改新密码，请牢记新密码")
	sflock.passwd = newpasswd
	sflock.islock = true
	sflock.unlock_exceedtime = nil
	safelock.refresh(player)
end

function safelock.unsetpasswd(player,passwd)
	if not safelock.checkfrozen(player) then
		return
	end
	local pid = player.m_ID
	local sflock = player:query("safelock")
	if not sflock or not sflock.passwd then
		net.msg.S2C.notify(player.pid,"你尚未设置安全锁密码")
		return
	end
	if sflock.passwd ~= passwd then
		safelock.on_error_passwd(player)
		return
	else
		player.thistemp:delete("safelock.errcnt")
	end
	logger.log("info","safelock",string.format("unsetpasswd,pid=%d passwd=%s",pid,sflock.passwd))
	net.msg.S2C.notify(player.pid,language.format("成功取消安全锁，请注意账号安全"))
	player:delete("safelock")
	safelock.refresh(player)
end

function safelock.unlock(player,passwd)
	if not safelock.checkfrozen(player) then
		return
	end
	local pid = player.m_ID
	local sflock = player:query("safelock")
	if not sflock or not sflock.passwd then
		net.msg.S2C.notify(player.pid,language.format("你尚未设置安全锁密码"))
		return
	end
	if not sflock.islock then
		net.msg.S2C.notify(player.pid,language.format("你已解锁，不需要再次解锁。"))
		return
	end
	if sflock.passwd ~= passwd then
		safelock.on_error_passwd(player)
		return
	else
		player.thistemp:delete("safelock.errcnt")
	end
	logger.log("info","safelock",string.format("unlock,pid=%d passwd=%s",pid,passwd))
	net.msg.S2C.notify(player.pid,"成功解除登录的安全锁")
	sflock.islock = nil
	sflock.unlock_exceedtime = nil
	safelock.refresh(player)
end


function safelock.checkfrozen(player)
	local errcnt,exceedtime = player.thistemp:query("safelock.errcnt")
	if errcnt then
		local limit = safelock.ERRCNT_LIMIT
		if errcnt >= limit then
			local leftmin = math.ceil((exceedtime-os.time())/60)
			net.msg.S2C.notify(player.pid,language.format("你已连续输入#<R>{1}#次错误的密码，#<R>{1}#分钟内禁止解除密码、修改密码、取消密码的操作",limit,leftmin))
			return false
		end
	end
	return true
end

function safelock.on_error_passwd(player)
	local errcnt,exceedtime = player.thistemp:query("safelock.errcnt")
	if errcnt then
		errcnt = errcnt + 1
		player.thistemp:add("safelock.errcnt",1)
	else
		errcnt = 1
		player.thistemp:set("safelock.errcnt",1,safelock.FROZEN_TIME)
	end
	local leftcnt = safelock.ERRCNT_LIMIT-errcnt
	if leftcnt > 0 then
		net.msg.S2C.notify(player.pid,language.format("请输入正确的密码,再输错#<R>{1}#后将进入冷却状态",leftcnt))
	end
	safelock.checkfrozen(player)
end


function safelock.get_unlock_exceedtime(player)
	local sflock = player:query("safelock")
	if sflock and sflock.unlock_exceedtime then
		local now = os.time()
		if sflock.unlock_exceedtime <= now then
			sflock.unlock_exceedtime = nil
			sflock.passwd = nil
			sflock.islock = nil
		else
			return sflock.unlock_exceedtime
		end
	end
end

function safelock.force_unlock(player,passwd)
	local pid = player.m_ID
	local sflock = player:query("safelock")
	if not sflock or not sflock.passwd then
		net.msg.S2C.notify(player.pid,language.format("你尚未设置安全锁密码"))
		return
	end
	if passwd then
		safelock.unsetpasswd(player,passwd)
	else
		local now = os.time()
		local unlock_exceedtime = safelock.get_unlock_exceedtime(player)
		if unlock_exceedtime then
			local lefttime = unlock_exceedtime - now
			net.msg.S2C.notify(player.pid,language.format("已处于强行解锁状态，还需要#<R>{1}#后自动解锁",strftime("%d天%h小时%m分钟",lefttime)))
		else
			logger.log("info","safelock",string.format("force_unlock,pid=%d",pid))
			local waitday = safelock.FORCE_UNLOCK_WAITDAY
			sflock.unlock_exceedtime = now + waitday * DAY_SECS
			safelock.refresh(player)
			net.msg.S2C.notify(player.pid,language.format("强行解除将于#<R>{1}天#后生效",waitday))
		end
	end
end

function safelock.islock(player)
	local sflock = player:query("safelock")
	if sflock and sflock.passwd and sflock.islock then
		return true
	end
	return false
end

function safelock.packsafelock(player)
	local unlock_exceedtime = safelock.get_unlock_exceedtime(player)
	local sflock = player:query("safelock")
	if sflock then
		return {
			islock = sflock.islock and 1 or 0,
			passwd = sflock.passwd and 1 or 0,
			unlock_exceedtime = unlock_exceedtime,  -- 强行解锁过期时间
		}
	else
		return {}
	end
end

function safelock.refresh(player)
	local package = safelock.packsafelock(player)
	sendpackage(player.pid,"safelock","sync",package)
end

function safelock.checklock(player)
	safelock.get_unlock_exceedtime(player) -- 检查强制解锁是否过期
	if safelock.islock(player) then
		sendpackage(player.pid,"safelock","popui_enterpasswd",{})
		return false
	end
	return true
end

return safelock
