-------------------------
-- 代理中心
-------------------------
module("ui", package.seeall)

clsAgentView = class("clsAgentView", clsBaseUI)

function clsAgentView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentView.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
    ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(0)
    local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
    local _username = ClsAgentDataMgr.GetInstance():GetReportid()
	proto.req_agent_junior_report_today({uid = _uid})
    proto.req_agent_today_report({username = _username})
    KE_SetTimeout(10, function() proto.req_invite_code_list() end)
end

function clsAgentView:dtor()
	
end

--注册控件事件
function clsAgentView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.Btn1, function() ClsUIManager.GetInstance():ShowPanel("clsAgentDesc") end)
	utils.RegClickEvent(self.Btn2, function() ClsUIManager.GetInstance():ShowPanel("clsAgentReport") end)
	utils.RegClickEvent(self.Btn3, function() ClsUIManager.GetInstance():ShowPanel("clsAgentMemberControl") end)
	utils.RegClickEvent(self.Btn4, function() self:setVisible(false) ClsUIManager.GetInstance():ShowPanel("clsAgentDealDetail", self) end)
	utils.RegClickEvent(self.Btn5, function() ClsUIManager.GetInstance():ShowPanel("clsAgentBetDetail") end)
	utils.RegClickEvent(self.Btn6, function() ClsUIManager.GetInstance():ShowPanel("clsAgentJuniorReport") end)
	utils.RegClickEvent(self.Btn7, function() ClsUIManager.GetInstance():ShowPanel("clsAgentJuniorOpen") end)
end

-- 注册全局事件
function clsAgentView:InitGlbEvents()
	
end