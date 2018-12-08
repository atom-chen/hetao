-------------------------
-- 六合彩
-------------------------
module("ui", package.seeall)

clsMoresWnd = class("clsMoresWnd", clsBaseUI)

function clsMoresWnd:ctor(parent, gameObj)
	clsBaseUI.ctor(self, parent, "uistu/MoresWnd.csb")
	self.gameObj = gameObj
	utils.RegClickEvent(self.BtnZouShiTu, function() 
		ClsUIManager.GetInstance():ShowPanel("clsLhcTrendUI"):SetGid(self.gameObj.gameArg.gid)
		self:removeSelf()
	end)
	utils.RegClickEvent(self.BtnJinQiKaiJ, function() 
		ClsUIManager.GetInstance():ShowPanel("clsRecentView"):SetGid(self.gameObj)
		self:removeSelf()
	end)
	utils.RegClickEvent(self.BtnGouCaiJiLu, function() 
		ClsUIManager.GetInstance():ShowPanel("clsBetHistoryView")
		self:removeSelf()
	end)
	utils.RegClickEvent(self.BtnHelp, function() 
		ClsUIManager.GetInstance():ShowPanel("clsHelpDocView"):ShowPage(self.gameObj.gameArg.cptype)
		self:removeSelf()
	end)
end

function clsMoresWnd:dtor()
	
end