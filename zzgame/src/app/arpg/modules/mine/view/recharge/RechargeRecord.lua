-------------------------
-- 充值记录
-------------------------
module("ui", package.seeall)

clsRechargeRecord = class("clsRechargeRecord", clsBaseUI)

function clsRechargeRecord:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/RechargeRecord.csb")
	local sz = self.AreaAuto:getContentSize()
	local itemSz = self.ListItem:getContentSize()
	self.listWnd = clsCompList.new(self.AreaAuto, ccui.ScrollViewDir.vertical, sz.width, sz.height, itemSz.width, itemSz.height+10)
	self.listWnd:setScrollBarEnabled(false)
	
	local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		
		local curBtn = self.ListItem:clone()
		
		local tRecharge = CellObj:GetCellData()
        local types = tRecharge.status
        if types == "1" then
            types = "等待审核"
        elseif types == "2" then
            types = "已到账"
        elseif types == "3" then
            types = "审核未通过"
        else
            types = "撤销"
        end
        
        curBtn:getChildByName("record_name"):setString(tRecharge.style.." "..tRecharge.price.."元")
        curBtn:getChildByName("record_time"):setString(tRecharge.addtime)
        if tRecharge.type ~= "4" then
            curBtn:getChildByName("record_state"):setString(types)
            curBtn:getChildByName("record_num"):setString("订单号："..tRecharge.order_num)
            gameutil.RegCopyEvent(curBtn:getChildByName("record_num"), tRecharge.order_num)
        else
            curBtn:getChildByName("record_state"):setVisible(false)
            curBtn:getChildByName("record_num"):setVisible(false)
        end
        utils.RegClickEvent(curBtn,function()
            ClsRechargeRecoMgr.GetInstance():SaveRechargeDetail(tRecharge)
            ClsUIManager.GetInstance():ShowPanel("clsRechargeDetail")
        end)
		
		return curBtn
	end
	self.listWnd:SetCellCreator(createFunc)
	
	self:InitUiEvents()
	self:InitGlbEvents()
    
    proto.req_user_chongzhi_record({time_start = "",time_end = "",type = "",rows = "",page = ""})
end

function clsRechargeRecord:dtor()
	
end

--注册控件事件
function clsRechargeRecord:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.Button_2,function()
        local argInfo = {
       		ScreetType = "RECHARGE",
       		callback = function(conditions)
       			print("筛选")
       			self._conditions = conditions
		        logger.dump(conditions)
		        self.listWnd:RemoveAll()
		        proto.req_user_chongzhi_record({time_start = conditions.time_start or "",time_end = conditions.time_end or "",type = conditions.typeinfo.type,rows = "",page = ""})
       		end,
       	}
        ClsUIManager.GetInstance():ShowPopWnd("clsScreeningWnd", argInfo)
    end)
end

-- 注册全局事件
function clsRechargeRecord:InitGlbEvents()
	g_EventMgr:AddListener(self,"on_req_user_chongzhi_record",self.on_req_user_chongzhi_record,self)
end

function clsRechargeRecord:on_req_user_chongzhi_record(recvdata)
    local records = ClsRechargeRecoMgr.GetInstance():GetRechargeRecord()
    
    self.Nodata:setVisible(#records.rows <= 0)
    
    local listWnd = self.listWnd
    self.listWnd:RemoveAll()
    for i, info in ipairs(records.rows) do
		listWnd:Insert(info)
	end
	
	gameutil.MarkAllLoaded(listWnd)
		
	self.listWnd:ForceReLayout()
end