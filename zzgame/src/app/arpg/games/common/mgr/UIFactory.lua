--------------------------
-- 控件工厂
--------------------------
UIFactory = {}

------------------------------- menu -------------------------------
function UIFactory.CreateMenuBtn(btnWid, btnHei, name)
	local BtnMenu = utils.CreateButton("uistu/common/btn_01.png", "uistu/common/btn_01.png")
	BtnMenu:setScale9Enabled(true)
	BtnMenu:setContentSize(btnWid,btnHei)
	BtnMenu:setColor(cc.c3b(155,155,155))
	
	local lblName = utils.CreateLabel(name, 28)
	BtnMenu:addChild(lblName)
	lblName:setPosition(btnWid/2, btnHei*0.5)
	lblName:setColor(cc.c3b(111,111,111))
	
	return BtnMenu
end

function UIFactory.CreateMenuBtnTab(btnWid, btnHei, name)
	local BtnMenu = ui.clsCheckButton.new(parent, "uistu/common/pnl_tag_btn.png", "uistu/common/pnl_tag_btn_red.png", wid, hei)
	BtnMenu:SetClickAble(false)
	BtnMenu:GetNormalSpr():setColor(cc.c3b(211,211,211))
	
	local lblName = utils.CreateLabel(name, 28)
	BtnMenu:addChild(lblName)
	lblName:setColor(cc.c3b(22,22,22))
	
	local sz = lblName:getContentSize()
	BtnMenu:SetSize(sz.width*lblName:getScale()+60, BtnMenu:getContentSize().height)
	lblName:setPosition((sz.width*lblName:getScale()+60)/2, BtnMenu:getContentSize().height*0.5)
	
	function BtnMenu:RefleshLook()
		ui.clsCheckButton.RefleshLook(self)
		if self:IsSelected() then
			lblName:setColor(cc.c3b(255,255,255))
		else
			lblName:setColor(cc.c3b(99,99,99))
		end
	end
	
	return BtnMenu
end

------------------------------- ball -------------------------------
local COLOR_NAME_BLACK = cc.c3b(77,77,77)
local COLOR_NAME_WHITE = cc.c3b(255,255,255)
local COLOR_NAME_RED = cc.c3b(250,2,2)

local COLOR_RATE_GRAY = cc.c3b(111,111,111)

function UIFactory.CreateRectButton(parent, wid,hei, name, rate)
	local btnFeature = ui.clsCheckButton.new(parent, "uistu/common/rect_white.png", "uistu/common/rect_white.png", wid, hei)
	
	local lblName = utils.CreateLabel(name, 36)
	btnFeature:addChild(lblName)
	lblName:setPosition(wid/2, hei*0.65)
	lblName:setColor(cc.c3b(255,255,255))
	lblName:enableBold()
	
	local lblRate = utils.CreateLabel("赔"..rate, 24)
	btnFeature:addChild(lblRate)
	lblRate:setPosition(wid/2, 25)
	lblRate:setColor(cc.c3b(255,255,255))
	
	btnFeature:GetCheckedSpr():setColor(cc.c3b(255,255,50))
	
	function btnFeature:RefleshLook()
		ui.clsCheckButton.RefleshLook(self)
		if self:IsSelected() then
			lblName:setColor(cc.c3b(255,255,50))
			lblRate:setColor(cc.c3b(255,255,50))
		else
			lblName:setColor(cc.c3b(255,255,255))
			lblRate:setColor(cc.c3b(255,255,255))
		end
	end
	
	return btnFeature
end

function UIFactory.CreateRectangleButton(parent, wid, hei, name, rate)
--	local btnFeature = ui.clsCheckButton.new(parent, "uistu/common/rect_gray.png", "uistu/common/rect_red.png", wid, hei)
	local btnFeature = ui.clsCheckButton.new(parent, "uistu/common/btn_01.png", "uistu/common/btn_02.png", wid, hei)
	local lblName = utils.CreateLabel(name, 32)
	btnFeature:addChild(lblName)
	lblName:setPosition(wid/2, hei*0.65)
	lblName:setColor(COLOR_NAME_BLACK)
	lblName:enableBold()
	
	local lblRate = utils.CreateLabel("赔"..rate, 24)
	btnFeature:addChild(lblRate)
	lblRate:setPosition(wid/2, 25)
	lblRate:setColor(COLOR_RATE_GRAY)
	
	function btnFeature:RefleshLook()
		ui.clsCheckButton.RefleshLook(self)
		if self:IsSelected() then
			lblName:setColor(COLOR_NAME_RED)
			lblRate:setColor(cc.c3b(255,0,0))
		else
			lblName:setColor(COLOR_NAME_BLACK)
			lblRate:setColor(COLOR_RATE_GRAY)
		end
	end
	
	return btnFeature
