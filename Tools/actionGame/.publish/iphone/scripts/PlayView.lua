--游戏界面类，操作飞机在里面飞行，用子弹打掉对应的飞机
--启动入口类
function setup()
	-------------------------构建背景元素，并显示
	local bgx = 0
	local bgy = 0
	bgSimpleItem = UI_SimpleItem(	nil,							-- arg[1]:父容器
									7000,							-- arg[2]:所属层
									bgx, bgy,							-- arg[3,4]:	表示位置
									"asset://assets/bg01.png.imag"	-- arg[5]:资源
								)
	-------------------------处理我方飞机逻辑
	
	--播放背景音乐
	bgMusic =  SND_Open("asset://music/battle_bgmap_pvp",true)
	SND_Play(bgMusic)
	-------------------------处理子弹相关逻辑
	
	-------------------------------加入返回铵钮
	returnButtonItem = UI_SimpleItem(nil,							-- arg[1]:父容器
									8000,							-- arg[2]:所属层
									282, 0,							-- arg[3,4]:	表示位置
									"asset://assets/return_01.png.imag"	-- arg[5]:资源
								)
end


--每帧执行的回调函数
function execute(deltaT)
	
end


function onClick(x, y)
	syslog(string.format("Click (%i,%i)",x,y))
	if (x >= 282 and x <=320 and y>=0 and y <=32) then
		--点中返回按钮
		sysLoad("asset://scripts/scenes/mainscene.lua")
	end
end

-- 离开此界面时候的回调，用于释放资源
function leave()
	
end



