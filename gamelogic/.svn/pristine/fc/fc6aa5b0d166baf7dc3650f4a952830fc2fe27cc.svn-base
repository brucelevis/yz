-- 任务
TASK_STATE_ACCEPT = 1 -- 接受
TASK_STATE_FINISH = 2 -- 完成

TASK_SCRIPT_SUSPEND = 1
TASK_SCRIPT_FINISH = 2
TASK_SCRIPT_FAIL = 3

TASK_PLAY_FINDNPC = 1
TASK_PLAY_FINDITEM = 2
TASK_PLAY_NPCWAR = 3
TASK_PLAY_NONPCWAR = 4

TASK_TYPE_NAME = {}
function settaskname(tasktype,name)
	TASK_TYPE_NAME[tasktype] = name
	TASK_TYPE_NAME[name] = tasktype
end
TASK_TYPE_MAIN		= 100 --主线
TASK_TYPE_BRANCH	= 101 --支线
TASK_TYPE_SHIMEN	= 102 --师门
TASK_TYPE_TEST		= 900 --测试
settaskname(TASK_TYPE_MAIN,"zhuxian")
settaskname(TASK_TYPE_BRANCH,"zhixian")
settaskname(TASK_TYPE_SHIMEN,"shimen")
settaskname(TASK_TYPE_TEST,"test")
