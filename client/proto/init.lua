---------------------------------------------------
local _require_prefix = nil
local proto

if PROTOCOL_IS_CLIENT then
	-- 客户端
	_require_prefix = "app.net.protocols."
	proto = {}
else
	-- 服务器
	_require_prefix = "proto."
	if not g_proto then
		g_proto = {}
	end
	proto = g_proto
end

local function require_( modulePath )
	return require(string.format("%s%s", _require_prefix, modulePath))
end

--[[
	新增协议proto以及协议定义文件protoc2s.lua,pros2c.lua时
	在proto_profix表中增加proto字段
]]
local proto_profix =
{
	"inittype", 	-- 公共类型[0,500)
	"test",			-- 测试协议[500,1000)
	"login",		-- 登录协议[1000,1500)
	"kuafu",		-- 跨服协议[1500,2000)
	"mail",			-- 邮箱协议[2000,2500)
	"scene",    	-- 场景协议[2500,3000)
	"friend",		-- 好友协议[3000,3500)
	"task",			-- 任务协议[3500,4000)
	"team",			-- 队伍协议[4000,4500)
	"msg",			-- 消息协议[4500,5000)
	"player",		-- 玩家协议[5000,5500)
	"item",			-- 物品/背包协议[5500,6000)
	"war",			-- 战斗协议[6000,6500)
	"title",		-- 称谓协议[6500,6600)
	"safelock",		-- 安全锁协议[6600,6700)
	"chapter",		-- 关卡协议[6700,6800)
	"skill",		-- 技能协议[6800,6900)
	"shop",			-- 商城协议[6900,7000)
	"guaji",		-- 挂机协议[7000,7100)
	"navigation",	-- 活动导航协议[7100,7200)
	"playunit",		-- 通用玩法协议[7200,7300)
}

---------------------------------------------------

local protocount = 1

local proto_c2s
local proto_s2c

local proto_c2s_info = {subfix="c2s.lua"}
local proto_s2c_info = {subfix="s2c.lua"}


local basestr = [[
.package {
	type 0 : integer
	session 1 : integer
}
.basetypey{
	key 0 : string
	src 1 : string
}
.basetype {
	p 0 : string
	s 1 : string
	n 2 : integer
	y 3 : basetypey
}
limited_max 30000 {
	request {
		base 0 : basetype
	}
}
]]

local typeCommonModule = require_("inittypecommon")
local typeCommonSrc = typeCommonModule.src

local function genProto(t, info)
	local proto_src = {}
	local baselen = #basestr
	local sep = "\n"
	local seplen = #sep
	local sumlen = baselen + seplen
	table.sort(t,function (a,b)
		return a.si < b.si
	end)
	--
	proto_src[#proto_src+1] = basestr
	info.modulelist = {}
	info.modulelist[#info.modulelist + 1] = {epos=sumlen, name="basestr" }
	--
	proto_src[#proto_src+1] = typeCommonSrc
	sumlen = sumlen + #typeCommonSrc + seplen
	info.modulelist[#info.modulelist + 1] = {epos=sumlen, name="typecommon" }
	--
	for i,protodt in ipairs(t) do
		proto_src[#proto_src+1] = protodt.src
		sumlen = sumlen + #protodt.src + seplen
		info.modulelist[#info.modulelist + 1] = {epos=sumlen, name=protodt.p }
	end
	local proto_src_final = table.concat(proto_src,sep)
	return proto_src_final
end

local function paser_linechagne(pos, parser_state)
	parser_state.lastpos = parser_state.lastpos or 0
	if parser_state.lastpos ~= pos then
		parser_state.lastpos = parser_state.pos or 0
	end
end

function proto.gets2c()
	local s2cParseErr = function (parser_state, ctx)
		return proto.parseErr(proto_s2c_info, parser_state, ctx)
	end
	return genProto(proto_s2c, proto_s2c_info), "s2c", {errorproc=s2cParseErr, line_change=paser_linechagne}
end

function proto.getc2s()
	local c2sParseErr = function (parser_state, ctx)
		return proto.parseErr(proto_c2s_info, parser_state, ctx)
	end
	return genProto(proto_c2s, proto_c2s_info), "c2s", {errorproc=c2sParseErr, line_change=paser_linechagne}
end

function proto.parseErr(protoInfo, parser_state, ctx)
	local modulename = ""
	for _,moduleInfo in ipairs(protoInfo.modulelist) do
		if moduleInfo.epos > parser_state.pos then
			modulename = string.format("%s%s",moduleInfo.name,protoInfo.subfix)
			break
		end
	end
	local errinfo = ctx:sub(parser_state.lastpos, parser_state.pos-2)
	return string.format("%s => '%s'", modulename, errinfo)
end

function proto.whenSubmoduleUpdated()
	typeCommonModule = require_("inittypecommon")
	typeCommonSrc = typeCommonModule.src
	proto_c2s = {}
	proto_s2c = {}
	for i,profix in ipairs(proto_profix) do
		proto_c2s[i] = require_(string.format("%sc2s",profix))
		proto_s2c[i] = require_(string.format("%ss2c",profix))
	end
end

-----------------------------------------
if not (proto_s2c and proto_c2s) then
	proto.whenSubmoduleUpdated()
end

return proto
