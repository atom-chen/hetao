-------------------------
-- 充值
-------------------------
module("ui", package.seeall)

clsRechargeScan = class("clsRechargeScan", clsBaseUI)
clsRechargeScan._cache_data = ""

function clsRechargeScan:ctor(parent, param)
	clsBaseUI.ctor(self, parent, "uistu/RechargeScan.csb")
	self._commitet = false
	
	self._param = {
		id = param.info2.id,
		from_way = const.FROMWAY,
		code = param.info2.code,
		money = param.money,
	}
	
	utils.RegClickEvent(self.BtnClose, function() 
		if self._commitet then
			self:removeSelf()
		else
			ClsUIManager.GetInstance():PopConfirmDlg("CFM_CANCEL_PAY", "提示", "您的充值未完成，是否放弃充值？", function(mnuId)
				if mnuId == 1 then
					self:removeSelf()
				end
			end) 
		end
	end)
	utils.RegClickEvent(self.BtnSure, function()
		if self.forbitCommit then 
			self:removeSelf() 
			g_EventMgr:FireEvent("RechargeOver")
			return 
		end
		proto.req_pay_commit(self._param)
	end)
	utils.RegClickEvent(self.BtnScan, function()
		self:SaveQrAndJumpToWeixin()
	end)
	
	self.qrImg = ccui.ImageView:create()
	self.qrImg:SetMaxSize(320,320)
	self:addChild(self.qrImg)
	self.qrImg:SetLoadedCallback(function()
		if utils.IsValidCCObject(self) then
			self._qrImgLoaded = true
		end
	end)
	self.qrImg:LoadTextureSync(param.info2.qrcode)
	self.qrImg:setAnchorPoint(cc.p(0.5,0.5))
	self.qrImg:setPosition(360,self.AreaAuto:getContentSize().height-178)
	
	self.qrImg:setTouchEnabled(true)
	local function touchEvent(sender, eventType)
		if eventType == ccui.TouchEventType.ended then 
			self:SaveQrAndJumpToWeixin()
		end 
	end
	self.qrImg:addTouchEventListener(touchEvent)
	
	
--	if device.platform ~= "windows" then
--    	local webView = ccexp.WebView:create()
--    	self:addChild(webView)
--    	webView:setContentSize(720,530)
--    	webView:setAnchorPoint(cc.p(0,0))
--    	webView:setPosition(0,0)
--    	self._web_view = webView
--	else
		self.htmlText = ScrollHtmlText.new( {
			width = 680,
			height = self.BtnScan:getPositionY()-40,
			color = cc.c3b(88,88,88),
			size = 28,
		})
		self.htmlText:setVerticalSpace(8)
		self.htmlText:setPosition(20,0)
		self:addChild(self.htmlText)
--	end
    
    self.lblAccountNum:setString(param.name or "")
    self.lblChargeMoney:setString(param.money .. "元")
    
    g_EventMgr:AddListener(self, "on_req_pay_commit", function(this, recvdata)
    	self._commitet = true
    	local data = recvdata and recvdata.data
		if data then
			g_EventMgr:FireEvent("RechargeOver")
			self:removeSelf()
		end
    end)
    
    self:LoadUrlData(clsRechargeScan._cache_data)
    
    KE_SetTimeout(2, function()
    	PlatformHelper.CheckCamera()
    end)
end

function clsRechargeScan:dtor()
	
end

function clsRechargeScan:TellForbit()
	self.forbitCommit = true
end

function clsRechargeScan:RefleshQRCode(imgpath)
	self.qrImg:LoadTextureSync(imgpath)
end

function clsRechargeScan:quitListener()
	if self._commitet then
		self:removeSelf()
		return
	end
	ClsUIManager.GetInstance():PopConfirmDlg("CFM_LEAVE_PLAY", "提示", "您的充值未完成，是否放弃充值？", function(mnuId)
		if mnuId == 1 then
			self:removeSelf()
		end
	end)
end

function clsRechargeScan:LoadUrlData(data)
	clsRechargeScan._cache_data = data
--	if self._web_view then self._web_view:loadHTMLString(data or "") end
	if self.htmlText then self.htmlText:setString(data or "") end
end

function clsRechargeScan:SaveQrAndJumpToWeixin()
	if not self._qrImgLoaded then
		utils.TellMe("请等待二维码刷新完毕")
		return
	end
	local function afterCaptured(bSucc, outFile)
		print("截屏成功：", outFile)
		if bSucc then
			SalmonUtils:saveImageToPhotos(function(bFlag)
				if bFlag == "failed" then
					KE_SetTimeout(1, function() utils.TellMe("保存截图失败，请重试或尝试手动截屏") end)
					return
				elseif bFlag == "success" then
					KE_SetTimeout(1, function() utils.TellMe("保存截图成功，请打开扫一扫进行支付") end)
				end
				if device.platform == "android" then
					KE_SetTimeout(1, function() SalmonUtils:openAnotherApp("com.tencent.mm", "微信") end)
				elseif device.platform == "ios" and SalmonUtils.openWeixin then
					KE_SetTimeout(1, function() SalmonUtils:openWeixin() end)
				end
			end, outFile)
		else
			KE_SetTimeout(1, function() utils.TellMe("截图失败，请重试或尝试手动截屏") end)
		end
	end
	cc.utils:captureScreen(afterCaptured, "wx_pay_jietu.jpg")
end
