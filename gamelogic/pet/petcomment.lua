cpetcomment = class("cpetcomment",{
	hotlimit = 3,
	queuelimit = 200,
})

function cpetcomment:init(conf)
	self.type = conf.type
	self.hotcomments = {}
	self.commentsqueue = cdequeue.new()
end

function cpetcomment:save()
	local data
	data.hotcomments = self.hotcomments
	data.commentsqueue = self.commentsqueue:save()
	data.type = self.type
	return data
end

function cpetcomment:load(data)
	for id,percomment in pairs(data.hotcomments) do
		id = tonumber(id)
		self.hotcomments[id] = percomment
	end
	self.commentsqueue:load(data.commentsqueue)
	self.type = data.type
end



return cpetcomment
