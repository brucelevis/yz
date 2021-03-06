ccarddb = class("ccarddb",citemdb)

function ccarddb:init(conf)
	citemdb.init(self,conf)
end

function ccarddb:addcardbytype(cardtype,num,reason)
	self:additembytype(cardtype,num,nil,reason)
end

ccarddb.costcardbytype = ccarddb.costitembytype
ccarddb.costcardbyid = ccarddb.costitembyid
ccarddb.addcardbyid = ccarddb.additembyid
ccarddb.getcard = ccarddb.getitem

function ccarddb:getcardbytype(cardtype)
	local items = self:getitemsbytype(cardtype)
	if next(items) then
		assert(#items == 1)
		return items[1]
	end
	return nil
end

-- 卡片获取后就永不删除，即使数量变成0也不删除
function ccarddb:delitem(itemid,reason)
end

return ccarddb
