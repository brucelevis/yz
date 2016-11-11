cvotemgr = class("cvotemgr",{
	AGREE_VOTE = 0,
})

function cvotemgr:init()
	self.type_id_vote = {}
	self.type_pid_id = {}
	self.voteid = 0
	self:check_timeout()
end

function cvotemgr:gen_voteid()
	if self.voteid >= MAX_NUMBER then
		self.voteid = 0
	end
	self.voteid = self.voteid + 1
	return self.voteid
end

function cvotemgr:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
	local type_id_vote = {}
	for typ,id_vote in pairs(data.type_id_vote) do
		if not type_id_vote[typ] then
			type_id_vote[typ] = {}
		end
		for id,vote in pairs(id_vote) do
			id = tonumber(id)
			vote = self:loadvote(vote)
			type_id_vote[typ][id] = vote
			for pid,votenum in pairs(vote.member_vote) do
				if not self.type_pid_id[typ] then
					self.type_pid_id[typ] = {}
				end
				self.type_pid_id[typ][pid] = id
			end
		end
	end
	self.type_id_vote = type_id_vote
end

function cvotemgr:save()
	local data = {}
	data.id = self.id
	local type_id_vote = {}
	for typ,id_vote in pairs(self.type_id_vote) do
		local tmp = {}
		for id,vote in pairs(id_vote) do
			id = tostring(id)
			vote = self:savevote(vote)
			tmp[id] = vote
		end
		if not next(tmp) then
			type_id_vote[typ] = tmp
		end
	end
	data.type_id_vote = type_id_vote
	return data
end

function cvotemgr:loadvote(votedata)
	local vote = {}
	for k,v in pairs(votedata) do
		if k == "member_vote" then
			local tmp = {}
			for pid,d in pairs(v) do
				pid = tonumber(pid)
				tmp[pid] = d
			end
			vote[k] = tmp
		elseif k == "giveup_member" then
			local tmp = {}
			for pid,d in pairs(v) do
				pid = tonumber(pid)
				tmp[pid] = d
			end
			vote[k] = tmp
		elseif k == "candidate" then
			local tmp = {}
			for pid,dict in pairs(v) do
				pid = tonumber(pid)
				local tmp2 = {}
				for pid2,d in pairs(dict) do
					pid2 = tonumber(pid2)
					tmp2[pid2] = d
				end
				tmp[pid] = tmp2
			end
			vote[k] = tmp
		else
			vote[k] = v
		end
	end
	return vote
end

function cvotemgr:savevote(vote)
	local votedata = {}
	for k,v in pairs(vote) do
		if k == "member_vote" then
			local tmp = {}
			for pid,d in pairs(v) do
				pid = tostring(pid)
				tmp[pid] = d
			end
			votedata[k] = tmp
		elseif k == "giveup_member" then
			local tmp = {}
			for pid,d in pairs(v) do
				pid = tostring(pid)
				tmp[pid] = d
			end
			votedata[k] = tmp
		elseif k == "candidate" then
			local tmp = {}
			for pid,dict in pairs(v) do
				pid = tostring(pid)
				local tmp2 = {}
				for pid2,d in pairs(dict) do
					pid2 = tostring(pid2)
					tmp2[pid2] = d
				end
				tmp[pid] = tmp2
			end
			votedata[k] = tmp
		else
			votedata[k] = v
		end
	end
	return votedata
end

function cvotemgr:newvote(vote)
	assert(vote.member_vote)
	local sum_vote = 0
	for _,votenum in pairs(vote.member_vote) do
		sum_vote = sum_vote + votenum
	end
	local half_sum_vote = math.floor(sum_vote/2) + 1
	vote.pass_vote = vote.pass_vote or half_sum_vote
	vote.pass_vote = math.min(vote.pass_vote,sum_vote)
	vote.giveup_member = vote.giveup_member or {}
	vote.candidate = vote.candidate or {[cvotemgr.AGREE_VOTE] = {},}
	return vote
end

