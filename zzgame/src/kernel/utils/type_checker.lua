-------------------------
-- 类型检查扩展
-------------------------
local valid_layer_id = {
	[const.LAYER_VIEW] = true,
	[const.LAYER_PANEL] = true,
	[const.LAYER_POPWND] = true,
	[const.LAYER_DLG] = true,
	[const.LAYER_TOAST] = true,
	[const.LAYER_DRAG] = true,
	[const.LAYER_GUIDE] = true,
	[const.LAYER_LOADING] = true,
	[const.LAYER_CLICKEFF] = true,
	[const.LAYER_WAITING] = true,
	[const.LAYER_TOPEST] = true,
}
function TYPE_CHECKER.IsValidGameLayerId(iLayerId)
	return iLayerId and valid_layer_id[iLayerId]
end