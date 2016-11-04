require "gamelogic.task.task"
require "gamelogic.task.taskdb"
require "gamelogic.task.taskcontainer"
require "gamelogic.task.auxilary"

function gettaskdata(taskname,tablename)
	if not data_GlobalTaskData[taskname] or not data_GlobalTaskData[taskname][tablename] then
		return
	end
	local data = data_GlobalTaskData[taskname][tablename]
	if table.find({"task","npc","award","text","fakedata"},tablename) then
		return _G[data]
	end
	return data
end

