---------------------------
-- 找回密码
---------------------------
module("ui",package.seeall)

clsForgetSec = class("clsForgetSec",clsBaseUI)

function clsForgetSec:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/ForgetSec.csb")
    
    utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    
	if device.platform ~= "windows" then
    	local webView = ccexp.WebView:create()
    	self:addChild(webView)
    	webView:setContentSize(720,1190)
    	webView:setAnchorPoint(cc.p(0,0))
    	webView:loadURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	else
    	PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end
end

function clsForgetSec:dtor()
    
end