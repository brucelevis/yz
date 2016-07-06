language = language or {}

function language.init(option)
	-- 原生语言
	language.language_from = option.language_from or  "cn"
	-- 翻译为的语言
	language.language_to = option.language_to or "en"
	-- 无须翻译字符串的前缀标记
	language.untranslate_char = option.untranslate_char or "$"
	language.translate_table = option.translate_table
end

function language.format(fmt,...)
	return language.packstring(fmt,...)
end

function language.translateto(packstr,language_name)
	return language.unpackstring(packstr,language_name)
end

-- 包装函数
function language.formatto(language_name,fmt,...)
	local packstr = language.format(fmt,...)
	return language.translateto(packstr,language_name)
end

function language.format2(fmt,...)
	local packstr = language.format(fmt,...)
	return language.translateto(packstr,language.language_to)
end

function language.untranslate(str)
	return string.format("%s%s",language.untranslate_char,str)
end


--/*
-- @functions 根据(字符串ID,语言名字)获取该语言对应的字符串,该函数需要由使用者定义
-- @param integer id 字符串ID
-- @param string language_name 语言名字
-- @return string
--*/
function language.getstring(id,language_name)
	-- 参考定义如下
	local translate_table = language.translate_table or data_language
	local lang_str = assert(translate_table[id],"Invalid string id:" .. tostring(id))
	local str = assert(lang_str[language_name],"Invalid language_name:" .. tostring(language_name))
	return str
end

-- 获取字符串对应的ID，如果没找到对应ID(尚未翻译)，则原样返回字符串
-- 该函数需要由使用者定义
function language.getstrid(str)
	-- 参考定义如下
	if not language.str_id then
		local translate_table = language.translate_table or data_language
		language.str_id = {}
		for id,v in pairs(translate_table) do
			-- 假定原生语言为中文
			local str = v[language.language_from] -- default: v.cn
			language.str_id[str] = id
		end
	end
	local id = language.str_id[str]
	return id or str
end


-- 私有方法
function language.packstring(fmt,...)
	local args = {...}
	for i,arg in ipairs(args) do
		arg = tostring(arg)
		args[i] = language.packstring(arg)
	end
	local id
	local untranslate_char = language.untranslate_char or "$"
	if string.sub(fmt,1,1) == untranslate_char then
		id = string.sub(fmt,2)
	else
		id = language.getstrid(fmt)
	end
	return {
		id = id,
		args = args,
	}
end

function language.unpackstring(packstr,language_name)
	-- unpackstring(arg)时，arg是字符串
	if type(packstr) == "string" then
		return packstr
	end
	language_name = language_name or language.language_to
	local fmt
	local id = packstr.id
	local typ = type(id)
	if typ == "number" then
		fmt = language.getstring(id,language_name)
		-- 未翻译的语句，显示原生语言
		if not fmt or fmt == "" then
			fmt = language.getstring(id,language.language_from)
		end
	else
		assert(typ == "string",typ)
		fmt = id
	end
	local args = packstr.args
	if args and next(args) then
		for i,arg in ipairs(args) do
			args[i] = language.unpackstring(arg,language_name)
		end
		return string.gsub(fmt,"({)(%d)(})",function (_,id,_)
			id = tonumber(id)
			return args[id]
		end)
	else
		return fmt
	end
end

return language

