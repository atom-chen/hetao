ClsAnounceMgr = class("ClsAnounceMgr",clsCoreObject)
ClsAnounceMgr.__is_singleton = true

function ClsAnounceMgr:ctor()
    clsCoreObject.ctor(self)
    self.data = {} 
end

function ClsAnounceMgr:SaveData(recvdata, tArgs)
    self.data[tArgs.type] = recvdata
end

function ClsAnounceMgr:GetData(Type)
    return self.data[Type]
end