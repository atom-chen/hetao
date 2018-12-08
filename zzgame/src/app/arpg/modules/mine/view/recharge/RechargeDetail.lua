module("ui",package.seeall)

clsRechargeDetail = class("clsRechargeDetail",clsBaseUI)

function clsRechargeDetail:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/RechargeDetails.csb")
    self.data = ClsRechargeRecoMgr.GetInstance():GetRechargeDetail()
    self:InUiEvent()
    self:Reflesh()
end

function clsRechargeDetail:InUiEvent()
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
end

function clsRechargeDetail:Reflesh()
    local types = self.data.status
    if types == "1" then
        types = "等待审核"
    elseif types == "2" then
        types = "已到账"
    else
        types = "审核未通过"
    end
    self.IDnumber:setString(self.data.order_num)
    self.Timenumber:setString(self.data.addtime)
    self.typeway:setString(self.data.style)
    self.statusway:setString(types)
    self.moneynumber:setString(self.data.price)
    self.discountnumber:setString(self.data.discount_price)
    local lin = 0
    local function ChangeLine(str)
        str = tostring(str)
        local headchar 
        local endchar
        if string.len(str) > 50 then
            lin = lin + 1
            headchar = string.sub(str,1,50)
            endchar = string.sub(str,51)
            str = headchar.."\n"..ChangeLine(endchar)
            return str
        else    
            return str
        end
    end
    ChangeLine(self.data.remark)
    if line ~= 1 then
        self.note:ignoreContentAdaptWithSize(false)
    end
    self.note:setString(self.data.remark)
    local y = self.note:getPositionY()-(lin-1)*7
    self.note:setPositionY(y-10)
    self.name6:setPositionY(y-10)
    --self.note:setContentSize(cc.size(500*math.min(lin,1),self.note:getContentSize().width+lin*15))
    self.note:setContentSize(cc.size(500,500))
    self.Image_1:setPosition(0,15)
    self.Image_1:setSize(self.note_5:getSize().width,self.note_5:getSize().height+(lin-1)*36)
end