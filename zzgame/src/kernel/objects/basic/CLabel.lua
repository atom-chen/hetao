-------------------------
-- 层
-------------------------
local label = cc.Label

function label:GetBoundSize()
	local sz = self:getContentSize()
	return cc.size(sz.width*self:getScale(), sz.height()*self:getScale())
end
