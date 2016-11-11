return {
	p = "task",
	si = 3500, -- [3500,4000)
	src = [[

task_opentask 3500 {
	request {
		base 0 : basetype
		taskkey 1 : string #任务标识
		taskid 2 : integer #指定任务id,未指定则随机
	}
}

#此协议测试用，接受任务统一使用opentask
task_accepttask 3501 {
	request {
		base 0 : basetype
		taskid 1 : integer #任务ID
	}
}

task_executetask 3502 {
	request {
		base 0 : basetype
		taskid 1 : integer
		ext 2 : string #扩展数据需要用json解包，如：ext.items上交物品列表
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

task_looktasknpc 3506 {
	request {
		base 0 : basetype
		taskid 1 : integer
		npcid 2 : integer
	}
}

task_tasktimeout 3507 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}

]]
}
