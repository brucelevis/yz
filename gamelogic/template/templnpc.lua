
ctemplnpc = class("ctemplnpc")

function ctemplnpc:init()
	self.id = 0
	self.resmgr = nil
	self.talk = ""
	self.options = nil
end

function ctemplnpc:config(conf)
	self.nid = assert(conf.nid)
	self.shape = assert(conf.shape)
	self.name = assert(conf.name)
	self.posid = assert(conf.posid)
	self.isclient = assert(conf.isclient)
	local mapid,x,y = scenemgr.getpos(self.posid)
	self.mapid = mapid
	self.pos = { x = x, y = y}
end

function ctemplnpc:setsession(text,options)
	self.text = text
	self.options = options
end

function ctemplnpc:save()
	local data = {}
	data.nid = self.nid
	data.shape= self.shape
	data.name = self.name
	data.isclient = self.isclient
	data.posid = self.posid
	return data
end

function ctemplnpc:load(data)
	if not data or not next(data) then
		return
	end
	self:config(data)
end


function ctemplnpc:look(pid,talk,respond)
	talk = talk or self.talk
	local callback
	local options
	if istrue(respond) then
		options = self.options or self:getoptions(respond)
		callback = function(player,answer)
			local func = self:getrespondfunc(respond)
			if type(func) == "function" then
				func(self,player,answer)
			else
				self:answer(player,answer)
			end
		end
	end
	net.msg.S2C.npcsay(pid,self,talk,options,callback)
end

function ctemplnpc:getrespondfunc(respond)
end

function ctemplnpc:getoptions(respond)
end

function ctemplnpc:answer(player,answer)
end

