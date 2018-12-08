module("ui",package.seeall)

clsSelectTimeView = class("clsSelectTimeView",clsBaseUI)


function clsSelectTimeView:ctor(parent)
    self.day = 31
    self.selectday = 0
    self.year = 0
    self.month = 0
    clsBaseUI.ctor(self,parent,"uistu/TimeSelect.csb")
    self:InUiEvent()
    self:Reflesh()
    self.ListView_Y:setScrollBarEnabled(false)
    self.ListView_M:setScrollBarEnabled(false)
    self.ListView_D:setScrollBarEnabled(false)
end

function clsSelectTimeView:InUiEvent()
    utils.RegClickEvent(self.BtnOK,function()
        local data = ClsRechargeRecoMgr.GetInstance():GetRechargeDate()
        if self.month < 10 then
            self.month = "0"..self.month
        end
        if self.selectday < 10 then
            self.selectday = "0"..self.selectday
        end
        if self.year ~= 0 and self.month ~= 0 and self.day ~= 0 then
            g_EventMgr:FireEvent("thetime",{kind = data.kind,year = self.year,month = self.month,day = self.selectday})
        else
            print("没有选择日期呀小伙子~")
        end
        self:removeSelf()
    end)
    utils.RegClickEvent(self.BtnCancel,function()
        self:removeSelf()
    end)
end

function clsSelectTimeView:Reflesh()
    ------------------年
    self.Yitem = {}
    for i = 2016,2100 do
        self.Yitem[i] = self.Panel_4:clone()
        self.Yitem[i]:getChildByName("number"):setString(i)
        utils.RegClickEvent(self.Yitem[i],function()
            self.ListView_Y:scrollToItem(self.ListView_Y:getIndex(self.Yitem[i]),cc.p(0.5,0.5),cc.p(0.5,0.5))
            self.Yitem[i]:getChildByName("number"):setTextColor(cc.c3b(255,0,0))
            self.year = i
            for k = 2016,i-1 do
                self.Yitem[k]:getChildByName("number"):setTextColor(cc.c3b(0,0,0))
            end
            for k = i+1,2100 do
                self.Yitem[k]:getChildByName("number"):setTextColor(cc.c3b(0,0,0))
            end
            self:ModifyDay()
            self:RefreshDay()
        end)
        self.ListView_Y:pushBackCustomItem(self.Yitem[i])
    end
    for i = 1,2 do
        self.Yitem[i] = self.Panel_4:clone()
        self.Yitem[i]:getChildByName("number"):setString("")
        self.ListView_Y:pushBackCustomItem(self.Yitem[i])
    end
    for i = 1,2 do
        self.Yitem[i] = self.Panel_4:clone()
        self.Yitem[i]:getChildByName("number"):setString("")
        self.ListView_Y:insertCustomItem(self.Yitem[i],0)
    end
    ----------------------月
    self.Mitem = {}
    for i = 1,12 do
        self.Mitem[i] = self.Panel_4:clone()
        self.Mitem[i]:getChildByName("number"):setString(i)
        utils.RegClickEvent(self.Mitem[i],function()
            self.ListView_M:scrollToItem(self.ListView_M:getIndex(self.Mitem[i]),cc.p(0.5,0.5),cc.p(0.5,0.5))
            self.Mitem[i]:getChildByName("number"):setTextColor(cc.c3b(255,0,0))
            self.month = i
            for k = 1,i-1 do
                self.Mitem[k]:getChildByName("number"):setTextColor(cc.c3b(0,0,0))
            end
            for k = i+1,12 do
                self.Mitem[k]:getChildByName("number"):setTextColor(cc.c3b(0,0,0))
            end
            self:ModifyDay()
            self:RefreshDay()
        end)
        self.ListView_M:pushBackCustomItem(self.Mitem[i])
    end
    for i = 13,14 do
        self.Mitem[i] = self.Panel_4:clone()
        self.Mitem[i]:getChildByName("number"):setString("")
        self.ListView_M:pushBackCustomItem(self.Mitem[i])
    end
    for i = 15,16 do
        self.Mitem[i] = self.Panel_4:clone()
        self.Mitem[i]:getChildByName("number"):setString("")
        self.ListView_M:insertCustomItem(self.Mitem[i],0)
    end
    ------------------日
    self:RefreshDay()

end

function clsSelectTimeView:RefreshDay()
    self.Ditem = {}
    self.ListView_D:removeAllChildren()
    for i = 1,self.day do
        self.Ditem[i] = self.Panel_4:clone()
        self.Ditem[i]:getChildByName("number"):setString(i)
        utils.RegClickEvent(self.Ditem[i],function()
            self.ListView_D:scrollToItem(self.ListView_D:getIndex(self.Ditem[i]),cc.p(0.5,0.5),cc.p(0.5,0.5))
            self.Ditem[i]:getChildByName("number"):setTextColor(cc.c3b(255,0,0))
            self.selectday = i
            for k = 1,i-1 do
                self.Ditem[k]:getChildByName("number"):setTextColor(cc.c3b(0,0,0))
            end
            for k = i+1,12 do
                self.Ditem[k]:getChildByName("number"):setTextColor(cc.c3b(0,0,0))
            end
            if self.selectday < 10 then 
                self.daylabel:setString("0"..self.selectday)
            else
                self.daylabel:setString(self.selectday)
            end
        end)
        self.ListView_D:pushBackCustomItem(self.Ditem[i])
    end
    for i = 32,33 do
        self.Ditem[i] = self.Panel_4:clone()
        self.Ditem[i]:getChildByName("number"):setString("")
        self.ListView_D:pushBackCustomItem(self.Ditem[i])
    end
    for i = 34,35 do
        self.Ditem[i] = self.Panel_4:clone()
        self.Ditem[i]:getChildByName("number"):setString("")
        self.ListView_D:insertCustomItem(self.Ditem[i],0)
    end
    self.yearlabel:setString(self.year)
    if self.month < 10 then
        self.monthlabel:setString("0"..self.month)
    else
        self.monthlabel:setString(self.month)
    end
    if self.selectday < 10 then 
        self.daylabel:setString("0"..self.selectday)
    else
        self.daylabel:setString(self.selectday)
    end
end

function clsSelectTimeView:ModifyDay()
    if self.month == 1 or self.month == 3 or self.month == 5 or self.month == 7 or self.month == 8 or self.month == 10 or self.month == 12 then
        self.day = 31
    elseif self.month == 2 and self:IsLeapYear(self.year) then
        self.day = 29
    elseif self.month == 2 then
        self.day = 28
    else
        self.day = 30
    end
    return self.day
end

function clsSelectTimeView:IsLeapYear(year)
    if (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0 then
        return true
    else
        return false
    end
end