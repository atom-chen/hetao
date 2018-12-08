-------------------------
-- 组管理器
-------------------------
module("grp", package.seeall)

clsIGroupMgr = class("clsIGroupMgr", clsCoreObject)

function clsIGroupMgr:ctor()
	clsCoreObject.ctor(self)
	
	self.tAllGroups = {}
end

function clsIGroupMgr:dtor()
	self:DoCleanup()
end

function clsIGroupMgr:DoCleanup()
	for grpID, grp in pairs(self.tAllGroups) do
		KE_SafeDelete(grp)
	end
	self.tAllGroups = {}
end

--@need override
function clsIGroupMgr:CreateGroup(grp_id)
	assert(false, "you should override me")
end

function clsIGroupMgr:RemoveGroup(grp_id)
	if self.tAllGroups[grp_id] then
		KE_SafeDelete(self.tAllGroups[grp_id])
		self.tAllGroups[grp_id] = nil
	end
end

function clsIGroupMgr:GetGroup(grp_id)
	return self.tAllGroups[grp_id]
end

function clsIGroupMgr:HasGroup(grp)
	return self.tAllGroups[grp:GetUid()] and true or false
end

function clsIGroupMgr:SetGroupRelation(grp_1, grp_2, relation)
	if is_number(grp_1) then grp_1 = self:GetGroup(grp_1) end
	if is_number(grp_2) then grp_2 = self:GetGroup(grp_2) end
	if grp_1 == grp_2 then return end
	
	if relation == const.RELATION_ENEMY then
		grp_1:AddEnemy(grp_2)
	elseif relation == const.RELATION_PARTNER then
		grp_1:AddPartner(grp_2)
	elseif relation == const.RELATION_NONE then
		grp_1:RemovePartner(grp_2)
		grp_1:RemoveEnemy(grp_2)
	else 
		assert(false, "参数错误: "..relation)
	end
end
