-------------------------
-- 充值
-------------------------
module("ui", package.seeall)

clsRechargeView2 = class("clsRechargeView2", clsBaseUI)
local mmm = 0
function clsRechargeView2:ctor(parent, rechargeIdx)
	clsBaseUI.ctor(self, parent, "uistu/RechargeView2.csb")
	
    self.curIndex = rechargeIdx
	self.EditorMoney = utils.ReplaceTextField(self.EditorMoney,"","ff000000")
    self.editBindName = utils.ReplaceTextField(self.editBindName,"","ff000000")
	self.EditorMoney:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
	
    self.Money_notice:setVisible(false)
    self.Panel_19:setVisible(false)
    self.h = self.Text_10:getPositionY()

    self:BindTypeBtn(self.Btn1, "网银转账", 1, "wy", 1)
	self:BindTypeBtn(self.Btn2, "ATM现金入款", 2, "", 3)
	self:BindTypeBtn(self.Btn3, "银行柜台", 3, "", 4)
	self:BindTypeBtn(self.Btn4, "手机转账", 4, "", 5)
	self:BindTypeBtn(self.Btn5, "支付宝转账", 5, "zfb", 6)
	self:BindTypeBtn(self.Btn6, "微信支付", 6, "wx", 7)
	
	self._bandStyleBtns = {}
	for i=1, 6 do 
		self._bandStyleBtns[i] = self["Btn"..i]
		utils.RegClickEvent(self._bandStyleBtns[i], function()
			self:CheckBankStyle(self._bandStyleBtns[i])
		end)
	end
    self:CheckBankStyle(self._bandStyleBtns[1])

	self.ListView2:setItemModel(self.ListItem2)
	KE_SafeDelete(self.ListItem2)
	self.ListItem2 = nil
    
	self.ListView3:setItemModel(self.ListItem3)
	KE_SafeDelete(self.ListItem3)
	self.ListItem3 = nil
	
	self.ListView2:setScrollBarEnabled(false)
	self.ListView3:setScrollBarEnabled(false)
	
	self:InitUiEvents()
	self:InitGlbEvents()
	self:RefleshUI()
	
	--proto.req_pay_get_pay_channel_info()
    local data = ClsRechargeRecoMgr.GetInstance():GetRechargeRecharge() or {}
    self:on_req_pay_get_pay_channel_info(data)
end

function clsRechargeView2:dtor()
	KE_KillTimer(self.tmr)
end

function clsRechargeView2:BindTypeBtn(btn, name, bank_style, Type, id)
	btn.bank_style = bank_style
	btn.type = Type 
	btn.id = id
	btn:getChildByName("lblCommitName"):setString(name)
end

function clsRechargeView2:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local w = self.ListView3:getContentSize().width
	local h = self:GetAdaptInfo().hAuto - 644
	self.ListView2:setContentSize(w, h)
	self.ListView3:setContentSize(w, h)
end

function clsRechargeView2:CheckBankStyle(btn)
	self._selectedBtn = btn
	for i=1, 6 do 
		local bSelect = btn == self._bandStyleBtns[i]
		self._bandStyleBtns[i]:getChildByName("Image_1"):setVisible(bSelect)
		self._bandStyleBtns[i]:getChildByName("Image_2"):setVisible(not bSelect)
        if bSelect then
            if i == 5 or i == 6 then
                self.Panel_19:setVisible(true)
                self.Text_10:setPositionY(self.h-30)
            else
                self.Panel_19:setVisible(false)
                self.Text_10:setPositionY(self.h)
            end
        end
	end
end

