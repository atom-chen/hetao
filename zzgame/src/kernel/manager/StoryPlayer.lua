-------------------------
-- 剧情播放器
--
--[[
ClsStoryPlayer.GetInstance():PlayStory( 
			"test_story_1", 
			function(reason) logger.warn("播放完毕回调") end)
]]--
-------------------------
ClsStoryPlayer = class("ClsStoryPlayer")
ClsStoryPlayer.__is_singleton = true

function ClsStoryPlayer:ctor()
	self.mCurStory = nil
	self.sCurStoryName = nil
end

function ClsStoryPlayer:dtor()
	self:DestoryCurStory()
end

function ClsStoryPlayer:IsPlayingStory()
	return self.mCurStory ~= nil
end

function ClsStoryPlayer:PlayStory(sFileName, finishCallback)
	if self:IsPlayingStory() then 
		logger.drama("上一剧情尚未结束: ", self.sCurStoryName)
		return 
	end
	
	local StoryInfo = setting.GetStoryCfg(sFileName)
	assert(StoryInfo, "不存在该剧情文件："..sFileName)
	if not StoryInfo then return end
	
	self.sCurStoryName = sFileName
	self:PlayInfo(StoryInfo, finishCallback)
end

function ClsStoryPlayer:PlayInfo(StoryInfo, finishCallback)
	if self:IsPlayingStory() then 
		logger.drama("上一剧情尚未结束: ", self.sCurStoryName)
		return 
	end
	
	logger.drama("开始播放剧情: ", self.sCurStoryName)
	g_EventMgr:FireEvent("STORY_BEGIN", self.sCurStoryName)
	
	self:CreateStoryPanel()
	
	self.mCurStory = smartor.clsSmartTree.new()
	self.mCurStory:BuildByInfo(StoryInfo)
	if self.mCurStory:GetContext():HasAtomId("starman") then
		local hero = ClsRoleSprMgr.GetInstance():CreateHero()
		if hero then hero:EnterMap(520, 400) end
		self.mCurStory:GetContext():SetPerformer("starman", hero)
	end
	self.mCurStory:Play(function(reason) 
		logger.drama("剧情播放完毕: ", self.sCurStoryName)
		self:DestoryCurStory()
		if finishCallback then
			finishCallback(self.sCurStoryName, reason)
		end
	end)
end

--跳过剧情
function ClsStoryPlayer:BreakStory()
	if not self:IsPlayingStory() then return end
	logger.drama("跳过剧情：",self.sCurStoryName)
	self:DestoryCurStory()
end

function ClsStoryPlayer:DestoryCurStory()
	if self.mCurStory then
		KE_SafeDelete(self.mCurStory)
		self.mCurStory = nil 
	end
	local name = self.sCurStoryName
	self.sCurStoryName = nil
	
	self:DestoryStoryPanel()
	
	g_EventMgr:FireEvent("STORY_END", name)
end

function ClsStoryPlayer:CreateStoryPanel()
	if ClsUIManager.GetInstance():GetWindow("clsStoryPanel") then return end
	local panel = ClsUIManager.GetInstance():ShowView("clsStoryPanel")
	utils.RegClickEvent(panel:GetComp("btn_break"), function()
		KE_SetTimeout(1,function() self:BreakStory() end)
	end)
end

function ClsStoryPlayer:DestoryStoryPanel()
	ClsUIManager.GetInstance():DestroyWindow("clsStoryPanel")
end
