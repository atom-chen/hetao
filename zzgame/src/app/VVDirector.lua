-------------------------
-- 总管理中心
-- 全局变量在这里定义
-------------------------
VVDirector = {}

--生命周期为到APP结束
function VVDirector:Init()
	if self._isinited then return end
	self._isinited = true
	self.mResMgr = ClsResManager.GetInstance()				--资源管理器
	self.mCacheMgr = ClsCacheManager.GetInstance()			--本地缓存管理器
	self.mLayerMgr = ClsLayerManager.GetInstance()			--层管理器
	self.mSceneMgr = ClsSceneManager.GetInstance()			--场景管理器
	self.mUIMgr = ClsUIManager.GetInstance()				--UI管理器
	self.mWeatherMgr = ClsWeatherManager.GetInstance()		--天气系统
	if GAME_CONFIG.ENABLE_AI_MODULE then
		self.mBTFactory = ai.ClsBTFactory.GetInstance()		--AI Factory
	end
	
	g_EventMgr:AddListener("VVDirector", "ENTER_SCENE", function(thisObj, scene_name)
--		local filename = ClsSceneManager.GetInstance():GetCurSceneCfg().music
--		if filename and filename ~= "" then
--			AudioManager.PlayMusic(filename)
--		end
	end)
	g_EventMgr:AddListener("VVDirector", "LEAVE_SCENE", function(thisObj)
--		AudioManager.StopMusic(true)
	end)
end

-- 初始化数据
function VVDirector:InitDatas()
	self.mTipProcedure = smartor.clsPromise.new()
	guide.ClsGuideMgr.GetInstance()
	UserEntity.GetInstance()
	ClsAgentDataMgr.GetInstance()
	ClsBankMgr.GetInstance()
	ClsBetHistoryMgr.GetInstance()
	ClsRechargeRecoMgr.GetInstance()
	ClsTitleMgr.GetInstance()
	ClsWithdrawMgr.GetInstance()
	clsFindMgr.GetInstance()
--	ClsPlayerInfoMgr.GetInstance()
	clsActiveMgr.GetInstance()
	ClsCollectMgr.GetInstance()
	ClsRedbagMgr.GetInstance()
	
	ClsGameK3Mgr.GetInstance()
	ClsGameKL10Mgr.GetInstance()
	ClsGameLhcMgr.GetInstance()
	ClsGamePcddMgr.GetInstance()
	ClsGamePk10Mgr.GetInstance()
	ClsGameSscMgr.GetInstance()
	ClsGame11x5Mgr.GetInstance()
	ClsGameYbMgr.GetInstance()
	ClsGameMgr.GetInstance()
end

-- 清理数据
function VVDirector:ClearDatas()
	KE_SafeDelete(self.mTipProcedure) self.mTipProcedure = nil
	guide.ClsGuideMgr.DelInstance()
	
	UserEntity.DelInstance()
	ClsAgentDataMgr.DelInstance()
	ClsBankMgr.DelInstance()
	ClsBetHistoryMgr.DelInstance()
	ClsTitleMgr.DelInstance()
	ClsRechargeRecoMgr.DelInstance()
	ClsWithdrawMgr.DelInstance()
	clsFindMgr.DelInstance()
	ClsPlayerInfoMgr.DelInstance()
	clsActiveMgr.DelInstance()
	ClsCollectMgr.DelInstance()
	ClsRedbagMgr.DelInstance()
	
	ClsGameK3Mgr.DelInstance()
	ClsGameKL10Mgr.DelInstance()
	ClsGameLhcMgr.DelInstance()
	ClsGamePcddMgr.DelInstance()
	ClsGamePk10Mgr.DelInstance()
	ClsGameSscMgr.DelInstance()
	ClsGame11x5Mgr.DelInstance()
	ClsGameYbMgr.DelInstance()
	ClsGameMgr.DelInstance()
	
	UserDbCache.GetInstance():ClearTmpData()
end

function VVDirector:GetTipProcedure() return self.mTipProcedure end

function VVDirector:SyncServerTime(serverTime)
	
end

function VVDirector:GetServerTime()
	return os.time()
end

-----------------------------分割线---------------------------------------

function VVDirector:CreateNotificationNode()
	local noti_node = cc.Director:getInstance():getNotificationNode()
	if not noti_node then
		noti_node = cc.Node:create()
		cc.Director:getInstance():setNotificationNode(noti_node)
	end
	assert(cc.Director:getInstance():getNotificationNode(), "noti_node创建失败")
	return noti_node
end

