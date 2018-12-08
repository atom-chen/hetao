-------------------------
-- 新手指引
-------------------------
module("guide", package.seeall)

ClsGuideMgr = class("ClsGuideMgr", clsCoreObject)
ClsGuideMgr.__is_singleton = true

ClsGuideMgr:RegisterEventType("start_guide")
ClsGuideMgr:RegisterEventType("finish_guide")
ClsGuideMgr:RegisterEventType("step_changed")
ClsGuideMgr:RegisterEventType("reg_new_btn")

function ClsGuideMgr:ctor()
	clsCoreObject.ctor(self)
	--
	self.tAllGuideBtn = {}		--注册表
	self._CurGuideId = nil		--当前指引ID
	self._CurGuideCfg = nil
	self._CurStep = nil
	self._CurStepCfg = nil
	self.mCompGuidePanel = nil
	self._HistoryTbl = {}		--已经引导过的ID不再重复引导
	--
	g_EventMgr:AddListener(self, "LEAVE_SCENE", function(thisObj)
		self:PauseGuide()
		self:UnRegAll()
	end)
	g_EventMgr:AddListener(self, "ENTER_SCENE", function(thisObj)
		self:ResumeGuide()
	end)
end

function ClsGuideMgr:dtor()
	self:finish_guide()
end

--开始
function ClsGuideMgr:StartGuide(GuideId)
	if self._HistoryTbl[GuideId] then
		logger.error("启动引导失败：已经引导过该ID: "..GuideId) 
		return 
	end
	
	local GuideCfg = setting.T_guide_cfg.Guide[GuideId]
	if not GuideCfg then 
		assert(false, "启动引导失败：配置表中不存在该指引ID："..GuideId)
		return
	end
	
	if not GuideCfg.StepList or #GuideCfg.StepList <= 0 then
		assert(false, "启动引导失败：配置表中步骤数为0："..GuideId)
		return
	end
	
	if self._CurGuideId then 
		logger.error("启动引导失败：上一引导尚未结束: "..self._CurGuideId) 
		return 
	end
	
	if GuideCfg.CheckAPI and not GuideCfg.CheckAPI() then
		logger.error("启动引导失败：检查启动条件不通过: "..GuideId) 
		return 
	end
	
	self:DestroyTimer("tm_delay_start")
	if not ClsLayerManager.GetInstance():GetLayer(const.LAYER_GUIDE) then
		logger.drama("等待进入引导......", GuideId)
		self:CreateTimerDelay("tm_delay_start", 2, function()
			self:StartGuide(GuideId)
		end)
		return
	end
	
	--
	self._CurGuideId = GuideId
	self._CurGuideCfg = GuideCfg
	self:_SetCurStep(1)
	
	if not self:GetCurGuideBtn() then 
		self:FaltalError("启动引导失败：尚未注册指引按钮")
		return 
	end
	
	logger.drama("********************************")
	logger.drama("************开始指引************", self._CurGuideId)
	logger.drama("********************************")
	logger.dump(self._CurGuideCfg)
	
	self:CreateGuidePanel()
	
	self:FireEvent("start_guide", self._CurGuideId)
end

--到下一步
function ClsGuideMgr:ToNextStep()
	self:_SetCurStep(self._CurStep+1)
end

--跳到第N步
function ClsGuideMgr:_SetCurStep(CurStep)
	local GuideCfg = self._CurGuideCfg
	if CurStep > #GuideCfg.StepList then
		self:on_ouide_oinished()
		return
	end
	
	self._CurStep = CurStep
	local StepIndex = self._CurGuideCfg.StepList[self._CurStep]
	self._CurStepCfg = setting.T_guide_cfg.DetailStep[StepIndex]
	logger.printf( "设置当前引导步骤： %s", self:GetDebugStr() )
	assert(self._CurStepCfg, "未配置步骤："..CurStep)
	self:FireEvent("step_changed", self._CurStep)
end

--正常结束
function ClsGuideMgr:on_ouide_oinished()
	logger.drama("引导正常结束", self._CurGuideId)
	self._HistoryTbl[self._CurGuideId] = true
	self:finish_guide()
end

--中断结束
function ClsGuideMgr:BreakGuide()
	logger.drama("跳过引导", self._CurGuideId)
	self:finish_guide()
end

--出错结束
function ClsGuideMgr:FaltalError(ErrorMsg)
	logger.error("【出错结束】: ", ErrorMsg)
	logger.error(self:GetDebugStr())
	self:finish_guide()
end

--结束
function ClsGuideMgr:finish_guide()
	logger.drama("********************************")
	logger.drama("************结束指引************", self._CurGuideId)
	logger.drama("********************************")
	self:DestoryGuidePanel()
	self._CurGuideId = nil
	self._CurGuideCfg = nil
	self._CurStep = nil
	self._CurStepCfg = nil
	self:FireEvent("finish_guide", self._CurGuideId)
end

