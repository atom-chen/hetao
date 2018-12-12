-------------------------
-- 代理报表
-------------------------
module("ui", package.seeall)

clsAgentReport = class("clsAgentReport", clsBaseUI)

function clsAgentReport:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentReport.csb")
    self.TextField_2 = utils.ReplaceTextField(self.TextField_2,"uistu/common/space.png","ff000000")
	self:InitUiEvents()
	self:InitGlbEvents()
    -- 1 今天  2 昨天   3 本月    4 上月
    self.time = 1
    self.id = ClsAgentDataMgr.GetInstance():GetReportid()
    self.TextField_2:setString(self.id)
	--proto.req_agent_today_report({username = self.id})
    self:req_agent_today_report(ClsAgentDataMgr.GetInstance():GetAgentReportToday())
end

function clsAgentReport:dtor()
	
end

--注册控件事件
function clsAgentReport:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() 
        ClsAgentDataMgr.GetInstance():SaveReportid("")
        proto.req_agent_today_report({username = ""})
        self:removeSelf() 
   end)
    utils.RegClickEvent(self.Button_2, function()
        ClsAgentDataMgr.GetInstance():SaveReportid(self.TextField_2:getString())
        self.id = self.TextField_2:getString() 
        ClsAgentDataMgr.GetInstance():SaveType(1)
        ClsUIManager.GetInstance():ShowPopWnd("clsAgentDataSelect") 
    end)
    self.TextField_2:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "ended" then
            ClsAgentDataMgr.GetInstance():SaveReportid(self.TextField_2:getString())
            self.id = self.TextField_2:getString()
        elseif evenName == "return" then
            ClsAgentDataMgr.GetInstance():SaveReportid(self.TextField_2:getString())
            self.id = self.TextField_2:getString()
        end
    end)
    utils.RegClickEvent(self.Button_1,function()
        if self.TextField_2:getString() == "" then
            utils.TellMe("当前搜索为空，显示自己的下级报表")
        end
        local _id = self.TextField_2:getText()
        ClsAgentDataMgr.GetInstance():SaveReportid(_id)
        self.id = _id
        if self.time == 1 then
            proto.req_agent_today_report({username = self.id})
        elseif self.time == 2 then
            proto.req_agent_yestoday_report({username = self.id})
        elseif self.item == 3 then
            proto.req_agent_cur_month_report({username = self.id})
        elseif self.item == 4 then
            proto.req_agent_last_month_report({username = self.id})
        end
    end)

end

-- 注册全局事件
function clsAgentReport:InitGlbEvents()
	g_EventMgr:AddListener(self,"on_req_agent_today_report",self.req_agent_today_report,self)
    g_EventMgr:AddListener(self,"on_req_agent_yestoday_report",self.req_agent_yestoday_report,self)
    g_EventMgr:AddListener(self,"on_req_agent_cur_month_report",self.req_agent_cur_month_report,self)
    g_EventMgr:AddListener(self,"on_req_agent_last_month_report",self.req_agent_last_month_report,self)
end

function clsAgentReport:req_agent_today_report(recvdata)
    local data = recvdata and recvdata.data or {}
    self.time = 1
    self.Text_32:setString("今天")
    self:Refresh(data)
end

function clsAgentReport:req_agent_yestoday_report(recvdata)
    local data = recvdata and recvdata.data or {}
    self.time = 2
    self.Text_32:setString("昨天")
    self:Refresh(data)
end

function clsAgentReport:req_agent_cur_month_report(recvdata)
    local data = recvdata and recvdata.data or {}
    self.time = 3
    self.Text_32:setString("本月")
    self:Refresh(data)
end

function clsAgentReport:req_agent_last_month_report(recvdata)
    local data = recvdata and recvdata.data or {}
    self.time = 4
    self.Text_32:setString("上月")
    self:Refresh(data)
end

function clsAgentReport:Refresh(data)
    local function ChangeLine(str)
        str = tostring(str)
        local headchar 
        local endchar
        if string.len(str) > 12 then
            headchar = string.sub(str,1,12)
            endchar = string.sub(str,13)
            str = headchar.."\n"..endchar
        end
        return str
    end
    self.Text_2:setString(ChangeLine(data.bet_money))
    self.Text_2_0:setString(ChangeLine(data.prize_money))
    self.Text_2_1:setString(ChangeLine(data.gift_money))
    self.Text_2_2:setString(ChangeLine(data.team_rebates))
    self.Text_2_3:setString(ChangeLine(data.team_profit))
    self.Text_2_4:setString(ChangeLine(data.charge_money))
    self.Text_2_5:setString(ChangeLine(data.withdraw_money))
    self.Text_2_6:setString(ChangeLine(data.first_charge_num))
    self.Text_2_7:setString(ChangeLine(data.register_num))
    self.Text_2_8:setString(ChangeLine(data.bet_num))
    self.Text_2_9:setString(ChangeLine(data.junior_num))
    self.Text_2_10:setString(ChangeLine(data.team_balance))
    self.Text_2_11:setString(ChangeLine(data.agent_rebates))
    self.Text_2_12:setString(ChangeLine(data.agent_salary))
    self.Text_2_13:setString(ChangeLine(data.agent_fenhong))
end

