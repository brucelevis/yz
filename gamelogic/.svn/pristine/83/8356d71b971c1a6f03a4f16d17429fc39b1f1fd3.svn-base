-- 跨服玩家代理
-- 如: 
-- local pid = 1000001
-- if not playermgr.getkuafuplayer(pid) then
--		return
-- end
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
	--local resume = resumemgr.getresume(pid)
	--if not resume or not resume:get("now_srvname") then
	--	logger.log("warning","cluster","[ignore cproxyplayer:call]",pid,cmd,...)
	--	error("cproxyplayer:call")
	--end
	--local now_srvname = resume:get("now_srvname")
	local kuafuplayer = playermgr.getkuafuplayer(pid)
	if not kuafuplayer or not kuafuplayer.go_srvname then
		logger.log("warning","cluster","[ignore cproxyplayer:call]",pid,cmd,...)
		error("cproxyplayer:call")
	end
	local now_srvname = kuafuplayer.go_srvname
	--print("rpc.call",now_srvname,"playermethod",pid,cmd,...)
	return rpc.call(now_srvname,"playermethod",pid,cmd,...)
end



function cproxyplayer.new(pid)
	local self = {
		pid = pid,
		cmd = false,
		parent = false,
	}
	setmetatable(self,cproxyplayer_meta)
	return self
end

return cproxyplayer
