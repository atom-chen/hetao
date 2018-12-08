-------------------------
-- 树结构
-------------------------
local clsTreeNode = class("clsTreeNode")

function clsTreeNode:ctor(Id, Pid, Data)
	self._Id = Id
	self._Pid = Pid
	self._Data = Data
	self._bExpanded = true
	self.Childrens = {}
end

function clsTreeNode:dtor()

end

function clsTreeNode:GetId() return self._Id end
function clsTreeNode:GetPid() return self._Pid end
function clsTreeNode:GetData() return self._Data end
function clsTreeNode:GetChildList() return self.Childrens end

function clsTreeNode:SetExpanded(bExpanded)
	self._bExpanded = bExpanded
end

function clsTreeNode:IsExpanded()
	return self._bExpanded
end

------------------------------------------

clsTree = class("clsTree")

function clsTree:ctor()
	clsCoreObject.ctor(self)
	self._AllNodes = {}
	self.Childrens = {}
end

function clsTree:dtor()
	self:DelAllNode()
end

function clsTree:IsEmpty() return table.is_empty(self.Childrens) end
function clsTree:GetNode(Id) return self._AllNodes[Id] end
function clsTree:GetChildList() return self.Childrens end

function clsTree:OnAddNode(Id, oTreeNode)
	assert(false, "子类重写")
end

function clsTree:OnDelNode(Id)
	assert(false, "子类重写")
end

function clsTree:OnNodeIdChanged(Id, NewId)
	assert(false, "子类重写")
end

function clsTree:OnNodeExpand(Id, bExpanded)
	assert(false, "子类重写")
end

function clsTree:AddNode(Id, Pid, Data)
	if Pid ~= nil then assert(self._AllNodes[Pid], "父节点不存在："..Pid) end
	assert(Id ~= nil, "Id不可为空")
	assert(not self._AllNodes[Id], "已经添加过该节点："..Id)
	
	local oTreeNode = clsTreeNode.new(Id, Pid, Data)
	self._AllNodes[Id] = oTreeNode
	
	if Pid ~= nil then 
		table.insert(self._AllNodes[Pid].Childrens, oTreeNode)
	else
		table.insert(self.Childrens, oTreeNode)
	end
	
	self:OnAddNode(Id, oTreeNode)
	
	return oTreeNode
end

function clsTree:DelNode(DelId)
	if DelId == nil then return end
	PreorderTraversal(self, function(CurNode, ParentNode, i)
		if CurNode._Id == DelId then
			--先删光子节点
			PostorderTraversal(self._AllNodes[DelId], function(CurDel, ParentOfCurDel, CurDelIdx)
				if ParentOfCurDel then
					local Id = CurDel._Id
					self._AllNodes[Id] = nil
					table.remove(ParentOfCurDel.Childrens, CurDelIdx)
					print("clsTree.DelNode", Id)
					self:OnDelNode(Id)
				end
			end)
			
			--再删自己
			self._AllNodes[DelId] = nil
			table.remove(ParentNode.Childrens, i)
			print("clsTree.DelNode", DelId)
			self:OnDelNode(DelId)
			
			return "break"
		end
	end)
	
	self:CheckValid()
end

function clsTree:DelAllNode()
	local Len = #self.Childrens
	for i=Len,1,-1 do
		self:DelNode(self.Childrens[i]._Id)
	end
	self._AllNodes = {}
	self.Childrens = {}
end

function clsTree:SetNodeExpanded(Id, bExpanded)
	if not self._AllNodes[Id] then return end
	self._AllNodes[Id]:SetExpanded(bExpanded)
	self:OnNodeExpand(Id, bExpanded)
end

function clsTree:ChgNodeId(Id, NewId)
	assert(NewId ~= nil, "新ID无效")
	if not self._AllNodes[Id] then return end
	if self._AllNodes[NewId] then return end
	local oTreeNode = self._AllNodes[Id]
	self._AllNodes[Id] = nil
	self._AllNodes[NewId] = oTreeNode
	oTreeNode._Id = NewId
	for _, ChildNode in ipairs(oTreeNode.Childrens) do
		ChildNode._Pid = NewId
	end
	self:OnNodeIdChanged(Id, NewId)
end

function clsTree:CheckValid()
	local idx = -1	--因为不计算自己在内
	PreorderTraversal(self, function(CurNode, ParentNode, i)
		idx = idx + 1
	end)
	assert( table.size(self._AllNodes) == idx, string.format("BUG：数目不一致  %d : %d", idx, table.size(self._AllNodes)) )
end
