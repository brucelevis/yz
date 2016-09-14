citemdb = class("citemdb",ccontainer)

function citemdb:init(conf)
	-- conf: {pid=xxx,name=xxx}
	ccontainer.init(self,conf)
	self.type = assert(conf.type)	-- 背包类型
	self.pid = conf.pid
	self.space = ITEMBAG_SPACE
	self.expandspace = 0
	self.pos_id = {}
	self.type_ids = {}
	self.loadstate = "unload"
	self.itempos_begin = ITEMPOS_BEGIN

	-- 物品排序类型(部分背包有用)
	self.sorttype = 0
end

function citemdb:load(data)
	if not data or not next(data) then
		return
	end
	ccontainer.load(self,data,function (itemdata)
		local item = self:newitem()
		item:load(itemdata)
		self:_onadd(item)
		return item
	end)
	self.expandspace = data.expandspace
	self.sorttype = data.sorttype or 0
end

function citemdb:save()
	local data = ccontainer.save(self,function (item)
		return item:save()
	end)
	data.expandspace = self.expandspace
	data.sorttype = self.sorttype
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
	assert(self.pid == player.pid)
	net.item.S2C.bag(self.pid,{
		type = self.type,
		space = self.space,
		expandspace = self.expandspace,
		sorttype = self.sorttype,
	})
	net.item.S2C.allitem(self.pid,self.type,self.objs)
end

function citemdb:onlogoff(player,reason)
end

function citemdb:genid()
	local player = playermgr.getplayer(self.pid)
	return player:genid()
end

function citemdb:newitem(itemdata)
	if itemdata then
		assert(itemdata.num > 0)
		itemdata.createtime = itemdata.createtime or os.time()
	end
	return citem.new(itemdata)
end

function citemdb:additem(item,reason)
	local itemtype = item.type
	local pos = self:getfreepos()
	assert(pos)
	local itemid = self:genid()
	logger.log("info","item",string.format("[additem] pid=%s itemid=%s itemtype=%s num=%s pos=%s reason=%s",self.pid,itemid,itemtype,item.num,pos,reason))
	item.pos = pos
	self:add(item,itemid)
	return item
end


function citemdb:delitem(itemid,reason)
	local item = self:getitem(itemid)
	if item then
		local pos = assert(item.pos,"No pos item:" .. tostring(itemid))
		local itemtype = item.type
		logger.log("info","item",string.format("[delitem] pid=%s itemid=%s itemtype=%s num=%s pos=%s reason=%s",self.pid,itemid,itemtype,item.num,pos,reason))
		self:del(itemid)
		return item
	end
end


function citemdb:getitem(itemid)
	return self:get(itemid)
end

function citemdb:getitembypos(pos)
	local itemid = self.pos_id[pos]
	return self:getitem(itemid)
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
			local item = self:getitem(itemid)
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
	local item = self:getitem(itemid)
	assert(item.num >= num)
	--item.num = item.num - num
	self:update(item.id,{
		num = item.num - num,
	})

	logger.log("info","item",string.format("[costitembyid] pid=%s itemid=%s num=%s leftnum=%s reason=%s",self.pid,itemid,num,item.num,reason))
	if item.num <= 0 then
		self:delitem(itemid,reason)
	end
end

function citemdb:additembyid(itemid,num,reason)
	assert(num > 0)
	local item = self:getitem(itemid)
	local maxnum = self:getmaxnum(item.type)
	assert(item.num + num <= maxnum)
	logger.log("info","item",string.format("[additembyid] pid=%s itemid=%s num=%s leftnum=%s reason=%s",self.pid,itemid,num,item.num,reason))
	--item.num = item.num + num
	self:update(item.id,{
		num = item.num + num,
	})
end

