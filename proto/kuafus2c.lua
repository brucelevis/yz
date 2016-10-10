return {
	p = "kuafu",
	si = 1500, -- [1500,2000)
	src = [[

.SrvType {
	srvname 0 : string			# 服务器唯一标识
	showsrvname 1 : string		# 显示的服务器名字
	srvno 2 : integer			# 服务器编号（仅用来显示排序)
	ip 3 : string				# ip
	port 4 : integer			# 端口
	zonename 5: string			# 区名唯一标识
	showzonename 6: string		# 显示的区名
}

kuafu_srvlist 1500 {
	request {
		base 0 : basetype
		srvlist 1 : *SrvType
		now_srvname 2 : string		# 当前服务器
		home_srvname 3 : string		# 原服
	}
}
]]
}
