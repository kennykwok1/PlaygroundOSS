--游戏界面类，操作飞机在里面飞行，用子弹打掉对应的飞机
--启动入口类
function setup()
	
	--初始化舞台相关信息 开始位置，地面左边，结束坐标的X，Y
	stageInf={startX= 0,groundY = 260,endX = 480,endY = 320}
	-- 初始化hero 宽 ，攻击距离 ，X方向移动速度, clickRunSts 标识是否按下方向键，direction标识
	-- 1 为 左 -1 为右 startPlayRunSts 为是否已经播放run 动画
	heroInf ={half_width =55,atkDistance= 200,runSpeedX=50,clickRunSts=false,direction=1
	,startPlayRunSts=false}
	-- 初始化 enemy宽，攻击距离，移动速度，工具频率，暂定每3秒攻击一次
	enemyInf ={half_width =50,atkDistance= 100,runSpeedX=20,atkRate=3}
	animationLayer = 7001

	--执行uiform task
	local mainForm = UI_Form(nil,
		7000,
		0, 0,
		"asset://GamePlayView.json",
		false
	)
	--加载首页音乐
	gameBGMusic = SND_Open("asset://music/battle_bgmap_pvp",true)
	SND_Play(gameBGMusic)
	--指定舞台根点为form
	TASK_StageOnly(mainForm)



	-- 生成hero的 swf 动画
	pHeroSWF = UI_SWFPlayer	(	mainForm, -- arg[1]:父容器
								animationLayer,-- arg[2]:所属层
								heroInf.half_width,stageInf.groundY, -- arg[3,4]:	表示位置
								"asset://hero.flsh",-- arg[5]:flash资源
								nil,    -- 动画名称
								"flash_callback"--播发完成后的回调
						 	)
	-- 注册idle动画播发结束回调
	registSwfEvt(pHeroSWF,"idle_loop","finishIdle_callback")
	-- 注册run动画播发结束回调
	registSwfEvt(pHeroSWF,"run_loop","finishRun_callback")

	-- 生成 enemy 的 swf 动画
	pEnemySWF = UI_SWFPlayer	(	mainForm, -- arg[1]:父容器
									animationLayer,-- arg[2]:所属层
									100,stageInf.groundY, -- arg[3,4]:	表示位置
									"asset://enemy.flsh",-- arg[5]:flash资源
									nil,    -- 动画名称
									"flash_callback"--播发完成后的回调
						 		)
	local prop = TASK_getProperty(pEnemySWF)
	prop.scaleX = -1
	-- 注册idle动画播发结束回调
	registSwfEvt(pEnemySWF,"idle_loop","finishIdle_callback")

end
-- 注册swf动画 事件
-- 参数1 为目标动画 参数2 为动画名称，参数3为回调函数
function registSwfEvt(target, animationName,callbackFunction )
	-- body
	sysCommand(target, UI_SWF_REACHFRAME, animationName, callbackFunction)
end
-- idle 动画部分完成回调，用于循环播放
function  finishIdle_callback( pSWF, label)
	sysCommand(pSWF, UI_SWF_GOTOFRAME, "idle")
	-- body
end
-- run 动画部分完成回调，用于循环播放
function  finishRun_callback( pSWF, label)
	sysCommand(pSWF, UI_SWF_GOTOFRAME, "run")
	-- body
end


-- flash 播发回调方法
function flash_callback(pSWF, label)
	if label == "" then
		syslog(string.format("[SWF]reach last frame."))
		sysCommand(pSWF, UI_SWF_GOTOFRAME, "idle")
	else
		
		syslog(string.format("[SWF]reach: <%s>", label))
	end
end



