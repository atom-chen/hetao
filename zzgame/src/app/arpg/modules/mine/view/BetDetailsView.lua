module("ui",package.seeall)

clsBetDetailsView = class("BetDetailsView",clsBaseUI)

function clsBetDetailsView:ctor(parent)
    self.data = ClsBetHistoryMgr.GetInstance():GetBetDetails()
    self.page = ClsBetHistoryMgr.GetInstance():GetPage()
    clsBaseUI.ctor(self,parent,"uistu/BetDetails.csb")
    self.Down = self.AreaAuto
    self.Upon:setScrollBarEnabled(false)
    self.Down:setScrollBarEnabled(false)
    if self.data then
        self:Reflesh()
    end
    self:InUiEvent()
    g_EventMgr:AddListener(self,"on_req_bet_cancel_xiazhu",function()
        
        if self.page == 2 then
            self.page = 4
        elseif self.page == -1 then
            slef.page = 0
        end
        g_EventMgr:FireEvent("cancelbet",{type = tostring(self.page),page = 1})
        --proto.req_user_bet_record_get_list({type = tostring(self.page),page = 1},nil)
        self:removeSelf()
    end,self)
end

function clsBetDetailsView:dtor()

end

function clsBetDetailsView:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
end

function clsBetDetailsView:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function() 
        self:removeSelf()
    end)
end

