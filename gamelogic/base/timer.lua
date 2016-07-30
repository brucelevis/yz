timer = timer or {
	timers = {},
	id = 0,
}
function timer.timeout(name,delay,callback)
	local typ = type(delay)
	if typ == "string" or typ == "table" then  -- cronexpr
		return timer.cron_timeout(name,delay,callback)
	end
	delay = delay * 100
	return timer.timeout2(name,delay,callback)
end

function timer.timeout2(name,delay,callback)
	local id = timer.addtimer(name,callback)

	logger.log("debug","timer",string.format("[timeout] id=%s name=%s,delay=%s callback=%s",id,name,delay,callback))
	skynet.timeout(delay,function ()
		timer.ontimeout(name,id)
	end)
	return id
end

function timer.untimeout(name,id)
	if timer.gettimer(name,id) then
		logger.log("debug","timer",string.format("[untimeout] name=%s,id=%s",name,id))
		return timer.deltimer(name,id)
	end
end

function timer.deltimerbyid(id)
	for name,callbacks in pairs(timer.timers) do
		if callbacks[id] then
			logger.log("debug","timer",string.format("[deltimerbyid] name=%s,id=%s",name,id))
			local callback = callbacks[id]
			callbacks[id] = nil
			return callback,name
		end
	end
end

function timer.cron_timeout(name,cron,callback,callit)
	if type(cron) == "string" then
		cron = cronexpr.new(cron)
	end
	assert(type(cron) == "table")
	local now = os.time()
	local nexttime = cronexpr.nexttime(cron,now)
	local delay = nexttime - now
	assert(delay > 0)
	if callit then
		callback()
	end
	local timerid = timer.timeout(name,delay,functor(timer.cron_timeout,name,cron,callback,true))
	return timerid
end


-- private method
function timer.genid()
	if timer.id > MAX_NUMBER then
		timer.id = 0
	end
	timer.id = timer.id + 1
	return timer.id
end

function timer.addtimer(name,callback)
	if not timer.timers[name] then
		timer.timers[name] = {}
	end
	local id = timer.genid()
	timer.timers[name][id] = callback
	return id
end

function timer.gettimer(name,id)
	local timers = timer.timers[name]
	if not id then
		return timers
	elseif timers then
		return timers[id]
	end
end

function timer.deltimer(name,id)
	local timers = timer.timers[name]
	if not id then
		local callbacks = timer.timers[name]
		timer.timers[name] = nil
		return callbacks
	elseif timers then
		local callback = timers[id]
		timers[id] = nil
		return callback
	end
end


function timer.ontimeout(name,id)
	local callback = timer.gettimer(name,id)
	if callback then
		timer.deltimer(name,id)
		logger.log("debug","timer",string.format("[ontimeout] name=%s id=%s",name,id))
		xpcall(callback,onerror)
	end
end

return timer
