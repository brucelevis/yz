gm = require "gamelogic.gm.init"

gm.union = gm.union or {}
--- 用法: union.addmoney 增加的资金 [公会ID]
--- 举例: union.addmoney 300 <=> 给自身公会增加300资金
--- 举例: union.addmoney 300 100001 <=> 给100001公会增加300资金
function gm.union.addmoney(args)
	local isok,args = checkargs(args,"int","*")
	local addmoney = args[1]
	local unionid = tonumber(args[2]) or master:unionid()
	if not unionid then
		gm.notify("用法: union.addmoney 增加的资金 [公会ID]")
		return
	end
	unionaux.addmoney(unionid,addmoney,"gm")
end

--- 用法： union.addoffer 增加的贡献度
--- 举例： union.addoffer 100	<=> 给自己增加100贡献度
function gm.union.addoffer(args)
	local isok,args = checkargs(args,"int")
	if not isok then
		gm.notify("用法： union.addoffer 增加的贡献度")
		return
	end
	local addoffer = args[1]
	if not master:unionid() then
		gm.notify("你没有公会")
		return
	end
	master:addoffer(addoffer,"gm")
end

--- 用法: union.additem 物品类型 物品数量 [公会ID]
--- 举例: union.additem 601001 10	<=> 给自身工会仓库增加10个601001
--- 举例: union.additem 601001 10 100001 <=> 给100001公会仓库增加10个601001
function gm.union.additem(args)
	local isok,args = checkargs(args,"int","int","*")
	local itemtype = args[1]
	local itemnum = args[2]
	local unionid = tonumber(args[3]) or master:unionid()
	if not unionid then
		gm.notify("用法: union.addmoney 增加的资金 [公会ID]")
		return
	end
	local itemdata = data_0501_ItemUnion[itemtype]
	if not itemdata or not istrue(itemdata.canstore) then
		gm.notify("该物品无法放入公会仓库")
		return
	end

	unionaux.unionmethod(unionid,"cangku:additembytype",itemtype,itemnum,nil,"gm")
end


return gm