-- 增加一个序列化的物品
-- packitem: 序列化的物品
function citemdb:additem2(packitem,reason)
	local itemtype = packitem.type
	local num = packitem.num
	local allnum = num
	local maxnum = self:getmaxnum(itemtype)
	local items = self:getitemsbytype(itemtype)
	for i,item in ipairs(items) do
		if num > 0 then
			if item.num < maxnum and self:canmerge(packitem,item) then
				local addnum = maxnum - item.num
				addnum = math.min(addnum,num)
				self:additembyid(item.id,addnum,reason)
				num = num - addnum
			end
		end
	end
	local now = os.time()
	if num > 0 then
		local needpos = math.ceil(num/maxnum)
		local freepos = self:getfreepos()
		local usepos = math.min(needpos,freepos)
		for i=1,usepos do
			local itemnum = math.min(maxnum,num)
			num = num - itemnum
			packitem.num = itemnum
			packitem.createtime = now
			local item = self:newitem(packitem)
			self:additem(item,reason)
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
		table.sort(items,citemdb.order_costitem)
		for i,item in ipairs(items) do
			if costnum >= item.num then
				costnum = costnum - item.num
				self:costitembyid(item.id,item.num,reason)
				-- costitembyid will delitem when item.num == 0
				--self:delitem(item.id,reason)
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
	if bind then
		-- 防止忘记写bind字段
		assert(type(bind) == "number")
		bind = bind == 1 and 1 or nil
	end
	return self:additem2({
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

function citemdb:expand(addspace)
	logger.log("info","item",string.format("[expandspace] pid=%s addspace=%s",self.pid,addspace))
	self.expandspace = self.expandspace + addspace
	net.item.S2C.bag(self.pid,{
		type = self.type,
		space = self.space,
		expandspace = self.expandspace,
		sorttype = self.sorttype,
	})
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
	local item1 = self:getitem(itemid)
	if item1 == nil then
		return
	end
	local oldpos = item1.pos
	local item2 = self:getitembypos(newpos)
	if item2 then
		self.pos_id[oldpos] = item2.id
		self:update(item2.id,{
			pos = oldpos,
		})
	else
		self.pos_id[oldpos] = nil
	end
	self.pos_id[newpos] = item1.id
	self:update(item1.id,{
		pos = newpos,
	})
	return item2
end

function citemdb:getmaxnum(itemtype)
	local itemdata = assert(itemaux.getitemdata(itemtype),"Invalid itemtype:" .. tostring(itemtype))
	if not itemdata.maxnum or itemdata.maxnum <= 0 then
		return MAX_NUMBER
	end
	return itemdata.maxnum
end

-- 整理背包(已废弃，背包无法整理，客户端也无法控制物品移动位置）
function citemdb:sort()
	logger.log("info","item",string.format("[sort] pid=%s name=%s",self.pid,self.name))
	local space = self:getspace()
	local freepos
	for pos = self.itempos_begin,self.itempos_begin + space do
		if not self.pos_id[pos] then
			freepos = pos
			break
		end
	end
	for pos = freepos + 1,self.itempos_begin + space do
		local id = self.pos_id[pos]
		if id then
			self:moveitem(id,freepos)
			freepos = freepos + 1
			assert(not self.pos_id[freepos])
		end
	end
end

function citemdb:fumoequip(itemid)
	local item = self:getitem(itemid)
	if not item then
		return
	end
	local maintype = itemaux.getmaintype(item.type)
	if maintype ~= ItemMainType.EQUIP then
		return
	end

	local attrs = data_0801_FixFumoAttr[item.type]
	if attrs then -- 固定附魔属性
	else
		local equiplv = item:get("lv")
		local fumodata = data_0801_Fumo[equiplv]
		if not fumodata then	-- 无须附魔的装备
			return
		end
		local minortype = itemaux.getminortype(item.type)
		local minortype_name = assert(EQUIPPOS_NAME[minortype],"Invalid item minortype:" .. tostring(minortype))
		

		local attrnum = choosekey(data_0801_PromoteEquipVar.FumoShowAttrNumRatio)
		local attrs = {}
		-- 随机attrnum条不重复的属性
		for i=1,attrnum do
			local attr = choosekey(data_0801_FumoAttrRatio,function (k,v)
				-- 已出现属性，强制将其概率改成0
				if attrs[k] then
					return 0
				end
				local key = string.format("%s_ratio",minortype_name)
				return v[key]
			end)
			local data = data_0801_FumoAttrRatio[attr]
			local attr_factor = data[string.format("%s_factor",minortype_name)]
			local maxval = math.floor(fumodata[attr] * attr_factor)
			local minval = math.floor(maxval * 0.2)
			attrs[attr] = math.random(minval,maxval)
		end
		item.fumo = attrs
	end
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
	-- 装备获取后自动生成附魔属性
	if itemaux.getmaintype(item.type) == ItemMainType.EQUIP then
		self:fumoequip(item.id)
	end
	-- 背包类型暂时不发给客户端，有客户断根据物品分类确定背包
	net.item.S2C.additem(self.pid,item)
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

function citemdb:onupdate(itemid,attr)
	attr.id = itemid
	net.item.S2C.updateitem(self.pid,attr)
end

return citemdb
