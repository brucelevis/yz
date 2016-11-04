local function test(pid1,pid2)
	local player1 = playermgr.getplayer(pid1)
	local player2 = playermgr.getplayer(pid2)
	print(pid1,pid2,player1,player2)
	if not (player1 and player2) then
		print("not online")
		return
	end
	local mailbox1 = mailmgr.getmailbox(pid1)
	local mailbox2 = mailmgr.getmailbox(pid2)
	mailbox1:delallmail()
	mailbox2:delallmail()
	local allmail = mailbox1:getmails()
	assert(#allmail == 0)

	local mailrequest = net.mail.C2S
	mailrequest.openmailbox(player1)
	-- cann't send to youself
	mailrequest.sendmail(player1,{
		to = pid1,
		title = "",
		content = "",
	})
	local mails = mailbox1:getmails()
	assert(#mails == 0)
	mails = mailbox2:getmails()
	assert(#mails == 0)
	mailrequest.sendmail(player1,{
		to = pid2,
		title = "title",
		content = "content",
	})
	mails = mailbox2:getmails()
	print("mail num",#mails)
	assert(#mails == 1)
	local mail = mails[1]
	mailrequest.delmail(player2,{
		mailid = mail.mailid,
	})
	mails = mailbox2:getmails()
	assert(#mails == 0)
	mailrequest.sendmail(player1,{
		to = pid2,
		title = "title",
		content = "content",
		attach = {
			gold = 100,
			silver = 200,
			items = {
				{type=401001,num=2,},
			},
		}
	})
	mails = mailbox2:getmails()
	mail = mails[1]
	assert(mail.title == "title" and mail.content == "content")
	pprintf("mail:%s",mail:save())
	local oldgold = player2.gold
	local oldsilver = player2.silver
	mailrequest.getattach(player2,{
		mailid = mail.mailid,
	})
	assert(player2.gold == oldgold + 100)
	assert(player2.silver == oldsilver + 200)
	local num = 10
	for i = 1,num do
		local suffix = tostring(i)
		mailrequest.sendmail(player1,{
			to = pid2,
			title = "title" .. suffix,
			content = "content" .. suffix,
		})
	end
	mails = mailbox2:getmails()
	assert(#mails == 11)
	mailrequest.delallmail(player2,{
	})
	mails = mailbox2:getmails()
	assert(#mails == 0)

end

return test
