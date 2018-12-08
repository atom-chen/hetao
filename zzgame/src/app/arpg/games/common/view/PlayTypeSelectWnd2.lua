-------------------------
-- 玩法选择界面
-------------------------
module("ui", package.seeall)

clsPlayTypeSelectWnd2 = class("clsPlayTypeSelectWnd2", clsBaseUI)

function clsPlayTypeSelectWnd2:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/PlayTypeSelectWnd2.csb")
	self.AreaPanel:setPositionY(self.AreaPanel:getPositionY()+GAME_CONFIG.HEIGHT_DIFF)
end

function clsPlayTypeSelectWnd2:dtor()
	
end

local name2tbl = {
	["和值"] = {"1", "6", "3"},
	["两连"] = {"3", "4"},
	["独胆"] = {"6"},
	["豹子"] = {"1", "1", "1"},
	["对子"] = {"4", "4"},
}
function clsPlayTypeSelectWnd2:RefleshUI(selectedInfo, infolist, Col, callback)
	if not infolist then return end
	
	local COL = 3
	local AreaSize = self.AreaPanel:getContentSize()
	local wid, hei = 220, 128
	local posX = { 0.17, 0.5, 0.83 }
	
	for idx, info in ipairs(infolist) do 
		local BtnFeature
		if selectedInfo and selectedInfo.name == info.name then
			BtnFeature = utils.CreateButton(RES_CONFIG.common_btn_yellow,RES_CONFIG.common_btn_white,RES_CONFIG.common_btn_white)
		else
			BtnFeature = utils.CreateButton(RES_CONFIG.common_btn_white,RES_CONFIG.common_btn_yellow,RES_CONFIG.common_btn_white)
		end
		
		BtnFeature:setScale9Enabled(true)
		BtnFeature:setContentSize(wid, hei)
		self.AreaPanel:addChild(BtnFeature)
		
		local lblName = utils.CreateLabel(info.name, 28)
		BtnFeature:addChild(lblName)
		lblName:setPosition(wid/2, hei*0.7)
		lblName:setColor(cc.c3b(255,255,255))
		BtnFeature.lblName = lblName
		
		utils.RegClickEvent(BtnFeature, function() 
			callback(info)
			self:removeSelf()
		end)
		
		
		local numtbl = name2tbl[info.name]
		for idx, nStr in ipairs(numtbl) do
			local sprDice = utils.CreateSprite(DICE_RES[nStr])
			sprDice:setScale(0.4)
			BtnFeature:addChild(sprDice)
			sprDice:setPosition(BtnFeature:getContentSize().width/2 + (sprDice:getContentSize().width*0.4+6)*(idx-(#numtbl+1)/2), 36)
		end
		
		local r,c = gameutil.GetRowColByIdx(COL, idx)
		BtnFeature:setPosition( AreaSize.width*posX[c], AreaSize.height-(r-0.5)*hei - math.ceil(idx/3)*10 )
	end
end
