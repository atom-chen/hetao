-------------------------
-- 下级报表
-------------------------
module("ui", package.seeall)

clsAgentJuniorReport = class("clsAgentJuniorReport", clsBaseUI)
g_EventMgr:RegisterEventType("showpage")
local nLevel = 0

function clsAgentJuniorReport:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentJuniorReport.csb")
	self:InitUiEvents()
	self:InitGlbEvents()
	self.ListView_1:setScrollBarEnabled(false)
    ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(0)
    --local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
	--proto.req_agent_junior_report_today({uid = _uid})
    local todaydata = ClsAgentDataMgr.GetInstance():GetAgentReportTodayData()
    self:Refresh(todaydata)
    g_EventMgr:AddListener(self,"on_req_agent_junior_report_today",self.Refresh,self)
    g_EventMgr:AddListener(self,"on_req_agent_junior_report_yestoday",self.Refresh,self)
    g_EventMgr:AddListener(self,"on_req_agent_junior_report_cur_month",self.Refresh,self)
    g_EventMgr:AddListener(self,"on_req_agent_junior_report_last_month",self.Refresh,self)
    --self:Refresh()
    g_EventMgr:AddListener(self,"showpage",function() 
        nLevel = nLevel + 1
        --print("_-----------------------------增加了一页"..nLevel)
        self.ListView_1:removeAllChildren()
        local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
        ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(0)
	    proto.req_agent_junior_report_today({uid = _uid})
    end)
end

function clsAgentJuniorReport:dtor()
	
end

function clsAgentJuniorReport:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local sz = self.ListView_1:getContentSize()
	self.ListView_1:setContentSize(sz.width, sz.height+GAME_CONFIG.HEIGHT_DIFF)
end

--注册控件事件
function clsAgentJuniorReport:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() 
        local _uid = ClsAgentDataMgr.GetInstance():GetJuniorUid()
        local _level = ClsAgentDataMgr.GetInstance():GetJuniorLevel()
        if nLevel == 0 then
            ClsAgentDataMgr.GetInstance():SaveJuniorUid("")
            self:removeSelf() 
        else
            if nLevel == 1 then
                _level[_uid].id = ""
            end
            nLevel = nLevel - 1
            local Daytype = _level[_uid].daytype
            if Daytype == 0 then
                ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(0)
                proto.req_agent_junior_report_today({uid = _level[_uid].id})
            elseif Daytype == 1 then
                ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(1)
                proto.req_agent_junior_report_yestoday({uid = _level[_uid].id})
            elseif Daytype == 2 then
                ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(2)
                proto.req_agent_junior_report_cur_month({uid = _level[_uid].id})
            elseif Daytype == 3 then
                ClsAgentDataMgr.GetInstance():SaveJuniorReportDay(3)
                proto.req_agent_junior_report_last_month({uid = _level[_uid].id})
            end
        end
        if _level and _level[_uid] and _level[_uid].id then
            ClsAgentDataMgr.GetInstance():SaveJuniorUid(_level[_uid].id)
        end
    end)
    utils.RegClickEvent(self.Button_2, function() 
        ClsAgentDataMgr.GetInstance():SaveType(2)
        ClsUIManager.GetInstance():ShowPopWnd("clsAgentDataSelect")
    end)
end

-- 注册全局事件
function clsAgentJuniorReport:InitGlbEvents()
	
end

function clsAgentJuniorReport:Refresh(recvdata)
    self.ListView_1:removeAllChildren()
    recvdata = recvdata or cacheddata 
    local _nDatetype = ClsAgentDataMgr.GetInstance():GetJuniorReportDay()
    if _nDatetype == 0 then
        self.Text_32:setString("今天")
    elseif _nDatetype == 1 then
        self.Text_32:setString("昨天")
    elseif _nDatetype == 2 then
        self.Text_32:setString("本月")
    elseif _nDatetype == 3 then
        self.Text_32:setString("上月")
    end
    local data = recvdata and recvdata.data
    if data == nil then
    	gameutil.MarkAllLoaded(self.ListView_1)
        return
    end
    
    self.ListView_1:setItemModel(self.Panel_1)
    local _curindex = 0
    for _,info in ipairs(data) do
        self.ListView_1:pushBackDefaultItem()
        local item = self.ListView_1:getItem(_curindex)
        item:getChildByName("username"):setString(info.username)
        if info.type == "2" then
            item:getChildByName("type"):setString(info.level.."级代理")
        else
            item:getChildByName("type"):setString("玩家")
        end
        item:getChildByName("betnum"):setString(info.bet_num)
        item:getChildByName("price"):setString(info.team_profit)
        if tonumber(info.team_profit) > 0 then
            item:getChildByName("price"):setTextColor(cc.c3b(255,0,0))
        end
        _curindex = _curindex + 1
        utils.RegClickEvent(item,function()
            local _id = ClsAgentDataMgr.GetInstance():GetJuniorUid()
            local _table = ClsAgentDataMgr.GetInstance():GetJuniorLevel()
            _table = _table or {}
            _table[info.uid] = _table[info.uid] or {}
            _table[info.uid].id = _id or ""
            _table[info.uid].daytype = _nDatetype
            ClsAgentDataMgr.GetInstance():SaveJuniorLevel(_table)
            ClsAgentDataMgr.GetInstance():SaveType(2)
            ClsAgentDataMgr.GetInstance():SaveJuniorUid(info.uid)
            ClsAgentDataMgr.GetInstance():SaveReportid(info.username)
            ClsUIManager.GetInstance():ShowPopWnd("clsClickMember")
        end)
    end
    gameutil.MarkAllLoaded(self.ListView_1)
end