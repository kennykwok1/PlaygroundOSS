--关于我们界面
--启动入口类
function setup()
	--构建界面元素，并显示
	local x = 0
	local y = 0
	--执行uiform task
	local mainForm = UI_Form(nil,
		7000,
		x, y,
		"asset://assets//UI_About.json",
		false
	)
	--指定舞台根点为form
	TASK_StageOnly(mainForm)
end

--每帧执行的回调函数
function execute(deltaT)
end

--重新load其它lua时间的回调
function leave()
	--清理舞台元素
	TASK_StageClear()
end

--return button
function onReturnClick()
	sysLoad("asset://scripts/scenes/mainscene.lua")
end