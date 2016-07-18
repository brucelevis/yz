--关卡容器
cchapterdb = class("cchapterdb",ccontainer)

function cchapterdb:init(param)
	ccontainer.init(self,param)
	self.mainline = {}
	self.mainlinestart = {}
	self.subline = {}
	self.loadstate = "unload"
end

function cchapterdb:load(data)
	if table.isempty(data) then
		return
	end
	local chapterdata = self:getchapterdata()
	for chapterid,chapter in pairs(data) do
		chapterid = tonumber(chapterid)
		if chapterdata[chapterid] then
			local idx = 100
	end
end

function cchapterdb:save()
	data = {}
	return data
end

function cchapterdb:getchapterdata(isstar)
	if isstar then
		return data_ChapterStarData
	end
	return data_ChapterData
end



