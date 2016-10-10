--延时包
cdelaypackage = class("cdelaypackage")

function cdelaypackage:init(pid)
	self.pid = pid
	self.packagelist = {}
	self.isopen = false
	self.limit = 100
end

function cdelaypackage:open()
	self.isopen = true
end

function cdelaypackage:close()
	self.isopen = false
end

function cdelaypackage:push(protoname,subprotoname,request)
	local data = {
		proto = protoname,
		sub = subprotoname,
		req = request,
	}
	table.insert(self.packagelist,data)
	if #self.packagelist >= self.limit then
		logger.log("error","error",string.format("[delaypkglimit] pid=%d proto=%s",self.pid,protoname))
		table.remove(1)
	end
end

function cdelaypackage:sendall()
	self.isopen = false
	local tmplist = self.packagelist
	self.packagelist = {}
	for _,data in ipairs(tmplist) do
		sendpackage(self.pid,data.proto,data.sub,data.req)
	end
end

return cdelaypackage
