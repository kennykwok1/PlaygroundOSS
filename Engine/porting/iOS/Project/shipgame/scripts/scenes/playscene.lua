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
	--初始化飞机，飞机坐标默认值
	local shipinitX = 160
	local shipinitY = 420
	--我方飞机坐标
	shipX = shipinitX
	shipY = shipinitY
	--我方飞机sprite frame(quick cocos2dx的概念)
	local shipAssetList = {
		"asset://assets/ship_01.png.imag",
		"asset://assets/ship_02.png.imag",
		"asset://assets/ship_03.png.imag"
	}
	shipMultiItem = UI_MultiImgItem( nil, 8000, shipinitX, shipinitY, shipAssetList, 0)
	--给飞船加动画效果，每100毫秒变化一张图片
	spriteFrameIndex = 0
	pIT0 = UTIL_IntervalTimer(0, "aniShip", 100, true)
	isFling = false
	--定义拖动回调的task
	shipControl = UI_Control( "onClick", "onDrag")
	--播放背景音乐
	bgMusic = SND_Open("asset://music/bgMusic",true)
	SND_Play(bgMusic)
	-------------------------处理子弹相关逻辑
	runTimer = true
	--子弹速度 单位是p/每帧
	bulletMeta = {asset = "asset://assets/bullet_01.png.imag", width = 14, height = 62}
	bulletSpeed = 15
	shipFireIT1 = UTIL_IntervalTimer(1, "shipFire", 1000/6, true)
	--子弹任务列表
	bullets = {}
	-------------------------处理最上的一排菜单，飞机数量，积分还有返回按钮
	shipPrepare = UI_SimpleItem(	nil,							-- arg[1]:父容器
									8000,							-- arg[2]:所属层
									0, 0,							-- arg[3,4]:	表示位置
									"asset://assets/ship_01.png.imag"	-- arg[5]:资源
								)
	pLabel = UI_Label 	(
							nil, 			-- <parent pointer>, 
							8000, 			-- <order>, 
							110,0,		-- <x>, <y>,
                            0xFF, 0xFFFFFF,	-- <alpha>, <rgb>, 
							"Heiti SC",	-- "<font name>", 
							32,				-- <font size>, 
							"game score:"	-- "<text string>"
						)
	--得分牌
	local texTable = {
		"asset://assets/Score-0.png.imag",
		"asset://assets/Score-1.png.imag",
		"asset://assets/Score-2.png.imag",
		"asset://assets/Score-3.png.imag",
		"asset://assets/Score-4.png.imag",
		"asset://assets/Score-5.png.imag",
		"asset://assets/Score-6.png.imag",
		"asset://assets/Score-7.png.imag",
		"asset://assets/Score-8.png.imag",
		"asset://assets/Score-9.png.imag"
	}
	pSCORE = UI_Score(	nil	,				-- arg[1]	
						8000,				-- arg[2]	
						10,					-- arg[3]	
						205, 0,				-- arg[4,5]	
						texTable,			-- arg[6]	
						9, 0,		-- arg[7,8]	
						6,					-- arg[9]	
						true,			-- arg[10]	
						false				-- arg[11]	
						)
	sysCommand(pSCORE, UI_SCORE_ALIGN, SCORE_ALIGN_LEFT)
	gameScore = 0
	--------------------------------敌机信息
	--敌机的一些配置数据
	enemyMeta = {
		{asset = "asset://assets/enemy_01.png.imag", width = 80, height = 43, speed = 0.9},
		{asset = "asset://assets/enemy_02.png.imag", width = 60, height = 37, speed = 0.8},
		{asset = "asset://assets/enemy_03.png.imag", width = 45, height = 25, speed = 1.3},
		{asset = "asset://assets/enemy_04.png.imag", width = 54, height = 30, speed = 1.4},
		{asset = "asset://assets/enemy_05.png.imag", width = 53, height = 41, speed = 2}
	}
	--敌机列表
	enemies = {}
	enemyComingIT3 = UTIL_IntervalTimer(3, "enemyComming", 20, false)
	enemyComingIT4 = UTIL_IntervalTimer(4, "enemyComming", 600, true)
	--设定随机种子
	math.randomseed(tostring(os.time()):reverse():sub(1, 6))
	-------------------------------加入返回铵钮
	returnButtonItem = UI_SimpleItem(nil,							-- arg[1]:父容器
									8000,							-- arg[2]:所属层
									282, 0,							-- arg[3,4]:	表示位置
									"asset://assets/return_01.png.imag"	-- arg[5]:资源
								)
end


--每帧执行的回调函数，处理子弹飞行，和敌机被击中，以及分数变化
function execute(deltaT)
	--处理子弹和敌机的自然消亡
	--采用从后往前遍历的方式，可以在lua table的遍历方法的直接删除table中的某个元素
	for i = #bullets, 1, -1 do
		--处理子弹飞行
		local bullet = bullets[i]
		bulletFly(bullet)
		local bulletProps = TASK_getProperty(bullet.task)
		if bulletProps.y <= 0 - bullet.meta.height then
			--子弹自燃消亡
			table.remove(bullets, i)
			TASK_kill(bullet.task)
		end
	end
	for i = #enemies, 1, -1 do
		local enemy = enemies[i]
		enemyFly(enemy)
		local props = TASK_getProperty(enemy.task)
		if props.y >= CONFIG_SCREEN_HEIGHT then
			table.remove(enemies, i)
			TASK_kill(enemy.task)
		end
	end
	--处理子弹和敌机碰撞
	for i = #bullets, 1, -1 do
		local bullet = bullets[i]
		for j = #enemies, 1, -1 do
			local enemy = enemies[j]
			--
			if intersectCheck(enemy, bullet) then
				--如果子弹和敌机碰撞，处理碰撞
				table.remove(enemies, j)
				TASK_kill(enemy.task)
				--
				table.remove(bullets, i)
				TASK_kill(bullet.task)
				--处理计分，每打一个飞机，计100分
				updateGameScore(100)
				break
			end
		end
	end
