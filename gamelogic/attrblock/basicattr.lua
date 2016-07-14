

cbasicattr = class("cbasicattr",cdatabaseable)
function cbasicattr:init(conf)
	cdatabaseable.init(self,conf)
	self.data = {}
end

function cbasicattr:save()
	return self.data
end

function cbasicattr:load(data)
	if not data or not next(data) then
		return
	end
	self.data = data
end

function cbasicattr:clear()
	cdatabaseable.clear(self)
end
