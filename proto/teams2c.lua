return {
	p = "team",
	si = 4000, -- [4000,4500)
	src = [[

team_selfteam 4000 {
	request {
		base 0 : basetype
		team 1 : TeamType
	}
}

team_addmember 4001 {
	request {
		base 0 : basetype
		teamid 1 : integer
		member 2 : MemberType
	}
}

team_updatemember 4002 {
	request {
		base 0 : basetype
		teamid 1 : integer
		member 2 : MemberType
	}
}

team_delmember 4003 {
	request {
		base 0 : basetype
		teamid 1 : integer
		pid 2 : integer
	}
}

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

team_syncteam 4005 {
	request {
		base 0 : basetype
		team 1 : TeamType
	}
}

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

team_delapplyer 4007 {
	request {
		base 0 : basetype
		applyers 1 : *integer
	}
}

team_openui_team 4008 {
	request {
		base 0 : basetype
		teams 1 : *TeamType
		automatch 2 : boolean
	}
}

team_publishteams 4009 {
	request {
		base 0 : basetype
		publishteams 1 : *PublishTeamType
	}
}
]]
}
