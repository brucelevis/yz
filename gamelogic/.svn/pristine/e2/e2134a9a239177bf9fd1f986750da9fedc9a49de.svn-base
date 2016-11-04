cprivatemsg = class("cprivatemsg")

function cprivatemsg:init(pid)
	self.pid = pid
	self.msgs = {}
	self.maxlen = 200
end

function cprivatemsg:load(data)
	if table.isempty(data) then
		return
	end
	local now = os.time()
	local lifetime = 7 * DAY_SECS
	local msgs = {}
	for i,packmsg in ipairs(data.msgs) do
		local sendtime = packmsg.sendtime
		if not sendtime and sendtime + lifetime > now then
			table.insert(msgs,packmsg)
		end
	end
	self.msgs = msgs
end

function cprivatemsg:save()
	local data = {}
	data.msgs = self.msgs
	return data
end

function cprivatemsg:clear()
	self.msgs = {}
end

function cprivatemsg:push(packmsg)
	local msg = assert(packmsg.msg)
	local sender = assert(packmsg.sender)
	packmsg.sendtime = packmsg.sendtime or os.time()
	table.insert(self.msgs,packmsg)
	if #self.msgs > self.maxlen then
		self:pop(1)
	end
end

cprivatemsg.add = cprivatemsg.push

function cprivatemsg:pop(pos)
	pos = pos or 1
	return table.remove(self.msgs,pos)
end

return cprivatemsg
