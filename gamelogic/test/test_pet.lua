local function test(pid)
	local player = playermgr.getplayer(pid)
	player.petdb:clear()
	local pet = petaux.newpet(20002)
	player.petdb:addpet(pet,"gm")
end

return test
