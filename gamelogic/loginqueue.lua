require "gamelogic.playermgr"

loginqueue = loginqueue or {}

function loginqueue.init()
	loginqueue.queue = {}
end

--@param table linkobj  {fd=连线ID,roleid=角色ID}
function loginqueue.push(linkobj,pos)
	logger.log("info","loginqueue",format("[push] linkobj=%s pos=%s",linkobj,pos))
	if pos then
		table.insert(loginqueue.queue,pos,linkobj)
	else
		table.insert(loginqueue.queue,linkobj)
	end
end

function loginqueue.pop()
	if loginqueue.len() > 0 then
		local linkobj = table.remove(loginqueue.queue,1)
		local fd,roleid = linkobj.fd,linkobj.roleid
		local obj = playermgr.getlinkobjbyfd(fd)
		logger.log("info","loginqueue",format("[pop] linkobj=%s",linkobj),obj)
		if obj then
			local player = playermgr.recoverplayer(roleid)
			playermgr.transfer_mark(obj,player)
			playermgr.nettransfer(obj,player)
			player:entergame()
		end
	end
end

function loginqueue.remove(pid)
	for i,v in ipairs(loginqueue.queue) do
		if v.pid == pid then
			table.remove(loginqueue.queue,i)
			break
		end
	end
end

function loginqueue.len()
	return #loginqueue.queue
end

return loginqueue
