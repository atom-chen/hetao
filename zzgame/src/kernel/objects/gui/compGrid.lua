-------------------------
-- 网格控件
--[[
用法示例：
local gridWnd = clsCompGrid.new(parent, nil, nil, CellWid, CellHei, ListWid, ListHei)
gridWnd:SetCellCreator(function()
	return ccui.Button:create()
end)
local dataList = {1,2,3,4}
local idx = 0
for r=1, 10 do
	for c=1, 10 do
		idx = idx + 1
		gridWnd:AddSlot(r, c, dataList[idx])
	end
end
gridWnd:ForceReLayout()
]]
-------------------------
local clsGridCell = class("clsGridCell")

function clsGridCell:ctor(CellId, CellData)
	self._CellId = CellId
	self._CellData = CellData
	self._bSelected = false
	self._CellComp = nil
end

function clsGridCell:dtor()
	if self._CellComp then
		KE_SafeDelete(self._CellComp)
		self._CellComp = nil 
	end
end

function clsGridCell:GetCellId() return self._CellId end
function clsGridCell:GetCellData() return self._CellData end
function clsGridCell:GetCellComp() return self._CellComp end
function clsGridCell:IsSelected() return self._bSelected end

------------------------------------------------------------------

clsCompGrid = class("clsCompGrid", function() return ccui.ListView:create() end, clsCoreObject)

clsCompGrid:RegisterEventType("ec_click_cell")

function clsCompGrid:ctor(parent, RowShowCount, ColShowCount, CellWid, CellHei, ListWid, ListHei)
	self:EnableNodeEvents()
	clsCoreObject.ctor(self)
	if parent then KE_SetParent(self, parent) end
	
	--
	RowShowCount = RowShowCount or 5
	ColShowCount = ColShowCount or 5
	CellWid = CellWid or 100
	CellHei = CellHei or 100
	ListWid = ListWid or CellWid*ColShowCount
	ListHei = ListHei or CellHei*RowShowCount
	assert(ListWid and ListHei and CellWid and CellHei, "这些参数不可为空")
	
	--
	self._RowList = {}
	self.tAllCellById = new_weak_table("v")
	
	self._HighLightImgPath = ""
	
	self._RowShowCount = RowShowCount
	self._ColShowCount = ColShowCount
	self._RowCount = RowShowCount
	self._ColCount = ColShowCount
	
	self.mCellParent = nil
	self.mInerContainer = nil
	
	self.iDirection = ccui.ScrollViewDir.vertical
	self.iListWid = ListWid
	self.iListHei = ListHei
	self.iCellWidth = CellWid
	self.iCellHeight = CellHei
	
	if self.iDirection == ccui.ScrollViewDir.vertical then 
		self.iMaxShowCnt = math.ceil(ListHei/CellHei)
	else
		self.iMaxShowCnt = math.ceil(ListWid/CellWid)
	end
	self.iMaxShowCnt = math.max(1, self.iMaxShowCnt)
	
	--
	self:_OnInit(self.iDirection, ListWid, ListHei)
end

function clsCompGrid:dtor()
	self:_RemoveAll()
end

function clsCompGrid:_OnInit(Direction, ListWid, ListHei, bkgImgPath)
	self:setDirection(Direction)
	self:setBounceEnabled(true)
	self:setBackGroundImageScale9Enabled(true)
	if bkgImgPath then self:setBackGroundImage(bkgImgPath) end
	self:setContentSize(cc.size(ListWid, ListHei))
	
	local default_item = ccui.Layout:create()
	default_item:setTouchEnabled(true)
	default_item:setContentSize(ListWid, ListHei)
	self:setItemModel(default_item)
	
	self:pushBackDefaultItem()
	self.mCellParent = self:getItem(0)
	self.mInerContainer = self:getInnerContainer()  -- self.mCellParent:getParent()
	
	self:_UpdateCellParentSize()
	
	-- 事件
	self:addScrollViewEventListener(function(sender, evenType)
		if evenType == 9 then  -- InerContainer位置发生了变化
			self:_OnContainerPosChg(self.mInerContainer:getPosition())
		end
	end)
end

