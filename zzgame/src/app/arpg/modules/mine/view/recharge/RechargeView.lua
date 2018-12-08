-------------------------
-- 充值
-------------------------
module("ui", package.seeall)

clsRechargeView = class("clsRechargeView", clsBaseUI)

function clsRechargeView:ctor(parent, rechargeIdx)
	clsBaseUI.ctor(self, parent, "uistu/RechargeView.csb")
    self.editBindName = utils.ReplaceTextField(self.editBindName,"","ff000000")
	
    self.curIndex = rechargeIdx
	self.EditorMoney = utils.ReplaceTextField(self.EditorMoney,"","ff000000")
	self.EditorMoney:setInputMode(cc.EDITBOX_INPUT_MODE_DECIMAL)
	
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
	--self:RefleshUI()
	
	--proto.req_pay_get_pay_channel_info()
    local data = ClsRechargeRecoMgr.GetInstance():GetRechargeRecharge() or {}
    self:on_req_pay_get_pay_channel_info(data)
end

function clsRechargeView:dtor()
	
end

function clsRechargeView:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local w = self.ListView3:getContentSize().width
	local h = self:GetAdaptInfo().hAuto - 345
	self.ListView2:setContentSize(w, h)
	self.ListView3:setContentSize(w, h)
end

--注册控件事件
function clsRechargeView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	
	local money_list = { 50, 100, 300, 500, 800, 1000, 2000, 3000 }
    local index_list = {[50] = 1,[100] = 2,[300] = 3,[500] = 4, [800] = 5, [1000] = 6, [2000] = 7, [3000] = 8}
	local tabGroup = clsCompTabGroup.new("button")
	for i, money in ipairs(money_list) do
		tabGroup:AddTabButton(money, self["Btn"..i])
		self["lblYuan"..i]:setString(money.."元")
        self["Btn"..i].lblDDDDD = self["lblYuan"..i]
	end
	utils.RegClickEvent(self.Button_Service,function()
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)

    self.EditorMoney:registerScriptEditBoxHandler(function(evenName, sender)
        if evenName == "changed" then
            tabGroup:SetSelectedTabSlient( tonumber(self.EditorMoney:getString()) )
        elseif evenName == "began" then 
            self.MoneyVisible:setVisible(false)
        elseif evenName == "return" then
            if self.EditorMoney:getString() == "" then
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
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)
    utils.RegClickEvent(self.Button_1,function()
		PlatformHelper.openURL(ClsHomeMgr.GetInstance():GetHomeConfigData().online_service)
	end)

end

-- 注册全局事件
function clsRechargeView:InitGlbEvents()
    g_EventMgr:AddListener(self,"RechargeOver",function()
        self:removeSelf()
    end,self)
	g_EventMgr:AddListener(self, "on_req_pay_get_pay_channel_info", self.on_req_pay_get_pay_channel_info, self)
end

function clsRechargeView:RefleshUI(recvdata)
	local userObj = UserEntity.GetInstance()
	self.lblAccount:setString(userObj:Get_username() or "")
	self.lblBalance:setString(string.format("%.3f元", userObj:Get_balance() or 0))
end

function clsRechargeView:on_req_pay_get_pay_channel_info(recvdata)
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
				self:AskPay(info1, info2)
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
				
			item:getChildByName("lblBank1"):setString(info2.name)
			item:getChildByName("lblBank2"):setString("")
			item:getChildByName("lblBank1"):setPositionY(item:getContentSize().height/2)
			utils.RegClickEvent(item, function()
				self:AskPay(info1, info2)
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
				
			item:getChildByName("lblBank1"):setString(info2.title)
			item:getChildByName("lblBank2"):setString(info2.Prompt)
			utils.RegClickEvent(item, function()
				self:AskPay(info1, info2)
			end)
		end
	end
end

function clsRechargeView:AskPay(info1, info2)
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
    
	local param = {}
	param.id = info2.id
	param.code = info2.code
	param.money = money
	param.from_way = const.FROMWAY
	
	param._client_data = {}
	param._client_data.info1 = info1
	param._client_data.info2 = info2
	param._client_data.money = money
	
	if info2.jump_mode == 2 or info2.jump_mode == "2" then
		ClsUIManager.GetInstance():ShowPopWnd("clsRechargeNotice"):RefreshUI(self.EditorMoney:getString(), info1, info2, 6)
	elseif info2.jump_mode == 4 or info2.jump_mode == "4" then
		proto.req_get_game_article_content({id="13", param=param})
		ClsUIManager.GetInstance():ShowPanel("clsRechargeScan", {
			info1 = info1,
			info2 = info2,
			name = info2.name,
            --name = self.editBindName:getString(),
			money = money,
		})
	else
		proto.req_pay_commit(param)
	end
end

function clsRechargeView:randomfloat()
    local num = math.random() * 100
    num = math.floor(num)
    if num == 0 then
        return 0.85
    end
    local num1 = num/100
    local num2 = math.floor(num1)
    return num1 - num2
end