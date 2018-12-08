-------------------------
-- 安全中心
-------------------------
module("ui", package.seeall)

clsSafeView = class("clsSafeView", clsBaseUI)

function clsSafeView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/SafeView.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
    self:Refresh()
    g_EventMgr:AddListener(self,"on_req_bank_pwd_chang",function() 
        self:Refresh()
    end,self)
end

function clsSafeView:dtor()
	
end

--注册控件事件
function clsSafeView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnSkzx, function() 
		ClsUIManager.GetInstance():ShowPanel("clsPayCenter")
	end)
    utils.RegClickEvent(self.BtnDlmm,function() 
        ClsUIManager.GetInstance():ShowPanel("clsModifyPasswords")
    end)
    utils.RegClickEvent(self.BtnZjmm,function() 
        if UserEntity.GetInstance():Get_bank_pwd() == 1 then
            ClsUIManager.GetInstance():ShowPanel("clsModifyBankPwd")
        else
            ClsUIManager.GetInstance():ShowPanel("clsBankBindView")
        end
    end)
end

-- 注册全局事件
function clsSafeView:InitGlbEvents()
	
end

function clsSafeView:Refresh()
    if UserEntity.GetInstance():Get_bank_pwd() == 1 then
        self.lblUnSet:setString("已设置")
    end
end