local function test()
	local deque = cdeque.new()
	assert(deque:count() == 0)
	deque:push(1)
	assert(deque:count() == 1)
	assert(deque:pop() == 1)
	assert(deque:count() == 0)
	deque:pushleft(2)
	assert(deque:count() == 1)
	assert(deque:popleft() == 2)
	assert(deque:count() == 0)
	for i = 1,10 do
		deque:push(i)
	end
	for i = 1,10 do
		assert(deque:popleft() == i)
	end
	for i = 1,10 do
		deque:pushleft(i)
	end
	for i = 1,10 do
		assert(deque:pop() == i)
	end
	for i = 6,10 do
		deque:push(i)
	end
	deque:extend({11,12,13,14,15})
	assert(deque:count() == 10,string.format("%s",deque:count()))
	deque:extendleft({5,4,3,2,1})
	assert(deque:count() == 15)
	for i = 1,15 do
		local idx = deque.first + i - 1
		assert(deque.objs[idx] == i,deque.objs[idx])
	end
	deque:del(10)
	assert(deque:count() == 14)
	deque:reverse()
	assert(deque:popleft() == 15)
	deque:rotate()
	assert(deque:popleft() == 1)
	local data = deque:save()
	deque = cdeque.new()
	deque:load(data)
	assert(deque:count() == 12)
	deque:clear()
	assert(deque:count() == 0)
	local a = {}
	local ti1 = os.time()
	for i = 1,100000 do
		table.insert(a,1)
	end
	local ti2 = os.time()
	print(string.format("table insert:%d",ti2-ti1))
	ti1 = os.time()
	for i = 1,100000 do
		table.remove(a,1)
	end
	ti2 = os.time()
	print(string.format("table remove:%d",ti2-ti1))
	deque = cdeque.new()
	ti1 = os.time()
	for i = 1,100000 do
		deque:push(1)
	end
	ti2 = os.time()
	print(string.format("deque push:%d",ti2-ti1))
	ti1 = os.time()
	for i = 1,100000 do
		deque:popleft()
	end
	ti2 = os.time()
	print(string.format("deque popleft:%d",ti2-ti1))
end

return test
