-------------------------
-- 算法库
-------------------------

-- 前序遍历
function PreorderTraversal(NodeInfo, VisitFunc)
	local function Traversal(CurNode, ParentNode, i)
		if not CurNode then return end
		if VisitFunc(CurNode, ParentNode, i) == "break" then return end
		
		if CurNode.Childrens then
			for idx, SubNode in ipairs(CurNode.Childrens) do
				Traversal(SubNode, CurNode, idx)
			end
		end
	end
	
	Traversal(NodeInfo)
end

-- 后序遍历
function PostorderTraversal(NodeInfo, VisitFunc)
	local function Traversal(CurNode, ParentNode, i)
		if not CurNode then return end
		
		if CurNode.Childrens then
			local Cnt = #CurNode.Childrens
			for idx=Cnt,1,-1 do
				Traversal(CurNode.Childrens[idx], CurNode, idx)
			end
		end
		
		VisitFunc(CurNode, ParentNode, i)
	end
	
	Traversal(NodeInfo)
end