--每帧执行的回调函数F
-- deltaT单位为 毫秒
function execute(deltaT)
	-- 如果已经点击方向键，并且没有播放run动画
	if heroInf.clickRunSts == true 
		and heroInf.startPlayRunSts ==false then
		heroInf.startPlayRunSts = true
		local prop = TASK_getProperty(pHeroSWF)
		syslog("direction-->"..heroInf.direction)
		syslog("prop.scaleX-->"..prop.scaleX)
		for k,v in pairs(prop) do
			print(k,v)
		end


	-- 	if prop.scaleX ~=heroInf.direction  then
	-- 		prop.scaleX = heroInf.direction
	-- 		TASK_setProperty(pHeroSWF, prop)
	-- 	end
	-- 	local temp = TASK_getProperty(pHeroSWF)
	-- 	syslog("after--->"..temp.scaleX)

	-- 	playHeroRun()
	-- elseif heroInf.clickRunSts == true 
	-- -- 当已经播放过run 动画，开始更新hero 的位置
	-- 	and heroInf.startPlayRunSts ==true then
	-- 	local prop1 = TASK_getProperty(pHeroSWF)
	-- 	local increaseX= heroInf.runSpeedX  * deltaT  * heroInf.direction /1000
	-- 	syslog("increaseX--->"..increaseX)
	-- 	if prop1.x + increaseX < stageInf.endX 
	-- 	or prop1.x + increaseX > heroInf.half_width   then
	-- 	-- 当当前位置还在屏幕之内的话，更新位置
	-- 		prop1.x= prop1.x+ increaseX
	-- 		syslog("x--->"..prop1.x)
	-- 		TASK_setProperty(pHeroSWF, prop1)
	-- 	end
	end
end
--  点击攻击
--  1 为 press ，2为 release 3为 click
function onClickAtk(sender,type)
	-- 如果为点击
	if type==3 then
		--todo 发动攻击，播放攻击动画
		playHeroAtk()
	end
end
--  点击方向键左键
--  1 为 press ，2为 release 3为 click
function OnClickLeft(sender,type)
	-- 如果为点击
	if type==1 then
		--todo 发动攻击，播放run动画
		heroInf.clickRunSts=true
		heroInf.direction=-1
	elseif type==2 then
		--todo 如果为release 停止攻击，播放idle动画
		heroInf.clickRunSts=false
		playHeroIdle()
	end
end
--  点击方向键右键
--  1 为 press ，2为 release 3为 click
function OnClickRight(sender,type)
	-- 如果为点击
	if type==1 then
		--todo 发动攻击，播放run动画
		heroInf.clickRunSts=true
		heroInf.direction=1
	elseif type==2 then
		--todo 如果为release 停止攻击，播放idle动画
		heroInf.clickRunSts=false
		playHeroIdle()
	end
end

-- 点击返回按钮
function onClickReturn(sender,type)
	if type==3 then
		sysLoad("asset://scripts/startGameView.lua")
	end
end

-- 离开此界面时候的回调，用于释放资源
function leave()
	-- TASK_kill(gameBGMusic)
	-- TASK_kill(pHeroSWF)
	-- TASK_kill(pEnemySWF)
	--清理舞台元素
	TASK_StageClear()
end
-- 停止动画
function swfStop(pSWF)
	sysCommand(pSWF, UI_SWF_STOP)
	
end
-- 播放idel动画
function playHeroIdle()
	heroSwfPLAY("idle")
end
-- 播放奔跑动画
function playHeroRun()
	heroSwfPLAY("run")
end
-- 播放攻击动画
function playHeroAtk()
	heroSwfPLAY("atk")
end
--播发hero动画
function heroSwfPLAY(animationName)
	sysCommand(pHeroSWF, UI_SWF_GOTOFRAME, animationName)
end

-- 播放idel动画
function playEnemyIdle()
	enemySwfPLAY("idle")
end
-- 播放奔跑动画
function playEnemyRun()
	enemySwfPLAY("run")
end
-- 播放攻击动画
function playEnemyAtk()
	enemySwfPLAY("atk")
end
--播发enemy动画
function enemySwfPLAY(animationName)
	sysCommand(pEnemySWF, UI_SWF_GOTOFRAME, animationName)
end

