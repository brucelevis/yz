-- 全局邮件（后台发来，同时给多人发送的邮件)

commonmail = commonmail or {
	condition = {},
}

-- mail格式:
-- {
-- srcid = 发件人ID,
-- author = 作者,
-- title = 标题,
-- content = 内容,
-- attach = 附件
-- to_pids = 收件人ID列表,
-- conditions = 条件（用于过滤收件人)
-- }
--
-- 流程：这里公有邮件采用即时发送机制，不用延迟发送，延迟发送的好处是计算量分散，坏处是延迟发送玩家的状态
-- 可能已经发生变化。
-- 1. 获取所有收件人列表（根据条件过滤收件人）
-- 2. 定时分阶段给所有收件人发送邮件
function commonmail.sendmail(mail)
	local amail = {
		srcid = mail.srcid or 0,
		sendtime = mail.sendtime or os.time(),
		author = mail.author or "GM",
		title = mail.title,
		content = mail.content,
		attach = mail.attach and cjson.decode(mail.attach),
	}

	local to_pids
	if table.isempty(mail.to_pids) then
		to_pids = db:hkeys(db:key("role","list")) or {}
	else
		to_pids = mail.to_pids
	end
	-- 只做一些简介信息中已有属性的判断,否则计算量太大了
	local conditions = mail.condition and cjson.decode(mail.conditions)
	if conditions and not table.isempty(conditions) then
		local pid_flag = {}
		for i,pid in ipairs(to_pids) do
			local player = resumemgr.getresume(pid)
			if player then
				local bpass = false
				for i,condition in ipairs(conditions) do
					local isok = true
					for cmd,args in pairs(condition) do
						local func = commonmail.condition[cmd]
						if func and not func(player,args) then
							isok = false
							break
						end
					end
					if isok then
						bpass = true
						break
					end
				end
				if bpass then
					pid_flag[pid] = true
				end
			end
		end
		to_pids = table.keys(pid_flag)
	end
	local len = #to_pids
	local needtime = 0
	local step = 1000
	for i=1,len,step do
		needtime = needtime + 10
		local pids = table.slice(to_pids,i,i+step-1)
		timer.timeout("commonmail.sendmail",needtime,functor(mailmgr.sendmails,pids,amail))
	end
	mail.to_pids = to_pids
	logger.log("info","mail",format("[commonmail.sendmail] mail=%s",mail))
end

local CONDITION = commonmail.condition
function CONDITION.lvin(player,args)
	local minlv,maxlv = table.unpack(args)
	return minlv <= player.lv and player.lv <= maxlv
end

function CONDITION.orgin(player,args)
	local orgids = args
	for i,orgid in ipairs(orgids) do
		if player.orgid == orgid then
			return true
		end
	end
	return false
end

function CONDITION.jobin(player,args)
	local jobids = args
	for i,jobid in ipairs(jobids) do
		if player.roletype == jobid then
			return true
		end
	end
	return false
end


return commonmail
