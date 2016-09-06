return {
	p = "team",
	si = 4000, -- [4000,4500)
	src = [[

.TeamApplyerType {
	pid 0 : integer
	name 1 : string
	lv 2 : integer
	roletype 3 : integer
	joblv 4 : integer
}


# 自身队伍信息(如果team为nil或者{}，表示自己无队伍，删除队伍时会这样发
team_selfteam 4000 {
	request {
		base 0 : basetype
		team 1 : TeamType
		applyers 2 : TeamApplyerType	# 仅当team有值时有效
	}
}

# 队伍：增加一个成员
team_addmember 4001 {
	request {
		base 0 : basetype
		teamid 1 : integer
		member 2 : MemberType
	}
}

# 队伍: 更新一个成员信息
team_updatemember 4002 {
	request {
		base 0 : basetype
		teamid 1 : integer
		member 2 : MemberType
	}
}

# 队伍: 删除一个成员
team_delmember 4003 {
	request {
		base 0 : basetype
		teamid 1 : integer
		pid 2 : integer
	}
}

# 发布的队伍信息
team_publishteam 4004 {
	request {
		base 0 : basetype
		publishteam 1 : PublishTeamType
	}
}

# 同步一个队伍信息(全量同步,一般用于获取其他队伍的完整信息)
team_syncteam 4005 {
	request {
		base 0 : basetype
		team 1 : TeamType
	}
}

# 增加若干入队申请者
team_addapplyer 4006 {
	request {
		base 0 : basetype
		applyers 1 : *TeamApplyerType
	}
}

# 删除若干入队申请者
team_delapplyer 4007 {
	request {
		base 0 : basetype
		applyers 1 : *integer
	}
}

# 打开队伍界面后需要同步的数据
team_openui_team 4008 {
	request {
		base 0 : basetype
		publishteams 1 : *PublishTeamType
		waiting_num 2 : integer		# 等待匹配的人数
		automatch 3 : boolean		# 是否处于自动匹配中
		target 4 : integer			# 组队目标:0/空--无目标，其他--目标ID，只有目标ID>0，minlv,maxlv才有意义
		minlv 5 : integer
		maxlv 6 : integer
	}
}

# 所有发布的队伍数据
team_publishteams 4009 {
	request {
		base 0 : basetype
		publishteams 1 : *PublishTeamType
	}
}

# 更新队伍(增量更新)：如组队目标/组队状态
team_updateteam 4010 {
	request {
		base 0 : basetype
		team 1 : TeamType
	}
}
]]
}
