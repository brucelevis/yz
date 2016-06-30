require "gamelogic.base.class"
require "gamelogic.base.databaseable"

ctemplate = class("template",cdatabaseable)

function ctemplate:init(conf)
	self.name = assert(conf.name)
	self.templateid = assert(conf.templateid)
	self.id = assert(conf.id)
	self.type = conf.type or TEMPLATE_TASK
	self.resourcemgr = object.cresourcemgr.new(conf)
	if not conf.pid then
		conf.pid = 0
	end
	conf.flag = "template"
	cdatabaseable.init(self,conf)
	self.data = {}
end

function ctemplate:save()
	local data = {}
	data.attr = self.data
	data.name = self.name
	data.type = self.type
	data.res = self.resourcemgr.save()
	return data
end

function ctemplate:load(data)
	if not data or not next(data) then
		return
	end
	self.data = data.attr
	self.name = data.name
	self.type = data.type
	self.resourcemgr.load(data.res)
end

function ctemplate:createnpc()
end

function ctemplate:getnpc()
end

function ctemplate:createscene()
end

function ctemplate:rewardplayer()
end

function ctemplate:createfight()
end

function ctemplate:release()
	self.resourcemgr.release()
end
