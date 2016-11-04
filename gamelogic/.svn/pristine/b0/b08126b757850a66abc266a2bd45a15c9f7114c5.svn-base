netchapter = netchapter or {
	C2S = {},
	S2C = {},
}

local C2S = netchapter.C2S
local S2C = netchapter.S2C

--c2s
function C2S.raisewar(player,request)
	local chapterid = assert(request.chapterid)
	player.chapterdb:raisewar(chapterid)
end

function C2S.getaward(player,request)
	local awardid = assert(request.awardid)
	player.chapterdb:mainlineaward(awardid)
end

function C2S.get_unlockcondition(player,request)
	local chapterid = assert(request.chapterid)
	player.chapterdb:get_unlockcondition(chapterid)
end

--s2c
function S2C.unlock(pid,chapterid)
	sendpackage(pid,"chapter","unlock",{
		chapterid = chapterid,
	})
end

function S2C.update(pid,chapter)
	sendpackage(pid,"chapter","update",{
		chapter = chapter,
	})
end

function S2C.allchapter(pid,chapters)
	sendpackage(pid,"chapter","allchapter",{
		chapters = chapters,
	})
end

function S2C.awardrecord(pid,records)
	sendpackage(pid,"chapter","awardrecord",{
		records = records,
	})
end

function S2C.send_unlockcondition(pid,chapterid,data)
	sendpackage(pid,"chapter","send_unlockcondition",{
		chapterid = chapterid,
		needtasks = data.needtasks,
	})
end

return netchapter
