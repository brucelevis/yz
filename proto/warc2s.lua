return {
	p = "war",
	si = 6000, --[6000,6500)
	src = [[

war_start_pvpwar 6000 {
	request {
		base 0 : basetype
		targetid 1 : integer
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
]]
}
