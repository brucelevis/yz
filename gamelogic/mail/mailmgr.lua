mailmgr = mailmgr or {}

function mailmgr.init()
	mailmgr.mailboxs = {}
end


function mailmgr.onlogin(player)
	local pid = player.pid
	mailmgr.getmailbox(pid) -- preload mailbox
end

function mailmgr.onlogoff(player,reason)
	local pid = player.pid
	mailmgr.unloadmailbox(pid)
end

function mailmgr.loadmailbox(pid)
	local mailbox = cmailbox.new(pid)
	mailbox:loadfromdatabase()
	mailmgr.mailboxs[pid] = mailbox
	mailbox.savename = string.format("%s.%s",mailbox.flag,mailbox.pid)
	autosave(mailbox)
	return mailbox
end

function mailmgr.unloadmailbox(pid)
	local mailbox = mailmgr.mailboxs[pid]
	if mailbox then
		closesave(mailbox)
		mailbox:savetodatabase()
		mailmgr.mailboxs[pid] = nil
	end
end

function mailmgr.getmailbox(pid)
	if not mailmgr.mailboxs[pid] then
		return mailmgr.loadmailbox(pid)
	end
	return mailmgr.mailboxs[pid]
end

-- 支持跨服邮件
function mailmgr.sendmail(pid,amail)
	local self_srvname = cserver.getsrvname()
	local home_srvname = globalmgr.home_srvname(pid)
	if not home_srvname then -- non-exist pid
		return nil
	end
	local now_srvname,isonline = globalmgr.now_srvname(pid)
	local to_srvname
	if now_srvname ~= self_srvname then
		if isonline then
			to_srvname = now_srvname
		else
			to_srvname = home_srvname
		end
	end
	if to_srvname ~= self_srvname then
		return rpc.call(to_srvname,"modmethod","mail.mailmgr",".sendmail",pid,amail)
	end
	amail = deepcopy(amail) -- 防止多个玩家修改同一份邮件
	if amail.attach then	-- 防止传入导表的概率字段
		amail.attach.ratio = nil
	end
	amail.sendtime = amail.sendtime or os.time()
	local mailbox = mailmgr.getmailbox(pid)
	amail.mailid = amail.mailid or mailbox:genid()
	local mail = cmail.new(amail)
	mail = mailbox:addmail(mail)
	if mail then
		net.mail.S2C.syncmail(pid,mail:pack())
	end
	return mail.mailid,self_srvname
end

function mailmgr.sendmails(pids,amail)
	for i,pid in ipairs(pids) do
		mailmgr.sendmail(pid,amail)
	end
end

return mailmgr
