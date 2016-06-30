
local function test(pid)
	local player = playermgr.getplayer(pid)
	local reason = "test"
	player.itemdb:clear()
	player:addgold(-player.gold,reason)
	player:addsilver(-player.silver,reason)
	player:addcoin(-player.coin,reason)
	
	local reward = {type=1,value={[1]=1000000}}
	reward = award.getaward(reward)
	doaward("player",pid,reward,reason,true)
	assert(player.gold==1)
	assert(player.silver==1)
	assert(player.coin==1)
	local reward = {type=2,value={[2]=1}}
	reward = award.getaward(reward)
	doaward("player",pid,reward,reason,true)
	assert(player.gold==2)
	assert(player.silver==2)
	assert(player.coin==2)
	local num = player.itemdb:getnumbytype(501001)
	assert(num == 1)
	local reward = {type=2,value={[3]=1}}
	reward = award.getaward(reward)
	doaward("player",pid,reward,reason,true)
	assert(player.gold==3)
	assert(player.silver==3)
	assert(player.coin==3)
	local num = player.itemdb:getnumbytype(501001)
	assert(num==3)  -- 1 + 2
	attach = reward
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