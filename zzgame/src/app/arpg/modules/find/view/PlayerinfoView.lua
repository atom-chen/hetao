module("ui",package.seeall)

clsPlayerInfoView = class("clsPlayerInfoView",clsBaseUI)

function clsPlayerInfoView:ctor(parent)
    clsBaseUI.ctor(self,parent,"uistu/PlayerInfo.csb")
    self.headicon:SetCircle(true)
    self.ScrollWnd:setScrollBarEnabled(false)
    self:InitUiEvents()
end

function clsPlayerInfoView:dtor()
end

function clsPlayerInfoView:SetParam(Uid, Type)
	self._uid = Uid
	self._type = Type 
	self:Refresh()
end


function clsPlayerInfoView:InitUiEvents()
    g_EventMgr:AddListener(self, "on_req_award_playerinfo", self.Refresh, self)
    utils.RegClickEvent(self.BtnClose,function()
        self:removeSelf()
    end)
end

function clsPlayerInfoView:Refresh(recvdata)
    local tInfo = ClsPlayerInfoMgr.GetInstance():GetPlayerInfoData(self._uid, self._type)
    if not tInfo then
		proto.req_award_playerinfo({uid=self._uid, type=self._type})
		return
    end
    
    local tLike = tInfo.game_list
    self.Sex:setString("性别："..tInfo.sex)
    self.lblNick:setString(tInfo.nickname or "")
    self.account:setString("账号:"..tInfo.username)
    self.lblTxLj:setString("头衔："..tInfo.VipName .. "  最近30天累计中奖："..tInfo.lucky_price)
    self.vip:setString(tInfo.VipID)
    self.headicon:SetHeadImg(tInfo.img)
    
    self.ScrollWnd:setPositionY( self.AreaAuto:getContentSize().height-(725-640) )
    self.ScrollWnd:setContentSize( self.ScrollWnd:getContentSize().width, self.AreaAuto:getContentSize().height-(725-640) )
    self.TextLike:setPositionY( self.AreaAuto:getContentSize().height-(725-665) )
    local cnt = #tLike
	local margin = { left=0, bottom=0, right=0, top=0}
	local innerGrid = clsInnerGrid.new(self.ScrollWnd:getContentSize().width, 4, cnt, 140+8, self.ScrollWnd:getContentSize().height, margin)
	self.ScrollWnd:setInnerContainerSize(cc.size(innerGrid:GetSize()))
	local btnWid, btnHei = innerGrid:GetCellSize()
	btnWid = btnWid - 8
	btnHei = btnHei - 8
    for i = 1,#tLike do
        local row = math.ceil( i / 4 )
        local sort = i % 4
        if sort == 0 then sort = 4 end
        local info = tLike[i]
		local BtnFeature = self:CreateFeatureBtn(btnWid,btnHei,info.game_img)
		self.ScrollWnd:addChild(BtnFeature)
		BtnFeature:setPosition( innerGrid:GetPosByIdx(i) )
	--	utils.RegClickEvent(BtnFeature, function()
	--		ClsGameMgr.GetInstance():OpenGame(info)
	--	end)
    end
end

function clsPlayerInfoView:CreateFeatureBtn(width,heith,img)
    local Btn = utils.CreateButton("uistu/common/null.png","uistu/common/light_gray.jpg")
    Btn:setScale9Enabled(true)
	Btn:setContentSize(width,heith)

    local ImageIcon = ccui.ImageView:create()
    Btn:addChild(ImageIcon)
    ImageIcon:setAnchorPoint(0.5,0.5)
    ImageIcon:setPosition(width/2,heith/2)
    ImageIcon:LoadTextureSync(img)
    ImageIcon:setScale(0.7)
    return Btn
end