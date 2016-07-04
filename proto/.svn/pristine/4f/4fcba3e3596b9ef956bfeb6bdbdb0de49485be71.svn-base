return {
	p = "task",
	si = 3500, -- [3500,4000)
	src = [[

task_opentask 3500 {
	request {
		base 0 : basetype
		tasktype 1 : integer # 任务类型
	}
}

task_accepttask 3501 {
	request {
		base 0 : basetype
		taskid 1 : integer # 任务ID
	}
}

task_submittask 3502 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}

task_giveuptask 3503 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}
]]
}
