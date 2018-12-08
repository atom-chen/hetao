-------------------------
-- 跟节点
-------------------------
module("smartor",package.seeall)

local default_args = {
	["sNodeName"] = "树名",
}

local x_root_node = class("x_root_node", clsPromise)

x_root_node._default_args = default_args

function x_root_node:ctor(argInfo, Ctx)
	clsPromise.ctor(self, argInfo, Ctx)
	self._node_type = "x_root_node"
end

function x_root_node:OnProc()
	self._playOver = true
end

return x_root_node