end

--子弹和敌机的碰撞检测
function intersectCheck(enemy, bullet)
	local enemyProps = TASK_getProperty(enemy.task)
	local bulletProps = TASK_getProperty(bullet.task)
	--
	local enemyMinX = enemyProps.x
	local enemyMaxX = enemyProps.x + enemy.meta.width - 1
	local enemyMinY = enemyProps.y
	local enemyMaxY = enemyProps.y + enemy.meta.height - 1
	--
	local bulletMinX = bulletProps.x
	local bulletMaxX = bulletProps.x + bullet.meta.width - 1
	local bulletMinY = bulletProps.y
	local bulletMaxY = bulletProps.y + bullet.meta.height - 1
	local isIntersect = (enemyMaxX < bulletMinX) or (bulletMaxX < enemyMinX) or (enemyMaxY < bulletMinY) or (bulletMaxY < enemyMinY)
	if not isIntersect then
		return true
	else
		return false
	end
end

function onDrag(mode, x, y, mvX, mvY)
	syslog(string.format("Drag - %i - (%i,%i) - mv : (%i,%i)",mode,x,y,mvX,mvY))
	if mode == PAD_ITEM_RELEASE then
		isFling = false
		beginX = 0
		beginY = 0
	elseif mode == PAD_ITEM_DRAG then
		if not isFling then
			isFling = true
			beginX = x
			beginY = y
		end
		local deltaX = x - beginX
		local deltaY = y - beginY
		syslog(string.format("Drag deltaX,deltaY:(%i,%i)", deltaX, deltaY))
		local shipMultiItemProps = TASK_getProperty(shipMultiItem)
		shipX = shipX + deltaX
		shipY = shipY + deltaY
		--处理坐标边标
		shipX = math.min(CONFIG_SCREEN_WIDTH - 60, shipX)
		shipX = math.max(0, shipX)
		--
		shipY = math.min(CONFIG_SCREEN_HEIGHT - 42, shipY)
		shipY = math.max(0,shipY)
		shipMultiItemProps.x = shipX
		shipMultiItemProps.y = shipY
		TASK_setProperty(shipMultiItem, shipMultiItemProps)
		--
		beginX = x
		beginY = y
	end
end

--使用自动轮播，使飞机动画化，飞机也可以使用swfplayer任务。这边我就图简单，没去做flash了
function aniShip(timerId)
	spriteFrameIndex = spriteFrameIndex + 1
	spriteFrameIndex = spriteFrameIndex % 3
	sysCommand(shipMultiItem, UI_MULTIIMG_SET_INDEX, spriteFrameIndex)
end

--处理飞船开火
function shipFire(timerId)
	--默认位置
	local offset = 13
	--左边加农炮打的
	local bulletLeftX, bulletLeftY = shipX + 11, shipY - 50
	local bullet = UI_SimpleItem(nil, 8000, bulletLeftX, bulletLeftY, bulletMeta.asset)
	table.insert(bullets, {task = bullet, meta = bulletMeta})
	--右边加农炮打的
	local bulletRightX, bulletRightY = shipX + 35, shipY - 50
	local bulletOther = UI_SimpleItem(nil, 8000, bulletRightX, bulletRightY, bulletMeta.asset)
	table.insert(bullets, {task = bulletOther, meta = bulletMeta})
end

--处理敌机掉落
function enemyComming()
	local enemyIndex = math.random(5)
	local meta = enemyMeta[enemyIndex]
	local beginX = math.random(320 - meta.width + 1)
	local beginY = 0 - meta.height
	local enemyTask = UI_SimpleItem(nil, 8000, beginX, beginY, meta.asset)
	table.insert(enemies, {task = enemyTask, meta = meta})
end

--这个方法每帧都会跑到,处理子弹飞行
function bulletFly(bullet)
	local props = TASK_getProperty(bullet.task)
	props.y = props.y - bulletSpeed
	TASK_setProperty(bullet.task, props)
end

--这个方法每帧都会跑到,，处理敌机飞行
function enemyFly(enemy)
	local props = TASK_getProperty(enemy.task)
	props.y = props.y + enemy.meta.speed
	TASK_setProperty(enemy.task, props)
end

--更新分数
function updateGameScore(score)
	gameScore = gameScore + score
	sysCommand(pSCORE, UI_SCORE_SET, gameScore)
end


function onClick(x, y)
	syslog(string.format("Click (%i,%i)",x,y))
	if (x >= 282 and x <=320 and y>=0 and y <=32) then
		--点中返回按钮
		sysLoad("asset://scripts/scenes/mainscene.lua")
	end
end

--重新load其它lua时间的回调
function leave()
	SND_Close(bgMusic)
	--关闭所有的定时器任务
	TASK_kill(pIT0)
	TASK_kill(shipFireIT1)
	TASK_kill(enemyComingIT4)
	--关闭界面显示元素
	TASK_kill(bgSimpleItem)
	TASK_kill(shipMultiItem)
	TASK_kill(shipControl)
	TASK_kill(shipPrepare)
	TASK_kill(pLabel)
	TASK_kill(pSCORE)
	TASK_kill(returnButtonItem)
	--清理舞台元素
	TASK_StageClear()
	for i = #bullets, 1, -1 do
		TASK_kill(bullets[i].task)
	end
	--
	for i = #enemies, 1, -1 do
		TASK_kill(enemies[i].task)
	end
end



