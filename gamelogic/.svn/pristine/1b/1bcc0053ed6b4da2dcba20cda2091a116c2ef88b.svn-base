csignin = class("csignin",{
	SIGNIN_STATUS_NO_BUNUS = 0,		-- 尚未领取奖励
	SIGNIN_STATUS_BONUS = 1,		-- 已领取奖励
})

function csignin:init(param)
	self.pid = assert(param.pid)			  -- 所属玩家ID
	self.name = assert(param.name)			  -- 签到名字
	self.starttime = assert(param.starttime)  -- 签到开始时间
	self.endtime = assert(param.endtime)	  -- 签到结束时间
	self.datatable = assert(param.datatable)  -- 导表数据名字
	-- 存盘数据
	self.signs = {}				-- 签到状态数据
	self.signin_day = 1			-- 当前可以在第几天签到
	self.max_signin_day = 1		-- 当前最大可以在第几天签到
	self.issignin = false		-- 今日是否已经签到
	self.pay_signin_day = 0		-- 已补签天数
end

function csignin:load(data)
	if table.isempty(data) then
		return
	end
	self.signs = data.signs
	self.signin_day = data.signin_day
	self.max_signin_day = data.max_signin_day
	self.issignin = data.issignin
	self.pay_signin_day = data.pay_signin_day
end

function csignin:save()
	local data = {}
	data.signs = self.signs
	data.signin_day = self.signin_day
	data.max_signin_day = self.max_signin_day
	data.issignin = self.issignin
	data.pay_signin_day = self.pay_signin_day
	return data
end

function csignin:onlogin(player)
	-- 上线：同步签到数据给客户端
end

function csignin:onlogoff(player)
end

-- 确保先调用:can_signin
function csignin:signin()
	local player = playermgr.getplayer(self.pid)
	if not player then
		return
	end
	logger.log("info","signin",string.format("[%s] [signin] pid=%s signin_day=%s",self.name,self.pid,self.signin_day))
	self.issignin = true
	local signin_day = self.signin_day
	self.signs[signin_day] = csignin.SIGNIN_STATUS_BONUS
	self.signin_day = self.signin_day + 1
	self:onupdate({
		issignin = self.issignin,
		signs = self.signs,
		signin_day = self.signin_day,
	})
	self:doaward(signin_day)
end

-- 补签（付费签到）
-- 调用前先调用:can_pay_signin
function csignin:pay_signin()
	local player = playermgr.getplayer(self.pid)
	if not player then
		return
	end
	self.pay_signin_day = self.pay_signin_day + 1
	logger.log("info","signin",string.format("[%s] [pay_signin] pid=%s pay_signin_day=%s",self.name,self.pid,self.pay_signin_day))
	self:signin()
end

-- 一键补签（付费签到）
-- 调用前先调用:can_pay_signin
function csignin:payall_signin()
	for day = self.signin_day,self.max_signin_day - 1 do
		self:pay_signin()
	end
end

-- 表格式有变化时，需要重写该函数
function csignin:doaward(signin_day)
	local datatable = self:getdatatable()
	local data = datatable(signin_day)
	local reward = data.reward
	local reason = string.format("signin:%s",signin_day)
	doaward("player",self.pid,reward,reason,true)
end

function csignin:onfivehourupdate()
	self.issignin = false
	self.max_signin_day = self.max_signin_day + 1
	self:onupdate({
		issignin = self.issignin,
		signs = self.signs,
		signin_day = self.signin_day,
		max_signin_day = self.max_signin_day,
		pay_signin_day = self.pay_signin_day,
		datatable = self.datatable,
	})
end

-- 每个月第一天5点时更新
function csignin:onmonthupdate()
end

function csignin:getdatatable()
	return _G[self.datatable]
end

-- 可重写
function csignin:can_signin()
	local now = os.time()
	if now < self.starttime then
		return false,language.format("签到尚未开始")
	end
	if now >= self.endtime then
		return false,language.format("签到已结束")
	end
	if self.issignin then
		return false,language.format("今日你已经签到")
	end
	local datatable = self:getdatatable()
	if not datatable[self.signin_day] then
		return false,language.format("无法再签到了")
	end
	return true
end

-- 可重写
function csignin:can_pay_signin()
	local now = os.time()
	if now < self.starttime then
		return false,language.format("签到尚未开始")
	end
	if now >= self.endtime then
		return false,language.format("签到已结束")
	end
	if self.signin_day >= self.max_signin_day then
		return false,language.format("目前全勤，不需要补签")
	end
	-- self.signin_day < self.max_signin_day时,正常情况下,self.signin_day一定是在签到范围内的
	local datatable = self:getdatatable()
	if not datatable[self.signin_day] then
		return false,language.format("补签失败")
	end
	return true
end

-- 可重写
-- 当属性变动时回调
function csignin:onupdate(attrs)
	print(self.pid,table.dump(attrs))
end

return csignin
