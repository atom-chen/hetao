----------------------
--长龙助手
----------------------
module("ui",package.seeall)

clsDragonHelpView = class("clsDragonHelpView",clsBaseUI)
local ClsChatMgr = require("dragon.model.ChatMgr")

function _sort(a,b)
    return a.times > b.times
end

function clsDragonHelpView:ctor(parent)
    clsBaseUI.ctor(self,parent,"hddt/DragonHelp.csb")
    self.bMoneyVisible = false
    proto.req_dragon_data()
--    proto.req_home_now_stamp()
--    proto.req_home_kithe_plan()
--    proto.req_home_game_plan()
    --proto.req_dragon_plays()
    self:CreateTimerDelay("tmr_dddd", 5, function()
        proto.req_user_bet_record_get_list({type = "0",page = 1})
    end)
    self:adaptor()
    self:InitGlbEvents()
    self:InitUiEvent()
    self:RefreshUi()
end

function clsDragonHelpView:adaptor()
    local sz = self.RootView:getContentSize()
    self.PanelPages:setContentSize(sz.width,sz.height-self.AreaTop:getSize().height)
    self.ListView_1:setContentSize(sz.width,sz.height-self.AreaTop:getSize().height-158)
    self.ListView_2:setContentSize(sz.width,sz.height-180)
    self.Panel_55:setPositionY(sz.height-180)
end

function clsDragonHelpView:InitGlbEvents()
    g_EventMgr:AddListener(self,"on_req_user_balance",self.RefreshUi,self)
    g_EventMgr:AddListener(self,"on_req_dragon_plays",self.on_req_dragon_plays,self)
    g_EventMgr:AddListener(self,"on_req_user_bet_record_get_list",self.on_req_user_bet_record_get_list,self)
    g_EventMgr:AddListener(self,"on_req_dragon_data",self.on_req_dragon_data,self)
end
function clsDragonHelpView:InitUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        data = ClsBetHistoryMgr.GetInstance():SaveDragonBet(false)
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnHelp,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsDragonInfoView")
    end)
    utils.RegClickEvent(self.Bet,function()
        self:SwitchTo(0)
    end)
    utils.RegClickEvent(self.BetHistory,function()
        self:SwitchTo(1)
    end)
    utils.RegClickEvent(self.BtnBalance,function()
    	self:SetMoneyVisible(not self.bMoneyVisible)
    	if self.bMoneyVisible then
			proto.req_user_balance()
    	end
    end)
end

function clsDragonHelpView:RefreshUi()
    self:SetMoneyVisible(self.bMoneyVisible)
end

function clsDragonHelpView:SwitchTo(nPage)
    if nPage < 0 then nPage = 0 end
	if nPage > 1 then nPage = 1 end
	self._curPage = nPage
	self:TurnToPages(nPage)
end

function clsDragonHelpView:TurnToPages(nPage)
    local highColor = cc.c3b(255,255,255)
    local normalColor = cc.c3b(251,169,171)
    self.Bet:setTitleColor(nPage==0 and highColor or normalColor)
    self.BetHistory:setTitleColor(nPage==1 and highColor or normalColor)
    local dstX = -self.PanelPages:getContentSize().width * nPage
    self.PanelPages:stopAllActions()
    local useTime = math.abs(self.PanelPages:getPositionX()-dstX) / 2000
    self.PanelPages:runAction(cc.MoveTo:create(useTime, cc.p(dstX,self.PanelPages:getPositionY())))
end

