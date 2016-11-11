-- 带有位置关系的容器类
cposcontainer = class("cposcontainer",ccontainer)

function cposcontainer:init(conf)
	ccontainer.init(self,conf)
	self.space = conf.initspace or 120
	self.beginpos = conf.beginpos or 1
	self.pos_id = {}
end

function cposcontainer:save(savefunc)
	local data = ccontainer.save(self,function(obj)
		local objdata
		if savefunc then
			objdata = savefunc(obj)
		else
			objdata = obj
		end
		objdata.pos = obj.pos
		return objdata
	end)
	return data
end

function cposcontainer:load(data,loadfunc)
	ccontainer.load(self,data,function(objdata)
		local obj
		if loadfunc then
			obj = loadfunc(objdata)
		else
			obj = objdata
		end
		obj.pos = objdata.pos
		self.pos_id[obj.pos] = obj.id
		return obj
	end)
end

function cposcontainer:clear()
	ccontainer.clear(self)
	self.pos_id = {}
end

function cposcontainer:add(obj,id)
	if obj.pos then
		local pos = obj.pos
		if self.pos_id[pos] then
			logger.log("error","item",string.format("[samepos] name=%s pos=%d id1=%d id2",self.name,pos,self.pos_id[pos],id))
			return
		end
	else
		obj.pos = self:getfreepos()
	end
	self.pos_id[obj.pos] = id
	return ccontainer.add(self,obj,id)
end

function cposcontainer:del(id)
	local obj = self:get(id)
	self.pos_id[obj.pos] = nil
	obj.pos = nil
	return ccontainer.del(self,id)
end

function cposcontainer:getspace()
	return self.space
end

function cposcontainer:getusespace()
	local len = 0
	for pos = self.beginpos,self.beginpos + self:getspace() - 1 do
		if self.pos_id[pos] then
			len = len + 1
		end
	end
	return len
end

function cposcontainer:getfreespace()
	return self:getspace() - self:getusespace()
end

function cposcontainer:getfreepos()
	local space = self:getspace()
	for pos = self.beginpos,self.beginpos + space - 1 do
		if not self.pos_id[pos] then
			return pos
		end
	end
end

function cposcontainer:getbypos(pos)
	local id = self.pos_id[pos]
	if not id then
		return
	end
	return self:get(id)
end

function cposcontainer:delbypos(pos)
	local id = self.pos_id[pos]
	if not id then
		return
	end
	return self:del(id)
end

function cposcontainer:moveto(srcpos,tarpos)
	if tarpos < self.beginpos or tarpos > self.beginpos + self:getspace() - 1 then
		return false
	end
	if not self.pos_id[srcpos] or self.pos_id[tarpos] then
		return false
	end
	local obj = self:getbypos(srcpos)
	self:update(obj.id,{ pos = tarpos, })
	self.pos_id[srcpos] = nil
	self.pos_id[tarpos] = obj.id
	return true
end

return cposcontainer

