local crab_c = require "crab.c"
local utf8_c = require "utf8.c"
local levenshtein = require "levenshtein"  -- 字符串相似比较

wordfilter = wordfilter or {}

function wordfilter.init(params)
	local filter_words = assert(params.filter_words)
	local exclude_words = params.exclude_words or {}
	wordfilter.replaceto = {}
	wordfilter.recoverfrom = {}
	for i,word in ipairs(exclude_words) do
		--local sign = md5.sumhexa(word)
		local sign = string.format("%d%d",i,os.time())
		wordfilter.replaceto[word] = string.format("{%s}",sign)
		wordfilter.recoverfrom[sign] = word
	end
	wordfilter.filter_words = {}
	for i,word in ipairs(filter_words) do
		local texts = {}
		assert(utf8_c.toutf32(word,texts),"non utf8 words detected:" .. word)
		table.insert(wordfilter.filter_words,texts)
	end
	crab_c.open(wordfilter.filter_words)
end

function wordfilter.filter(msg)
	-- 1. 将无须过滤的排除单词替换成特殊符号
	for word,repl in pairs(wordfilter.replaceto) do
		msg = string.gsub(msg,word,repl)
	end
	-- 2. 过滤敏感字
	local texts = {}
	if not utf8_c.toutf32(msg,texts) then
		return false,"UNKNOW MSG"
	end
	crab_c.filter(texts)
	msg = utf8_c.toutf8(texts)
	-- 3. 恢复无须过滤的排除单词
	msg = string.gsub(msg,"{(.+)}",wordfilter.recoverfrom)
	return true,msg
end


local UTF8_LEN_ARR  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
function wordfilter.utf8len(input)
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

function wordfilter.utf8chars(input)
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

function wordfilter.get_similar(str1,str2)
	local distance = levenshtein.levenshtein(str1,str2)
	local len1 = string.len(str1)
	local len2 = string.len(str2)
	local maxlen = math.max(len1,len2)
	return 1-distance/maxlen
end

return wordfilter
