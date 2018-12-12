ClsBetHistoryMgr = class("ClsBetHistoryMgr",clsCoreObject)
ClsBetHistoryMgr.__is_singleton = true

function ClsBetHistoryMgr:ctor()
    clsCoreObject.ctor(self)
    self.page = ""
    self.tBetHistory = {}
    self.tBetDetails = {}
    self.tDragonBet = false
end

function ClsBetHistoryMgr:SaveBetHistory(data)
    assert(data==nil or type(data)=="table")
    self.tBetHistory = data


end

function ClsBetHistoryMgr:GetBetHistory()
    return self.tBetHistory
end

function ClsBetHistoryMgr:SaveBetDetails(data)
    self.tBetDetails = data
end

function ClsBetHistoryMgr:GetBetDetails()
    return self.tBetDetails
end

function ClsBetHistoryMgr:SavePage(data)
    self.page = data
end

function ClsBetHistoryMgr:GetPage()
    return self.page
end

function ClsBetHistoryMgr:SaveDragonBet(data)
    self.tDragonBet = data
end

function ClsBetHistoryMgr:GetDragonBet()
    return self.tDragonBet
end