# 使用Klab PlaygroundOSS 制作一个格斗类型的游戏模型 
   1.由于没有美术资源，本demo当中的所有动画和资源都是程序员制作的，所有资源和动画不美观的地方还请放过

#游戏项目路径
**/PlaygroundOSS/Engine/porting/iOS/Project/actionGame**

#游戏截图
[开始游戏截图] https://github.com/kennykwok1/PlaygroundOSS/blob/master/Engine/porting/iOS/Project/actionGame/Screenshots/StartGameView.jpg


[游戏战斗界面截图] https://github.com/kennykwok1/PlaygroundOSS/blob/master/Engine/porting/iOS/Project/actionGame/Screenshots/GamePlayView.jpg

#游戏视频
[游戏视频链接，无音效，实际游戏是有音效的] http://v.youku.com/v_show/id_XMTQyNzI3MzY1Ng==.html

#Toboggan工程项目
**/playgroundoss/Tools/actionGame**


#游戏项目目录结构说明
* /start.lua------游戏入口
* /scripts/scenes/startGameView.lua ------主菜单的界面
* /scripts/scenes/PlayView.lua -------游戏界面，处理hero 和 enemy 相关的攻击，被击，跑动逻辑
* /scripts/utils/extern.lua     --------扩展lua类的用法
* /scripts/utils/BattleState.lua     --------lua的有限状态机实现
* /assets    --------资源目录
* /music     --------音乐和音效目录



#游戏编译和启动
1. 在mac环境下，使用xcode打开项目工程下的actionGame.xcodeproj
2. 编译这个工程，然后使用模拟器或真机来运行该项目，用IOS6或之上的版本模拟器启动运行。设计分辩率是480 * 320，在非480 * 320分辨率下，暂时不能全屏显示。
3. 开始游戏，使用方向键控制角色移动，攻击按钮控制角色攻击

# 使用当中遇到的问题
	1.无法打开包括文件:“SDKDDKVer.h”
	解决办法：在包含目录 和 引用目录 分别加入 $(WindowsSDK_IncludePath);和 $(WindowsSDK_LibraryPath_x86);
	2.使用Toboggan编辑器时遇到问题
	  1）编辑器对 net framework 要求 4.5以上，以及图片必须是png格式的。
	  2）图片资源需要放在根目录下（因为swf原因），并且创建texture，并且把碎图打包进去，才能成功publish资源。  
	  3）对swf 资源有一些规则要就比如 fla文件需要命名为*.flash.fla,fla 文件库中的元件需要导出为 *.png.imag，同时需要同名的*.png文件打包在texture中
	  以上三点任何一点不满足要就都不能成功publish。
