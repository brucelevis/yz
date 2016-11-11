cpetcommentmgr = class("cpetcommentmgr",ccontainer)

function cpetcommentmgr:init()
	ccontainer.init(self,{
		name = "cpetcommentmgr",
	}) self.savename = "petcomment"
	self.loadstate = "unload"
	autosave(self)
end

function cpetcommentmgr:save()
	ccontainer.save(self,function(petcomment)
		return petcomment:save()
	end)
end

function cpetcommentmgr:load(data)
	ccontainer.load(self,data,function(commentdata)
		local petcomment = cpetcomment.new()
		petcomment:load(commentdata)
		return petcomment
	end)
end

function cpetcommentmgr:loadfromdatabase()
	if not self.loadstate or self.loadstate == "unload" then
		self.loadstate = "loading"
		local db = dbmgr.getdb()
		local data = db:get(db:key("global","petcomment"))
		self:load(data)
		self.loadstate = "loaded"
	end
end

function cpetcommentmgr:savetodatabase()
	if not cserver.isdatacenter() then
		return
	end
	if self.loadstate ~= "loaded" then
		return
	end
	local data = self:save()
	local db = dbmgr.getdb()
	db:set(db:key("global","petcomment"),data)
end

function cpetcommentmgr:getpetcomment(pettype)
	if self.loadstate ~= "loaded" then
		return nil,language.format("网络繁忙，请稍后重试")
	end
	if not data_1700_PetHandBook[pettype] then
		return nil,language.format("宠物类型非法")
	end
	local petcomment = self:get(pettype)
	if not petcomment then
		petcomment = cpetcomment.new({ type = pettype, })
		self:add(petcomment,pettype)
	end
	return petcomment
end

function cpetcommentmgr:clear(reason)
	logger.log("info","pet",string.format("[clear] reason=%s",reason))
	ccontainer.clear(self)
end

function cpetcommentmgr:onclear(petcomments)
	for _,petcomment in pairs(petcomments) do
		petcomment:clear()
	end
end

return cpetcommentmgr
