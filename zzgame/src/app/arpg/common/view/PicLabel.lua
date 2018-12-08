-------------------------
-- 图片数字
-------------------------
module("ui", package.seeall)

clsPicLabel = class("clsPicLabel", function() return ccui.Layout:create() end)

function clsPicLabel:ctor(parent)
	self:EnableNodeEvents()
--	self:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
--	self:setBackGroundColor(cc.c3b(222,222,34))
	if parent then KE_SetParent(self, parent) end
end

function clsPicLabel:dtor()
	
end

function clsPicLabel:setString(numStr, COL)
	self._numStr = numStr
	
	self:removeAllChildren()
	self._diceList = {}
	self._diceBgList = {}
	
	COL = COL or 5
	local szW, szH = 45, 40
	
	local numtbl = string.split(numStr, ",")
	if numtbl and #numtbl > 0 then
		local ROW = math.ceil(#numtbl/COL)
		self:setContentSize(cc.size(szW*math.min(COL,#numtbl), szH*ROW))
		
		for idx, nStr in ipairs(numtbl) do
			local c = idx%COL  if c==0 then c = COL end
			local r = math.ceil(idx/COL)
				
			if not utils.IsValidCCObject(self._diceList[idx]) then
				local sprBgDice = utils.CreateSprite("uistu/common/bg_red_circle.png")
				self:addChild(sprBgDice)
				sprBgDice:setPosition(szW*(c-0.5), szH*(ROW-r+0.5))
				sprBgDice:setScale((szW-4)/sprBgDice:getContentSize().width)
				self._diceBgList[idx] = sprBgDice
				
				local sprDice = utils.CreateLabel(nStr, 22)
				self:addChild(sprDice, 1)
				sprDice:setPosition(sprBgDice:getPosition())
				self._diceList[idx] = sprDice
				
			--	local nnn = tonumber(nStr)
			--	if nnn >= 12 and nnn <= 19 then
			--		sprDice:setPositionX(sprDice:getPositionX()-1)
			--	end
			else
				self._diceList[idx]:setString(nStr)
			end
		end
	end
end

function clsPicLabel:getString()
	return self._numStr
end