function clsBetDetailsView:Reflesh()
    self.number:setString(self.data.order_num)
    if self.data.status == "1" then
        self.BtnUndo:setVisible(false)
        --中奖单子
        self.item = {}
        for i = 1,6 do
            self.item[i] = self.Betdigital:clone()
            self.Upon:pushBackCustomItem(self.item[i])
        end
        self.item[1]:getChildByName("name"):setString("期号")
        self.item[1]:getChildByName("number"):setString(self.data.issue)
        self.item[2]:getChildByName("name"):setString("彩种")
        self.item[2]:getChildByName("number"):setString(self.data.game)
        self.item[3]:getChildByName("name"):setString("玩法")
        self.item[3]:getChildByName("number"):setString(self.data.tname)
        self.item[4]:getChildByName("name"):setString("投注号码")
        self.item[4]:getChildByName("number"):setString(self.data.names)
        self.item[5]:getChildByName("name"):setString("开奖状态")
        self.item[5]:getChildByName("number"):setString("已中奖")
        self.item[6]:getChildByName("name"):setString("开奖号码")
        self.item[6]:getChildByName("number"):setString(self.data.open_resu_num)
        self.items = {}
        for i = 1,7 do
            self.items[i] = self.Betdigital:clone()
            self.Down:pushBackCustomItem(self.items[i])    
        end
        self.items[1]:getChildByName("name"):setString("投注金额")
        self.items[1]:getChildByName("number"):setString(self.data.price_sum) 
        self.items[2]:getChildByName("name"):setString("中奖注数")
        self.items[2]:getChildByName("number"):setString(self.data.win_counts) 
        self.items[3]:getChildByName("name"):setString("投注返利")
        self.items[3]:getChildByName("number"):setString(self.data.rebate) 
        self.items[4]:getChildByName("name"):setString("投注赔率")
        self.items[4]:getChildByName("number"):setString(self.data.rate) 
        self.items[5]:getChildByName("name"):setString("中奖金额")
        self.items[5]:getChildByName("number"):setString(self.data.win_price) 
        local truely = tonumber(self.data.win_price) - tonumber(self.data.price_sum)
        self.items[6]:getChildByName("name"):setString("实际输赢")
        self.items[6]:getChildByName("number"):setString(truely) 
        self.items[7]:getChildByName("name"):setString("投注时间")
        self.items[7]:getChildByName("number"):setString(self.data.bet_time) 
    elseif self.data.status == "2" then
        --和局
        self.BtnUndo:setVisible(false)
        self.item = {}
        for i = 1,6 do
            self.item[i] = self.Betdigital:clone()
            self.Upon:pushBackCustomItem(self.item[i])
        end
        self.item[1]:getChildByName("name"):setString("期号")
        self.item[1]:getChildByName("number"):setString(self.data.issue)
        self.item[2]:getChildByName("name"):setString("彩种")
        self.item[2]:getChildByName("number"):setString(self.data.game)
        self.item[3]:getChildByName("name"):setString("玩法")
        self.item[3]:getChildByName("number"):setString(self.data.tname)
        self.item[4]:getChildByName("name"):setString("投注号码")
        self.item[4]:getChildByName("number"):setString(self.data.names)
        self.item[5]:getChildByName("name"):setString("开奖状态")
        self.item[5]:getChildByName("number"):setString("和局")
        self.item[6]:getChildByName("name"):setString("开奖号码")
        self.item[6]:getChildByName("number"):setString(self.data.open_resu_num)
        self.items = {}
        for i = 1,7 do
            self.items[i] = self.Betdigital:clone()
            self.Down:pushBackCustomItem(self.items[i])    
        end
        self.items[1]:getChildByName("name"):setString("投注金额")
        self.items[1]:getChildByName("number"):setString(self.data.price_sum) 
        self.items[2]:getChildByName("name"):setString("中奖注数")
        self.items[2]:getChildByName("number"):setString("") 
        self.items[3]:getChildByName("name"):setString("投注返利")
        self.items[3]:getChildByName("number"):setString("") 
        self.items[4]:getChildByName("name"):setString("投注赔率")
        self.items[4]:getChildByName("number"):setString("") 
        self.items[5]:getChildByName("name"):setString("中奖金额")
        self.items[5]:getChildByName("number"):setString("") 
        self.items[6]:getChildByName("name"):setString("实际输赢")
        self.items[6]:getChildByName("number"):setString("") 
        self.items[7]:getChildByName("name"):setString("投注时间")
        self.items[7]:getChildByName("number"):setString(self.data.bet_time) 
    elseif self.data.status == "3" then
        --撤销单子
        self.BtnUndo:setVisible(false)
        self.Down:setPosition(0,self.Down:getPositionY()+170)
        self.item = {}
        for i = 1,4 do
            self.item[i] = self.Betdigital:clone()
            self.Upon:pushBackCustomItem(self.item[i])
        end
        self.item[1]:getChildByName("name"):setString("期号")
        self.item[1]:getChildByName("number"):setString(self.data.issue)
        self.item[2]:getChildByName("name"):setString("彩种")
        self.item[2]:getChildByName("number"):setString(self.data.game)
        self.item[3]:getChildByName("name"):setString("玩法")
        self.item[3]:getChildByName("number"):setString(self.data.tname)
        self.item[4]:getChildByName("name"):setString("投注号码")
        self.item[4]:getChildByName("number"):setString(self.data.names)
        self.items = {}
        for i = 1,2 do
            self.items[i] = self.Betdigital:clone()
            self.Down:pushBackCustomItem(self.items[i])    
        end
        self.items[1]:getChildByName("name"):setString("投注金额")
        self.items[1]:getChildByName("number"):setString(self.data.price_sum) 
        self.items[2]:getChildByName("name"):setString("投注时间")
        self.items[2]:getChildByName("number"):setString(self.data.bet_time) 
    elseif self.data.status == "4" then
        --待开奖
        if self.data.types and self.data.types == "dragon" then
            self.BtnUndo:setVisible(false)
        else
            self.BtnUndo:setVisible(true)
        end
        utils.RegClickEvent(self.BtnUndo,function()
            proto.req_bet_cancel_xiazhu({order_num = self.data.order_num},{gid = self.data.gid})
        end)
        self.Down:setPosition(0,self.Down:getPositionY()+90)
        self.item = {}
        for i = 1,5 do
            self.item[i] = self.Betdigital:clone()
            self.Upon:pushBackCustomItem(self.item[i])
        end
        self.item[1]:getChildByName("name"):setString("期号")
        self.item[1]:getChildByName("number"):setString(self.data.issue)
        self.item[2]:getChildByName("name"):setString("彩种")
        self.item[2]:getChildByName("number"):setString(self.data.game)
        self.item[3]:getChildByName("name"):setString("玩法")
        self.item[3]:getChildByName("number"):setString(self.data.tname)
        self.item[4]:getChildByName("name"):setString("投注号码")
        self.item[4]:getChildByName("number"):setString(self.data.names)
        self.item[5]:getChildByName("name"):setString("开奖状态")
        self.item[5]:getChildByName("number"):setString("待开奖")
        self.items = {}
        for i = 1,2 do
            self.items[i] = self.Betdigital:clone()
            self.Down:pushBackCustomItem(self.items[i])    
        end
        self.items[1]:getChildByName("name"):setString("投注金额")
        self.items[1]:getChildByName("number"):setString(self.data.price_sum) 
        self.items[2]:getChildByName("name"):setString("投注时间")
        self.items[2]:getChildByName("number"):setString(self.data.bet_time) 
    elseif self.data.status == "5" then
        --未中奖
        self.BtnUndo:setVisible(false)
        self.item = {}
        for i = 1,6 do
            self.item[i] = self.Betdigital:clone()
            self.Upon:pushBackCustomItem(self.item[i])
        end
        self.item[1]:getChildByName("name"):setString("期号")
        self.item[1]:getChildByName("number"):setString(self.data.issue)
        self.item[2]:getChildByName("name"):setString("彩种")
        self.item[2]:getChildByName("number"):setString(self.data.game)
        self.item[3]:getChildByName("name"):setString("玩法")
        self.item[3]:getChildByName("number"):setString(self.data.tname)
        self.item[4]:getChildByName("name"):setString("投注号码")
        self.item[4]:getChildByName("number"):setString(self.data.names)
        self.item[5]:getChildByName("name"):setString("开奖状态")
        self.item[5]:getChildByName("number"):setString("未中奖")
        self.item[6]:getChildByName("name"):setString("开奖号码")
        self.item[6]:getChildByName("number"):setString(self.data.open_resu_num)
        self.items={}
        for i = 1,3 do
            self.items[i] = self.Betdigital:clone()
            self.Down:pushBackCustomItem(self.items[i])    
        end
        self.items[1]:getChildByName("name"):setString("投注金额")
        self.items[1]:getChildByName("number"):setString(self.data.price_sum)
        self.items[2]:getChildByName("name"):setString("投注返利")
        self.items[2]:getChildByName("number"):setString(self.data.rebate) 
        self.items[3]:getChildByName("name"):setString("投注时间")
        self.items[3]:getChildByName("number"):setString(self.data.bet_time) 
    end
end