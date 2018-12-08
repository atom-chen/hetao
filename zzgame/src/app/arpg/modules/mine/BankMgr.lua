-------------------------------
-- 银行卡列表缓存数据
-------------------------------
ClsBankMgr = class("ClsBankMgr", clsCoreObject)
ClsBankMgr.__is_singleton = true

function ClsBankMgr:ctor()
	clsCoreObject.ctor(self)
end

function ClsBankMgr:dtor()

end

function ClsBankMgr:SetBankList(banklist)
	self._bankList = banklist
end

function ClsBankMgr:GetBankList()
	return self._bankList
end
