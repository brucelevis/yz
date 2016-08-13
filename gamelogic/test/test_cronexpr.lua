local function test()
	local date = os.date("*t",os.time({year=2016,month=7,day=10,hour=10,min=35,sec=25}))
	pprintf("date:%s",date)
	local cron = cronexpr.new("* 40 * * * *")
	local nexttime,nextdate = cronexpr.nexttime(cron,date)
	-- {year=2016,month=7,day=10,hour=10,min=40,sec=0}
	pprintf("%s\n",nextdate)
	assert(nextdate.hour == 10 and nextdate.min==40 and nextdate.sec==0)
	local cron = cronexpr.new("* 20 * * * *")
	local nexttime,nextdate = cronexpr.nexttime(cron,date)
	-- {year=2016,month=7,day=10,hour=11,min=20,sec=0}
	pprintf("%s\n",nextdate)
	assert(nextdate.hour==11 and nextdate.min==20 and nextdate.sec==0)
	-- sec min hour dom mon dow
	local cron = cronexpr.new("3 0-18/2 2-16/3 2,4,6,8 1-12/2 1,2,3")
	local nexttime,nextdate = cronexpr.nexttime(cron,date)
	-- 2016/7/11 是星期一
	-- {year=2016,month=7,day=11,hour=2,min=0,sec=3}
	pprintf("%s\n",nextdate)
	assert(nextdate.year == date.year and
		nextdate.month == date.month and
		nextdate.day == 11 and
		nextdate.hour == 2 and
		nextdate.min == 0 and
		nextdate.sec == 3)
end

return test
