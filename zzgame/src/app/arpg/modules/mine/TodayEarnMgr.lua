ClsTodayEarnMgr = class("ClsTodayEarnMgr",clsCoreObject)
ClsTodayEarnMgr.__is_singleton = true

function ClsTodayEarnMgr:ctor()
    clsCoreObject.ctor(self)
    self.data = nil 
end

function ClsTodayEarnMgr:SaveData(recvdata)
    self.data = recvdata
end

function ClsTodayEarnMgr:GetData()
    return self.data
end