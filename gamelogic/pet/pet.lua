cpet = class("cpet")

function cpet:init(param)
	param = param or {}
	self.pid = param.pid
	self.id = param.id
	self.type = param.type
	self.createtime = param.createtime
	-- 位置一般是放入容器后才有的属性
	self.pos = param.pos

	self.lv = 1
	self.exp = 0
	self.status = petaux.status("兴奋")
	self.relationship = petaux.relationship("陌生")
	self.close = 0		-- 亲密度
	self.liliang = 0
	self.minjie = 0
	self.tili = 0
	self.lingqiao = 0
	self.zhili = 0
	self.xingyun = 0
end

function cpet:load(data)
	if not data or not next(data) then
		return
	end
	self.id = data.id
	self.type = data.type
	self.createtime = data.createtime
	self.pos = data.pos
	self.lv = data.lv
	self.exp = data.exp
	self.status = data.status
	self.relationship = data.relationship
	self.close = data.close
end

function cpet:save()
	local data = {}
	data.id = self.id
	data.type = self.type
	data.createtime = self.createtime
	data.pos = self.pos
	data.lv = self.lv
	data.exp = self.exp
	data.status =  self.status
	data.relationship = self.relationship
	data.close = self.close
	return data
end

function cpet:pack()
	return self:save()
end

function cpet:get(attr)
	local petdata = petaux.getpetdata(self.type)
	return petdata[attr]
end

return cpet
