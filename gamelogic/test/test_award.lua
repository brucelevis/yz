
local function test(pid)
	local player = playermgr.getplayer(pid)
	local reason = "test"
	player.itemdb:clear()
	player:addgold(-player.gold,reason)
	player:addsilver(-player.silver,reason)
	player:addcoin(-player.coin,reason)
	
	local reward = {gold=1,silver=1,coin=1}
	doaward("player",pid,reward,reason,true)
	print(player.gold,player.silver,player.coin)
	assert(player.gold==1)
	assert(player.silver==1)
	assert(player.coin==1)
	local reward = {gold=1,silver=1,coin=1,items={{type=501001,num=1,bind=0},}}
	doaward("player",pid,reward,reason,true)
	assert(player.gold==2)
	assert(player.silver==2)
	assert(player.coin==2)
	local num = player.itemdb:getnumbytype(501001)
	assert(num == 1)
	local reward = {gold=1,silver=1,coin=1,items={{type=501001,num=2,bind=0},}}
	doaward("player",pid,reward,reason,true)
	assert(player.gold==3)
	assert(player.silver==3)
	assert(player.coin==3)
	local num = player.itemdb:getnumbytype(501001)
	assert(num==3)  -- 1 + 2
	local attach = reward
	local mailid = mailmgr.sendmail(pid,{
		srcid = SYSTEM_MAIL,
		author = "系统",
		title = "test",
		content = "test",
		attach = attach,
	})
	local mailbox = mailmgr.getmailbox(pid)
	mailbox:getattach(mailid)
	--print(player.gold,mailid,mailbox:getmail(mailid))
	assert(player.gold==4)
	assert(player.silver==4)
	assert(player.coin==4)
	local num = player.itemdb:getnumbytype(501001)
	assert(num==5) -- 1 + 2 + 2
end

return test
