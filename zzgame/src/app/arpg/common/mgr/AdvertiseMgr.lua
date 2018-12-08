-------------------------
-- 宣传推荐管理器
-------------------------
ClsAdvertiseMgr = class("ClsAdvertiseMgr", clsCoreObject)
ClsAdvertiseMgr.__is_singleton = true

function ClsAdvertiseMgr:ctor()
	clsCoreObject.ctor(self)
	self.bHasCheckLoginAdver = false
	self._HistoryList = {}
end

function ClsAdvertiseMgr:dtor()

end

--登录宣传
function ClsAdvertiseMgr:CheckLoginAdver()
	if self.bHasCheckLoginAdver then return end
	self.bHasCheckLoginAdver = true
	if not VVDirector:GetTipProcedure() then return end
	
	local nextNode = VVDirector:GetTipProcedure()
	for _, info in ipairs(setting.T_advertise) do
		if info.login_checker() then
			logger.normal("推荐成立", info.Id, info.ImgPath)
			local procedure_1 = smartor.clsPromise.new(info)
			procedure_1:SetProcFunc(function(thisObj, Procedure)
				local ctx = Procedure:GetArgInfo()
				logger.normal("登录宣传", ctx.Id, ctx.ImgPath)
				Procedure:Done()
			end)
			nextNode = nextNode:SetNext(procedure_1)
		else 
			logger.normal("推荐失败", info.Id, info.ImgPath)
		end
	end
	VVDirector:GetTipProcedure():Run()
end

-- 条件宣传
function ClsAdvertiseMgr:CheckSpecAdver()
	if not VVDirector:GetTipProcedure() then return end
	local nextNode = VVDirector:GetTipProcedure()
	for _, info in ipairs(setting.T_advertise) do
		if not self._HistoryList[info.Id] and info.spec_checker() then
			self._HistoryList[info.Id] = true 
			
			local procedure_1 = smartor.clsPromise.new(info)
			procedure_1:SetProcFunc(function(thisObj, Procedure) 
				local privateData = Procedure:GetArgInfo()
				logger.normal("条件宣传", privateData.Id, privateData.ImgPath)
				Procedure:Done()
			end)
			nextNode = nextNode:SetNext(procedure_1)
			
			break
		end
	end
	VVDirector:GetTipProcedure():Run()
end

--服务端推图弹窗
function ClsAdvertiseMgr:CreatePushorWnd(info1)
	local parent = cc.Director:getInstance():getRunningScene()
	if not parent then return nil end
	
	local wnd = ui.clsBaseUI.new()
	wnd:SetModal(true, true, true)
	
	local bg = ccui.ImageView:create("uistu/common/bg_white.png")
	bg:setPosition(display.cx,display.cy)
	bg:setScale9Enabled(true)
	bg:ignoreContentAdaptWithSize(false)
	wnd:addChild(bg)
--	bg:setTouchEnabled(true)
			local title = ccui.ImageView:create("uistu/bg/web_dialog_bg.png")
			title:setAnchorPoint(cc.p(0.5,0))
			title:setScale9Enabled(true)
			bg:addChild(title)
			local labTitle = utils.CreateLabel("最新通知", 28)
			title:addChild(labTitle)
			title:setContentSize(600,title:getContentSize().height)
			labTitle:setPosition(title:getContentSize().width/2, 36)
	
	local labKnow = utils.CreateLabel("我知道了", 28, cc.c3b(233,35,23))
	bg:addChild(labKnow)
	labKnow:setPosition(600/2, 23)
	
	local htmlText = HtmlText.new( {
		color = cc.c3b(110,110,110),
		size = 24,
		fixWidth = 600,
	})
	htmlText:setAnchorPoint(0,0)
	htmlText:setVerticalSpace(8)
	htmlText:setPosition(0, 50)
	bg:addChild(htmlText)
	
	htmlText:setContentSize(600, 300)
	htmlText:setString(info1.content)
	
	bg:setContentSize( 600, 50+htmlText:getRealHeight() )
	title:setPosition(bg:getContentSize().width/2,bg:getContentSize().height)
	
	htmlText:setReRenderCallback(function()
		bg:setContentSize( 600, 50+htmlText:getRealHeight() )
		title:setPosition(bg:getContentSize().width/2,bg:getContentSize().height)
	end)
	
	parent:addChild(wnd, const.LAYER_POPWND)
	
	return wnd
end

local pre_user = false
--服务端推图弹窗
function ClsAdvertiseMgr:AddPushor(info1)
	if not info1.content or info1.content == "" then return end
	if not VVDirector:GetTipProcedure() then return end
	if pre_user and pre_user == UserEntity.GetInstance():Get_username() then return end
	pre_user = UserEntity.GetInstance():Get_username()
	
	local procedure_1 = smartor.clsPromise.new(info1)
	procedure_1:SetProcFunc(function(thisObj, Procedure) 
		local privateData = Procedure:GetArgInfo()
		local wnd = self:CreatePushorWnd(privateData)
		if wnd then
			wnd:AddScriptHandler(const.CORE_EVENT.exit, function()
				Procedure:Done()
			end)
		else
			Procedure:Done()
		end
	end)
	VVDirector:GetTipProcedure():SetNext(procedure_1)
	VVDirector:GetTipProcedure():Run()
end
