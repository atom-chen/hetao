-------------------------
-- 网格：固定宽度 + 固定单元格高度
-------------------------
clsInnerGrid = class("clsInnerGrid")

function clsInnerGrid:ctor(totalWidth, COL, cellCount, cellHei, minHeight, margin)
	self._totalWidth = totalWidth
	self._COL = COL
	self._cellCount = cellCount
	self._cellHei = cellHei
	self._minHeight = minHeight
	self._margin = margin or {}
	self._margin.left = self._margin.left or 0
	self._margin.bottom = self._margin.bottom or 0
	self._margin.right = self._margin.right or 0
	self._margin.top = self._margin.top or 0
	--
	self._ROW = 0
	self._cellWid = 0
	self._totalHeight = 0
	self:FixLayout()
end

function clsInnerGrid:dtor()
	
end

function clsInnerGrid:FixLayout()
	--算出行数
	self._ROW = math.ceil(self._cellCount/self._COL)
	--算出格子宽度
	self._cellWid = (self._totalWidth-(self._margin.left+self._margin.right)) / self._COL
	--参数cellHei为空时，表示和格子宽度相同
	if not self._cellHei then
		self._cellHei = self._cellWid
	end
	--算出视图高度
	self._totalHeight = self._cellHei * self._ROW + self._margin.top + self._margin.bottom
	if self._minHeight and self._totalHeight < self._minHeight then
		self._totalHeight = self._minHeight
	end
end

function clsInnerGrid:GetSize()
	return self._totalWidth, self._totalHeight
end

function clsInnerGrid:GetCellSize()
	return self._cellWid, self._cellHei
end

function clsInnerGrid:GetRowColByIdx(idx)
	local COL = self._COL
	local r = math.ceil(idx/COL)
	local c = idx%COL
	if c == 0 then c = COL end
	return r, c
end

function clsInnerGrid:GetIdxByRowCol(r, c)
	return (r-1) * self._COL + c
end

function clsInnerGrid:GetPosByIdx(idx)
	local r, c = self:GetRowColByIdx(idx)
	return self:GetPosByRowCol(r,c)
end

function clsInnerGrid:GetPosByRowCol(r,c)
	local x = self._margin.left + (c-0.5) * self._cellWid
	local y = self._totalHeight - self._margin.top - (r-0.5) * self._cellHei
	return x, y
end
