module("ui",package.seeall)

clsGradeView = class("clsGradeView", clsBaseUI)

function clsGradeView:ctor(parent)
    clsBaseUI.ctor(self, parent, "uistu/VipUpgrade.csb")
    self:InitUiEvent()
    self:RefleshUI()
    local infodata = clsActiveMgr.GetInstance():GetGradeData()
    self:OnReqGradeInfo(infodata)
    
    local img = clsActiveMgr.GetInstance():GetGradeImg()
    self.Vip_upimg:setScale9Enabled(false)
	self.Vip_upimg:ignoreContentAdaptWithSize(true)
    self.Vip_upimg:SetLoadedCallback(function()
    	local szImg = self.Vip_upimg:getContentSize()
    	if self.Vip_upimg._gifSprite then
    		szImg = self.Vip_upimg._gifSprite:getContentSize()
    	end
    	local w, h = self.AreaAuto:getContentSize().width, szImg.height*self.AreaAuto:getContentSize().width/szImg.width
    	self.Vip_upimg:SetMaxSize(w,h)
    	if self.Vip_upimg._gifSprite then
    		self.Vip_upimg._gifSprite:setPosition(w/2,h/2)
    	end
    	self.AreaAuto:requestDoLayout()
    end)
    self.Vip_upimg:LoadTextureSync(img)
    
    if not img then
    	proto.req_grade_uplevel_img()
    end
    proto.req_grade_grade_info()
end

function clsGradeView:InitUiEvent()
    utils.RegClickEvent(self.BtnClose, function() 
        self:removeSelf() 
    end)
end

function clsGradeView:RefleshUI()
    g_EventMgr:AddListener(self, "on_req_grade_uplevel_img", self.OnReqGradeUplevelImg, self)
    g_EventMgr:AddListener(self, "on_req_grade_grade_info", self.OnReqGradeInfo, self)
    g_EventMgr:AddListener(self, "on_req_grade_uplevel_award", self.req_grade_uplevel_award, self)
end

function clsGradeView:OnReqGradeUplevelImg(recvdata)
	recvdata = recvdata or clsActiveMgr.GetInstance():GetGradeImg()
	if not recvdata or not recvdata.data then return end
    self.Vip_upimg:LoadTextureSync(recvdata.data.img)
end

function clsGradeView:OnReqGradeInfo(recvdata)
	recvdata = recvdata or clsActiveMgr.GetInstance():GetGradeData()
    local gradedata = recvdata and recvdata.data or {}
    self.Text_41:setString(string.format("VIP%d",gradedata.vip_id or 0))
    self.Text_42:setString(gradedata.money)
    if gradedata.is_reward == true then
        self.ReciveBtn:setEnabled(true)
        self.ReciveBtn:setTitleText("领取")
        self.ReciveBtn:setTitleColor(cc.c3b(244,244,244))
        utils.RegClickEvent(self.ReciveBtn,function()
            proto.req_grade_uplevel_award()
        end)
    else
        self.ReciveBtn:setEnabled(false)
        self.ReciveBtn:setTitleText("不可领取")
        self.ReciveBtn:setTitleColor(cc.c3b(22,22,22))
    end
end

function clsGradeView:req_grade_uplevel_award(recvdata)
    if recvdata.code == 200 then
        utils.TellMe("领取成功")
        self.ReciveBtn:setEnabled(false)
        self.ReciveBtn:setTitleText("不可领取")
        self.ReciveBtn:setTitleColor(cc.c3b(22,22,22))
    end
end