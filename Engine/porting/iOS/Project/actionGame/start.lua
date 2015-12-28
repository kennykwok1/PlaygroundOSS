
function setup()
	--载入lua模拟class 模块 以及dump信息的方法
	--require("extern") 暂时注掉，载入在现有的Engine中暂时不能使用
	--以后有时间再对其进行扩展

	-- design resolution
	CONFIG_SCREEN_WIDTH  = 480
	CONFIG_SCREEN_HEIGHT = 320
	--
	GL_SetResolution(CONFIG_SCREEN_WIDTH, CONFIG_SCREEN_HEIGHT)
	
	

end

function execute(deltaT)
	--跳转到主界面
	syslog("enter start game view")
	sysLoad("asset://scripts/startGameView.lua")
	
end

function leave()

end
