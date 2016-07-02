citemdb = class("citemdb",ccontainer)

function citemdb:init(conf)
	-- conf: {pid=xxx,name=xxx}
	ccontainer.init(self,conf)
	self.pid = conf.pid
	self.space = ITEMBAG_SPACE
	self.expandspace = 0
	self.pos_id = {}
	self.type_ids = {}
	self.loadstate = "unload"
	self.itempos_begin = ITEMPOS_BEGIN
end

function citemdb:load(data)
	if not data or not next(data) then
		return
	end
	ccontainer.load(self,data,function (itemdata)
		local item = citem.new()
		item:load(itemdata)
		self:_onadd(item)
		return item
	end)
	self.expandspace = data.expandspace
end

function citemdb:save()
	local data = ccontainer.save(self,function (item)
		return item:save()
	end)
	data.expandspace = self.expandspace
	return data
end

function citemdb:clear()
	ccontainer.clear(self)
	self.expandspace = 0
	self.pos_id = {}
	self.type_ids = {}
end

function citemdb:oncreate(player)
end

function citemdb:onlogin(player)
end

function citemdb:onlogoff(player)
end

function citemdb:genid()
	local player = playermgr.getplayer(self.pid)
	return player:genid()
end

function citemdb:newitem(itemdata)
	assert(itemdata.num > 0)
	itemdata.createtime = itemdata.createtime or os.time()
	return citem.new(itemdata)
end

function citemdb:additemobj(item,reason)
	local itemid = item.id
	local itemtype = item.type
	local pos = self:getfreepos()
	if not pos then
		--mailmgr.sendmail(self.pid,{
		--	srcid = 0,
		--	author = "系统",
		--	title = "背包空间不足",
		--	content = "背包空间不足",
		--	attach = {
		--		item,
		--	},
		--})
		return
	end
	local itemid = self:genid()
	logger.log("info","item",string.format("[additem] pid=%s itemid=%s itemtype=%s num=%s pos=%s reason=%s",self.pid,itemid,itemtype,item.num,pos,reason))
	item.pos = pos
	self:add(item,itemid)
	return item
end

function citemdb:_onadd(item)
	local itemid = item.id
	local pos = item.pos
	local itemtype = item.type
	self.pos_id[pos] = itemid
	if not self.type_ids[itemtype] then
		self.type_ids[itemtype] = {}
	end
	table.insert(self.type_ids[itemtype],itemid)
end

function citemdb:onadd(item)
	self:_onadd(item)
	net.item.S2C.syncitem(self.pid,item)
end

function citemdb:delitemobj(itemid,reason)
	local item = self:getitemobj(itemid)
	if item then
		local pos = assert(item.pos,"No pos item:" .. tostring(itemid))
		local itemtype = item.type
		logger.log("info","item",string.format("[delitem] pid=%s itemid=%s itemtype=%s num=%s pos=%s reason=%s",self.pid,itemid,itemtype,item.num,pos,reason))
		self:del(itemid)
		return item
	end
end

function citemdb:ondel(item)
	local itemid = item.id
	local pos = item.pos
	local itemtype = item.type
	item.pos = nil
	self.pos_id[pos] = nil
	if self.type_ids[itemtype] then
		for pos,id in ipairs(self.type_ids[itemtype]) do
			if id == itemid then
				table.remove(self.type_ids[itemtype],pos)
				break
			end
		end
	end
	net.item.S2C.delitem(self.pid,itemid)
end

function citemdb:onclear(objs)
	for id,_ in pairs(objs) do
		net.item.S2C.delitem(self.pid,id)
	end
end


function citemdb:getitemobj(itemid)
	return self:get(itemid)
end

function citemdb:getitembypos(pos)
	local itemid = self.pos_id[pos]
	return self:getitemobj(itemid)
end

function citemdb:canmerge(srcitem,toitem)
	if srcitem.type ~= toitem.type then
		return false
	end
	if srcitem.bind ~= toitem.bind then
		return false
	end
	return true
end

function citemdb:getitemsbytype(itemtype,filter)
	local ids = self.type_ids[itemtype]
	if ids then
		local items = {}
		for i,itemid in ipairs(ids) do
			local item = self:getitemobj(itemid)
			if not filter or filter(item) then
				table.insert(items,item)
			end
		end
		return items
	end
	return {}
