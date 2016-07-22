return {
	p = "team",
	si = 4000, -- [4000,4500)
	src = [[

# 自身队伍信息(如果team为nil或者{}，表示自己无队伍，删除队伍时会这样发
team_selfteam 4000 {
	request {
		base 0 : basetype
		team 1 : TeamType
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
		teamid 1 : integer
		time 2 : integer
		target 3 : integer
		lv 4 : integer
		captain 5 : MemberType
	}
}

# 同步一个队伍信息
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
		.TeamApplyerType {
			pid 0 : integer
			name 1 : string
			lv 2 : integer
			roletype 3 : integer
		}
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
		teams 1 : *TeamType
		automatch 2 : boolean
	}
}

# 所有发布的队伍数据
team_publishteams 4009 {
	request {
		base 0 : basetype
		publishteams 1 : *PublishTeamType
	}
}
]]
}