--/*
-- 新增投票
-- @param typ string/integer 投票类型
-- @param vote table  具体投票信息
-- @e.g
-- votemgr:addvote("罢免帮主",{
--		member_vote = {
--			[10001] = 3,  --10001玩家的投票占3票
--		},
--		candidate = {     -- 可选字段
--			[10001] = {},  -- 候选人10001的支持者
--		},
--		giveup_member = {  -- 弃权成员
--		}
--		allow_voteto_self = false, -- 是否允许投给自己
--		pass_vote = 10,	  -- 投票数达到一定值则终止投票
--		exceedtime = os.time() + 300, -- 过期时间
--		-- 如果投票需要存盘，callback就必须用pack_function打包
--		callback = function (vote,state,id)  -- 投票出结果后的回调函数
--		end,
-- })
--*/
function cvotemgr:addvote(typ,vote)
	if not self.type_id_vote[typ] or not next(self.type_id_vote[typ]) then
		self.type_id_vote[typ] = {}
		self.type_pid_id[typ] = {}
	end
	local voteid = self:gen_voteid()
	vote.id = voteid
	vote.type = typ
	logger.log("info","vote",format("[addvote] type=%s id=%s vote=%s",typ,voteid,vote))
	self.type_id_vote[typ][voteid] = vote
	for pid,votenum in pairs(vote.member_vote) do
		self.type_pid_id[typ][pid] = voteid
	end
	xpcall(self.onaddvote,onerror,self,vote)
	return voteid
end

function cvotemgr:delvote(id,typ)
	if typ then
		return self:__delvote(id,typ)
	else
		for typ,_ in pairs(self.type_id_vote) do
			local vote = self:__delvote(id,typ)
			if vote then
				return vote
			end
		end
	end
end

function cvotemgr:__delvote(id,typ)
	local id_vote = self.type_id_vote[typ]
	if id_vote then
		local vote = id_vote[id]
		if vote then
			logger.log("info","vote",format("[delvote] type=%s id=%s vote=%s",typ,id,vote))
			xpcall(self.ondelvote,onerror,self,vote)
			id_vote[id] = nil
			for pid,_ in pairs(vote.member_vote) do
				self.type_pid_id[typ][pid] = nil
			end
			return vote
		end
	end
end

function cvotemgr:getvote(id,typ)
	if typ then
		return self:__getvote(id,typ)
	else
		for typ,_ in pairs(self.type_id_vote) do
			local vote = self:__getvote(id,typ)
			if vote then
				return vote
			end
		end
	end
end

function cvotemgr:__getvote(id,typ)
	local id_vote = self.type_id_vote[typ]
	if not id_vote then
		return
	end
	return id_vote[id]
end


function cvotemgr:getvotebypid(typ,pid)
	local id
	for k,pid_id in pairs(self.type_pid_id) do
		if k == typ then
			id = pid_id[pid]
			break
		end
	end
	if id then
		return self:__getvote(id,typ)
	end
end

function cvotemgr:isvoted(vote,pid)
	for topid,supporter in pairs(vote.candidate) do
		if supporter[pid] then
			return true,topid
		end
	end
	return false
end

function cvotemgr:isgiveup(vote,pid)
	for giveup_pid,_ in pairs(vote.giveup_member) do
		if giveup_pid == pid then
			return true
		end
	end
	return false
end

function cvotemgr:voteto(typ,pid,topid)
	topid = topid or cvotemgr.AGREE_VOTE
	local vote = self:getvotebypid(typ,pid)
	if not vote then
		return false,language.format("未参与投票")
	end
	if not vote.member_vote[pid] then
		return false,language.format("退出后无法继续投票")
	end
	if self:isgiveup(vote,pid) then
		return false,language.format("弃权后无法继续投票")
	end
	if self:isvoted(vote,pid) then
		return false,language.format("无法重复投票")
	end
	if not vote.allow_voteto_self and pid == topid then
		return false,language.format("无法给自身投票")
	end
	local votenum = vote.member_vote[pid]
	if not vote.candidate[topid] then
		return false,language.format("未知候选人")
	end
	vote.candidate[topid][pid] = true
	logger.log("info","vote",string.format("[voteto] type=%s pid=%s topid=%s votenum=%s",typ,pid,topid,votenum))
	if self:check_endvote(vote) then
		self:delvote(vote.id,typ)
	else
		xpcall(self.onupdatevote,onerror,self,vote)
	end
	return true
end

function cvotemgr:giveup_vote(typ,pid)
	local vote = self:getvotebypid(typ,pid)
	if not vote then
		return false,language.format("未参与投票")
	end
	if not vote.member_vote[pid] then
		return false,language.format("退出后无法继续弃权")
	end
	if self:isgiveup(vote,pid) then
		return false,language.format("弃权后无法继续弃权")
	end
	if self:isvoted(vote,pid) then
		return false,language.format("已投过票了，弃权失效")
	end
	local votenum = vote.member_vote[pid]
	logger.log("info","vote",string.format("[giveup_vote] type=%s pid=%s votenum=%s",typ,pid,votenum))
	vote.giveup_member[pid] = true
	if self:check_endvote(vote) then
		self:delvote(vote.id,typ)
	else
		xpcall(self.onupdatevote,onerror,self,vote)
	end
	return true
