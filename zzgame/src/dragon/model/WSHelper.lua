local WSHelper = {}

function WSHelper:Init(url)
    local clsWebSock = require("dragon.model.web_socket")
    self.Ws = self.Ws or clsWebSock.new(url)
end

function WSHelper:Destroy()
    KE_SafeDelete(self.Ws)
    self.Ws = nil
end

function WSHelper:SendLogin()
    local data = {
        type = "login",
        token = HttpUtil.token,
    }
    self.Ws:SendMsg(data)
end

-- {"type":"txt","msg":"xxxxxx","to":123}
function WSHelper:SendTxtMsg( strMsg, toUser )
    if not strMsg or strMsg == "" then 
        print("发送内容不可为空") 
        utils.TellMe("请输入有效的信息")
        return false 
    end
    local data = {
        type = "txt",
        msg = strMsg,
        to = toUser,
    }
    return self.Ws:SendMsg(data)
end

-- {"type":"img","msg":"http://xxxx.png","to":123}
function WSHelper:SendImgMsg( strMsg, toUser )
    if not strMsg or strMsg == "" then 
        print("发送内容不可为空") 
        utils.TellMe("请输入有效的信息")
        return false 
    end
    local data = {
        type = "img",
        msg = strMsg,
        to = toUser,
    }
    return self.Ws:SendMsg(data)
end

-- {"type":"lottery","msg":"","to":123}
function WSHelper:SendLotteryMsg( strMsg, toUser )
    if not strMsg or strMsg == "" then 
        print("发送内容不可为空") 
        utils.TellMe("请输入有效的信息")
        return false 
    end
    local data = {
        type = "lottery",
        msg = strMsg,
        to = toUser,
    }
    return self.Ws:SendMsg(data)
end

-- {"type":"standings","msg":"","to":123}
function WSHelper:SendStandingsMsg( strMsg, toUser )
    if not strMsg or strMsg == "" then 
        print("发送内容不可为空") 
        utils.TellMe("请输入有效的信息")
        return false 
    end
    local data = {
        type = "standings",
        msg = strMsg,
        to = toUser,
    }
    return self.Ws:SendMsg(data)
end

cc.exports.WSHelper = WSHelper