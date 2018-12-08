-------------------------
-- 网格：固定宽度 + 固定单元格高度
-------------------------
clsAutoGrid = class("clsAutoGrid")

function clsAutoGrid:ctor(totalWidth, minHeight, spaceLeft, spaceRight)
	self._totalWidth = totalWidth
	self._minHeight = minHeight
	self._spaceLeft = spaceLeft or 0
	self._spaceRight = spaceRight or 0
	
	self._curY = 0
	self._totalHeight = 0
end

function clsAutoGrid:dtor()
	
end

function clsAutoGrid:Begin()
	self._curY = 0
	self._rows = {}
end

function clsAutoGrid:AddSpace(hei)
	self._curY = self._curY - hei
end

-- { {wid=10,hei=10}, ... }
function clsAutoGrid:AddRow(objList, COL, btnWid, btnHei, layoutType, hSpace)
	local posList = {}
	local Cnt = #objList
	local rrr = 1
	
	if layoutType == "left" then
		self._curY = self._curY - btnHei/2
		
		local beginX = self._spaceLeft + btnWid/2
		local toX = self._totalWidth - self._spaceRight - btnWid/2
		local stepX = (toX-beginX)/(COL-1)
	
		for idx=1, Cnt do
			local r,c = gameutil.GetRowColByIdx(COL, idx)
			posList[idx] = { x = beginX+stepX*(c-1), y = self._curY, obj=objList[idx] }
			
			if idx%COL==0 and idx~=Cnt then 
				rrr = rrr + 1
				self._curY = self._curY - hSpace -btnHei
			end
		end
		
		self._curY = self._curY - btnHei/2
		
	elseif layoutType == "center" then
		assert(Cnt==1)
		self._curY = self._curY - btnHei/2
		posList[1] = { x=self._totalWidth/2, y = self._curY, obj=objList[1] }
		self._curY = self._curY - btnHei/2
	end
	
	table.insert(self._rows, posList)
	return posList
end

function clsAutoGrid:End()
	self._totalHeight = math.max(self._minHeight or 0, -self._curY)
	for _, posList in ipairs(self._rows) do
		for _, posInfo in ipairs(posList) do
			posInfo.obj:setPosition(posInfo.x, posInfo.y+self._totalHeight)
		end 
	end 
	return self._totalHeight
end