end

function citemdb:getnumbytype(itemtype)
	local num = 0
	local items = self:getitemsbytype(itemtype)
	for i,item in ipairs(items) do
		num = num + item.num
	end
	return num
end

function citemdb:costitembyid(itemid,num,reason)
	assert(num > 0)
	local item = self:getitemobj(itemid)
	assert(item.num >= num)
	item.num = item.num - num
	if item.num <= 0 then
		self:delitemobj(itemid,reason)
	else
		logger.log("info","item",string.format("[costitembyid] pid=%s itemid=%s num=%s reason=%s",self.pid,itemid,num,reason))
	end
end

function citemdb:additembyid(itemid,num,reason)
	assert(num > 0)
	local item = self:getitemobj(itemid)
	local itemdata = getitemdata(item.type)
	assert(item.num + num <= itemdata.maxnum)
	logger.log("info","item",string.format("[additembyid] pid=%s itemid=%s num=%s reason=%s",self.pid,itemid,num,reason))
	item.num = item.num + num
end

function citemdb:additem(packitem,reason)
	local itemtype = packitem.type
	local num = packitem.num
	local allnum = num
	local itemdata = assert(getitemdata(itemtype),"Invalid itemtype:" .. tostring(itemtype))
	local items = self:getitemsbytype(itemtype)
	for i,item in ipairs(items) do
		if num > 0 then
			if item.num < itemdata.maxnum and self:canmerge(packitem,item) then
				local addnum = itemdata.maxnum - item.num
				addnum = math.min(addnum,num)
				self:additembyid(item.id,addnum,reason)
				num = num - addnum
			end
		end
	end
	local now = os.time()
	if num > 0 then
		local needpos = math.ceil(num/itemdata.maxnum)
		local freepos = self:getfreepos()
		local usepos = math.min(needpos,freepos)
		for i=1,usepos do
			local itemnum = math.min(itemdata.maxnum,num)
			num = num - itemnum
			packitem.num = itemnum
			packitem.createtime = now
			local item = self:newitem(packitem)
			self:additemobj(item,reason)
		end
	end
	return allnum-num,num
end

function citemdb:costitembytype(itemtype,num,reason)
	assert(num > 0)
	local hasnum = self:getnumbytype(itemtype)
	if hasnum < num then
		return 0
	end
	local items = self:getitemsbytype(itemtype)
	if items and next(items) then
		local costnum = num
		items = table.sort(items,citemdb.order_costitem)
		for i,item in ipairs(items) do
			if costnum >= item.num then
				costnum = costnum - item.num
				self:delitemobj(item.id,reason)
			else
				self:costitembyid(item.id,costnum,reason)
				break
			end
		end
	end
	return num
end

-- 返回成功增加的数量,剩余未加成功的数量
function citemdb:additembytype(itemtype,num,bind,reason)
	assert(num > 0)
	return self:additem({
		type = itemtype,
		num = num,
		bind = bind,
	},reason)
end

function citemdb:getusespace()
	return self.len
end

function citemdb:getfreespace()
	return self:getspace() - self:getusespace()
end

function citemdb:getspace()
	return self.expandspace + self.space
end

function citemdb:getfreepos()
	local space = self:getspace()
	for pos = self.itempos_begin,self.itempos_begin + space do
		if not self.pos_id[pos] then
			return pos
		end
	end
end

function citemdb:expandspace(addspace)
	logger.log("info","item",string.format("[expandspace] pid=%s addspace=%s",self.pid,addspace))
	self.expandspace = addspace
end

function citemdb.order_costitem(item1,item2)
	if item1.bind then
		return true
	end
	if item2.bind then
		return false
	end
	return true
end

function citemdb:moveitem(itemid,newpos)
	local item1 = self:getitemobj(itemid)
	if item1 == nil then
		return
	end
	local oldpos = item1.pos
	local item2 = self:getitembypos(newpos)
	if item2 then
		self.pos_id[oldpos] = item2.id
		item2.pos = oldpos
		net.item.S2C.syncitem(self.pid,item2)
	else
		self.pos_id[oldpos] = nil
	end
	self.pos_id[newpos] = item1.id
	item1.pos = newpos
	net.item.S2C.syncitem(self.pid,item1)
	return item2
end

return citemdb
