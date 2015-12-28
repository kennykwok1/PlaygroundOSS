--主界面类，有选择菜单
--启动入口类
function setup()
	local x = 0
	local y = 0
	--执行uiform task
	local mainForm = UI_Form(nil,
		7000,
		x, y,
		"asset://StartGameView.json",
		false
	)
	--加载首页音乐
	mainMusic = SND_Open("asset://music/battle_bgmap_pvp",true)
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
-- 开始游戏按钮回调方法
function OnStartGame(sender,type)
	if type==3 then
		syslog("OnStartGame")
		sysLoad("asset://scripts/PlayView.lua")
	end
end
