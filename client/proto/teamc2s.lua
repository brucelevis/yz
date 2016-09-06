return {
	p = "team",
	si = 4000, -- [4000,4500)
	src = [[
# 创建队伍
team_createteam 4000 {
	request {
		base 0 : basetype
		target 1 : integer		#组队目标(可选，不发表示不限组队目标)
		minlv 2 : integer		#最低等级(可选,不发服务端自动选择个最低等级)
		maxlv 3 : integer		#最高等级(可选，不发服务端自动选择个最高等级)
	}
}

# 已作废
team_dismissteam 4001 {
}

# 发布队伍
team_publishteam 4002 {
	request {
		base 0 : basetype
		target 1 : integer		#组队目标(可选，不发表示不限组队目标)
		minlv 2 : integer		#最低等级(可选,不发服务端自动选择个最低等级)
		maxlv 3 : integer		#最高等级(可选，不发服务端自动选择个最高等级)
		captain 4 : MemberType  # 队长信息
	}
}

# 加入队伍
team_jointeam 4003 {
	request {
		base 0 : basetype
		teamid 1 : integer		# 队伍ID
	}
}

# 暂离队伍
team_leaveteam 4004 {
	request {
		base 0 : basetype
	}
}

# 退出队伍
team_quitteam 4005 {
	request {
		base 0 : basetype
	}

}

# 归队
team_backteam 4006 {
	request {
		base 0 : basetype
	}

}

# 召回队员
team_recallmember 4007 {
	request {
		base 0 : basetype
		pids 1 : *integer  #不发表示召回所有暂离队员
	}

}

# 申请成为队长
team_apply_become_captain 4008 {
	request {
		base 0 : basetype
	}
}

# 同意入队
team_agree_jointeam 4009 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

# 改变队长/提升队长
team_changecaptain 8010 {
	request {
		base 0 : basetype
		pid 1 : integer			#提升为队长的玩家ID
	}
}

# 邀请入队
team_invite_jointeam 8011 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}

#请求同步一个队伍数据
team_syncteam 8012 {
	request {
		base 0 : basetype
		teamid 1 : integer
	}
}

# 打开组队界面
team_openui_team 8013 {
	request {
		base 0 : basetype
	}
}

# 自动匹配(无队伍选择自动匹配+队长选择自动匹配都是发这个协议)
team_automatch 8014 {
	request {
		base 0 : basetype
		# 下面字段只对无队伍选择自动匹配有用，队长选择自动匹配时，使用的是队伍自身的组队目标+等级范围
		target 1 : integer		#组队目标(可选，不发表示不限组队目标)
		minlv 2 : integer		#最低等级(可选,不发服务端自动选择个最低等级)
		maxlv 3 : integer		#最高等级(可选，不发服务端自动选择个最高等级)
	}
}

# 取消自动匹配
team_unautomatch 8015 {
	request {
		base 0 : basetype
	}
}

# 更改组队目标(对于无队伍的玩家，只在他处于自动匹配时发此协议有效，此时相当于
# 更改其自动匹配目标)
team_changetarget 8016 {
	request {
		base 0 : basetype
		target 1 : integer		#组队目标(可选，不发表示不限组队目标)
		minlv 2 : integer		#最低等级(可选,不发服务端自动选择个最低等级)
		maxlv 3 : integer		#最高等级(可选，不发服务端自动选择个最高等级)
	}
}

# 申请入队
team_apply_jointeam 8017 {
	request {
		base 0 : basetype
		teamid 1 : integer
	}
}

# 删除：入队申请者
team_delapplyers 8018 {
	request {
		base 0 : basetype
		# 发空表示清空所有申请者
		pids 1 : *integer
	}
}

# 查看发布的队伍
team_look_publishteams 8019 {
	request {
		base 0 : basetype
	}
}

# 踢出队员/成员（只有队长才能执行)
team_kickmember 8020 {
	request {
		base 0 : basetype
		pid 1 : integer
	}
}
]]
}
