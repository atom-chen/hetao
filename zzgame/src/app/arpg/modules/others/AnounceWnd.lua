------------------------
-- 公告弹窗
------------------------
module("ui",package.seeall)

clsAnounceWnd = class("clsAnounceWnd",clsBaseUI)

function clsAnounceWnd:ctor(parent)
	clsBaseUI.ctor(self,parent,"uistu/AnounceWnd.csb")
	
	self.BkgFrame:setPositionY(GAME_CONFIG.DESIGN_H_2)
	
	self.htmlText = ScrollHtmlText.new( {
		width = 420,
		height = 400,
		color = cc.c3b(220,59,64),
		size = 24,
	})
	self.htmlText:setVerticalSpace(8)
	self.htmlText:setPosition(35,85)
	self.BkgFrame:addChild(self.htmlText)
	
	utils.RegClickEvent(self.BtnOk, function() self:removeSelf() end)
end

function clsAnounceWnd:dtor()

end

function clsAnounceWnd:RefleshUI(contStr, titleStr)
--	self.lblTitle:setString(titleStr or "")
	self.htmlText:setString(contStr or "")
end
