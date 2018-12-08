module("ui",package.seeall)

clsScreeningView = class("clsScreeningView",clsBaseUI)

function clsScreeningView:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/Screening.csb")
    self.type = ""
    self.starttime = ""
    self.endtime = ""
    self.record = ClsScreeningMgr.GetInstance():GetType()
    if self.record == 3 then
        self:AccountBtn()
    end
    self:InUiEvent()
    self:Reflesh()
end

function clsScreeningView:AccountBtn()
    self.AccountBtnList = {}
    self.AccountBtnList[0] = self.Button_29
    self.AccountBtnList[1] = self.Button_9
    self.AccountBtnList[2] = self.Button_10
    self.AccountBtnList[3] = self.Button_11
    self.AccountBtnList[4] = self.Button_12
    self.AccountBtnList[5] = self.Button_13
    self.AccountBtnList[6] = self.Button_14
    self.AccountBtnList[7] = self.Button_15
    self.AccountBtnList[8] = self.Button_16
    self.AccountBtnList[11] = self.Button_17
    self.AccountBtnList[12] = self.Button_18
    self.AccountBtnList[13] = self.Button_19
    self.AccountBtnList[14] = self.Button_20
    self.AccountBtnList[15] = self.Button_21
    self.AccountBtnList[18] = self.Button_24
    self.AccountBtnList[19] = self.Button_25
    self.AccountBtnList[20] = self.Button_26
    self.AccountBtnList[21] = self.Button_27
    self.AccountBtnList[22] = self.Button_28
end

function clsScreeningView:dtor()
    
end

