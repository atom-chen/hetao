-------------------------
-- 收款中心
-------------------------
module("ui", package.seeall)

clsPayCenter = class("clsPayCenter", clsBaseUI)

function clsPayCenter:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/PayCenter.csb")
	self.ListView_1 = self.AreaAuto
	self.ListView_1:setItemModel(self.ListItem)
	KE_SafeDelete(self.ListItem)
	self.ListItem = nil
	self.ListView_1:setScrollBarEnabled(false)
	
	self:InitUiEvents()
	self:InitGlbEvents()
	
	proto.req_user_shoukuan_binded_cards()
end

function clsPayCenter:dtor()
	
end

--注册控件事件
function clsPayCenter:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
end

-- 注册全局事件
function clsPayCenter:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_user_shoukuan_binded_cards", self.on_req_user_shoukuan_binded_cards, self)
	g_EventMgr:AddListener(self, "on_req_user_bind_wx_zfb", function(thisObj, recvdata) 
		proto.req_user_shoukuan_binded_cards()
	end, self)
	g_EventMgr:AddListener(self, "on_req_user_bind_bankcard", function(thisObj, recvdata) 
		proto.req_user_shoukuan_binded_cards()
	end, self)
end

function clsPayCenter:on_req_user_shoukuan_binded_cards(recvdata)
	local data = recvdata and recvdata.data
	if not data then return end
	self.ListView_1:removeAllItems()
	local idx = 0
	for i, info in ipairs(data) do
		if info.is_open == 1 or info.is_open == "1" then 
			self.ListView_1:pushBackDefaultItem()
			idx  = idx + 1
			local item = self.ListView_1:getItem(idx-1)
			utils.getNamedNodes(item)
			local name = info.name
			if not name or info.name == "" then name = "银行卡收款" end
			item.lblName:setString(name)
			item.lblNum:setString(info.num or "")
			item.lblUnbinded:setVisible(not info.is_bind)
			item.imgIcon:LoadTextureSync(info.img)
            item.Image_2:setVisible(false)
			if not info.is_bind then
				item.lblName:setPositionY(55)
			else
				item.lblName:setPositionY(77)
			end
		
			item:addTouchEventListener(function(sender, state)
				if state ~= 2 then return end
				
				if info.is_bind then
					if info.bank_id == "51" then
						if utils.IsValidCCObject(self._imgZfb) then
							self.ListView_1:removeItem(self.ListView_1:getIndex(self._imgZfb))
						else
							self._imgZfb = ccui.ImageView:create()
							self._imgZfb:SetMaxSize(300,300)
							self._imgZfb:LoadTextureSync(info.img)
							self.ListView_1:insertCustomItem(self._imgZfb, self.ListView_1:getIndex(item)+1)
						end
					elseif info.bank_id == "52" then
						if utils.IsValidCCObject(self._imgWx) then
							self.ListView_1:removeItem(self.ListView_1:getIndex(self._imgWx))
						else
							self._imgWx = ccui.ImageView:create()
							self._imgWx:SetMaxSize(300,300)
							self._imgWx:LoadTextureSync(info.img)
							self.ListView_1:insertCustomItem(self._imgWx, self.ListView_1:getIndex(item)+1)
						end
					end
				else
					if info.bank_id == "51" then
						ClsUIManager.GetInstance():ShowPanel("clsZhiFuBaoBindView"):SetFromInfo(info)
					elseif info.bank_id == "52" then
						ClsUIManager.GetInstance():ShowPanel("clsWeiXinBindView"):SetFromInfo(info)
					else
						ClsUIManager.GetInstance():ShowPanel("clsBankBindView"):SetFromInfo(info)
						self:removeSelf()
					end
				end
			end)
		end
	end
end
