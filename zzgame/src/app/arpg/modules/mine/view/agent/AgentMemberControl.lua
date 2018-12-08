-------------------------
-- 会员管理
-------------------------
module("ui", package.seeall)

clsAgentMemberControl = class("clsAgentMemberControl", clsBaseUI)
g_EventMgr:RegisterEventType("showmemberpage")
nLevel = 0
function clsAgentMemberControl:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/AgentMemberControl.csb")
	
	self:InitListWnd()
    self:InitUiEvents()
	self:InitGlbEvents()
    local _id = ClsAgentDataMgr.GetInstance():GetMemberid()
	proto.req_agent_junior_member({uid = _id})
end

function clsAgentMemberControl:dtor()
	
end

function clsAgentMemberControl:ForceAdapt()
	clsBaseUI.ForceAdapt(self)
	local sz = self.ConstWnd:getContentSize()
	self.ConstWnd:setContentSize(sz.width, sz.height+GAME_CONFIG.HEIGHT_DIFF)
end

--注册控件事件
function clsAgentMemberControl:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() 
        local _id = ClsAgentDataMgr.GetInstance():GetMemberid()
        local _table = ClsAgentDataMgr.GetInstance():GetJuniorData()
        local _uid = _table[_id]
        if nLevel == 0 then
            ClsAgentDataMgr.GetInstance():SaveMemberid("")
            self:removeSelf() 
        else
            if nLevel == 1 then
                _uid = ""
            end
            nLevel = nLevel - 1
            if _id and _uid then
                ClsAgentDataMgr.GetInstance():SaveMemberid(_uid)
                proto.req_agent_junior_member({uid = _uid})
            end
        end
    end)
end

-- 注册全局事件
function clsAgentMemberControl:InitGlbEvents()
	g_EventMgr:AddListener(self,"on_req_agent_junior_member",self.Refresh,self)
    g_EventMgr:AddListener(self,"showmemberpage",function()
        nLevel = nLevel + 1
        local _id = ClsAgentDataMgr.GetInstance():GetMemberid()
	    proto.req_agent_junior_member({uid = _id})
    end)
end

function clsAgentMemberControl:InitListWnd()
    local sz = self.ConstWnd:getContentSize()
    self.listWnd = clsCompList.new(self.ConstWnd, ccui.ScrollViewDir.vertical, sz.width, sz.height, sz.width, 82)
    self.listWnd:setScrollBarEnabled(false)
    local createFunc = function(CellObj)
		local info = CellObj:GetCellData()
		local curBtn = self.Button_1:clone()
		utils.getNamedNodes(curBtn)
    	curBtn.Text_5:setString(info.username or "")
        if info.type == "1" then
            curBtn.Text_6:setString("玩家")
        else
            curBtn.Text_6:setString("1级代理")
        end
    	curBtn.Text_7:setString(os.date( "%Y-%m-%d", tonumber(info.update_time) ) or "")
        curBtn.Text_8:setString(info.junior_num)
		
		utils.RegClickEvent(curBtn, function() 
			if info.type == "2" and info.junior_num > 0 then
                local _id = ClsAgentDataMgr.GetInstance():GetMemberid()
                local _idtable = ClsAgentDataMgr.GetInstance():GetJuniorData()
                _idtable = _idtable or {}
                _idtable[info.uid] = _id or ""
                ClsAgentDataMgr.GetInstance():SaveMemberid(info.uid)
                ClsAgentDataMgr.GetInstance():SaveJuniorData(_idtable)
                ClsAgentDataMgr.GetInstance():SaveType(6)
            else
                ClsAgentDataMgr.GetInstance():SaveType(5)
            end
            ClsAgentDataMgr.GetInstance():SaveMemberdata(info)
            ClsUIManager.GetInstance():ShowPopWnd("clsClickMember")
		end)
		
		return curBtn
	end
	self.listWnd:SetCellCreator(createFunc)
end

function clsAgentMemberControl:Refresh(recvdata)
    local data = recvdata and recvdata.data or {}
    
    local preCnt = self.listWnd:GetCellCount()
	local prePos = self.listWnd:getInnerContainerPosition()
    self.listWnd:RemoveAll()
    for i,v in pairs(data) do
        self.listWnd:Insert(v)
    end
    self.listWnd:ForceReLayout()
	local curCnt = self.listWnd:GetCellCount()
	if preCnt == curCnt then
		self.listWnd:setInnerContainerPosition(prePos)
	end
	
	gameutil.MarkAllLoaded(self.listWnd)
end