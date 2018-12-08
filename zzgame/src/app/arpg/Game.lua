------------------
-- 控制游戏进程
------------------
clsGame = class("clsGame")

function clsGame:ctor()
--	self._mEffectMgr = ClsEffectMgr.GetInstance()				--特效管理器
--	self._mStoryPlayer = ClsStoryPlayer.GetInstance()			--剧情播放器
end

function clsGame:dtor()
--	self._mStoryPlayer = ClsStoryPlayer.DelInstance()
--	self._mEffectMgr = ClsEffectMgr.DelInstance()
end

function clsGame:PauseGame()
	
end

function clsGame:ResumeGame()
	
end
