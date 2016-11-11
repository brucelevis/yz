cpetcomment = class("cpetcomment",{
	hotlimit = 3,
	queuelimit = 100,
})

function cpetcomment:init(conf)
	self.type = conf.type
	self.hotcomment = {}
	self.commentqueue = cdeque.new()
	self.commentid = 0
end

function cpetcomment:save()
	local data = {}
	local hotcomment = {}
	for _,comment in pairs(self.hotcomment) do
		table.insert(hotcomment,self:savecomment(comment))
	end
	data.hotcomment = hotcomment
	local petcomment = self
	data.commentqueue = self.commentqueue:save(function(comment)
		return petcomment:savecomment(comment)
	end)
	data.type = self.type
	data.commentid = self.commentid
	return data
end

function cpetcomment:load(data)
	for _,commentdata in pairs(data.hotcomment) do
		local comment = self:loadcomment(commentdata)
		table.insert(self.hotcomment,comment)
	end
	local petcomment = self
	self.commentqueue:load(data.commentqueue,function(commentdata)
		return petcomment:loadcomment(commentdata)
	end)
	self.type = data.type
	self.commentid = data.commentid
end

function cpetcomment:savecomment(comment)
	local data = {}
	data.id = comment.id
	data.pid = comment.pid
	data.name = comment.name
	data.time = comment.time
	data.likecnt = comment.likecnt
	data.like = {}
	for pid,_ in pairs(comment.like) do
		pid = tostring(pid)
		data.like[pid] = 1
	end
	return data
end

function cpetcomment:loadcomment(data)
	local comment = {}
	comment.id = data.id
	comment.pid = data.pid
	comment.name = data.name
	comment.time = data.time
	comment.likecnt = data.likecnt
	comment.like = {}
	for pid,_ in pairs(data.like) do
		pid = tonumber(pid)
		comment.like[pid] = 1
	end
	return comment
end

function cpetcomment:genid()
	if not self.commentid or self.commentid >= MAX_NUMBER then
		self.commentid = 0
	end
	self.commentid = self.commentid + 1
	return self.commentid
end

function cpetcomment:addcomment(pid,name,msg,time)
	logger.log("info","pet",string.format("[addcomment] pid=%d pettype=%d msg=%s",pid,self.type,msg))
	local comment = {
		pid = pid,
		name = name,
		msg = msg,
		time = time,
		like = {},
		likecnt = 0,
	}
	comment.id = self:genid()
	self.commentqueue:push(comment)
	if self.commentqueue:count() > self.queuelimit then
		self.commentqueue:popleft()
	end
	return true
end

function cpetcomment:likecomment(pid,id)
	local target
	for _,comment in pairs(self.hotcomment) do
		if comment.id == id and not comment.like[pid] then
			target = comment
			break
		end
	end
	for _,comment in pairs(self.commentqueue:getobjs()) do
		if comment.id == id and not comment.like[pid] then
			target = comment
			break
		end
	end
	if target then
		logger.log("info","pet",string.format("[likecomment] pid=%d pettype=%d id=%d owner=%d",pid,self.type,id,target.pid))
		target.like[pid] = 1
		target.likecnt = target.likecnt + 1
		return true
	else
		return false
	end
end

function cpetcomment:pack(pid)
	local comments = {}
	for _,comment in pairs(self.hotcomment) do
		table.insert(comments,{
			id = comment.id,
			pid = comment.pid,
			name = comment.name,
			msg = comment.msg,
			likecnt = comment.likecnt,
			time = comment.time,
			ishot = true,
			islike = comment.like[pid] and true or false
		})
	end
	for _,comment in pairs(self.commentqueue:getobjs()) do
		table.insert(comments,{
			id = comment.id,
			pid = comment.pid,
			name = comment.name,
			msg = comment.msg,
			likecnt = comment.time,
			ishot = false,
			islike = comment.like[pid] and true or false
		})
	end
	return comments
end

function cpetcomment:calhotcomment()
	local comments = self.hotcomment
	self.hotcomment = {}
	table.extends(comments,self.commentqueue:getobjs())
	table.sort(comments,function(comment1,comment2)
		return comment1.likecnt < comment2.likecnt or comment1.likecnt == comment2.likecnt and comment1.id < comment2.id
	end)
	for i = 1,self.hotlimit do
		local comment = comments[-i]
		table.insert(self.hotcomment,deepcopy(comment))
		self.commentqueue:del(comment)
	end
end

function cpetcomment:clear()
	self.hotcomment = {}
	self.commentqueue:clear()
end

return cpetcomment