function clsDragonHelpView:on_req_dragon_plays(recvdata)
    self.plays = recvdata.data.plays
    self.game = recvdata.data.games
    if not self.plays or not self.game then return end
    print("有数据下来了接收到了。"..#self.ListView_1:getItems())
    for i = 0,#self.ListView_1:getItems()-1 do
        local item = self.ListView_1:getItem(i)
         print("那么这个彩种的gid是？"..item.gid)
        utils.getNamedNodes(item)
        for c,v in pairs(self.game) do
            if tostring(item.gid) == tostring(c) then
                item.GamePic:SetHeadImg(v.img)
                item.GameName:setString(v.name)
               
            end
        end
        for c,v in pairs(self.plays) do
            if c == item.name then
                item.Text_38:setString(v.balls[1].name)
                item.SingleRew:setString("奖"..v.balls[1].rate)
                item.Text_39:setString(v.balls[2].name)
                item.DoubleRew:setString("奖"..v.balls[2].rate)
                item.play:setString(v.name)
            end
        end
    end
end

function clsDragonHelpView:on_req_dragon_data()
    local data = ClsChatMgr.GetInstance():GetBetData()
    local tData = {}
    for c,v in pairs(data) do
        local ddata = {}
        ddata.index = c
        ddata.gid = v.gid
        ddata.kj_issue = v.kj_issue
        ddata.name = v.name
        ddata.times = v.times
        table.insert(tData,ddata)
    end
    table.sort(tData,_sort)
    for _,info in pairs (tData) do
        local item = self.listitem:clone()
        utils.getNamedNodes(item)
        item.TimeDate:setString(info.times.."期")
        item.Date:setString(info.kj_issue.."期")
        item.SorD:setString(info.name)
        print("position:"..self.Date:getPositionX())
        print("contentsize:"..self.Date:getContentSize().width)
        item.Time:setPositionX(item.Date:getPositionX()+utils.GetBoundSize(item.Date).width+10)
        item.name = info.index
        item.gid = info.gid
        self.ListView_1:pushBackCustomItem(item)
    end
end

function clsDragonHelpView:on_req_user_bet_record_get_list()
    local data = ClsBetHistoryMgr.GetInstance():GetDragonBet()
    self.ListView_2:removeAllItems()
    if not data.total then 
        local item = self.Panel_11:clone()
        utils.getNamedNodes(item)
        utils.RegClickEvent(item.more,function()
            ClsUIManager.GetInstance():ShowPopWnd("clsBetHistoryView")
        end)
        self.ListView_2:pushBackCustomItem(item)
        return 
    end
    for _,info in pairs(data.rows) do
        local item = self.HistoryItem:clone()
        utils.getNamedNodes(item)
        self.ListView_2:pushBackCustomItem(item)
        item.name:setString(info.game)
        item.number:setString(info.issue)
        item.money:setString(info.price_sum)
        if info.status == "1" then
            item.reward:setString("+"..info.win_price)
            item.reward:setTextColor(cc.c3b(221,66,71))
        elseif info.status == "2" then
            item.reward:setString("和局")
        elseif info.status == "3" then
            item.reward:setString("已撤单")
        elseif info.status == "4" then
            item.reward:setString("待开奖")
        elseif info.status == "5" then
            item.reward:setString("未中奖")
        end
        info.types = "dragon"
        utils.RegClickEvent(item.Button_69,function()
	        ClsBetHistoryMgr.GetInstance():SaveBetDetails(info)
	        ClsBetHistoryMgr.GetInstance():SavePage(1)
	        ClsUIManager.GetInstance():ShowPopWnd("clsBetDetailsView")
        end)
    end
    local item = self.Panel_11:clone()
    utils.getNamedNodes(item)
    utils.RegClickEvent(item.more,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsBetHistoryView")
    end)
    self.ListView_2:pushBackCustomItem(item)
    proto.req_dragon_plays()
end

function clsDragonHelpView:on_req_user_balance(recvdata)
    local data = recvdata and recvdata.data
    if not data then return end
end

function clsDragonHelpView:SetMoneyVisible(bVisible)
	self.bMoneyVisible = bVisible
	if self.bMoneyVisible then
		local userObj = UserEntity.GetInstance()
		self.lblBalance:setString("余额："..(userObj:Get_balance() or "0"))
		self.lblBalance:setTextColor(cc.c3b(255,255,255))
	else
		self.lblBalance:setString("余额：*****")
		self.lblBalance:setTextColor(cc.c3b(251,169,171))
	end
    self.lblBalance:setPositionX(self.lblBalance:getContentSize().width)
	local x = math.max(60, self.lblBalance:getPositionX()+30)
	self.BtnBalance:setContentSize(self.lblBalance:getContentSize().width+90,self.BtnBalance:getContentSize().height)
    self.eye_see:setPositionX(x)
	self.eye_unsee:setPositionX(x)
	self.eye_see:setVisible(bVisible)
	self.eye_unsee:setVisible(not bVisible)
end