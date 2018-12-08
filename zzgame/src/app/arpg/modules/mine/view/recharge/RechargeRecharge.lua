module("ui",package.seeall)

clsRechargeRecharge = class("clsRechargeRecharge",clsBaseUI)
function clsRechargeRecharge:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/RechargeRecharge.csb")
    self.ListView_1:setSwallowTouches(false)
    self.ListView_1:setScrollBarEnabled(false)
    self.AreaAuto:setScrollBarEnabled(false)
    
    self:InitGlbEvents()
    self:InitUiEvents()
    
    proto.req_user_balance()
    proto.req_pay_get_pay_channel_info()
end

function clsRechargeRecharge:ForceAdapt()
    clsBaseUI.ForceAdapt(self)
    self.AreaAuto:setInnerContainerSize(cc.size(720,1190))
    self.layer_1:setPositionY(self.AreaAuto:getInnerContainerSize().height)
end

function clsRechargeRecharge:dror()

end

function clsRechargeRecharge:Refresh()
    local userObj = UserEntity.GetInstance()
    self.HeadIcon:SetHeadImg(userObj:Get_img(), true, userObj:Get_dengji())
    self.Text_43:setString(userObj:Get_username())
    self.Text_44:setString(string.format("余额：%.3f",userObj:Get_balance() or 0))
end

function clsRechargeRecharge:InitUiEvents()
    utils.RegClickEvent(self.BtnClose,function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_Service,function()
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
end

function clsRechargeRecharge:InitGlbEvents()
    g_EventMgr:AddListener(self,"RechargeOver",function()
        self:removeSelf()
    end,self)
    g_EventMgr:AddListener(self, "on_req_user_balance", self.Refresh, self, true)
    g_EventMgr:AddListener(self, "on_req_pay_get_pay_channel_info", self.on_req_pay_get_pay_channel_info, self)
end

function clsRechargeRecharge:on_req_pay_get_pay_channel_info(recvdata)
    ClsRechargeRecoMgr.GetInstance():SaveRechargeRecharge(recvdata)
    
    local data = recvdata and recvdata.data
    if not data then return end
    
    ClsUIManager.GetInstance():ShowPopWnd("clsAnounceWnd"):RefleshUI(data.is_bomb_box.bomb_box)
    
    self.ListView_1:removeAllItems()
    for idx, infol in ipairs(data.zhifu) do
		local item = self.ListItem1:clone()
        item:setSwallowTouches(false)
        if infol.type == "bank" then
            item:getChildByName("lblBank1"):setString(infol.name)
            item:getChildByName("ImgBankLogo"):loadTexture("uistu/wnds/bank.png")
            item:getChildByName("lblBank2"):setString("单笔最低"..infol.list[1].catm_min.."元，最高"..infol.list[1].catm_max.."元")
            utils.RegClickEvent(item,function()
                ClsUIManager.GetInstance():ShowPanel("clsRechargeView2", idx)
            end)
        elseif infol.type == "wx" then
            item:getChildByName("lblBank1"):setString(infol.name)
            item:getChildByName("ImgBankLogo"):loadTexture("uistu/wnds/wx.png")
            item:getChildByName("lblBank2"):setString("单笔最低"..infol.list[1].catm_min.."元，最高"..infol.list[1].catm_max.."元")
            utils.RegClickEvent(item,function()
                ClsUIManager.GetInstance():ShowPanel("clsRechargeView", idx)
            end)
        elseif infol.type == "zfb" then
            item:getChildByName("lblBank1"):setString(infol.name)
            item:getChildByName("ImgBankLogo"):loadTexture("uistu/wnds/zfb.png")
            item:getChildByName("lblBank2"):setString("单笔最低"..infol.list[1].catm_min.."元，最高"..infol.list[1].catm_max.."元")
            utils.RegClickEvent(item,function()
                ClsUIManager.GetInstance():ShowPanel("clsRechargeView", idx)
            end)
        elseif infol.type == "wy" then
            item:getChildByName("lblBank1"):setString(infol.name)
            item:getChildByName("ImgBankLogo"):loadTexture("uistu/wnds/unionpay.png")
            item:getChildByName("lblBank2"):setString("单笔最低"..infol.list[1].catm_min.."元，最高"..infol.list[1].catm_max.."元")
            utils.RegClickEvent(item,function()
                ClsUIManager.GetInstance():ShowPanel("clsRechargeView", idx)
            end)
        elseif infol.type == "other" then
            item:getChildByName("lblBank1"):setString(infol.name)
            item:getChildByName("ImgBankLogo"):loadTexture("uistu/wnds/other.png")
            item:getChildByName("lblBank2"):setString("单笔最低"..infol.list[1].catm_min.."元，最高"..infol.list[1].catm_max.."元")
            utils.RegClickEvent(item,function()
                ClsUIManager.GetInstance():ShowPanel("clsRechargeView", idx)
            end)
        else
            item:getChildByName("lblBank1"):setString(infol.name)
            item:getChildByName("ImgBankLogo"):loadTexture("uistu/common/null.png")
            item:getChildByName("lblBank2"):setString("单笔最低"..infol.list[1].catm_min.."元，最高"..infol.list[1].catm_max.."元")
            utils.RegClickEvent(item,function()
                ClsUIManager.GetInstance():ShowPanel("clsRechargeView", idx)
            end)
        end
		
		self.ListView_1:pushBackCustomItem(item)
	end
end