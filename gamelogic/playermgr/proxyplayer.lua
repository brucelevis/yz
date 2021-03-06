-- 跨服玩家代理
-- 如: 
-- local pid = 1000001
-- local player = cproxyplayer.new(pid)
-- player.itemdb:additembytype(105001,10,nil,"test:rpc")
-- local addgold = player:addgold(10,"test:rpc")
-- print(addgold)  -- 10
-- 只支持rpc调用函数，并且需要保证调用的函数,参数和返回值是"值类型"
-- 暂时不支持rpc获取属性
cproxyplayer = cproxyplayer or {}

cproxyplayer_meta = cproxyplayer_meta or {}

function cproxyplayer_meta.__index(self,cmd)
	self.cmd = cmd
	local proxy = cproxyplayer.new(self.pid)
	proxy.parent = self
	self[cmd] = proxy
	return proxy
end

function cproxyplayer_meta.__call(self,first,...)
	local pid = self.pid

	local cmds = {}
	table.insert(cmds,1,self.parent.cmd)
	if self.parent == first then
		table.insert(cmds,1,":")
	else
		table.insert(cmds,1,".")
	end
	local root = self.parent
	while root.parent do
		table.insert(cmds,1,root.parent.cmd)
		table.insert(cmds,1,".")
		root = root.parent
	end
	local cmd = table.concat(cmds)
	local now_srvname = root.now_srvname
	--print("rpc.call",now_srvname,"playermethod",pid,cmd,...)
	return rpc.call(now_srvname,"playermethod",pid,cmd,...)
end



function cproxyplayer.new(pid,now_srvname)
	now_srvname = now_srvname or globalmgr.now_srvname(pid)
	local self = {
		pid = pid,
		cmd = false,
		parent = false,
		now_srvname = now_srvname,
	}
	setmetatable(self,cproxyplayer_meta)
	return self
end

return cproxyplayer
