-------------------------
-- 银行列表
-------------------------
module("ui", package.seeall)

clsBankListView = class("clsBankListView", clsBaseUI)

function clsBankListView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/BankListView.csb")
	
	self.ListView_1:setItemModel(self.ListItem)
	KE_SafeDelete(self.ListItem) 
	self.ListItem = nil
	
	g_EventMgr:AddListener(self, "on_req_user_bankcard_list", self.on_req_user_bankcard_list, self, true)
	
	if not ClsBankMgr.GetInstance():GetBankList() then
		proto.req_user_bankcard_list()
	end
end

function clsBankListView:dtor()
	
end

function clsBankListView:SetCallback(funcCallback)
	self._callback = funcCallback
end

function clsBankListView:on_req_user_bankcard_list(recvdata)
	local infolist = ClsBankMgr.GetInstance():GetBankList()
	if not infolist then return end
	
	local listWnd = self.ListView_1
	for idx, info in ipairs(infolist) do
		listWnd:pushBackDefaultItem()
		local item = listWnd:getItem(idx-1)
		item:getChildByName("ImgBankLogo"):LoadTextureSync(info.img)
		item:getChildByName("lblBankName"):setString(info.bank_name)
	end
	
	listWnd:addEventListener(function(sender, eventType)
		if ccui.ListViewEventType.ONSELECTEDITEM_END == eventType then
			local curIndex = listWnd:getCurSelectedIndex()
			local chooseInfo = infolist[curIndex+1]
			if self._callback then
				self._callback(chooseInfo)
			end
			KE_SetTimeout(1, function() self:removeSelf() end)
		end 
	end)
end
