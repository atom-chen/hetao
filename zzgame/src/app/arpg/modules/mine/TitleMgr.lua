ClsTitleMgr = class("ClsTitleMgr",clsCoreObject)

function ClsTitleMgr:ctor()
    clsCoreObject.ctor(self)
    self.TitleData = {}
end

function ClsTitleMgr:saveTitleData(recvdata)
    self.TitleData = recvdata
end

function ClsTitleMgr:getTitleData()
    return self.TitleData
end