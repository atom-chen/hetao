---------------
-- 攻击目标寻找逻辑
---------------
module("ai",package.seeall)

FOR_BUDDY = {
	SELF = 1,
	TEAMMATE = 2,
	SELF_TEAMMATE = 3,
	ENEMY =	4,
}
PRIORITY = {
	NONE = 0,
	RANDOM = 1,
	LESS_HP = 2,
	EASY_DIE = 3,
	NEAREST = 4,
	FARTHEST = 5,
}

clsTargetLogic = class("clsTargetLogic")

function clsTargetLogic:ctor(ForBuddy, Priority, Count)
	self.curTargets = {}
	self.ForBuddy = ForBuddy
	self.Priority = Priority
	self.Count = Count
end

function clsTargetLogic:dtor()
	
end

local math_abs = math.abs
local SquareDistance = math.SquareDistance
function clsTargetLogic:SortTargets(theOwner, targets)
	if self.Priority == PRIORITY.RANDOM then
		table.shuffle(targets)
		
	elseif self.Priority == PRIORITY.LESS_HP then
		table.sort(targets, function(a,b) 
			return a:GetCurHP() < b:GetCurHP() 
		end)
		
	elseif self.Priority == PRIORITY.EASY_DIE then
		table.sort(targets, function(a,b) 
			if a:GetCurHP() == b:GetCurHP() then
				return a:GetPhyDef() < b:GetPhyDef()
			end
			return a:GetCurHP() < b:GetCurHP() 
		end)
		
	elseif self.Priority == PRIORITY.NEAREST then 
		table.sort(targets, function(a,b) 
			return SquareDistance(a:GetPosX(),a:GetPosY(), theOwner:GetPosX(),theOwner:GetPosY()) < SquareDistance(b:GetPosX(),b:GetPosY(), theOwner:GetPosX(),theOwner:GetPosY())
		end)
		
	elseif self.Priority == PRIORITY.FARTHEST then 
		table.sort(targets, function(a,b) 
			return SquareDistance(a:GetPosX(),a:GetPosY(), theOwner:GetPosX(),theOwner:GetPosY()) > SquareDistance(b:GetPosX(),b:GetPosY(), theOwner:GetPosX(),theOwner:GetPosY())
		end)
	end
	
	return targets
end

-- aliveType: 1：活着的    2：死亡的
function clsTargetLogic:Search(theOwner, aliveType)
	local targets = {}
	
	if self.ForBuddy == FOR_BUDDY.SELF then
		if aliveType == 1 then 
			if theOwner:IsAlive() then
				return { theOwner }
			end 
		elseif aliveType == 2 then 
			if theOwner:IsDead() then
				return { theOwner }
			end 
		else 
			return { theOwner }
		end 
		
	elseif self.ForBuddy == FOR_BUDDY.TEAMMATE then
		targets = self:SortTargets( theOwner, theOwner:GetTeammateList(aliveType) )
		
	elseif self.ForBuddy == FOR_BUDDY.SELF_TEAMMATE then
		local teammateList = theOwner:GetTeammateList(aliveType) or {}
		table.insert(teammateList, 1, theOwner)
		targets = self:SortTargets( theOwner, teammateList )
		
	elseif self.ForBuddy == FOR_BUDDY.ENEMY then
		targets = self:SortTargets( theOwner, theOwner:GetEnemyList(aliveType) )
		
	end
	
	if self.Count >= 1 then
		while (#targets > self.Count) do
			table.remove(targets, #targets)
		end
	end
	
	return targets
end

function clsTargetLogic:SearchInPool(theOwner, objList)
	return self:SortTargets( theOwner, objList )
end

function clsTargetLogic:Clone()
	return clsTargetLogic.new(self.ForBuddy, self.Priority, self.Count)
end
