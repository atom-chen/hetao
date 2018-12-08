---------------------------
-- 头像
---------------------------
local HeadView = ccui.ImageView

function HeadView:SetHeadImg(imgPath, bCircle, vipLvl)
	print("-------头像", imgPath, bCircle, vipLvl)
	if bCircle == nil then bCircle = true end
	self:SetCircle(bCircle)
	vipLvl = tonumber(vipLvl) or 0
	if imgPath == nil or imgPath == 0 or imgPath == "" or imgPath == "0" then
		imgPath = "uistu/others/default01.jpg"
	end
	self:LoadTextureSync(imgPath)
	
	if vipLvl and vipLvl >=1 and vipLvl <= 9 then
		if not self._sprVipIcon or not utils.IsValidCCObject(self._sprVipIcon) then
			self._sprVipIcon = utils.CreateSprite(string.format("uistu/common/vip%d.png",vipLvl))
			self:addChild(self._sprVipIcon)
			self._sprVipIcon:setAnchorPoint(cc.p(0,0))
			local sz = self:getContentSize()
			self._sprVipIcon:setPosition(sz.width*0.72, sz.height*0.73)
		else
			self._sprVipIcon:setTexture( string.format("uistu/common/vip%d.png",vipLvl) )
		end
	else
		if self._sprVipIcon then
			KE_SafeDelete(self._sprVipIcon)
			self._sprVipIcon = nil 
		end
	end
end
