-------------------------
-- 场景管理器
-------------------------
ClsSceneManager = class("ClsSceneManager")
ClsSceneManager.__is_singleton = true

function ClsSceneManager:ctor()
	self._mCurScene = nil
	self._sCurSceneName = nil
	self._sPreSceneName = nil
	self.bSwitching = false
end

function ClsSceneManager:dtor()
	if self._mCurScene then
		self._mCurScene:OnDestroy()
	end
end

function ClsSceneManager:IsSwitching() return self.bSwitching end
function ClsSceneManager:GetCurScene() return self._mCurScene end
function ClsSceneManager:GetCurSceneName() return self._sCurSceneName end
function ClsSceneManager:GetPreSceneName() return self._sPreSceneName end
function ClsSceneManager:GetCurSceneCfg() return const.SCENE_CFG[self._sCurSceneName] end

function ClsSceneManager:RunScene(SceneObj)
	local theDirector = cc.Director:getInstance()
	if theDirector:getRunningScene() then
	    theDirector:replaceScene(SceneObj)
	else
	    theDirector:runWithScene(SceneObj)
	end
end

function ClsSceneManager:Turn2Scene(scene_name, OnLoadingOver)
	assert(not self.bSwitching, "禁止嵌套调用Turn2Scene")
	if self.bSwitching then return end
	self.bSwitching = true
	
	local sceneInfo = const.SCENE_CFG[scene_name]
	local scene_cls = sceneInfo.scene_cls
	
	-- 销毁旧场景资源
	self._sPreSceneName = self._sCurSceneName
	g_EventMgr:FireEvent("LEAVE_SCENE")
	ClsUIManager.GetInstance():DestroyAllWindow()
	if self._mCurScene then
		if self._mCurScene.OnDestroy then self._mCurScene:OnDestroy() end
		self._mCurScene:removeAllChildren()
	end
	
	--清理缓存，检查泄露
	local preSceneInfo = const.SCENE_CFG[self._sPreSceneName]
	if preSceneInfo and preSceneInfo.freemem then
		KE_GC_ENGINE()
		KE_GC_LUA()
		CheckMemoryLeak() 
	else
		KE_GC_LUA()
	end
	
	logger.printf( "切换场景: %s--->%s", self._sPreSceneName, scene_name )
	
	-- 创建新场景
	self._sCurSceneName = scene_name
	self._mCurScene = scene_cls.new()
	
	-- 运行新场景
	self:RunScene(self._mCurScene)
	
	if OnLoadingOver then OnLoadingOver() end
	self._mCurScene:OnLoadingOver()
	
	g_EventMgr:FireEvent("ENTER_SCENE", scene_name)
	utils.CheckWaiting()
	KE_CheckNetConnect(true)
	
	self.bSwitching = false
	
	return self._mCurScene
end
