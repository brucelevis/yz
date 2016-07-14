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


return taskaux
