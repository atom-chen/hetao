module("ui",package.seeall)

clsAgentBetList = class("clsAgentBetList",clsBaseUI)

function clsAgentBetList:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/AgentBetList.csb")
    self.data = ClsAgentDataMgr.GetInstance():GetAgentBetDetail()
    if self.data then
        self:Refresh(self.data)
    end
    --proto.req_agent_bet_detail({order_num = self.order_num})
    --g_EventMgr:AddListener(self,"on_req_agent_bet_detail",self.Refresh,self)
    self:InUiEvent()
end

function clsAgentBetList:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
end

function clsAgentBetList:Refresh(recvdata)
    local data = recvdata and recvdata.data
    self.gameicon:LoadTextureSync(data.gameimg)
    self.name:setString(data.game)
    self.state:setString("第"..data.issue.."期")
    local status 
    if data.status == 1 or data.status == "1" then
        status = "已中奖"
    elseif data.status == 2 or data.status == "2" then
        status = "和局"
    elseif data.status == 3 or data.status == "3" then
        status = "撤单"
    elseif data.status == 4 or data.status == "4" then
        status = "待开奖"
    elseif data.status == 5 or data.status == "5" then
        status = "未中奖"
    end
    self.status:setString(status)
    self.time:setString( os.date("%y-%m-%d %H:%M:%S",data.bet_time))
    self.list_num:setString(data.order_num)
    self.bet_price:setString(data.price_sum)
    self.reward:setString(data.win_sum)
    self.rebate:setString(data.rebate_price	)
    self.win_num:setString(data.lottery)
    self.bet_num:setString(data.contents)
    self.type:setString(data.tid)
end