-- 适配框架
__object_id = __object_id or 0
print("newid:",__object_id)

cobject = cobject or {}

cobject_mt = cobject_mt or {}
function cobject_mt.__index(self,key)
	if key == "pid" then
		return self.m_ID
	elseif key == "__agent" then
		return self.m_agent
	elseif key == "__fd" then
		return self.m_connectionId
	elseif key == "__ip" then
		local pos = string.find(self.m_addr,":")
		if pos then
			return self.m_addr:sub(1,pos-1)
		end
	elseif key == "__port" then
		local pos = string.find(self.m_addr,":")
		if pos then
			return self.m_addr:sub(pos+1)
		end
	else
		return cobject[key]
	end
end


function cobject.new()
	local self = {}
	__object_id = __object_id - 1
	self.m_ID = __object_id
	self.__state = "link"
	setmetatable(self,cobject_mt)
	return self
end

-- 客户端连上后，会新建连线对象，并立即调用whenConnected
function cobject:whenConnected(connectionId,addr,agenthandle)
	self.m_connectionId = connectionId
	self.m_addr = addr
	self.m_agent = agenthandle
end


-- 客户端断线后，会触发连线对象调用exitgame并且删除连线对象
function cobject:exitgame()
	local player = playermgr.getobjectbyfd(self.m_connectionId)
	if player then
		assert(player.__state == "online")
		player:disconnect("disconnect")
	end
end

-- 客户端断线后，会触发连线对象调用exitgame并紧接着调用whenDisConnected
function cobject:whenDisConnected()
	self.m_connectionId = nil
	self.m_addr = nil
	self.m_agent = nil
end

return cobject
