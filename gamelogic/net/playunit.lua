netplayunit = netplayunit or {
	C2S = {},
	S2C = {},
}

local C2S = netplayunit.C2S
local S2C = netplayunit.S2C


-- s2c
function S2C.opendati(pid,questionid,respondid,data)
	sendpackage(pid,"playunit","opendati",{
		questionid = questionid,
		respondid = respondid,
		cnt = data.cnt,
		maxcnt = data.maxcnt,
		exceedtime = data.exceedtime,
		npcname = data.npcname,
		npcshape = data.npcshape,
		questionbank = data.questionbank,
	})
end

return netplayunit
