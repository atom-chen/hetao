if device.platform == "android" then
	luaj = require("cocos.cocos2d.luaj")
elseif device.platform == "ios" then
	luaoc = require("cocos.cocos2d.luaoc")
elseif device.platform == "mac" then
	luaoc = require("cocos.cocos2d.luaoc")
end

if device.platform == "android" then
	require("kernel.platform.android.SalmonUtils")
elseif device.platform == "ios" then
	require("kernel.platform.ios.SalmonUtils")
elseif device.platform == "mac" then
	require("kernel.platform.SalmonUtils")
else
	require("kernel.platform.SalmonUtils")
end

require("kernel.platform.PlatformHelper")
require("kernel.platform.HttpHelper")
require("kernel.platform.KeyBoard")
