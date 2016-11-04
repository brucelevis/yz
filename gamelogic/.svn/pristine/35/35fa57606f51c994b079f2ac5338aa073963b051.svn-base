require "gamelogic.award"

local function onbuysomething(player,request,buttonid)
	if buttonid == 1 then -- confirm
		local costgold = request.attach.extra.gold
		if not player:validpay("gold",costgold,true) then
			return
		end
		doaward("player",player.pid,request.attach,true,"test")
	end
end

local function test(pid,choice)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local request = {
		title = "条件不足",
		content = "是否花费100金币购买:",
		attach = {
			silver = 100,
			items = {
				{
					type = 501001,
					num = 3,
				},
				{
					type = 501001,
					num = 2,
				},
			},
			extra = {
				gold = 100,
			},
		},
		buttons = {
			"确认",
			"取消",
		},
	}
	local LACK_CONDITION = 0
	local id
	if choice == 1 then
		id = net.msg.S2C.messagebox(pid,request,onbuysomething)
	elseif choice == 2 then
		onbuysomething(player.pid,request,{buttonid=id})
	end
end

return test
