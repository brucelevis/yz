playunit_dati = playunit_dati or {}
huodongmgr.playunit.dati = playunit_dati

--[[
data 可配置参数
{
	questionid = 0,
	cnt = 1,
	maxcnt = 1,
	npcname = "",
	npcshape = 0,
	exceedtime = 0,
	questionbank = "data_1100_QuestionBank01",
}
]]--
function playunit_dati.opendati(pid,callback,data)
	local player = playermgr.getplayer(pid)
	if player.indati then
		return
	end
	local lifetime
	if data.exceedtime then
		lifetime = data.exceedtime + 10
	end
	local questionid = data.questionid or randlist(table.keys(data_1100_QuestionBank01))
	local request = {
		questionid = questionid,
		data = data,
		lifetime = lifetime,
		callback = callback,
	}
	local respondid = reqresp.req(pid,request,playunit_dati.responddati)
	net.playunit.S2C.opendati(pid,questionid,respondid,data)
	player.indati = { questionid = questionid, respondid = respondid, data = data }
	return questionid
end

function playunit_dati.responddati(pid,request,respond)
	local answer = respond.answer
	local callback =  request.callback
	local questionid = request.questionid
	local player = playermgr.getplayer(pid)
	if not player then
		return
	end
	player.indati = nil
	local result
	local questionbank = _G[request.data.questionbank]
	if not questionbank then
		questionbank  = data_1100_QuestionBank01
	end
	if answer == questionbank[questionid].right_answer then	-- 正确
		result = "yes"
		net.msg.S2C.notify(pid,language.format("回答正确"))
	elseif answer == -1 then
		result = "closed"
	elseif answer == 0 then
		result = "timeout"
	else	-- 错误
		net.msg.S2C.notify(pid,language.format("回答错误"))
		result = "no"
	end
	if callback then
		callback(player,result)
	end
end

function playunit_dati.generate_norepeat(num,questionbank)
	local questionbank = _G[questionbank] or data_1100_QuestionBank01
	local questions = shuffle(table.keys(questionbank),true,num)
	return questions
end

function playunit_dati.onlogin(player)
	if not player.indati then
		return
	end
	local respondid = player.indati.respondid
	if not reqresp.sessions[respondid] then
		player.indati = nil
		return
	end
	local data = player.indati.data
	local questionid = player.indati.questionid
	net.playunit.S2C.opendati(player.pid,questionid,respondid,data)
end

return playunit_dati
