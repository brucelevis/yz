

local function gettaskdata(taskid)
	local maintype = gettasktype(taskid)
	if not g_taskdata[maintype] then
		error("unknow task type"...taskid)
		return
	end
	local data = g_taskdata[maintype][1]
	return data[taskid]
end

local function tasktypename(taskid)
	local maintype = gettasktype(taskid)
	if not g_taskdata[maintype] then
		error("unknow taskid"..taskid)
		return
	end
	return g_taskdata[maintype][2]
end

local function gettasktype(taskid)
	return math.floor(taskid / 10000)
end


auxilary = {
	gettaskdata = gettaskdata,
	tasktypename = tasktypename,
}

return auxilary
