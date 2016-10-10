--<<data_RoCenterSrvList 导表开始>>
data_RoCenterSrvList = {

	accountcenter = {
		srvname = "accountcenter",
		showsrvname = "内网账号中心",
		ip = "192.168.1.244",
		inner_ip = "192.168.1.244",
		cluster_port = 0,
		cluster_zone = "inner",
		openday = "42537",
		closeday = "",
		db = {host="192.168.1.244",port=6371,db=0},
		purpose = "内网测试",
		machine_name = "",
		machine_type = "虚拟机",
	},

	datacenter = {
		srvname = "datacenter",
		showsrvname = "内网数据中心",
		ip = "192.168.1.244",
		inner_ip = "192.168.1.244",
		cluster_port = 3020,
		cluster_zone = "inner",
		openday = "42537",
		closeday = "",
		db = {host="192.168.1.244",port=6370,db=0},
		purpose = "内网测试",
		machine_name = "",
		machine_type = "虚拟机",
	},

	accountcenter_test = {
		srvname = "accountcenter_test",
		showsrvname = "外网测试服账号中心",
		ip = "106.75.137.23",
		inner_ip = "10.13.57.252",
		cluster_port = 0,
		cluster_zone = "test",
		openday = "42636",
		closeday = "",
		db = {host="10.13.57.252",port=6371,db=0},
		purpose = "内网测试",
		machine_name = "",
		machine_type = "ucloud",
	},

	datacenter_test = {
		srvname = "datacenter_test",
		showsrvname = "外网测试服数据中心",
		ip = "106.75.137.23",
		inner_ip = "10.13.57.252",
		cluster_port = 3020,
		cluster_zone = "test",
		openday = "42636",
		closeday = "",
		db = {host="10.13.57.252",port=6370,db=0},
		purpose = "内网测试",
		machine_name = "",
		machine_type = "ucloud",
	},

}
return data_RoCenterSrvList
--<<data_RoCenterSrvList 导表结束>>