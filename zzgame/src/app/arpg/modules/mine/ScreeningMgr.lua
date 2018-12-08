---------------
-----筛选时间
---------------
ClsScreeningMgr = class("ClsScreeningMgr",clsCoreObject)

function ClsScreeningMgr:ctor()
    clsCoreObject.ctor(self)
    --type 1  提现记录    2   充值记录   3  账户明细
    self.type = ""
end

function ClsScreeningMgr:SaveType(data)
    self.type = data
end

function ClsScreeningMgr:GetType(data)
    return self.type
end
