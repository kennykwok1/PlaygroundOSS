--程序启动入口类
--启动入口类
function setup()
	-- design resolution
	CONFIG_SCREEN_WIDTH  = 320
	CONFIG_SCREEN_HEIGHT = 480
	--
	GL_SetResolution(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
	--载入字体
	FONT_load("AlexBrush","asset://assets/AlexBrush-Regular-OTF.otf")
	--载入utils model
	syslog("begin require utils/functions")
	--注释掉require代码，以防使用没修改过的playgroundOSS来启动这个项目
	--require("utils/functions")
	--跳转到主界面
	syslog("begin enter scripts/scenes/mainscene.lua")
	sysLoad("asset://scripts/scenes/mainscene.lua")
end

--每帧执行的回调函数
function execute(deltaT)
	
end

--重新load其它lua时间的回调
function leave()
end