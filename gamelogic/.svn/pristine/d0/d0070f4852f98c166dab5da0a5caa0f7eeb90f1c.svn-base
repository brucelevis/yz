local mc = require "multicast"

channel = channel or {}

function channel.init()
	channel.channels = {}
	channel.add("world")
end

function channel.add(name,...)
	if select("#",...) > 0 then
		local args = table.pack(...)
		table.insert(args,1,name)
		name = table.concat(args,"#")
	end
	assert(name)
	assert(channel.channels[name]==nil)
	local chan = mc.new()
	logger.log("info","channel",string.format("[add] name=%s channel=%s",name,chan.channel))
	channel.channels[name] = chan
end

function channel.del(name,...)
	if select("#",...) > 0 then
		local args = table.pack(...)
		table.insert(args,1,name)
		name = table.concat(args,"#")
	end
	-- 延迟1s后再删除频道,减少channel.unsubscribe后紧跟channel.del可能存在的时序问题(涉及不同服)
	skynet.timeout(1,function ()
		channel._del(name)
	end)
end

function channel._del(name)
	local chan = channel.get(name)
	if chan then
		logger.log("info","channel",string.format("[del] name=%s channel=%s",name,chan.channel))
		chan:delete()
		channel.channels[name] = nil
	end
end

function channel.get(name,...)
	if select("#",...) > 0 then
		local args = table.pack(...)
		table.insert(args,1,name)
		name = table.concat(args,"#")
	end
	return channel.channels[name]
end

function channel.publish(name,...)
	if channel.delay_publish(name,...) then
		return
	end
	return channel._publish(name,...)
end

function channel._publish(name,...)
	local chan = channel.get(name)
	if chan then
		logger.log("debug","channel",format("[publish] name=%s channel=%s pack=%s",name,chan.channel,{...}))
		chan:publish(...)
	end
end

function channel.subscribe(name,pid)
	local chan = channel.get(name)
	if not chan then
		return
	end
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local agent = player.__agent
	logger.log("info","channel",string.format("[subscribe] name=%s channel=%s pid=%s",name,chan.channel,pid))
	skynet.send(agent,"lua","subscribe",chan.channel)
end

function channel.unsubscribe(name,pid)
	local chan = channel.get(name)
	if not chan then
		return
	end
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local agent = player.__agent
	logger.log("info","channel",string.format("[unsubscribe] name=%s channel=%s pid=%s",name,chan.channel,pid))
	skynet.send(agent,"lua","unsubscribe",chan.channel)
end

-- 广播频率,消息优先级控制
channel.WORLDMSG_PRIORITY = {
	hornmsg = 1,
	worldmsg = 2,
}
function channel.delay_publish(name,...)
	-- 只对世界频道消息进行:延迟发送
	if name ~= "world" then
		return false
	else
		channel.init_delay_publish(name)
	end
	local pack = ...
	local type = pack.s
	local priority = channel.WORLDMSG_PRIORITY[type]
	if priority == 1 then
		table.insert(channel.hornmsgs,pack)
	elseif priority == 2 then
		table.insert(channel.worldmsgs,pack)
	end
	return true
end

function channel.init_delay_publish(name)
	if not channel.binit then
		channel.binit = true
		channel.hornmsgs = {}
		channel.worldmsgs = {}
		-- 0.5s
		timer.timeout2("timer.delay_publish",50,channel.starttimer_publish)
	end
end

function channel.starttimer_publish()
	local name = "world"
	timer.timeout2("timer.delay_publish",50,channel.starttimer_publish)
	local limit = 50
	local msgs = {}
	for i=1,limit do
		local pack = table.remove(channel.hornmsgs,1)
		if not pack then
			break
		end
		table.insert(msgs,pack)
	end
	for i,pack in ipairs(msgs) do
		channel._publish(name,pack)
	end
	msgs = {}
	for i=1,limit do
		local pack = table.remove(channel.worldmsgs,1)
		if not pack then
			break
		end
		table.insert(msgs,pack)
	end
	for i,pack in ipairs(msgs) do
		channel._publish(name,pack)
	end
end

return channel
