return {
	p = "task",
	si = 3500, -- [3500,4000)
	src = [[
task_addtask 3500 {
	request {
		base 0 : basetype
		task 1 : TaskType
	}
}

#登录成功后发送
task_alltask 3501 {
	request {
		base 0 : basetype
		tasks 1 : *TaskType
	}
}

task_deltask 3502 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}

#任务完成后通知
task_finishtask 3503 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}

task_updatetask 3504 {
	request {
		base 0 : basetype
		task 1 : TaskType
	}
}

#任务对话
#transstr 需要cjson.decode，用来替换导表中指定的字符串如:{ npcname = "Mike",}
task_tasktalk 3505 {
	request {
		base 0 : basetype
		name 1 : string #导表标识
		textid 2 : integer #对比表ID
		transstr 3 : string
	}
}

]]
}
