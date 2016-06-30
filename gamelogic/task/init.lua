require "gamelogic.task.task"
require "gamelogic.task.taskdb"


local g_taskdata={
	[1302] = data_OrgRunRingTask,
	[1000] = data_TestTask,
}





function gettaskdata(taskid)
	local maintype = math.floor(taskid / 10000)
	if not g_taskdata[maintype] then
		error("unknow task type"...taskid)
		return
	end
	return g_taskdata[maintype][taskid]
end
