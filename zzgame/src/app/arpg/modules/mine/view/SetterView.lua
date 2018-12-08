-------------------------
-- 设置
-------------------------
module("ui", package.seeall)

clsSetterView = class("clsSetterView", clsBaseUI)

function clsSetterView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/SetterView.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
	self.lblVersion:setString(PlatformHelper.getVersion())
end

function clsSetterView:dtor()
	
end

--注册控件事件
function clsSetterView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.RuleBtn, function() 
        ClsUIManager.GetInstance():ShowPanel("clsHelpDocView"):SetPageIdx(1)
    end)
    utils.RegClickEvent(self.AboutBtn,function()
        ClsUIManager.GetInstance():ShowPanel("clsAboutView")
    end)
    utils.RegClickEvent(self.ExitBtn,function()
        proto.req_login_logout()
    end)
    
    utils.RegClickEvent(self.SoundNF,function()
        self:ToggleSound(not UserDefaultData:Get_soundonoff(true))
    end)
    utils.RegClickEvent(self.ShakeNF,function()
        self:ToggleShake(not UserDefaultData:Get_shakeonoff(true))
    end)
    
    utils.RegClickEvent(self.BtnSwitchNet,function()
        HttpUtil._useOkHttp = not HttpUtil._useOkHttp
        utils.TellMe(HttpUtil._useOkHttp and "当前库：OkHttp" or "当前库：XmlHttpRequest")
    end)
    
    self:ToggleSound(UserDefaultData:Get_soundonoff(true))
    self:ToggleShake(UserDefaultData:Get_shakeonoff(true))
end

-- 注册全局事件
function clsSetterView:InitGlbEvents()
	g_EventMgr:AddListener(self, "fail_req_login_logout", function(thisObj, recvdata)
		self:removeSelf()
	end)
end

function clsSetterView:ToggleShake(onoff)
	if onoff == nil then onoff = true end
	UserDefaultData:Set_shakeonoff(onoff)
	if onoff then
		--开
		self.ImageShnf:setColor(cc.c3b(0,128,0))
		self.ImageShbf:setPositionX(57)
	else
		--关
		self.ImageShnf:setColor(cc.c3b(111,111,111))
		self.ImageShbf:setPositionX(13)
	end
end

function clsSetterView:ToggleSound(onoff)
	if onoff == nil then onoff = true end
	UserDefaultData:Set_soundonoff(onoff)
	if onoff then
		--开
		self.ImageSonf:setColor(cc.c3b(0,128,0))
		self.ImageSobf:setPositionX(57)
	else
		--关
		self.ImageSonf:setColor(cc.c3b(111,111,111))
		self.ImageSobf:setPositionX(13)
	end
end 