local function test()
	local callback = {}
	function callback.onadd(ranks,rank)
		--pprintf("%s onadd %s",ranks,rank)
	end

	function callback.ondel(ranks,rank)
		pprintf("%s ondel %s",ranks.name,rank)
	end

	function callback.onupdate(ranks,rank,oldpos)
		pprintf("%s onupdate %s from %d",ranks.name,rank,oldpos)
	end

	function callback.onclear(ranks)
		pprintf("%s onclear",ranks.name)
	end

	local ranks = cranks.new("test",
		{"id1","id2"},
		{"sortid1","sortid2",},
		{desc=true,limit=100,callback=callback})
	for i=1,400 do
		local rank = {
			id1 = math.random(1,1000),
			id2 = math.random(1,1000),
			sortid1 = math.random(1,1000),
			sortid2 = math.random(1,1000),
			other = "other",
		}
		if not ranks:get(rank.id1,rank.id2) then
			ranks:add(rank)
		end
	end
	assert(ranks:len() == ranks.limit*2)
	local rank = ranks:getbypos(1)
	ranks:update({
		id1 = rank.id1,
		id2 = rank.id2,
		sortid1 = rank.sortid1 - 100,
	})
	assert(ranks:get(rank.id1,rank.id2) == rank)
	ranks:delbypos(rank.pos)
	for pos,rank in ipairs(ranks.ranks) do
		assert(rank.pos == pos)
	end
	ranks:clear()
end

return test
