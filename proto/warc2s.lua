return {
	p = "war",
	si = 6000, --[6000,6500)
	src = [[

war_start_pvpwar 6000 {
	request {
		base 0 : basetype
		targetid 1 : integer
		wartype 2 : integer   #战斗类型(服务端会检查当前场景是否可以发起此类pvp战斗)
	}
}

war_quitwar 6001 {
	request {
		base 0 : basetype
	}
}

war_watchwar 6002 {
	request {
		base 0 : basetype
		watch_pid 1 : integer
		warid 2 : integer
	}
}

war_quit_watchwar 6003 {
	request {
		base 0 : basetype
	}
}

# pve war
war_start_taskwar 6004 {
	request {
		base 0 : basetype
		taskid 1 : integer
	}
}

war_fixwar 6005 {
	request {
		base 0 : basetype
		warid 1 : integer
	}
}

# 邀请切磋
war_invite_qiecuo 6006 {
	request {
		base 0 : basetype
		targetid 1 : integer  #目标玩家ID
	}
}
]]
}
