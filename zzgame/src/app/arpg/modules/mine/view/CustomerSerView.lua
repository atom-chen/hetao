module("ui",package.seeall)

clsCustomerSerView = class("clsCustomerSerView",clsBaseUI)

function clsCustomerSerView:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/CustomerService.csb")
    self:InitUiEvents()
    --0没选中输入框 1选中内容输入框 2选中姓名输入框 3选中邮箱输入框
    self.tSelects = 0
    self.bContainSelect = false
    self.bNameSelect = false
    self.bMailSelect = false
    
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

function clsCustomerSerView:dtor()
    
end

function clsCustomerSerView:InitUiEvents()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BgPanel,function()
        if self.tSelects~= 0 then
            self.tSelects = 0
            local num = self.contain_2:getString()
            if self.tSelects~=1 and self.bContainSelect then
                if num == "" or not num then
                    self.Contain:setColor(cc.c3b(255,0,0))
                    self.Tip_contain:setVisible(true)
                else
                    self.Contain:setColor(cc.c3b(0,0,0))
                    self.Tip_contain:setVisible(false)
                end
            end
            local num1 = self.TextField_1:getString()
            if self.tSelects~=2 and self.bNameSelect then
                if num1 == "" or not num1 then
                    self.Contain_name:setColor(cc.c3b(255,0,0))
                    self.Tip_name:setVisible(true)
                else
                    self.Contain_name:setColor(cc.c3b(0,0,0))
                    self.Tip_name:setVisible(false)
                end
            end
            local num2 = self.TextField_3:getString()
            if self.tSelects~=3 and self.bMailSelect then
                if num2 == "" or not num2 then
                    self.Contain_mail:setColor(cc.c3b(255,0,0))
                    self.Tip_email:setVisible(true)
                else
                    self.Contain_mail:setColor(cc.c3b(0,0,0))
                    self.Tip_email:setVisible(false)
                end
            end
        end
    end)
    utils.RegClickEvent(self.contain_2,function()
        self.tSelects = 1
        self.bContainSelect = true
    end)
    utils.RegClickEvent(self.TextField_1,function()
        self.tSelects = 2
        self.bNameSelect = true
    end)
    utils.RegClickEvent(self.TextField_3,function()
        self.tSelects = 3
        self.bMailSelect = true
    end)
end