end

function cvotemgr:cancel_voteto(typ,pid)
	local vote = self:getvotebypid(typ,pid)
	if not vote then
		return false,language.format("未参与投票")
	end
	local isvote,topid = self:isvoted(vote,pid)
	if not isvote then
		return false,language.format("未投票过，无法取消")
	end
	local votenum = vote.member_vote[pid]
	logger.log("info","vote",string.format("[cancel_voteto] type=%s pid=%s topid=%s votenum=%s",typ,pid,topid,votenum))
	vote.candidate[topid][pid] = nil
	return true
end

-- cancel_voteto/quit_vote两个接口可能没太大用
-- 一般退出投票视为弃权，仍然保留两个接口，便于后续定制
function cvotemgr:quit_vote(typ,pid)
	local vote = self:getvotebypid(typ,pid)
	if not vote then
		return
	end
	logger.log("info","vote",string.format("[quit_vote] type=%s pid=%s",typ,pid))
	self:cancel_voteto(typ,pid)
	vote.member_vote[pid] = nil
	vote.giveup_member[pid] = nil
	local sum_vote = 0
	for _,votenum in pairs(vote.member_vote) do
		sum_vote = sum_vote + votenum
	end
	vote.pass_vote = math.min(vote.pass_vote,sum_vote)
	self.type_pid_id[typ][pid] = nil
	if self:check_endvote(vote) then
		self:delvote(vote.id,typ)
	else
		xpcall(self.onupdatevote,onerror,self,vote)
	end
	return true
end


-- 结束投票规则:按投票支持率达到多少为结束标准
function cvotemgr:check_endvote(vote,reason)
	local has_vote = 0
	local candidate_sumvote = {}
	for id,supporter in pairs(vote.candidate) do
		local sumvote = 0
		for pid,_ in pairs(supporter) do
			local votenum = vote.member_vote[pid]
			sumvote = sumvote + votenum
		end
		candidate_sumvote[id] = sumvote
		has_vote = has_vote + sumvote
	end
	local giveup_vote = 0
	for pid,_ in pairs(vote.giveup_member) do
		local votenum = vote.member_vote[pid]
		giveup_vote = giveup_vote + votenum
	end
	local sum_vote = 0
	for _,votenum in pairs(vote.member_vote) do
		sum_vote = sum_vote + votenum
	end
	if reason == "timeout" then
		local hitid
		for id,votenum in pairs(candidate_sumvote) do
			if votenum >= vote.pass_vote then
				hitid = id
			end
		end
		if hitid then
			self:callback(vote,"pass",hitid)
		else
			self:callback(vote,"unpass")
		end
		return true
	else
		if not vote.must_timeout_endvote then
			local hitid
			for id,votenum in pairs(candidate_sumvote) do
				if votenum >= vote.pass_vote then
					hitid = id
				end
			end
			if hitid then
				self:callback(vote,"pass",hitid)
				return true
			else
				if sum_vote - giveup_vote < vote.pass_vote then
					self:callback(vote,"unpass")
					return true
				end
			end
		end
		return false
	end
end

function cvotemgr:check_timeout()
	timer.timeout("cvotemgr.check_timeout",10,functor(self.check_timeout,self))
	local now = os.time()
	for typ,id_vote in pairs(self.type_id_vote) do
		for id,vote in pairs(id_vote) do
			if vote.exceedtime and now >= vote.exceedtime then
				xpcall(self.check_endvote,onerror,self,vote,"timeout")
				self:delvote(id,typ)
			end
		end
	end
end

function cvotemgr:onaddvote(vote)
	--print("onaddvote:",table.dump(vote))
end

function cvotemgr:ondelvote(vote)
	--print("ondelvote:",table.dump(vote))
end

function cvotemgr:onupdatevote(vote)
	--print("onupdatevote:",table.dump(vote))
end

function cvotemgr:callback(vote,state,id)
	local callback = vote.callback
	if not callback then
		return
	end
	if type(callback) == "table" then  -- 序列化回调函数
		local func = unpack_function(callback)
		return func(vote,state,id)
	else
		return callback(vote,state,id)
	end
end

return cvotemgr