function clsCompGrid:_UpdateCellParentSize()
	local OldWid, OldHei = self.iWidCellParent, self.iHeiCellParent
	
	local ConWid, ConHei = self.iListWid, self.iListHei
	if self.iDirection == ccui.ScrollViewDir.vertical then 
		ConHei = math.max(self.iCellHeight*#self._RowList, ConHei)
	else
		local RealColCnt = self._RowList[1] and #self._RowList[1] or 1
		ConWid = math.max(self.iCellWidth*RealColCnt, ConWid)
	end
	
	if OldWid~=ConWid or OldHei~=ConHei then
		self.iWidCellParent, self.iHeiCellParent = ConWid, ConHei
		self.mCellParent:setContentSize(ConWid, ConHei)
		self:forceDoLayout()
	end
end

function clsCompGrid:_CalCellPos(iRow,iCol)
	return (iCol-0.5)*self.iCellWidth, self.iHeiCellParent+(-iRow+0.5)*self.iCellHeight
end

function clsCompGrid:_OnContainerPosChg(x,y)
	if self.iDirection == ccui.ScrollViewDir.vertical then 
		local bottom_row = #self._RowList + math.ceil(y/self.iCellHeight) 
		local top_row = bottom_row - self.iMaxShowCnt
		self:_OnSeeableCellsChg(top_row, bottom_row, 1, self._ColCount)
	else
		local left_col = -math.floor(x/self.iCellWidth) 
		local right_col = left_col + self.iMaxShowCnt
		self:_OnSeeableCellsChg(1, self._RowCount, left_col, right_col)
	end
end

function clsCompGrid:_OnSeeableCellsChg(top_row, bottom_row, left_col, right_col)
	if self._top_row==top_row and self._bottom_row==bottom_row and self._left_col==left_col and self._right_col==right_col then
		return
	end
	self._top_row = top_row 
	self._bottom_row = bottom_row 
	self._left_col = left_col 
	self._right_col = right_col
	
	for r = top_row, bottom_row do
		for c = left_col, right_col do
			self:_OnCellSeeable(r, c)
		end
	end
end

function clsCompGrid:_OnCellSeeable(iRow, iCol)
	local CellObj = self._RowList[iRow] and self._RowList[iRow][iCol]
	if not CellObj then return end
	if CellObj._CellComp then return end
	--创建子元素
	CellObj._CellComp = self._fCellCreator(CellObj)
	KE_SetParent(CellObj._CellComp, self.mCellParent)
	CellObj._CellComp:setPosition(self:_CalCellPos(iRow,iCol))
--	utils.RegClickEvent(CellObj._CellComp, function(sender)
--		logger.normal("点击：",iRow,iCol)
--		self:SetSelectCell(CellObj)
--	end)
	--刷新子元素组件
	self:_RefleshCellComp(CellObj)
end

-------------------
-- 以下为对外接口
-------------------
function clsCompGrid:SetCellCreator(cellCreator)
	assert(is_function(cellCreator), "Cell的创建接口必须为函数")
	self._fCellCreator = cellCreator
end

function clsCompGrid:SetCellReflesher(cellReflesher)
	assert(is_function(cellReflesher), "Cell的刷新接口必须为函数")
	self._fCellReflesher = cellReflesher
end

function clsCompGrid:Expand(Cnt)
	Cnt = Cnt or 1
	local bSucc = false
	for i=1, Cnt do
		bSucc = true
		table.insert(self._RowList, {})
	end
	if bSucc then
		self:_UpdateCellParentSize()
	end
end

-- Insert或Remove后须手动调用一下ForceReLayout才会刷新视图。
function clsCompGrid:AddSlot(iRow, iCol, CellData, CellId)
	if CellId and self.tAllCellById[CellId] then
		assert(false, "已经添加过该ID的元素："..CellId)
		return 
	end
	if self.iDirection == ccui.ScrollViewDir.vertical then 
		assert(iCol>=1 and iCol<=self._ColCount)
	else
		assert(iRow>=1 and iRow<=self._RowCount)
	end
	
	local OldRowCnt = #self._RowList
	
	if not self._RowList[iRow] or OldRowCnt < iRow then
		local LastRow = OldRowCnt + 1
		for i=LastRow, iRow do
			self._RowList[i] = self._RowList[i] or {}
		end
	end
	
	self._RowList[iRow][iCol] = self._RowList[iRow][iCol] or clsGridCell.new(CellId, CellData) 
	
	self:UpdateSlotDataByPos(iRow, iCol, CellData, CellId)
	
	if OldRowCnt ~= #self._RowList then
		self:_UpdateCellParentSize()
	end
end

function clsCompGrid:RemoveSlotByPos(iRow,iCol)
	if not self._RowList[iRow] then return end
	if not self._RowList[iRow][iCol] then return end
	local CellObj = self._RowList[iRow][iCol]
	if self._CurSelectCell == CellObj then self._CurSelectCell = nil end
	if CellObj._CellId then self.tAllCellById[CellObj._CellId] = nil end
	KE_SafeDelete(CellObj)
	self._RowList[iRow][iCol] = nil 
end

function clsCompGrid:RemoveSlotById(CellId)
	local iRow,iCol = self:GetSlotPosById(CellId)
	if iRow and iCol then
		self:RemoveSlotByPos(iRow,iCol)
	end
end

-- Insert或Remove后须手动调用一下ForceReLayout才会刷新视图。
function clsCompGrid:RemoveRow(iRow)
	iRow = iRow or #self._RowList
	if not self._RowList[iRow] then return end
	
	local ColList = self._RowList[iRow]
	for c, CellObj in pairs(ColList) do
		if self._CurSelectCell == CellObj then self._CurSelectCell = nil end
		if CellObj._CellId then self.tAllCellById[CellObj._CellId] = nil end
		KE_SafeDelete(CellObj)
	end
	table.remove(self._RowList, iRow)
	
	self:_UpdateCellParentSize()
end

function clsCompGrid:_RemoveAll()
	self._CurSelectCell = nil
	for r, ColList in pairs(self._RowList) do
		for c, CellObj in pairs(ColList) do
			KE_SafeDelete(CellObj)
		end
	end
	self._RowList = {}
	self.tAllCellById = new_weak_table("v")
	self._top_row = nil
	self._bottom_row = nil
	self._left_col = nil
	self._right_col = nil
end

function clsCompGrid:RemoveAll()
	self:_RemoveAll()
	self:_UpdateCellParentSize()
end

-- Insert或Remove后须手动调用一下ForceReLayout刷新视图。
function clsCompGrid:ForceReLayout()
	self._top_row = nil
	self._bottom_row = nil
	self._left_col = nil
	self._right_col = nil
	
	for r, ColList in pairs(self._RowList) do
		for c, CellObj in pairs(ColList) do
			if CellObj._CellComp then 
				CellObj._CellComp:setPosition(self:_CalCellPos(r,c))
			end
		end
	end
	
	self:_OnContainerPosChg(self.mInerContainer:getPosition())
end


function clsCompGrid:DelSlotDataByPos(iRow, iCol)
	if not self._RowList[iRow] or not self._RowList[iRow][iCol] then 
		assert(false, string.format("不存在该格子：%d,%d",iRow,iCol))
		return 
	end
	
	local CellObj = self._RowList[iRow][iCol]
	if CellObj._CellId then
		self.tAllCellById[CellObj._CellId] = nil
	end
	CellObj._CellId = nil
	CellObj._CellData = nil
	
	self:_RefleshCellComp(CellObj)
end

function clsCompGrid:DelSlotDataById(CellId)
	if not self.tAllCellById[CellId] then
		logger.normal("删除失败：不存在该ID：",CellId)
		return 
	end
	
	local CellObj = self.tAllCellById[CellId]
	CellObj._CellData = nil
	CellObj._CellId = nil
	self.tAllCellById[CellId] = nil
	
	self:_RefleshCellComp(CellObj)
end

function clsCompGrid:UpdateSlotDataByPos(iRow, iCol, CellData, CellId)
	if CellData == nil then
		assert(false, "无效的数据")
		return
	end
	if not self._RowList[iRow] or not self._RowList[iRow][iCol] then 
		assert(false, string.format("不存在该格子：%d,%d",iRow,iCol))
		return 
	end
	
	local CellObj = self._RowList[iRow][iCol]
	CellObj._CellData = CellData 
	
	if CellId then
		if CellObj._CellId and CellObj._CellId ~= CellId then
			self.tAllCellById[CellObj._CellId] = nil
		end
		CellObj._CellId = CellId
		self.tAllCellById[CellId] = CellObj
	end
	
	self:_RefleshCellComp(CellObj)
end

function clsCompGrid:UpdateSlotDataById(CellId, CellData)
	if not self.tAllCellById[CellId] then
		logger.normal("更新失败：不存在该ID：",CellId)
		return 
	end
	
	local CellObj = self.tAllCellById[CellId]
	CellObj._CellData = CellData
	if CellData == nil then
		CellObj._CellId = nil
		self.tAllCellById[CellId] = nil
	end
	self:_RefleshCellComp(CellObj)
end

function clsCompGrid:RefleshCellCompByPos(r,c)
	if not self._RowList[r] then return end
	if not self._RowList[r][c] then return end
	self:_RefleshCellComp(self._RowList[r][c])
end

function clsCompGrid:RefleshCellCompById(id)
	if not self.tAllCellById[id] then return end
	self:_RefleshCellComp(self.tAllCellById[id])
end

function clsCompGrid:_RefleshCellComp(CellObj)
	local CellComp = CellObj and CellObj._CellComp
	if not CellComp then return end
	if CellObj._bSelected then
		self:HighLightSelectComp(CellComp, true)
	end
	if self._fCellReflesher then
		self._fCellReflesher(CellComp, CellObj)
	end
end

--------------------------------------------------------------

function clsCompGrid:GetCellParent() return self.mCellParent end
function clsCompGrid:GetInerContainer() return self.mInerContainer end
function clsCompGrid:GetRowList() return self._RowList end
function clsCompGrid:GetRowCount() return #self._RowList end
function clsCompGrid:GetColCount() return self._ColCount end
function clsCompGrid:GetCellByPos(r,c) return self._RowList[r] and self._RowList[r][c] end
function clsCompGrid:GetCellById(id) return self.tAllCellById[id] end
function clsCompGrid:GetCellCompById(id) return self.tAllCellById[id] and self.tAllCellById[id]._CellComp end
function clsCompGrid:GetCellCompByPos(r,c) return self._RowList[r] and self._RowList[r][c] and self._RowList[r][c]._CellComp end

function clsCompGrid:GetCellDataById(CellId)
	if not CellId then return nil end
	return self.tAllCellById[CellId] and self.tAllCellById[CellId]._CellData
end

function clsCompGrid:GetFirstEmptyPos()
	local RowCnt, ColCnt = #self._RowList, self._ColCount
	for r=1, RowCnt do
		for c=1, ColCnt do
			if not self._RowList[r] or not self._RowList[r][c] then
				return r, c
			end
			if not self._RowList[r][c]._CellData then
				return r, c
			end
		end
	end
	return nil 
end

function clsCompGrid:ForceGetFirstEmptyPos()
	local r,c = self:GetFirstEmptyPos()
	if not r then 
		self:Expand() 
		r, c = self:GetFirstEmptyPos()
	end
	return r,c
end

function clsCompGrid:GetSlotPosById(id) 
	if id == nil then return nil end
	for r, ColList in pairs(self._RowList) do
		for c, CellObj in pairs(ColList) do
			if CellObj._CellId == id then 
				return r,c 
			end
		end
	end
	return nil 
end

function clsCompGrid:GetPosOfCellComp(CellComp)
	if not CellComp then return nil end
	for r, ColList in pairs(self._RowList) do
		for c, CellObj in pairs(ColList) do
			if CellObj._CellComp == CellComp then 
				return r,c 
			end
		end
	end
	return nil 
end

function clsCompGrid:GetCellPosByCellObj(target)
	if not target then return nil end
	for r, ColList in pairs(self._RowList) do
		for c, CellObj in pairs(ColList) do
			if CellObj == target then 
				return r,c 
			end
		end
	end
	return nil 
end

function clsCompGrid:ForeachCellObjs(Func)
	for r, ColList in pairs(self._RowList) do
		for c, CellObj in pairs(ColList) do
			Func(CellObj, r, c)
		end
	end
end

--------------------------------------------------------

function clsCompGrid:SetHighLightImgPath(imgpath)
	self._HighLightImgPath = imgpath
end

function clsCompGrid:HighLightSelectComp(Comp, bHighLight)
	if not Comp then return end
	if bHighLight and self._HighLightImgPath then
		if not Comp._ListHighLightSpr then 
			Comp._ListHighLightSpr = cc.Scale9Sprite:create(self._HighLightImgPath)
			local SizeComp = Comp:getContentSize()
			Comp._ListHighLightSpr:setContentSize(SizeComp)
			Comp._ListHighLightSpr:setPosition(SizeComp.width/2, SizeComp.height/2)
			KE_SetParent(Comp._ListHighLightSpr, Comp)
		end
	else
		if Comp._ListHighLightSpr then
			KE_SafeDelete(Comp._ListHighLightSpr)
			Comp._ListHighLightSpr = nil 
		end
	end
end

function clsCompGrid:SetSelectCellSilent(CellObj)
	if self._CurSelectCell then
		self._CurSelectCell._bSelected = false
		self:HighLightSelectComp(self._CurSelectCell._CellComp, false)
	end
	
	self._CurSelectCell = CellObj
	
	if CellObj then 
		CellObj._bSelected = true 
		self:HighLightSelectComp(CellObj._CellComp, true)
	end
end

function clsCompGrid:SetSelectCell(CellObj)
	self:SetSelectCellSilent(CellObj)
	self:FireEvent("ec_click_cell", CellObj)
end

function clsCompGrid:SetSelectedPos(r,c)
	self:SetSelectCell(self._RowList[r] and self._RowList[r][c])
end

function clsCompGrid:SetSelectedId(CellId)
	self:SetSelectCell(self.tAllCellById[CellId])
end

function clsCompGrid:GetSelectedCell()
	return self._CurSelectCell
end

function clsCompGrid:GetSelectedPos()
	return self:GetCellPosByCellObj(self._CurSelectCell)
end

function clsCompGrid:GetSelectedId()
	return self._CurSelectCell and self._CurSelectCell._CellId
end