function clsScreeningView:InUiEvent()
    utils.RegClickEvent(self.Button_3,function()
        self.Button_3:setColor(cc.c3b(255,0,0))
        self.Button_4:setColor(cc.c3b(255,255,255))
        self.Button_5:setColor(cc.c3b(255,255,255))
        self.Button_6:setColor(cc.c3b(255,255,255))
        if self.record == 1 then
            self.type = "1"
        else
            self.type = ""
            self.Button_7:setColor(cc.c3b(255,255,255))
        end
    end)
    utils.RegClickEvent(self.Button_4,function()
        self.Button_4:setColor(cc.c3b(255,0,0))
        self.Button_3:setColor(cc.c3b(255,255,255))
        self.Button_5:setColor(cc.c3b(255,255,255))
        self.Button_6:setColor(cc.c3b(255,255,255))
        if self.record == 1 then
            self.type = "2"
        else
            self.type = "1"
            self.Button_7:setColor(cc.c3b(255,255,255))
        end
    end)
    utils.RegClickEvent(self.Button_5,function()
        self.Button_5:setColor(cc.c3b(255,0,0))
        self.Button_4:setColor(cc.c3b(255,255,255))
        self.Button_3:setColor(cc.c3b(255,255,255))
        self.Button_6:setColor(cc.c3b(255,255,255))
        if self.record == 1 then
            self.type = "4"
        else
            self.type = "2"
            self.Button_7:setColor(cc.c3b(255,255,255))
        end
    end)
    utils.RegClickEvent(self.Button_6,function()
        self.Button_6:setColor(cc.c3b(255,0,0))
        self.Button_4:setColor(cc.c3b(255,255,255))
        self.Button_5:setColor(cc.c3b(255,255,255))
        self.Button_3:setColor(cc.c3b(255,255,255))
        if self.record == 1 then
            self.type = "5"
        else
            self.Button_7:setColor(cc.c3b(255,255,255))
            self.type = "3"
        end
    end)
    utils.RegClickEvent(self.Button_7,function()
        self.Button_7:setColor(cc.c3b(255,0,0))
        self.Button_4:setColor(cc.c3b(255,255,255))
        self.Button_5:setColor(cc.c3b(255,255,255))
        self.Button_3:setColor(cc.c3b(255,255,255))
        self.Button_6:setColor(cc.c3b(255,255,255))
        self.type = "4"
    end)
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnSure,function() 
        if self.record == 1 then
            local data = ClsWithdrawMgr.GetInstance():GetWithdrawData()
            data.type = self.type or data.type
            data.time_start = self.starttime or data.time_start
            data.time_end = self.endtime or data.time_end
            ClsWithdrawMgr.GetInstance():SaveWithdrawData(data)
            g_EventMgr:FireEvent("screeting")
            proto.req_user_Payout_record_get_payout_list({type = self.type,time_start = self.starttime,time_end = self.endtime,page = 1})
        elseif self.record == 2 then
            proto.req_user_chongzhi_record({type = self.type,time_start = self.starttime,time_end = self.endtime,page = "",rows = ""})
        end
        self:removeSelf()
    end)
    utils.RegClickEvent(self.Button_1,function()
        ClsRechargeRecoMgr.GetInstance():SaveRechargeDate({kind = 1})
        ClsUIManager.GetInstance():ShowPopWnd("clsSelectTimeView")
    end)
    utils.RegClickEvent(self.Button_2,function() 
        ClsRechargeRecoMgr.GetInstance():SaveRechargeDate({kind = 2})
        ClsUIManager.GetInstance():ShowPopWnd("clsSelectTimeView")
    end)
    g_EventMgr:AddListener(self,"thetime",function(this,data)
        if data.kind == 1 then
            self.Button_1:setTitleText("起："..data.year.."-"..data.month.."-"..data.day)
            self.starttime = data.year..data.month..data.day
        elseif data.kind == 2 then
            self.Button_2:setTitleText("起："..data.year.."-"..data.month.."-"..data.day)
            self.endtime = data.year..data.month..data.day
        end
    end,self)
    if self.record == 3 then
        for i,v in pairs(self.AccountBtnList) do
            utils.RegClickEvent(v,function()
                v:setColor(cc.c3b(255,0,0))
                self.type = tostring(i)
                for k,b in pairs(self.AccountBtnList) do
                    if k~= i then
                        b:setColor(cc.c3b(255,255,255))
                    end
                end
                self.Button_22:setColor(cc.c3b(255,255,255))
                self.Button_23:setColor(cc.c3b(255,255,255))
            end)
        end
        utils.RegClickEvent(self.Button_22,function()
            self.type = "5,6,12,15,7,8,18"
            self.Button_22:setColor(cc.c3b(255,0,0))
            self.Button_23:setColor(cc.c3b(255,255,255))
            for i,v in pairs(self.AccountBtnList) do
                v:setColor(cc.c3b(255,255,255))
            end
        end)
        utils.RegClickEvent(self.Button_23,function()
            self.type = "13,14"
            self.Button_23:setColor(cc.c3b(255,0,0))
            self.Button_22:setColor(cc.c3b(255,255,255))
            for i,v in pairs(self.AccountBtnList) do
                v:setColor(cc.c3b(255,255,255))
            end
        end)
    end
    utils.RegClickEvent(self.BtnClose_0,function()
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnSure_0,function()
    	g_EventMgr:FireEvent("screeting", {type = self.type, time_start = self.starttime,time_end = self.endtime})
        proto.req_cash_list({type = self.type, time_start = self.starttime,time_end = self.endtime})
        self:removeSelf()
    end)
end

function clsScreeningView:Reflesh()
    if self.record == 1 then
        self.boxbg_0:setVisible(false)
        self.Button_3:setTitleText("审核中")
        self.Button_4:setTitleText("提现成功")
        self.Button_5:setTitleText("预备提现")
        self.Button_6:setTitleText("审核通过")
        self.Button_7:setVisible(false)
    elseif self.record == 2 then
        self.boxbg_0:setVisible(false)
        self.Button_3:setTitleText("全部")
        self.Button_4:setTitleText("银行转账")
        self.Button_5:setTitleText("线上入款")
        self.Button_6:setTitleText("彩豆充值")
    elseif self.record == 3 then
        self.boxbg:setVisible(false)

    end
end