end

function UIFactory.CreateBigCircleBtn(parent, wid,hei, name,rate)
	local BtnFeature = ui.clsCheckButton.new(parent, "", "", wid, hei)
	
	local circleSpr = utils.CreateImageView("uistu/games/baiquan.png")
	BtnFeature:addChild(circleSpr)
	circleSpr:setPosition(wid/2, hei/2)
	BtnFeature.circleSpr = circleSpr
	circleSpr:setScale9Enabled(false)
	circleSpr:ignoreContentAdaptWithSize(false)
	circleSpr:setContentSize(wid-20,hei-20)
	circleSpr:setColor(cc.c3b(255,0,0))
	
	local lblName = utils.CreateLabel(name, 32)
	BtnFeature:addChild(lblName)
	lblName:setPosition(wid/2, hei*0.62)
	lblName:setColor(COLOR_NAME_BLACK)
	lblName:enableBold()
	
	local lblRate = utils.CreateLabel(rate, 24)
	BtnFeature:addChild(lblRate)
	lblRate:setPosition(wid/2, 35)
	lblRate:setColor(COLOR_RATE_GRAY)
	
	function BtnFeature:RefleshLook()
		ui.clsCheckButton.RefleshLook(self)
		if self:IsSelected() then
			lblName:setColor(COLOR_NAME_WHITE)
			lblRate:setColor(COLOR_NAME_WHITE)
			
			if not BtnFeature.highSpr then
				BtnFeature.highSpr = utils.CreateSprite("uistu/games/yuan.png")
				BtnFeature.highSpr:setColor(cc.c3b(250,0,0))
				BtnFeature:addChild(BtnFeature.highSpr, -1)
				BtnFeature.highSpr:setScale( (BtnFeature.circleSpr:getContentSize().width)/BtnFeature.highSpr:getContentSize().width )
				local x, y = BtnFeature.circleSpr:getPosition()
				BtnFeature.highSpr:setPosition(x,y)
			end
			BtnFeature.highSpr:setVisible(true)
		else
			lblName:setColor(COLOR_NAME_BLACK)
			lblRate:setColor(COLOR_RATE_GRAY)
			
			if BtnFeature.highSpr then
				BtnFeature.highSpr:setVisible(false)
			end
		end
	end
	
	return BtnFeature
end

function UIFactory.CreateFeatureButtonLhc(parent, wid,hei, name,rate,code)
	local BtnFeature = ui.clsCheckButton.new(parent, "", "", wid, hei)
	
	local circleSpr = utils.CreateImageView("uistu/games/baiquan.png")
	BtnFeature:addChild(circleSpr)
	circleSpr:setPosition(wid/2, hei*0.64)
	BtnFeature.circleSpr = circleSpr
	circleSpr:setScale9Enabled(false)
	circleSpr:ignoreContentAdaptWithSize(false)
	circleSpr:setContentSize(80,80)
	circleSpr:setColor(cc.c3b(255,0,0))
	
	local ballColor = ClsGameLhcMgr.GetInstance():GetBallColor(code)
	if ballColor then 
		circleSpr:setColor(ballColor)
	end
	
	local lblName = utils.CreateLabel(name, 32)
	BtnFeature:addChild(lblName)
	lblName:setPosition(wid/2, hei*0.64)
	lblName:setColor(COLOR_NAME_BLACK)
	lblName:enableBold()
	
	local lblRate = utils.CreateLabel(rate, 24)
	BtnFeature:addChild(lblRate)
	lblRate:setPosition(wid/2, 23)
	lblRate:setColor(COLOR_RATE_GRAY)
	
	function BtnFeature:RefleshLook()
		ui.clsCheckButton.RefleshLook(self)
		if self:IsSelected() then
			lblName:setColor(COLOR_NAME_WHITE)
			
			if not BtnFeature.highSpr then
				BtnFeature.highSpr = utils.CreateSprite("uistu/games/yuan.png")
				BtnFeature.highSpr:setColor(cc.c3b(250,0,0))
				BtnFeature:addChild(BtnFeature.highSpr, -1)
				BtnFeature.highSpr:setScale( (BtnFeature.circleSpr:getContentSize().width)/BtnFeature.highSpr:getContentSize().width )
				local x, y = BtnFeature.circleSpr:getPosition()
				BtnFeature.highSpr:setPosition(x,y)
			end
			BtnFeature.highSpr:setVisible(true)
		else
			lblName:setColor(COLOR_NAME_BLACK)
			
			if BtnFeature.highSpr then
				BtnFeature.highSpr:setVisible(false)
			end
		end
	end
	
	return BtnFeature
