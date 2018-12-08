ModuleUtil = {}

ModuleUtil.dragon = 1

function ModuleUtil.EnterModule(modId)
    if modId == ModuleUtil.dragon then
        local loader = require("dragon.loader")
        loader.Enter()
    else
        assert(false, "未定义的模块ID")
    end 
end 