-------------------------
-- 树形控件
-------------------------
local ICON_SIZE = 40
local HALF_ICON_SIZE = 20
local TEXT_WID = 200

clsCompTree = class("clsCompTree", ccui.ScrollView, clsCoreObject, clsTree)

clsCompTree:RegisterEventType("ec_add_node")
clsCompTree:RegisterEventType("ec_del_node")
clsCompTree:RegisterEventType("ec_chg_nodeid")
clsCompTree:RegisterEventType("ec_select_changed")
clsCompTree:RegisterEventType("ec_node_expand")

function clsCompTree:ctor(parent, ListWid, ListHei, bkgImgPath)
	clsScrollView.ctor(self, parent)
	clsCoreObject.ctor(self)
	clsTree.ctor(self)
	assert(ListWid and ListHei, "这些参数不可为空")
	
	self.iListWid = ListWid
	self.iListHei = ListHei
	self._BtnList = {}
	
	--
	self:setDirection(ccui.ScrollViewDir.both)
--	self:setBounceEnabled(true)
	self:setBackGroundImageScale9Enabled(true)
	self:setBackGroundImage(bkgImgPath)
	self:setContentSize(cc.size(ListWid, ListHei))
	
	self.mCellParent = cc.Node:create()
	self:addChild(self.mCellParent)
end

function clsCompTree:dtor()
	
end

function clsCompTree:OnAddNode(Id, oTreeNode)
	self:Draw()
	self:FireEvent("ec_add_node", Id, oTreeNode)
end

function clsCompTree:OnDelNode(Id)
	if self.mSelectedId == Id then 
		self:SetSelectedNode(nil) 
	end
	KE_SafeDelete(self._BtnList[Id])
	self._BtnList[Id] = nil
	self:Draw()
	self:FireEvent("ec_del_node", Id)
end

function clsCompTree:OnNodeIdChanged(Id, NewId)
	self:Draw()
	self:FireEvent("ec_chg_nodeid", Id, NewId)
end

function clsCompTree:OnNodeExpand(Id, bExpanded)
	self:Draw()
	self:FireEvent("ec_node_expand", Id, bExpanded)
end


function clsCompTree:GenTextContent(oTreeNode)
	return oTreeNode._Id
end

function clsCompTree:CreateNode(oTreeNode)
	if not self._BtnList[oTreeNode._Id] then
		self._BtnList[oTreeNode._Id] = utils.CreateButton("res/uiface/commons/panels/edit_bg_2.png")
		local Btn = self._BtnList[oTreeNode._Id]
		Btn:setScale9Enabled(true)
		Btn:setContentSize(TEXT_WID,ICON_SIZE)
		Btn:setAnchorPoint(cc.p(0,0.5))
		Btn:setTitleAlignment(cc.TEXT_ALIGNMENT_LEFT)
		Btn:setTitleText( self:GenTextContent(oTreeNode) ) 
		self.mCellParent:addChild(Btn)
		
		utils.RegClickEvent(Btn, function(sender)
			self:SetSelectedNode(oTreeNode._Id)
		end)
		Btn:setSwallowTouches(false)
	end
	return self._BtnList[oTreeNode._Id]
end

function clsCompTree:ResetNodeType(oTreeNode)
	local Btn = self._BtnList[oTreeNode._Id]
	
	if oTreeNode.Childrens and #oTreeNode.Childrens>0 then
		if not Btn.m_BtnExpand then
			Btn.m_BtnExpand = utils.CreateButton("res/uiface/commons/panels/dividing_dark.png")
			local BtnExpand = Btn.m_BtnExpand
			BtnExpand:setScale9Enabled(true)
			BtnExpand:setContentSize(30,30)
			BtnExpand:setPosition(-HALF_ICON_SIZE,HALF_ICON_SIZE)
			BtnExpand:setTitleFontSize(28)
			BtnExpand:setTitleText("+") 
			Btn:addChild(BtnExpand)
			
			utils.RegClickEvent(BtnExpand, function()
				oTreeNode:SetExpanded(not oTreeNode:IsExpanded())
				BtnExpand:setTitleText(oTreeNode:IsExpanded() and "+" or "-")
				self:Draw()
			end)
		end
	elseif Btn.m_BtnExpand then
		KE_SafeDelete(Btn.m_BtnExpand)
		Btn.m_BtnExpand = nil
	end
end

function clsCompTree:Draw()
	for _, Btn in pairs(self._BtnList) do Btn:setVisible(false) end
	
	local idx = 0
	local level = 0
	local max_level = 0
	
	local function DrawNode(ParentNode)
		level = level + 1
		max_level = math.max(max_level, level)
		
		for _, oTreeNode in ipairs(ParentNode.Childrens) do
			local Btn = self:CreateNode(oTreeNode)
			self:ResetNodeType(oTreeNode)
			Btn:setVisible(true)
			idx = idx + 1
			Btn:setPosition((level-1)*ICON_SIZE, -idx*ICON_SIZE+HALF_ICON_SIZE)
			
			if oTreeNode:IsExpanded() and oTreeNode.Childrens and #oTreeNode.Childrens>0 then
				DrawNode(oTreeNode)
			end
		end
		
		level = level - 1
	end
	
	DrawNode(self)
	
	self._TotalW = max_level * ICON_SIZE + TEXT_WID
	self._TotalH = idx * ICON_SIZE
	local Wid = math.max(self._TotalW, self.iListWid)
	local Hei = math.max(self._TotalH, self.iListHei)
	self:setInnerContainerSize(cc.size(Wid,Hei))
	self.mCellParent:setPosition(ICON_SIZE, Hei)
end


function clsCompTree:SetSelectedNodeSilent(SelectId)
	KE_SafeDelete(self.mSprHigh)
	self.mSprHigh = nil 
	
	self.mSelectedId = SelectId
	
	if SelectId == nil or not self._AllNodes[SelectId] then
		self.mSelectedId = nil
		return
	end
	
	self.mSprHigh = cc.Scale9Sprite:create("res/uiface/commons/frames/frame_choosed.png")
	KE_SetParent(self.mSprHigh, self._BtnList[SelectId], 99)
	local tSize = self._BtnList[SelectId]:getContentSize()
	self.mSprHigh:setContentSize(tSize.width,tSize.height)
	self.mSprHigh:setPosition(tSize.width/2,tSize.height/2)
end

function clsCompTree:SetSelectedNode(SelectId)
	self:SetSelectedNodeSilent(SelectId)
	self:FireEvent("ec_select_changed", self.mSelectedId)
end

function clsCompTree:GetSelectedNode()
	if not self._AllNodes[self.mSelectedId] then
		self.mSelectedId = nil
	end
	return self.mSelectedId
end

