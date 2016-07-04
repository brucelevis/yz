return {
	p = "player",
	si = 5000, -- [5000,5500)
	src = [[
player_heartbeat 5000 {
	request {
		base 0 : basetype
		msg 1 : string
	}
}

player_resource 5001 {
	request {
		base 0 : basetype
		gold 1 : integer
		chip 2 : integer
	}
}

player_switch 5002 {
	request {
		base 0 : basetype
		gm 1 : boolean
		friend 2 : boolean
		automatch 3 : boolean
	}
}
]]
}
