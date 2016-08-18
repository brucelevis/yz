--师门任务
cshimentask = class("cshimentask",ctaskcontainer)

function cshimentask:init(conf)
	ctaskcontainer.init(self,conf)
end

function cshimentask:nexttask(taskid,reason)
	local donecnt = self:getdonecnt()
	local donelimit = self:getformdata("donelimit")
	if donecnt >= donelimit then
		return nil,language.format("今天已经做完了20次师门任务，明天再来吧")
	end

end

function cshimentask:onlogin(player)
	local dayno = getdayno()
	if self.dayno ~= dayno then
		self:resettask()
	end
end

function cshimentask:ondayupdate()
	self:resettask()
end

function cshimentask:resettask()
	self:clear("resettask")
	self.dayno = getdayno()
	self.ringnum = 0
end

return cshimentask