end

function UIFactory.CreateHexiaoBtn(parent, wid,hei, name, code)
	local BtnFeature = ui.clsCheckButton.new(parent, "uistu/bg/pink_bg_square.png", "uistu/bg/red_bg_square.png", wid, hei)
	
	local lblName = utils.CreateLabel(name, 36)
	BtnFeature:addChild(lblName)
	lblName:setPosition(wid/2, hei*0.65)
	lblName:setColor(COLOR_NAME_BLACK)
	lblName:enableBold()
	
	local lblCodes = utils.CreateLabel(ClsGameLhcMgr.GetInstance():GetShengXiaoCodes(name), 24)
	BtnFeature:addChild(lblCodes)
	lblCodes:setPosition(wid/2, hei*0.25)
	lblCodes:setColor(cc.c3b(111,111,111))
	
	return BtnFeature
end

function UIFactory.CreateSquareBtn(parent, wid,hei, name,rate,code)
	local BtnFeature = ui.clsCheckButton.new(parent, "uistu/bg/pink_bg_square.png", "uistu/bg/red_bg_square.png", wid, hei)
	
	local lblName = utils.CreateLabel(name, 36)
	BtnFeature:addChild(lblName)
	lblName:setPosition(wid/2, hei*0.72)
	lblName:setColor(COLOR_NAME_BLACK)
	lblName:enableBold()
	
	local lblRate = utils.CreateLabel("赔率："..rate, 24)
	BtnFeature:addChild(lblRate)
	lblRate:setPosition(wid/2, 50)
	lblRate:setColor(cc.c3b(255,22,22))
	
	local lblCodes = utils.CreateLabel(ClsGameLhcMgr.GetInstance():GetShengXiaoCodes(name), 24)
	BtnFeature:addChild(lblCodes)
	lblCodes:setPosition(wid/2, 24)
	lblCodes:setColor(cc.c3b(111,111,111))
	
	function BtnFeature:RefleshLook()
		ui.clsCheckButton.RefleshLook(self)
		if self:IsSelected() then
			lblName:setColor(COLOR_NAME_WHITE)
			lblRate:setColor(cc.c3b(250,250,250))
			lblCodes:setColor(cc.c3b(250,250,250))
		else
			lblName:setColor(COLOR_NAME_BLACK)
			lblRate:setColor(cc.c3b(255,22,22))
			lblCodes:setColor(cc.c3b(111,111,111))
		end
	end
	
	return BtnFeature
end

function UIFactory.CreateSquareBtn_2(parent, wid,hei, name,rate)
	local BtnFeature = ui.clsCheckButton.new(parent, "uistu/bg/pink_bg_square.png", "uistu/bg/red_bg_square.png", wid, hei)
	
	local lblName = utils.CreateLabel(name, 36)
	BtnFeature:addChild(lblName)
	lblName:setPosition(wid/2, hei*0.65)
	lblName:setColor(COLOR_NAME_BLACK)
	lblName:enableBold()
	
	local lblRate = utils.CreateLabel("赔率: "..rate, 22)
	BtnFeature:addChild(lblRate)
	lblRate:setPosition(wid/2, 30)
	lblRate:setColor(cc.c3b(250,11,11))
	
	function BtnFeature:RefleshLook()
		ui.clsCheckButton.RefleshLook(self)
		if self:IsSelected() then
			lblRate:setColor(cc.c3b(250,250,250))
		else
			lblRate:setColor(cc.c3b(250,11,11))
		end
	end
	
	return BtnFeature
end
