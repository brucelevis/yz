-- 双端队列
cdeque = class("cdeque")

function cdeque:init(conf)
	self.objs = {}
	self.first = 0
	self.last = -1
end

function cdeque:save(savefunc)
	local data = {}
	data.first = self.first
	data.last = self.last
	local objs = {}
	for idx,obj in pairs(self.objs) do
		if savefunc then
			objs[idx] = savefunc(obj)
		else
			objs[idx] = obj
		end
	end
	data.objs = objs
	return data
end

function cdeque:load(data,loadfunc)
	if table.isempty(data) then
		return
	end
	self.first = data.first
	self.last = data.last
	for idx,objdata in pairs(data.objs) do
		idx = tonumber(idx)
		if loadfunc then
			self.objs[idx] = loadfunc(objdata)
		else
			self.objs[idx] = objdata
		end
	end
end

function cdeque:push(obj)
	self.last = self.last + 1
	self.objs[self.last] = obj
end

function cdeque:pushleft(obj)
	self.first = self.first - 1
	self.objs[self.first] = obj
end

function cdeque:clear()
	local objs = self.objs
	self.objs = {}
	self.first = 0
	self.last = -1
	for _,obj in pairs(objs) do
		if type(obj) == "table" and type(obj.clear) == "function" then
			obj:clear()
		end
	end
end

function cdeque:count()
	return self.last - self.first + 1
end

function cdeque:extend(tbl)
	if not table.isarray(tbl) then
		return
	end
	for _,obj in ipairs(tbl) do
		self:push(obj)
	end
end

function cdeque:extendleft(tbl)
	if not table.isarray(tbl) then
		return
	end
	for _,obj in ipairs(tbl) do
		self:pushleft(obj)
	end
end

function cdeque:pop()
	assert(self.first <= self.last,"deque is empty")
	local obj = self.objs[self.last]
	self.objs[self.last] = nil
	self.last = self.last - 1
	return obj
end

function cdeque:popleft()
	assert(self.first <= self.last,"deque is empty")
	local obj = self.objs[self.first]
	self.objs[self.first] = nil
	self.first = self.first + 1
	return obj
end

function cdeque:del(target)
	local del_idx
	for idx,obj in pairs(self.objs) do
		if obj == target then
			del_idx = idx
			self.objs[idx] = nil
			break
		end
	end
	if del_idx then
		for idx = del_idx + 1,self.last do
			local obj = self.objs[idx]
			self.objs[idx] = nil
			self.objs[idx - 1] = obj
		end
		self.last = self.last - 1
	end
end

function cdeque:reverse()
	local count = self:count()
	local obj,idx1,idx2
	for i = 0,math.floor(count / 2) - 1 do
		idx1 = self.first + i
		idx2 = self.last - i
		obj = self.objs[idx1]
		self.objs[idx1] = self.objs[idx2]
		self.objs[idx2] = obj
	end
end

-- 向右旋转step步，如果step小于0则向左旋转
function cdeque:rotate(step)
	step = step or 1
	local count = self:count()
	local step = step % count
	local oldobjs = self.objs
	self.objs = {}
	for oldidx = self.first,self.last do
		local offset = (oldidx - self.first + step) % count
		local newidx = self.first + offset
		self.objs[newidx] = oldobjs[oldidx]
	end
end

return cdeque
