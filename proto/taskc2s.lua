return {
	p = "task",
	si = 3500, -- [3500,4000)
	src = [[

task_opentask 3500 {
	request {
		base 0 : basetype
		taskkey 1 : string #任务标识
	}
}

task_accepttask 3501 {
	request {
		base 0 : basetype
		taskid 1 : integer # 任务ID
	}
}

task_executetask 3502 {
	request {
		base 0 : basetype
		taskid 1 : integer
		ext 2 : string #扩展数据需要用json解包
	}
}

task_finishtask 3503 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}

task_submittask 3504 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}

task_giveuptask 3505 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}
]]
}
