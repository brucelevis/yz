cpetcommentmgr = class("cpetcommentmgr",ccontainer)

function cpetcommentmgr:init()
	ccontainer.init(self,{
		name = "cpetcommentmgr",
	})
	self.savename = "cpetcommentmgr"
	self.loadstate = "unloaded"
	autosave(self)
end

function cpetcommentmgr:save()
	ccontainer.save(self,function(comment)
		return comment:save()
	end)
end

function cpetcommentmgr:load(data)
	ccontainer.load(self,data,function(commentdata)
		local comment = cpetcomment.new()
		comment:load(commentdata)
		return comment
	end)
end

function cpetcommentmgr:loadfromdatabase()
end

function cpetcommentmgr:savetodatabase()
	if self.loadstate = "loaded" then
		local data = self:save()
		local db = dbmgr.getdb()
		db:set("petcommentmgr",data)
	end
end

function cpetcommentmgr:clear()
	logger.log("info","pet","clear")
end


return cpetcommentmgr
