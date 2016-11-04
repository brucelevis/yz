cunioncangku = class("cunioncangku",citemdb)

function cunioncangku:init(conf)
	conf.logname = "union"
	citemdb.init(self,conf)
end

function cunioncangku:owner()
	local unionid = self.pid
	return unionmgr:getunion(unionid)
end

function cunioncangku:packitem(item)
	local data = item:pack()
	data.uuid = data.id
	data.id = nil
	return data
end

function cunioncangku:allitem()
	local items = {}
	for uuid,item in pairs(self.objs) do
		table.insert(items,self:packitem(item))
	end
	return items
end

function cunioncangku:genid()
	return uuid()
end

function cunioncangku:key2id(id)
	return id
end

function cunioncangku:getspace()
	local space = citemdb.getspace(self)
	local union = self:owner()
	local data = data_1800_UnionCangKu[union.cangku_lv]
	return space + data.cangku_expandspace
end

function cunioncangku:onadd(item)
	local union = self:owner()
	local pids = table.keys(union.openui_pids)
	unionmgr:sendpackage(pids,"union","additem",{
		item = self:packitem(item),
	})
end

function cunioncangku:ondel(item)
	local union = self:owner()
	local pids = table.keys(union.openui_pids)
	unionmgr:sendpackage(pids,"union","additem",{
		uuid = item.id,
	})
end

function cunioncangku:onupdate(uuid,attr)
	attr.id = nil
	attr.uuid = uuid
	local union = self:owner()
	local pids = table.keys(union.openui_pids)
	unionmgr:sendpackage(pids,"union","additem",{
		item = attr,
	})
end

function cunioncangku:onclear(objs)
	local union = self:owner()
	local pids = table.keys(union.openui_pids)
	for uuid in pairs(objs) do
		unionmgr:sendpackage(pids,"union","delitem",{
			uuid = uuid,
		})
	end
end

return cunioncangku
