-------------------------
-- 日期筛选控件
-------------------------
module("ui", package.seeall)

clsAgentDataSelect = class("clsAgentDataSelect", clsBaseUI)

function clsAgentDataSelect:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentDateSelect.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
	
end

function clsAgentDataSelect:dtor()
	
end

--注册控件事件
function clsAgentDataSelect:InitUiEvents()
	utils.RegClickEvent(self.Button_3_3, function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_3_7, function() self:removeSelf() end)
    local _type = ClsAgentDataMgr.GetInstance():GetType()
    if _type == 1 then
        local _id = ClsAgentDataMgr.GetInstance():GetReportid()
        self.Panel_1:setVisible(false)
        utils.RegClickEvent(self.Button_3,function()
            proto.req_agent_today_report({username = _id})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_0,function()
            proto.req_agent_yestoday_report({username = _id})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_1,function()
            proto.req_agent_cur_month_report({username = _id})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_2,function()
            proto.req_agent_last_month_report({username = _id})
            self:removeSelf()
        end)
    elseif _type == 2 then
        self.Panel_1:setVisible(false)
        utils.RegClickEvent(self.Button_3,function()
            ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(0)
            local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
            proto.req_agent_junior_report_today({uid = _uid})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_0,function()
            ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(1)
            local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
            proto.req_agent_junior_report_yestoday({uid = _uid})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_1,function()
            ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(2)
            local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
            proto.req_agent_junior_report_cur_month({uid = _uid})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_2,function()
            ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(3)
            local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
            proto.req_agent_junior_report_last_month({uid = _uid})
            self:removeSelf()
        end)
    elseif _type == 3 then
        self.Panel_3:setVisible(false)
        local Bet_type = ClsAgentDataMgr.GetInstance():GetBetType()
        utils.RegClickEvent(self.Button_3_4,function()
            g_EventMgr:FireEvent("Bet_Between_day",{between_day = 0,index = 0,type = Bet_type})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_5,function()
            g_EventMgr:FireEvent("Bet_Between_day",{between_day = 1,index = 0,type = Bet_type})
            self:removeSelf()
        end)
        utils.RegClickEvent(self.Button_3_6,function()
            g_EventMgr:FireEvent("Bet_Between_day",{between_day = 7,index = 0,type = Bet_type})
            self:removeSelf()
        end)
    elseif _type == 4 then
        self.Panel_3:setVisible(false)
        local Trading_type = ClsAgentDataMgr.GetInstance():GetTradingType()
        --if Trading_type == 1 then
            utils.RegClickEvent(self.Button_3_4,function()
                g_EventMgr:FireEvent("Between_day",{between_day = 0,index = 0,type = Trading_type})
                self:removeSelf()
            end)
            utils.RegClickEvent(self.Button_3_5,function()
                g_EventMgr:FireEvent("Between_day",{between_day = 1,index = 0,type = Trading_type})
                self:removeSelf()
            end)
            utils.RegClickEvent(self.Button_3_6,function()
                g_EventMgr:FireEvent("Between_day",{between_day = 7,index = 0,type = Trading_type})
                self:removeSelf()
            end)
    end

end

-- 注册全局事件
function clsAgentDataSelect:InitGlbEvents()
	
end