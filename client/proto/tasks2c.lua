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
		submitnpc 2 : integer
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
		taskid 1 : integer
		textid 2 : integer #对白表ID
		transstr 3 : string
		respondid 4 : integer #如果带有回调id,玩家点完对白（跳过）需要回msg.respondanswer协议
	}
}

.CanAcceptType {
	taskkey 0 : string #任务标识
	taskid 1 : integer #任务ID,这项可能为nil
}

#可接任务列表
task_update_canaccept 3506 {
	request {
		base 0 : basetype
		canaccept 1 : *CanAcceptType
	}
}

]]
}
