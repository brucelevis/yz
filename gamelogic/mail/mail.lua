

cmail = class("cmail")

function cmail:init(conf)
	conf = conf or {}
	self.mailid = conf.mailid or 0
	self.sendtime = conf.sendtime or 0
	self.author = conf.author or ""
	self.title = conf.title or ""
	self.content = conf.content or ""
	self.attach = conf.attach or {}
	self.readtime = conf.readtime or 0
	self.srcid = conf.srcid or 0
	self.lifetime = conf.lifetime or 10 * DAY_SECS
	self.buttons = conf.buttons
	self.callback = conf.callback
	self.autodel = conf.autodel or true		-- true:无附件邮件，阅读后可以自动删除
end

function cmail:load(data)
	if not data or not next(data) then
		return
	end
	self.mailid = data.mailid
	self.sendtime = data.sendtime
	self.author = data.author
	self.title = data.title
	self.content = data.content
	self.attach = data.attach
	self.readtime = data.readtime
	self.srcid = data.srcid
	self.lifetime = data.lifetime
	self.buttons = data.buttons
	self.callback = data.callback
	self.autodel = data.autodel
end

function cmail:save()
	local data = {}
	data.mailid = self.mailid
	data.sendtime = self.sendtime
	data.author = self.author
	data.title = self.title
	data.content = self.content
	data.attach = self.attach
	data.readtime = self.readtime
	data.srcid = self.srcid
	data.lifetime = self.lifetime
	data.buttons = self.buttons
	data.callback = self.callback
	data.autodel = self.autodel
	return data
end

function cmail:pack()
	return self:save()
end

function cmail:can_autodel()
	if self.autodel then
		if self.readtime and 
			table.isempty(self.attach)
			and table.isempty(self.buttons) then
			return true
		end
	end
	return false
end

return cmail
