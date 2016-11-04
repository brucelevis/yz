
netmail = netmail or {
	C2S = {},
	S2C = {}
}

local C2S = netmail.C2S
local S2C = netmail.S2C

function C2S.openmailbox(player)
	local pid = player.pid
	local mailbox = mailmgr.getmailbox(pid)
	local mails = mailbox:getmails()
	local allmail = {}
	for _,mail in ipairs(mails) do
		table.insert(allmail,mail:pack())
	end
	netmail.S2C.allmail(pid,allmail)
end

function C2S.readmail(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local mailbox = mailmgr.getmailbox(pid)
	local mail = mailbox:getmail(mailid)
	if not mail then
		return
	end
	mail.readtime = os.time()
	netmail.S2C.syncmail(pid,mail:pack())
end

function C2S.delmail(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local mailbox = mailmgr.getmailbox(pid)
	local mail = mailbox:delmail(mailid)
	local result = mail and true or false
	netmail.S2C.delmail_result(pid,result)
end

function C2S.getattach(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local mailbox = mailmgr.getmailbox(pid)
	mailbox:getattach(mailid)
end

function C2S.sendmail(player,request)
	local pid = player.pid
	local targetid = assert(request.to)
	local title = request.title or ""
	local content = request.content or ""
	local attach = request.attach or {}
	if pid == targetid then
		return
	end
	if not globalmgr.home_srvname(targetid) then
		net.msg.S2C.notify(pid,string.format("找不到id为%d的玩家",targetid))
		return
	end
	mailmgr.sendmail(targetid,{
		srcid = pid,
		author = player:query("name"),
		title = title,
		content = content,
		attach = attach,
	})

end

function C2S.delallmail(player,request)
	local pid = player.pid
	local mailbox = mailmgr.getmailbox(pid)
	mailbox:delallmail()
	netmail.S2C.allmail(pid,{})
end

-- s2c
function S2C.syncmail(pid,mail)
	sendpackage(pid,"mail","syncmail",{
		mail = mail,
	})
end

function S2C.allmail(pid,mails)
	sendpackage(pid,"mail","allmail",{
		mails = mails,
	})
end

function S2C.delmail_result(pid,result)
	sendpackage(pid,"mail","delmail_result",{
		result = result,
	})
end

return netmail
