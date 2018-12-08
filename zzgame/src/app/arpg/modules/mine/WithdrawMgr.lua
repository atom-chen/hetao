ClsWithdrawMgr = class("ClsWitehdrawMgr",clsCoreObject)
ClsWithdrawMgr.__is_singleton = true

function ClsWithdrawMgr:ctor()
    clsCoreObject.ctor(self)
    self.WithdrawData = {}
end

function ClsWithdrawMgr:SaveWithdrawData(recvdata)
    self.WithdrawData = recvdata
end

function ClsWithdrawMgr:GetWithdrawData()
    return self.WithdrawData
end