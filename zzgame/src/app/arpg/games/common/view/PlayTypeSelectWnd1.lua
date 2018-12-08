-------------------------
-- 玩法选择界面
-------------------------
module("ui", package.seeall)

clsPlayTypeSelectWnd1 = class("clsPlayTypeSelectWnd1", clsBaseUI)

function clsPlayTypeSelectWnd1:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/PlayTypeSelectWnd1.csb")
	self.AreaPanel:setPositionY(self.AreaPanel:getPositionY()+GAME_CONFIG.HEIGHT_DIFF)
end

function clsPlayTypeSelectWnd1:dtor()
	
end

function clsPlayTypeSelectWnd1:RefleshUI(selectedInfo, infolist, Col, callback)
	if not infolist then return end
	
	local cnt = #infolist
	local margin = { left=4, bottom=4, right=4, top=4}
	local innerGrid = clsInnerGrid.new(self.AreaPanel:getContentSize().width, Col, cnt, 72, nil, margin)
	self.AreaPanel:setContentSize(innerGrid:GetSize())
	local btnWid, btnHei = innerGrid:GetCellSize()
	btnWid = btnWid - 8
	btnHei = btnHei - 8
	
	local highColor = cc.c3b(250,0,0)
	local normalColor = cc.c3b(227,227,227)
	for idx, info in ipairs(infolist) do 
		local bkgColor = normalColor
		local nameColor = cc.c3b(22,22,22)
		if selectedInfo and selectedInfo.name == info.name then
			bkgColor = highColor
			nameColor = cc.c3b(255,255,255)
		end
		local BtnMenu = ccui.Layout:create()
		BtnMenu:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		BtnMenu:setBackGroundColor(bkgColor)
	--	BtnMenu:setScale9Enabled(true)
		BtnMenu:setAnchorPoint(cc.p(0.5,0.5))
		BtnMenu:setTouchEnabled(true)
		BtnMenu:setContentSize(btnWid, btnHei)
		self.AreaPanel:addChild(BtnMenu)
		
		local lblName = utils.CreateLabel(info.name, 28)
		BtnMenu:addChild(lblName)
		lblName:setPosition(btnWid/2, btnHei*0.5)
		lblName:setColor(nameColor)
		
		utils.RegClickEvent(BtnMenu, function() 
			callback(info)
			self:removeSelf()
		end)
		
		BtnMenu:setPosition( innerGrid:GetPosByIdx(idx) )
	end
end
