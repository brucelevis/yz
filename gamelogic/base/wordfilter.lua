local crab_c = require "crab.c"
local utf8_c = require "utf8.c"

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

return wordfilter
