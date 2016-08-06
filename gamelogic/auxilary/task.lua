taskaux = taskaux or {}

local tablenames = {
	task = true,
	npc = true,
	award = true,
	text = true,
	fake = true,
}

function taskaux.gettaskdata(taskname,tablename)
	if not data_1500_GlobalTask[taskname] or not data_1500_GlobalTask[taskname][tablename] then
		return
	end
	local data = data_1500_GlobalTask[taskname][tablename]
	if tablenames[tablename] then
		return _G[data]
	end
	return data
end

function taskaux.newcontainer(taskname,pid,tasktype)
	local cls = g_taskcls[taskname]
	return cls.new({
		name = taskname,
		pid = pid,
		type = tasktype,
	})
end

return taskaux