--注册控件事件
function clsRechargeView2:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	
	local money_list = { 50, 100, 300, 500, 800, 1000, 2000, 3000 }
    local index_list = {[50] = 1,[100] = 2,[300] = 3,[500] = 4, [800] = 5, [1000] = 6, [2000] = 7, [3000] = 8}
	local tabGroup = clsCompTabGroup.new("button")
	for i, money in ipairs(money_list) do
		tabGroup:AddTabButton(money, self["Btn_"..i])
		self["lblYuan"..i]:setString(money.."元")
        self["Btn_"..i].lblDDDDD = self["lblYuan"..i]
	end
	
	utils.RegClickEvent(self.Button_Service,function()
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
    self.EditorMoney:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "changed" then
            tabGroup:SetSelectedTabSlient( tonumber(self.EditorMoney:getString()) )
            local data1 = tonumber(self.EditorMoney:getString())
            if data1 then
                data1 = string.format("%0.2f", data1)
                mmm = data1
            end
        elseif evenName == "began" then 
            self.MoneyVisible:setVisible(false)
        elseif evenName == "return" then
            local data = tonumber(self.EditorMoney:getString())
            if data then
                data = string.format("%0.2f", data)
                mmm=data
                self.EditorMoney:setString(data)
            else
                self.EditorMoney:setString("")
                self.MoneyVisible:setVisible(true)
            end
        end
    end)
    tabGroup.OnSelectChange = function(this, id, old_selected_id)
        clsCompTabGroup.OnSelectChange(this, id, old_selected_id)
        for btn_id, btn in pairs(this.tTabButtons) do
           if btn.lblDDDDD and btn.lblDDDDD.setTextColor then
               btn.lblDDDDD:setTextColor( btn_id == id and cc.c3b(255,255,255) or cc.c3b(221,66,71) )
           end
	    end
    end
    tabGroup:AddListener(self, "ec_select_changed", function(thisObj, id, old_selected_id)
        self:DestroyTimer("Setmoney")
        self:CreateTimerDelay("Setmoney",1,function()
            if id then
                self.MoneyVisible:setVisible(false)
		        self.EditorMoney:setString(id)
            end
        end)
	end)
    --客服
	utils.RegClickEvent(self.Button_Service,function()
	--	ClsUIManager.GetInstance():ShowPanel("clsCustomerSerView")
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
    utils.RegClickEvent(self.Button_1,function()
	--	ClsUIManager.GetInstance():ShowPanel("clsCustomerSerView")
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)

end

-- 注册全局事件
function clsRechargeView2:InitGlbEvents()
    g_EventMgr:AddListener(self,"RechargeOver",function()
        self:removeSelf()
    end,self)
	g_EventMgr:AddListener(self, "on_req_pay_get_pay_channel_info", self.on_req_pay_get_pay_channel_info, self)
    KE_KillTimer(self.tmr)
	self.tmr = KE_SetInterval(1, function(dt)
		local str = self.EditorMoney:getString()
        if str~="" then
            str = tonumber(str)
            if str and math.floor(str) < str then
                self.Money_notice:setVisible(false)
            else
                self.Money_notice:setVisible(true)
            end
        end
	end)
end

function clsRechargeView2:RefleshUI(recvdata)
	local userObj = UserEntity.GetInstance()
	self.lblAccount:setString(userObj:Get_username() or "")
	self.lblBalance:setString(string.format("%.3f元", userObj:Get_balance() or 0))
end

function clsRechargeView2:on_req_pay_get_pay_channel_info(recvdata)
	local data = recvdata and recvdata.data
	if not data then return end
	
	local curIndex = self.curIndex
	local info1 = data.zhifu[curIndex]
	
	if info1.type == "bank" then
		self.ListView2:setVisible(false)
		self.ListView3:setVisible(true)
		self.ListView3:removeAllItems()
		for i, info2 in ipairs(info1.list) do
			self.ListView3:pushBackDefaultItem()
			local item = self.ListView3:getItem(i-1)
				
			item:getChildByName("lblBankName"):setString(info2.bank_name)
			item:getChildByName("lblBindName"):setString(info2.name)
			item:getChildByName("lblKaihuHang"):setString(info2.card_address)
			item:getChildByName("lblCardNum"):setString(info2.num)
				
			utils.RegClickEvent(item, function()
				local money = self.EditorMoney:getString()
				money = tonumber(money)
				if not money or money < 0 then
					utils.TellMe("请输入有效的充值额度")
					return
				end

                if money < tonumber(info2.catm_min) or money > tonumber(info2.catm_max) then
                    utils.TellMe("充值金额的范围，最低"..info2.catm_min..",最高"..info2.catm_max)
					return
                end
				
                if not self._selectedBtn then
			        utils.TellMe("请选择转账方式")
			        return 
		        end
		        
                local bindName = self.editBindName:getString()
	            if not bindName or bindName == "" then
		            utils.TellMe("请输入存款人姓名")
		            return
	            end
                ClsUIManager.GetInstance():ShowPopWnd("clsRechargeNotice"):RefreshUI(money, info1, info2, self._selectedBtn.id, bindName)
			end)
		end
	elseif info1.type == "wy" then
		self.ListView2:setVisible(true)
		self.ListView3:setVisible(false)
		self.ListView2:removeAllItems()
		for i, info2 in ipairs(info1.list) do
			self.ListView2:pushBackDefaultItem()
			local item = self.ListView2:getItem(i-1)
				
			local imgGameIcon = item:getChildByName("ImgBankLogo")
			imgGameIcon:setScale9Enabled(false)
			imgGameIcon:setContentSize(80,80)
			imgGameIcon:ignoreContentAdaptWithSize(false)
			imgGameIcon:LoadTextureSync(info2.img)
			local bindName = self.editBindName:getString()
--			if not bindName or bindName == "" then
--				utils.TellMe("请输入存款人姓名")
--				return
--			end
			item:getChildByName("lblBank1"):setString(info2.name)
			item:getChildByName("lblBank2"):setString("")
			item:getChildByName("lblBank1"):setPositionY(item:getContentSize().height/2)
			utils.RegClickEvent(item, function()
				local money = self.EditorMoney:getString()
				money = tonumber(money)
				if not money or money < 0 then
					utils.TellMe("请输入有效的充值额度")
					return
				end

				if money < tonumber(info2.catm_min) or money > tonumber(info2.catm_max) then
					utils.TellMe("充值金额的范围，最低"..info2.catm_min..",最高"..info2.catm_max)
					return
				end
					
				if not self._selectedBtn then
					utils.TellMe("请选择转账方式")
					return 
				end
		            
				local bindName = self.editBindName:getString()
				if not bindName or bindName == "" then
					utils.TellMe("请输入存款人姓名")
					return
				end
				ClsUIManager.GetInstance():ShowPopWnd("clsRechargeNotice"):RefreshUI(money, info1, info2, self._selectedBtn.id, bindName)
			end)
		end
	else
		self.ListView2:setVisible(true)
		self.ListView3:setVisible(false)
		self.ListView2:removeAllItems()
		for i, info2 in ipairs(info1.list) do
			self.ListView2:pushBackDefaultItem()
			local item = self.ListView2:getItem(i-1)
				
			local imgGameIcon = item:getChildByName("ImgBankLogo")
			imgGameIcon:setScale9Enabled(false)
			imgGameIcon:setContentSize(80,80)
			imgGameIcon:ignoreContentAdaptWithSize(false)
			imgGameIcon:LoadTextureSync(info2.img)
			local bindName = self.editBindName:getString()
			item:getChildByName("lblBank1"):setString(info2.title)
			item:getChildByName("lblBank2"):setString(info2.Prompt)
			utils.RegClickEvent(item, function()
				local money = self.EditorMoney:getString()
				money = tonumber(money)
				if not money or money < 0 then
					utils.TellMe("请输入有效的充值额度")
					return
				end

				if money < tonumber(info2.catm_min) or money > tonumber(info2.catm_max) then
					utils.TellMe("充值金额的范围，最低"..info2.catm_min..",最高"..info2.catm_max)
					return
				end
					
				if not self._selectedBtn then
					utils.TellMe("请选择转账方式")
					return 
				end
		            
				local bindName = self.editBindName:getString()
				if not bindName or bindName == "" then
					utils.TellMe("请输入存款人姓名")
					return
				end
				
				ClsUIManager.GetInstance():ShowPopWnd("clsRechargeNotice"):RefreshUI(money, info1, info2, self._selectedBtn.id, bindName)
			end)
		end
	end
end
