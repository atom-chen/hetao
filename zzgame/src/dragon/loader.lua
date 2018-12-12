local loader = {}

loader.filelist = {
    "dragon.loader",
    "dragon.config",

    "dragon.model.GlobalEvents",
    "dragon.model.DragonMgr",
    "dragon.model.ChatMgr",
    "dragon.model.WSHelper",

    "dragon.proto.proto_register",
    "dragon.proto.protocal_define.dragon",
    "dragon.proto.rpc.dragon",

    "dragon.view.DragonMainUI",
    "dragon.view.DragonScene",
    "dragon.view.DragonBoard",
    "dragon.view.DragonHelp",
    "dragon.view.DragonInfo",
    "dragon.view.DragonRank",
}

-- 卸载模块文件
function loader.UnLoad()
    local string_find = string.find 
    for k, v in pairs(package.loaded) do 
       -- print("sssssssssssss", k, v)
        if string_find(k, "dragon") then
            print("卸载文件：", k)
            package.loaded[k] = nil
        end
    end
end

-- 重新加载模块文件
function loader.ReLoad()
    loader.UnLoad()

    for _, filepath in ipairs(loader.filelist) do
        require(filepath)
    end
end

-- 进入本模块的唯一入口
function loader.Enter()
    loader.ReLoad()
    require("dragon.proto.proto_register"):RegisterAllProtocal()
    -- 进入长龙场景
    local ClsDragonMgr = require("dragon.model.DragonMgr")
    ClsDragonMgr.GetInstance():req_domain_list()
    ClsSceneManager.GetInstance():Turn2Scene("clsDragonScene")

    --[[
    -- 下载测试
    print("开始下载")
    local szUrl = "http://118.24.69.192:8080/examples/servlets/hotupdate/yicai/maios/aicai/assets/res/project.manifest"
    local szSaveName = "testdown"
    local szSavePath = GAME_CONFIG.LOCAL_DIR
    local handler = function(nMsgType, nDownType, nExtra)
        print("下载信息：", nMsgType, nDownType, nExtra)
        if nDownType == 3 then
            KE_SetTimeout(1, function()
                local str = io.readfile(szSavePath.."/"..szSaveName)
                --print(str)
                local json = require("kernel.framework.json")
                print("ssssssssssssssssssssssssssssss")
                dump(json.decode(str))
                print("ssssssssssssssssssssssssssssss")
            end)
        end
    end
    downFileAsync(szUrl,szSaveName,szSavePath,handler)
    ]]--
end

return loader