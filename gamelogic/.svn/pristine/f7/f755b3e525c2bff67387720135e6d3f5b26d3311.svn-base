netskill = netskill or {
	C2S = {},
	S2C = {},
}

local C2S = netskill.C2S
local S2C = netskill.S2C

--c2s
function C2S.wieldskill(player,request)
	local skillid = assert(request.skillid)
	local position = assert(request.position)
	player.warskilldb:wieldskill(skillid,position)
end

function C2S.setcurslot(player,request)
	local slot = assert(request.slot)
	player.warskilldb:setcurslot(slot)
end

function C2S.learnskill(player,request)
	local skillid = assert(request.skillid)
	local skilldb = player:getskilldb(skillid)
	if skilldb then
		skilldb:learnskill(skillid)
	end
end

function C2S.resetpoint(player,request)
	player.warskilldb:resetpoint()
end

function C2S.changepos(player,request)
	local skillid1 = assert(request.skillid1)
	local skillid2 = assert(request.skillid2)
	player.warskilldb:changepos(skillid1,skillid2)
end

--s2c
function S2C.addskill(pid,skill)
	sendpackage(pid,"skill","addskill",{ skill = skill,})
end

function S2C.updateskill(pid,skill)
	sendpackage(pid,"skill","updateskill",{ skill = skill,})
end

function S2C.updateslot(pid,skillids,curslot)
	logger.log("info","skill",format("[debug] %s %s",skillids,curslot))
	sendpackage(pid,"skill","updateslot",{
		curslot = curslot,
		skillids = skillids,
	})
end

function S2C.allskill(pid,skills)
	sendpackage(pid,"skill","allskill",{ skills = skills,})
end

function S2C.updatepoint(pid,skillpoint)
	sendpackage(pid,"skill","updatepoint",{ point = skillpoint,})
end

return netskill
