--主界面类，有选择菜单
--启动入口类
function setup()
	local x = 0
	local y = 0
	--执行uiform task
	local mainForm = UI_Form(nil,
		7000,
		x, y,
		"asset://assets//UI_Main.json",
		false
	)
	--加载首页音乐
	mainMusic = SND_Open("asset://music/mainMainMusic",true)
	SND_Play(mainMusic)
	--指定舞台根点为form
	TASK_StageOnly(mainForm)
	--
end

--每帧执行的回调函数
function execute(deltaT)
end

--重新load其它lua时间的回调
function leave()
	--关闭音乐
	mainMusic = SND_Close(mainMusic)
	--清除舞台
	TASK_StageClear()
end

function onNewGameClick(tbl)
	syslog("onNewGameClick")
	sysLoad("asset://scripts/scenes/playscene.lua")
end

function onAboutClick(tbl)
	syslog("onAboutClick")
	sysLoad("asset://scripts/scenes/aboutscene.lua")
end
