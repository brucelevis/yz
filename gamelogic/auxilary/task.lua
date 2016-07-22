taskaux = taskaux or {}

function taskaux.gettaskdata(taskname,tablename)
	if not data_GlobalTaskData[taskname] or not data_GlobalTaskData[taskname][tablename] then
		return
	end
	local data = data_GlobalTaskData[taskname][tablename]
	if table.find({"task","npc","award","text","fake"},tablename) then
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
