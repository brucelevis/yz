ctask = class("ctask")

function ctask:init(conf)
	conf = deepcopy(conf)
	self.taskid = assert(conf.taskid)
	self.state = assert(conf.state)
	self.type = assert(conf.type)
	self.pid = assert(conf.pid)
	self.exceedtime = conf.exceedtime
	self.data = conf.data or {}
	self.execute_step = 1
	self.execute_result = TASK_SCRIPT_NONE
end

function ctask:load(data)
	if not data or not next(data) then
		return
	end
	self.taskid = data.taskid
	self.state = data.state
	self.exceedtime = data.exceedtime
	self.type = data.type
	self.data = data.data
	self.execute_step = data.execute_step or 1
end

function ctask:save()
	local data = {}
	data.taskid = self.taskid
	data.state = self.state
	data.exceedtime = self.exceedtime
	data.type = self.type
	data.data = self.data
	data.execute_step = self.execute_step
	return data
end

function ctask:set(key,val)
	local attrs = {}
	for attr in string.gmatch(key,"([^.]+)%.?") do
		table.insert(attrs,attr)
	end
	local lastkey = table.remove(attrs)
	local root = self
	for i,attr in ipairs(attrs) do
		root = root[attr]
	end
	root[lastkey] = val
end

function ctask:get(key)
	local root = self
	local attrs = {}
	for attr in string.gmatch(key,"([^.]+)%.?") do
		root = root[attr]
	end
	return root
end

return ctask

