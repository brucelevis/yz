-- 扩展string
function string.ltrim(str,charset)
	local patten
	if charset then
		patten = string.format("^[%s]+",charset)
	else
		patten = string.format("^[ \t\n\r]+")
	end
	return string.gsub(str,patten,"")
end

function string.rtrim(str,charset)
	local patten
	if charset then
		patten = string.format("[%s]+$",charset)
	else
		patten = string.format("[ \t\n\r]+$")
	end

	return string.gsub(str,patten,"")
end

function string.trim(str)
	str = string.ltrim(str)
	return string.rtrim(str)
end

function string.isdigit(str)
	local ret = pcall(tonumber,str)
	return ret
end

function string.hexstr(str)
	assert(type(str) == "string")
	local len = #str
	return string.format("0x" .. string.rep("%x",len),string.byte(str,1,len))
end

local NON_WHITECHARS_PAT = "%S+"
function string.split(str,pat,maxsplit)
	pat = pat and string.format("[^%s]+",pat) or NON_WHITECHARS_PAT
	maxsplit = maxsplit or -1
	local ret = {}
	local i = 0
	for s in string.gmatch(str,pat) do
		if not (maxsplit == -1 or i <= maxsplit) then
			break
		end
		table.insert(ret,s)
		i = i + 1
	end
	return ret
end

function string.urlencodechar(char)
	return string.format("%%%02X",string.byte(char))
end

function string.urldecodechar(hexchar)
	return string.char(tonumber(hexchar,16))
end

function string.urlencode(str)
	str = string.gsub(str,"([^%w%.%- ])",string.urlencodechar)
	str = string.gsub(str," ","+")
	return str
end

function string.urldecode(str)
	str = string.gsub(str,"+"," ")
	str = string.gsub(str,"%%(%x%x)",string.urldecodechar)
	return str
end


local algorithm = require "algorithm"
local utf8_c = require "utf8.c"
local UTF8_LEN_ARR  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}

function string.utf8len(input)
	return utf8_c.len(input)
	--local len  = string.len(input)
	--local left = len
	--local cnt  = 0
	--local arr = UTF8_LEN_ARR
	--while left ~= 0 do
	--	local tmp = string.byte(input, -left)
	--	local i   = #arr
	--	while arr[i] do
	--		if tmp >= arr[i] then
	--			left = left - i
	--			break
	--		end
	--		i = i - 1
	--	end
	--	cnt = cnt + 1
	--end
	--return cnt
end

function string.utf8chars(input)
	local len  = string.len(input)
	local left = len
	local chars  = {}
	local arr  = UTF8_LEN_ARR
	while left ~= 0 do
		local tmp = string.byte(input, -left)
		local i   = #arr
		while arr[i] do
			if tmp >= arr[i] then
				table.insert(chars,string.sub(input,-left,-(left-i+1)))
				left = left - i
				break
			end
			i = i - 1
		end
	end
	return chars
end


-- 获取字符串编辑相似度
function string.get_similar(str1,str2)
	local distance = algorithm.levenshtein(str1,str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local maxlen = math.max(len1,len2)
	return 1-distance/maxlen
end

-- 获取单词发音相似度，返回值越大，相似度越高
function string.get_soundex_diff(word1,word2)
	local str1 = algorithm.soundex(word1)
	local str2 = algorithm.soundex(word2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	assert(len1 == len2)
	local diff = 0
	for i=1,len1 do
		if string.char(str1,i,i) == string.char(str2,i,i) then
			diff = diff + 1
		end
	end
	return diff
end

-- 获取字符串发音相似度(仅对中文拼音，拉丁语系有参考意义)
function string.get_soundex_similar(str1,str2)
	local words1 = {}
	local words2 = {}
	for word in string.gmatch(str1,"%S+") do
		table.insert(words1,word)
	end
	for word in string.gmatch(str2,"%S+") do
		table.insert(words2,word)
	end
	local len1 = #words1
	local len2 = #words2
	if (len1 == 0 and len2 ~= 0) or
		(len1 ~= 0 and len2 == 0) then
		return 0
	end
	if len1 == 0 and len2 == 0 then
		return 1
	end
	local minlen = math.min(len1,len2)
	local maxlen =  math.max(len1,len2)
	local diff = 0
	for i = 1,minlen do
		diff = diff + string.get_soundex_diff(words1[i],words2[i])
	end
	return diff / (maxlen * 4)
end

function string.totime(str)
	local year,mon,day,hour,min,sec = string.match(str,"^(%d+)/(%d+)/(%d+)%s+(%d+):(%d+):(%d+)$")

	return os.time({
		year = tonumber(year),
		month = tonumber(mon),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec),
	})
end

