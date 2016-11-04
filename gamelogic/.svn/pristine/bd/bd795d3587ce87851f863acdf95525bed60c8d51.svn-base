local function test()
	wordfilter.init({
		filter_words = {
			"奸",
			"台独",
		},
		exclude_words = {
			"除奸",
		},
	})
	local msg = "台独分子奸杀妇女"
	local isok,msg = wordfilter.filter(msg)
	assert(isok)
	assert(msg == "**分子*杀妇女")
	local msg = "台独分子在做除奸任务"
	local isok,msg = wordfilter.filter(msg)
	assert(isok)
	assert(msg == "**分子在做除奸任务")
end

return test
