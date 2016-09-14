openui = openui or {}

--[[
function onbuysomething(pid,request,response)
	local player = playermgr.getplayer(pid)
	local answer = response.answer
	if answer == -1 then	-- close window
	elseif answer == 0 then -- timeout
	elseif answer == 1 then -- button 1
	elseif answer == 2 then -- button 2
	end
end

openui.messagebox(10001,{
				type = MB_LACK_CONDITION,
				title = "条件不足",
				content = "是否花费100金币购买:",
				buttons = {
					openui.button("确认"),
					openui.button("取消",10),
				},
				attach = {
					lackres = {
						silver = 1000,
						items = {
							{
								itemid = 14101,
								num = 3,
							},
							{
								itemid = 14201,
								num = 2,
							},
						},
					},
					costgold = 100,
					}}
				,onbuysomething)
--]]


function openui.messagebox(pid,request,callback)
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	local lang = player:getlanguage()
	local pack_request = {}
	pack_request.type = assert(request.type)
	if request.title then
		pack_request.title = assert(language.translateto(request.title))
	end
	if request.content then
		pack_request.content = assert(language.translateto(request.content))
	end
	if request.attach then
		pack_request.attach = cjson.encode(request.attach)
	end
	pack_request.buttons = {}
	local lang = player:getlanguage()
	for i,button in ipairs(request.buttons) do
		local content = button.content
		if type(content) == "table" then
			content = language.translateto(button.content,lang)
		end
		pack_request.buttons[i] = {
			content = content,
			timeout = button.timeout,
		}
	end
	local id = reqresp.req(pid,request,callback)
	pack_request.id = id
	sendpackage(pid,"msg","messagebox",pack_request)
	return id
end


function openui.button(content,timeout)
	return {
		content = content,
		timeout = timeout,
	}
end

-- 一些其他弹框杂项
-- 打造物品成功
function openui.produceequip_succ(pid,itemid)
	sendpackage(pid,"item","produceequip_succ",{
		itemid = itemid,
	})
end

return openui
