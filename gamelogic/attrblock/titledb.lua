-- 称谓容器
ctitledb = class("ctitledb",ccontainer)

function ctitledb:init(param)
	ccontainer.init(self,param)
	self.cur_titleid = nil
end

function ctitledb:load(data)
	if table.isempty(data) then
		return
	end
	ccontainer.load(self,data)
	self.cur_titleid = data.cur_titleid
end

function ctitledb:save()
	local data = ccontainer.save(self)
	data.cur_titleid = self.cur_titleid
	return data
end

function ctitledb:clear()
	ccontainer.clear(self)
	self.cur_titleid = nil
end

function ctitledb:name2id(title)
	if type(title) == "number" then
		return title
	end
end

function ctitledb:gettitle(title)
	local id = self:name2id(title)
	return self:get(id)
end

function ctitledb:addtitle(id)
	local id = self:name2id(id)
	local titledata = self:gettitledata(id)
	local datatable = self:getdatatable()
	-- 尝试删除低优先级的互斥称谓
	for titleid,v in pairs(datatable) do
		if titleid ~= id and v.unique == titledata.unique then
			if self:gettitle(titleid) then
				if v.priority >= titledata.priority then
					return false
				else
					self:deltitle(titleid)
				end
			end
		end
	end
	local now = os.time()
	local oldtitle = self:gettitle(id)
	if oldtitle then
		if titledata.resettype == 1 then		-- 不能重复获得
			return false
		elseif titledata.resettype == 2 then	-- 重置有效期
			if titledata.validtime then
				self:update(id,{
					exceedtime = now + titledata.validtime,
				})
			end
			logger.log("info","title",format("[reset exceedtime] pid=%s title=%s",self.pid,oldtitle))
			return oldtitle
		else
			assert(titledata.resettype == 3)	-- 延长有效期
			if titledata.validtime then
				self:update(id,{
					exceedtime = (oldtitle.exceedtime or now) + titledata.validtime,
				})
			end
			logger.log("info","title",format("[delay exceedtime] pid=%s title=%s",self.pid,oldtitle))
			return oldtitle
		end
	end
	local title = {
		id = id,
	}
	if titledata.validtime and titledata.validtime > 0 then
		title.exceedtime = now + titledata.validtime
	end
	logger.log("info","title",format("[addtitle] pid=%s title=%s",self.pid,title))
	self:add(title,id)
	if titledata.tryset == 1 then
		local cur_titledata = self:gettitledata(self.cur_titleid)
		if not cur_titledata or cur_titledata.category == titledata.category then
			self:set_curtitle(id)
		end
	end
	return title
end

function ctitledb:deltitle(id)
	local id = self:name2id(id)
	local title = self:gettitle(id)
	if title then
		logger.log("info","title",format("[deltitle] pid=%s title=%s",self.pid,title))
		self:del(id)
		if id == self.cur_titleid then
			self:unset_curtitle()
		end
		return title
	end
end

function ctitledb:set_curtitle(id)
	local title = assert(self:gettitle(id))
	logger.log("info","title",string.format("[set_curtitle] pid=%s titleid=%s",self.pid,id))
	self.cur_titleid = id
	self:sync_curtitle()
end

function ctitledb:unset_curtitle()
	local old_titleid = self.cur_titleid
	if old_titleid then
		logger.log("info",string.format("[unset_curtitle] pid=%s titleid=%s",self.pid,self.cur_titleid))
		self.cur_titleid = nil
		self:sync_curtitle()
		return old_titleid
	end
end

function ctitledb:getdatatable()
	return data_0701_Title
end

function ctitledb:gettitledata(id)
	local datatable = self:getdatatable()
	return datatable[id]
end

-- proto
function ctitledb:onadd(title)
	sendpackage(self.pid,"title","add",title)
end

function ctitledb:ondel(title)
	sendpackage(self.pid,"title","del",title)
end

function ctitledb:onupdate(titleid,attrs)
	local pack = {
		id = titleid,
	}
	table.update(pack,attrs)
	sendpackage(self.pid,"title","update",pack)
end

function ctitledb:sync_curtitle()
	sendpackage(self.pid,"title","sync_curtitle",{
		cur_titleid = self.cur_titleid,
	})
	-- TODO: sync scene
end

return ctitledb
