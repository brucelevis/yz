
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
	local packdata = {}
	for _,mail in ipairs(mails) do
		table.insert(packdata,mail:pack())
	end
	return {mails = packdata,}
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
	return {result = mail and true or false,}		
end

function C2S.getattach(player,request)
	local pid = player.pid
	local mailid = assert(request.mailid)
	local mailbox = mailmgr.getmailbox(pid)
	mailbox:getattach(mailid)
end

function C2S.sendmail(player,request)
	local pid = player.pid
	local targetid = assert(request.pid)
	local title = request.title or ""
	local content = assert(request.content)
	local attach = request.attach or {}
	if pid == targetid then
		return
	end
	if not route.getsrvname(targetid) then
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
end

-- s2c
function S2C.syncmail(pid,maildata)
	maildata.pid = pid
	sendpackage(pid,"mail","syncmail",maildata)
end

return netmail
