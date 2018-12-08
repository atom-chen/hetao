-------------------------
--
-- 小红点：
-- 1. 每个因素都可能引起多种类型的小红点更新
-- 2. 每个类型的小红点更新可能由多种因素引起
-- 3. 每一类型的小红点更新可能刷新一个或多个按钮，具体看哪些按钮使用了该类型的小红点
-- 4. 每个按钮只能注册唯一类型的小红点
--
-- 关键字：
-- factor:	 	引起小红点变化的因素
-- point_id: 	小红点类型
-- check_func: 	判断是否显示小红点的接口
-- red_button:	热点按钮
--
-------------------------
module("redpoint", package.seeall)

local REDPOINT_TABLE = {
	-- 签到
	["red_signin"] = {
		point_id = "red_signin",
		factor_list = {"c_signin","c_signin_list"},
		check_func = function()
			return false
		end,
	},
}

local MAP_FACTOR_2_REDCFGS = {}
for key, info in pairs(REDPOINT_TABLE) do
	assert( key==info.point_id, string.format("不一致 %s,%s", key, info.point_id) )
	for _, factor in ipairs(info.factor_list) do
		MAP_FACTOR_2_REDCFGS[factor] = MAP_FACTOR_2_REDCFGS[factor] or {}
		MAP_FACTOR_2_REDCFGS[factor][info.point_id] = info 
	end
end


function GetRedSprScale(Node)
	local iScale = 1
	while Node do
		iScale = iScale * Node:getScale()
		Node = Node:getParent()
	end
	return 1/iScale
end

function _ShowRedPointSpr(RedBtn, bShow)
	local RedPointInfo = RedBtn.__RedPointInfo
	
	if bShow and not RedBtn.__RedPointSpr then
		RedBtn.__RedPointSpr = RedBtn.__RedPointSpr or utils.CreateSprite("uistu/common/redpoint.png")
		KE_SetParent(RedBtn.__RedPointSpr, RedBtn)
		local BtnSize = RedBtn:getContentSize()
		RedBtn.__RedPointSpr:setPosition(BtnSize.width-15, BtnSize.height-20)
		RedBtn.__RedPointSpr:setScale(GetRedSprScale(RedBtn))
	end
	if RedBtn.__RedPointSpr then
		RedBtn.__RedPointSpr:setVisible(bShow)
		RedBtn.__RedPointSpr:setLocalZOrder(99)
	end
end

-------------------------------------------------------------------------

ClsRedPointMgr = class("ClsRedPointMgr", clsCoreObject)
ClsRedPointMgr.__is_singleton = true

for _, info in pairs(REDPOINT_TABLE) do
	ClsRedPointMgr:RegisterEventType(info.point_id)
end

function ClsRedPointMgr:ctor()
	clsCoreObject.ctor(self)
	self._bIsWorking = false
	self._RedButtons = {}
end

function ClsRedPointMgr:dtor()
	self:StopWork()
end

function ClsRedPointMgr:IsBtnAdded(Btn)
	for point_id, btnlist in pairs(self._RedButtons) do
		for RedBtn, RedPointInfo in pairs(btnlist) do
			if RedBtn == Btn then 
				assert(RedBtn.__RedPointInfo.point_id == point_id, "小红点数据信息错误")
				return true 
			end
		end
	end
	return false 
end

function ClsRedPointMgr:RegisterRedButton(point_id, RedBtn)
	assert(REDPOINT_TABLE[point_id], "没有注册该类型红点："..point_id)
	if not RedBtn then logger.error("无效的按钮") return end
	if self:IsBtnAdded(RedBtn) then logger.error("该按钮已经注册过红点") return end
	
	-- 注册
	self._RedButtons[point_id] = self._RedButtons[point_id] or new_weak_table("v")
	local RedPointInfo = {
		["point_id"] = point_id,
	}
	RedBtn.__RedPointInfo = RedPointInfo
	self._RedButtons[point_id][RedBtn] = RedPointInfo
	
	-- 刷新按钮红点
	local RedCfg = REDPOINT_TABLE[point_id]
	local bShowRedPoint = RedCfg.check_func()
	_ShowRedPointSpr(RedBtn, bShowRedPoint)
end

function ClsRedPointMgr:RemoveRedButton(RedBtn)
	local point_id = RedBtn and RedBtn.__RedPointInfo and RedBtn.__RedPointInfo.point_id
	if not point_id or not self._RedButtons[point_id] then return end
	self._RedButtons[point_id][RedBtn] = nil
	RedBtn.__RedPointInfo = nil
end

function ClsRedPointMgr:Triger(sFactor)
	local tmStart = os.clock()
	local RedInfoList = MAP_FACTOR_2_REDCFGS[sFactor]
	assert(RedInfoList, "没有注册该因素："..sFactor)
	for point_id, RedCfg in pairs(RedInfoList) do
		local bShowRedPoint = RedCfg.check_func()
		self:_RefleshRedPoint(point_id, bShowRedPoint)
		self:FireEvent(point_id, bShowRedPoint)
	end
	logger.normal( string.format("触发小红点因素：%s  用时：%f", sFactor, os.clock()-tmStart) )
end

function ClsRedPointMgr:_RefleshRedPoint(point_id, bShowRedPoint)
	local btnlist = self._RedButtons[point_id]
	if not btnlist then return end
	for RedBtn, _ in pairs(btnlist) do
		_ShowRedPointSpr(RedBtn, bShowRedPoint)
	end
end

function ClsRedPointMgr:StartWork()
	if self._bIsWorking then return end
	self._bIsWorking = true
	logger.normal("小红点启动......")
	g_EventMgr:AddListener(self, "NET_RECIEVE_PTO", function(thisObj, sPtoName)
		if MAP_FACTOR_2_REDCFGS[sPtoName] then
			self:Triger(sPtoName)
		end
	end)
	self:_ForceUpdateAll()
end

function ClsRedPointMgr:StopWork()
	self._bIsWorking = false
	self._RedButtons = {}
	g_EventMgr:DelListener(self)
	logger.normal("小红点停止......")
end

function ClsRedPointMgr:_ForceUpdateAll()
	for factor, _ in pairs(MAP_FACTOR_2_REDCFGS) do
		self:Triger(factor)
	end
end

function ClsRedPointMgr:DumpDebugInfo()
	if not self._bIsWorking then return end
	
	for point_id, btnlist in pairs(self._RedButtons) do
		logger.normal(string.format("%s   注册按钮数量：%d", point_id, table.size(btnlist)))
	end
	
	KE_SetTimeout(1, function() self:_ForceUpdateAll() end)
end

--------------------------
-- 三个对外接口
--------------------------
--注册按钮
function RegisterRedButton(point_id, Btn)
	ClsRedPointMgr.GetInstance():RegisterRedButton(point_id, Btn)
end
--注销按钮
function RemoveRedButton(Btn)
	ClsRedPointMgr.GetInstance():RemoveRedButton(Btn)
end
--触发因子
function Triger(sFactor)
	ClsRedPointMgr.GetInstance():Triger(sFactor)
end
