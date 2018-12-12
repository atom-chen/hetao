-------------------------
-- 聊天室管理器
-------------------------
local json = require("kernel.framework.json")
local crypto = require("kernel.framework.crypto")


local ClsChatMgr = class("ClsChatMgr", clsCoreObject)
ClsChatMgr.__is_singleton = true

function ClsChatMgr:ctor()
	clsCoreObject.ctor(self)
    self.ChatRecord = {} --聊天记录
    self.BetData = {} --彩种信息
    self.YesterWin = {} --排行榜
end

function ClsChatMgr:dtor()

end

function ClsChatMgr:SaveChatRecord(recvdata)
    self.ChatRecord = recvdata
end

function ClsChatMgr:GetChatRecord()
    return self.ChatRecord
end

function ClsChatMgr:GetChatData(id)
    return self.ChatRecord[id]
end

function ClsChatMgr:AddChatRecord(data)
    table.insert( self.ChatRecord, data )
    return #self.ChatRecord
end

function ClsChatMgr:GetChatRecordCnt()
    return #self.ChatRecord
end

function ClsChatMgr:SaveBetData(recvdata)
    self.BetData = recvdata
end

function ClsChatMgr:GetBetData()
    return self.BetData
end

function ClsChatMgr:SaveYesterWin(recvdata)
    self.YesterWin = recvdata
end

function ClsChatMgr:GetYesterWin()
    return self.YesterWin
end

return ClsChatMgr
