-------------------------
-- 游戏状态机
-------------------------
local FSM_NONE = "初始"
local FSM_LOGIN = "登录"
local FSM_GAMING = "游戏中"
local FSM_PAUSE = "暂停"
local FSM_EXITAPP = "结束"

local FROM_TABLE = {
	[FSM_NONE] 		= {},
	[FSM_LOGIN] 	= { [FSM_NONE]  = true, [FSM_GAMING] = true, [FSM_PAUSE] = true  },
	[FSM_GAMING] 	= { [FSM_PAUSE] = true, [FSM_LOGIN]  = true  },
	[FSM_PAUSE] 	= { [FSM_LOGIN] = true, [FSM_GAMING] = true  },
	[FSM_EXITAPP] 	= { [FSM_PAUSE] = true  },
}

----------------------------------------------------------

ClsStateMachine = class("ClsStateMachine")
ClsStateMachine.__is_singleton = true

function ClsStateMachine:ctor()
	self._curState = FSM_NONE
end

---------------------
-- 流程
---------------------
function ClsStateMachine:_CanToState(toState)
	if not FROM_TABLE[toState][self._curState] then
		logger.warn(string.format("【警告】从状态【%s】转换到状态【%s】",self._curState,toState))
	end
	logger.normal(string.format("状态机：%s ---> %s",self._curState,toState))
	return true
end

--退出程序
function ClsStateMachine:_exit_app()
	self._curState = FSM_EXITAPP
	logger.warn("状态机: ToStateExitApp")
--	if self.game then KE_SafeDelete(self.game) self.game = nil end
--	redpoint.ClsRedPointMgr.GetInstance():StopWork()
--	VVDirector:ClearDatas()
--	ClsSceneManager.GetInstance():GetCurScene():removeAllChildren()
--	KE_SetTimeout(100, function()
		ClsApp.GetInstance():Exit()
--	end)
end

--退出APP
function ClsStateMachine:ConfirmExitApp()
	self:ToStatePause()
end

--双击返回键退出APP
function ClsStateMachine:AskExitApp()
	if self._tmr_exit then
		self:_exit_app()
	end
	self._tmr_exit = KE_SetAbsTimeout(2, function()
		self._tmr_exit = nil
	end)
	utils.TellMe("再按一次退出", 2)
end

---------------------------------------------------------

--启动
function ClsStateMachine:StartUp()
	logger.warn("\n \n \n*****************************************")
	logger.warn("状态机: 启动")
	ClsLoginMgr.GetInstance()
	self:ToStateLogin()
end

--登录
function ClsStateMachine:ToStateLogin()
	if not self:_CanToState(FSM_LOGIN) then return false end
	self._curState = FSM_LOGIN
	--
	redpoint.ClsRedPointMgr.GetInstance():StopWork()
	if self.game then KE_SafeDelete(self.game) self.game = nil end
	VVDirector:ClearDatas()
	--
	VVDirector:InitDatas()
	--
	ClsSceneManager.GetInstance():Turn2Scene("clsHallScene")
    --ClsSceneManager.GetInstance():Turn2Scene("clsEquipment")
	if not ClsLoginMgr.GetInstance():QuickLogon() then
		proto.req_get_game_article_content({id="68"})
	end
end

--重新登录 
function ClsStateMachine:ReLogin()
	if not self:_CanToState(FSM_LOGIN) then return false end
	self._curState = FSM_LOGIN
	--
	redpoint.ClsRedPointMgr.GetInstance():StopWork()
	if self.game then KE_SafeDelete(self.game) self.game = nil end
	VVDirector:ClearDatas()
	--
	VVDirector:InitDatas()
	--
	ClsSceneManager.GetInstance():Turn2Scene("clsHallScene")
	if not ClsLoginMgr.GetInstance():IsLogout() then
		ClsUIManager.GetInstance():ShowPopWnd("clsLoginUI4")
	end
end

--进入游戏
function ClsStateMachine:ToStateGameing()
	if not self:_CanToState(FSM_GAMING) then return false end
	self._curState = FSM_GAMING
	
--	if ClsSceneManager.GetInstance():GetCurSceneName() ~= "clsHallScene" then
--		ClsSceneManager.GetInstance():Turn2Scene("clsHallScene")
--	end
--	KE_SetTimeout(3,function()
--		ClsAdvertiseMgr.GetInstance():CheckLoginAdver()
--		redpoint.ClsRedPointMgr.GetInstance():StartWork()
--	end)
	if self.game then 
		KE_SafeDelete(self.game) 
		self.game = nil 
	end
	self.game = clsGame.new()
end

--暂停游戏
function ClsStateMachine:ToStatePause()
	if not self:_CanToState(FSM_PAUSE) then return false end
	self._preState = self._curState
	self._curState = FSM_PAUSE
	
	if self.game then self.game:PauseGame() end
	
	local function callback(mnuId) 
		if mnuId == 1 then
			self:_exit_app() 
		else
			self:Resume()
		end
	end
	ClsUIManager.GetInstance():PopConfirmDlg("CFM_EXITAPP", "退出游戏", "您确定退出游戏？", callback)
end

--恢复游戏
function ClsStateMachine:Resume()
	if not self:_CanToState(self._preState) then return false end
	self._curState = self._preState
	if self.game then self.game:ResumeGame() end
end
