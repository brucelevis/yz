credpacketmgr = class("credpacketmgr",ccontainer)

function credpacketmgr:init(conf)
	ccontainer.init(self,conf)
	self:starttimer_check_redpacket()
end

function credpacketmgr:add(redpacket_data)
	local redpacket = credpacket.new(redpacket_data)
	local id = globalmgr.genid("redpacket")
	ccontainer.add(self,redpacket,id)
	return redpacket
end

-- player:{pid=xxx,name=xxx}
function credpacketmgr:spell_luck(player,id)
	local redpacket = self:get(id)
	if not redpacket then
		return false,language.format("该红包已过期")
	end
	local state,rank,restype = redpacket:spell_luck(player)
	
	return true,state,rank,restype
end

function credpacketmgr:lookranks(id)
	local redpacket = self:get(id)
	if not redpacket then
		return false,language.format("该红包已过期")
	end
	return true,redpacket.ranks.ranks,redpacket.restype
end

function credpacketmgr:ondel(redpacket)
	if redpacket.leftmoney > 0 then
		local date = os.date("*t",redpacket.createtime)
		mailmgr.sendmail(redpacket.owner,{
			srcid = SYSTEM_MAIL,
			author = language.format("系统"),
			title = language.format("{1}红包剩余返还",redpacket.type == 1 and "世界" or "公会"),
			content = language.format("你在{1}月{2}日{3}时{4}分派发的红包已经过期，剩余{5}铜币还未派发。",date.month,date.day,date.hour,date.min,redpacket.leftmoney),
			attach = {
				[getresflag(redpacket.restype)] = redpacket.leftmoney,
			},
		})
	end
end

function credpacketmgr:starttimer_check_redpacket()
	timer.timeout("timer.check_redpacket",60,functor(self.starttimer_check_redpacket,self))
	local now = os.time()
	for id,redpacket in pairs(self.objs) do
		if redpacket.createtime + redpacket.lifetime < now then
			self:del(id)
		end
	end
end

return credpacketmgr