--暂停引导
function ClsGuideMgr:PauseGuide()
	self:DestoryGuidePanel()
end

--恢复引导
function ClsGuideMgr:ResumeGuide()
	if not self:IsGuiding() then return end
	self:CreateGuidePanel()
end

----------------------------------------------------------------------------

function ClsGuideMgr:GetDebugStr()
	return string.format("引导ID：%d  当前步骤：%d  总步骤数：%d", 
					self._CurGuideId, self._CurStep, #self._CurGuideCfg.StepList)
end

function ClsGuideMgr:CreateGuidePanel()
	self:DestroyTimer("tm_create_guidepanel")
	if not self:IsGuiding() then return end
	if self.mCompGuidePanel then return end
	
	local Parent = ClsLayerManager.GetInstance():GetLayer(const.LAYER_GUIDE)
	if not Parent then
		logger.drama("等待创建指引界面... ...", self._CurGuideId)
		self:CreateTimerDelay("tm_create_guidepanel", 1, function()
			self:CreateGuidePanel()
		end)
		return
	end
	
	self.mCompGuidePanel = clsGuidePanel.new(Parent)
end

function ClsGuideMgr:DestoryGuidePanel()
	KE_SafeDelete(self.mCompGuidePanel)
	self.mCompGuidePanel = nil
end

function ClsGuideMgr:IsGuiding() return self._CurGuideId ~= nil end
function ClsGuideMgr:GetCurGuideId() return self._CurGuideId end
function ClsGuideMgr:GetCurGuideCfg() return self._CurGuideCfg end
function ClsGuideMgr:GetCurStep() return self._CurStep end
function ClsGuideMgr:GetCurStepCfg() return self._CurStepCfg end

function ClsGuideMgr:GetCurGuideTbl()
	if not self:IsGuiding() then return end
	if not self:GetCurStepCfg() then return end
	local BtnName = self:GetCurStepCfg().Component
	if not self.tAllGuideBtn[BtnName] then 
		logger.error("尚未注册指引按钮：", BtnName, self:GetDebugStr()) 
	end
	return self.tAllGuideBtn[BtnName]
end

function ClsGuideMgr:GetCurGuideBtn()
	if not self:IsGuiding() then return end
	if not self:GetCurStepCfg() then return end
	local BtnName = self:GetCurStepCfg().Component
	local GuideTbl = self.tAllGuideBtn[BtnName]
	if not GuideTbl then return end
	local GuideBtn = GuideTbl.GuideBtn
	if tolua.isnull(GuideBtn) then 
		logger.drama("指引按钮已经释放：", BtnName)
		self:UnRegGuideBtn(BtnName)
		return 
	end
	return GuideBtn
end

function ClsGuideMgr:GetCurGuideCallback()
	if not self:IsGuiding() then return end
	if not self:GetCurStepCfg() then return end
	local BtnName = self:GetCurStepCfg().Component
	local GuideTbl = self.tAllGuideBtn[BtnName]
	if not GuideTbl then return end
	local GuideBtn = GuideTbl.GuideBtn
	if tolua.isnull(GuideBtn) then 
		logger.drama("指引按钮已经释放：", BtnName)
		self:UnRegGuideBtn(BtnName)
		return 
	end
	return GuideTbl._OnCallback
end

-- 注册指引按钮
function ClsGuideMgr:RegGuideBtn(BtnName, GuideBtn, OnCallback)
	if not setting.T_guide_cfg.Components[BtnName] then 
		logger.error( string.format("未配置该指引按钮：%s",BtnName) )
		return 
	end
	assert(GuideBtn and not tolua.isnull(GuideBtn), string.format("无效的按钮：%s",BtnName))
	assert(OnCallback==nil or is_function(OnCallback), string.format("指引回调必须为函数：%s",BtnName))
	logger.drama("注册指引按钮：", BtnName)
	
	self.tAllGuideBtn[BtnName] = {
		BtnName = BtnName, 
		GuideBtn = GuideBtn, 
		_OnCallback = OnCallback,
	}
	
	self:FireEvent("reg_new_btn", BtnName, GuideBtn)
end

-- 注销指引按钮
function ClsGuideMgr:UnRegGuideBtn(BtnName)
	self.tAllGuideBtn[BtnName] = nil
	logger.drama("移除指引按钮：", BtnName)
end

-- 注销所有指引按钮
function ClsGuideMgr:UnRegAll()
	self.tAllGuideBtn = {}
	logger.drama("移除所有指引按钮")
end

----------------------------------------------------------------------------

function RegGuideBtn(self, BtnName, GuideBtn, OnCallback)
	ClsGuideMgr.GetInstance():RegGuideBtn(BtnName, GuideBtn, OnCallback)
end

function UnRegGuideBtn(self, BtnName)
	ClsGuideMgr.GetInstance():UnRegGuideBtn(BtnName)
end

function StartGuide(self, GuideId)
	ClsGuideMgr.GetInstance():StartGuide(GuideId)
end
