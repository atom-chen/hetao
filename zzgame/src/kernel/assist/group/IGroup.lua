-------------------------
-- 群组
-------------------------
module("grp", package.seeall)

clsIGroup = class("clsIGroup")

function clsIGroup:ctor(id)
	assert(id, "ERROR: no clsIGroup id")
	self.Uid = id
	self.tPartnerList = {}	--好友列表
	self.tEnemyList = {}	--敌人列表
end

function clsIGroup:dtor()
	self:ClearAllPartners()
	self:ClearAllEnemys()
end

function clsIGroup:GetUid()
	return self.Uid
end

-------------------------------------------------------

function clsIGroup:GetPartnerList()
	return self.tPartnerList or {}
end

function clsIGroup:ClearAllPartners()
	for _, grp in pairs(self.tPartnerList) do
		grp.tPartnerList[self.Uid] = nil
	end
	self.tPartnerList = {}
end

function clsIGroup:AddPartner(grp)
	if not grp then return end
	local partner_id = grp:GetUid()
	
	if grp==self or partner_id==self.Uid then
		assert(false, "ERROR: self AddPartner self")
		return
	end
	
	self:RemoveEnemy(grp)
	grp.tPartnerList[self.Uid] = self
	self.tPartnerList[partner_id] = grp
end

function clsIGroup:RemovePartner(partner)
	if not partner then return end
	local id = is_number(partner) and partner or partner:GetUid()
	local grp = self.tPartnerList[id]
	if grp then grp.tPartnerList[self.Uid] = nil end
	self.tPartnerList[id] = nil
end

-------------------------------------------------------

function clsIGroup:GetEnemyList()
	return self.tEnemyList
end

function clsIGroup:ClearAllEnemys()
	for _, grp in pairs(self.tEnemyList) do
		grp.tEnemyList[self.Uid] = nil
	end
	self.tEnemyList = {}
end

function clsIGroup:AddEnemy(grp)
	if not grp then return end
	local enemy_id = grp:GetUid()
	
	if grp==self or enemy_id==self.Uid then
		logger.error("ERROR: self add self", enemy_id, self.Uid)
		return
	end
	
	self:RemovePartner(grp)
	grp.tEnemyList[self.Uid] = self
	self.tEnemyList[enemy_id] = grp
end

function clsIGroup:RemoveEnemy(enemy)
	if not enemy then return end
	local id = is_number(enemy) and enemy or enemy:GetUid()
	local grp = self.tEnemyList[id]
	if grp then grp.tEnemyList[self.Uid] = nil end
	self.tEnemyList[id] = nil
end

