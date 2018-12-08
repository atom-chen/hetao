-------------------------
-- 个人信息
-------------------------
module("ui", package.seeall)

clsMyInfoView = class("clsMyInfoView", clsBaseUI)
g_EventMgr:RegisterEventType("showNotice")
g_EventMgr:RegisterEventType("hiddenNotice")
function clsMyInfoView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/MyInfoView.csb")
	self.EditEmail = utils.ReplaceTextField(self.EditEmail, "", "ff000000")
	self.EditPhone = utils.ReplaceTextField(self.EditPhone, "", "ff000000")
	self.EditNick = utils.ReplaceTextField(self.EditNick, "", "ff000000")
	self.EditEmail:setTextHorizontalAlignment(2)
	self.EditPhone:setTextHorizontalAlignment(2)
	self.EditNick:setTextHorizontalAlignment(2)
	self.EditPhone:setInputMode(cc.EDITBOX_INPUT_MODE_PHONENUMBER)
	self.EditEmail:setInputMode(cc.EDITBOX_INPUT_MODE_EMAILADDR)
	--self.notice:setVisible(false)
	self:InitUiEvents()
	self:InitGlbEvents()
	self:SwitchTo(1)
	KE_SetTimeout(10, function()
		proto.req_user_nobility()
	end)
end

function clsMyInfoView:dtor()
	
end

--注册控件事件
function clsMyInfoView:InitUiEvents()
    if UserEntity.GetInstance():IsModifyed("nickname") then
        self.EditNick:setTouchEnabled(false)
        self.Sprite_1_2:setVisible(false)
    end
    if UserEntity.GetInstance():IsModifyed("phone") then
        self.EditPhone:setTouchEnabled(false)
        self.Sprite_1_0:setVisible(false)
    end
    if UserEntity.GetInstance():IsModifyed("email") then
        self.EditEmail:setTouchEnabled(false)
        self.Sprite_5:setVisible(false)
    end
    if UserEntity.GetInstance():IsModifyed("sex") then
        self.BtnSex:setTouchEnabled(false)
        self.Sprite_7:setVisible(false)
        local userObj = UserEntity.GetInstance()
        self.lblSex:setString( userObj:Get_sex() == "1" and "男" or "女" )
    else
        self.BtnSex:setTouchEnabled(true)
        self.Sprite_7:setVisible(true)
        self.lblSex:setString( "未设置" )
    end
    if UserEntity.GetInstance():IsModifyed("birthday") then
        self.BtnBirthday:setTouchEnabled(false)
        self.Sprite_6:setVisible(false)
    end
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
    utils.RegClickEvent(self.BtnPersonal,function() 
        self:SwitchTo(1)
    end)
    utils.RegClickEvent(self.BtnGrade,function()
        self:SwitchTo(2)
    end)
    utils.RegClickEvent(self.BtnSex,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsSexSelectWnd", function(sSex)
        	--if sSex == UserEntity.GetInstance():Get_sex() then return end
        	local function callback(mnuId)
        		if mnuId == 1 then
					UserEntity.GetInstance():ReqChangeInfo("sex", sSex)
                    self.lblSex:setString( UserEntity.GetInstance():Get_sex() == "1" and "男" or "女" )
				else
					self.lblSex:setString( "未设置" )
				end
			end
			ClsUIManager.GetInstance():PopConfirmDlg("CFM_CHG_MYINFO", 
					"温馨提示", 
					"注意：性别一经保存将无法再修改！是否设置性别？",
					callback)
        end)
    end)
    utils.RegClickEvent(self.BtnBirthday,function()
        ClsUIManager.GetInstance():ShowPopWnd("clsDateSelectWnd2", function(tTime)
        	local function callback(mnuId)
        		if mnuId == 1 then
        	--		local birthday = libtime.MkTime(tTime.year, tTime.month, tTime.day, 0, 0, 0)
                    local y = tonumber(os.date("%Y"))
                    local m = tonumber(os.date("%m"))
                    local d = tonumber(os.date("%d"))
                    if tonumber(tTime.year) == y and ((tonumber(tTime.month) == m and tonumber(tTime.day) > d ) or tonumber(tTime.month) > m) then
                        utils.TellMe("生日不可设置为未来")
                        return
                    end
        			local birthday = string.format("%d/%02d/%02d", tTime.year, tTime.month, tTime.day)
					UserEntity.GetInstance():ReqChangeInfo( "birthday", birthday )
				end
			end
			ClsUIManager.GetInstance():PopConfirmDlg("CFM_CHG_MYINFO", 
					"温馨提示", 
					"注意：生日一经保存将无法再修改！是否设置生日？",
					callback)
            
        end)
    end)
    utils.RegClickEvent(self.BtnHead,function()
    	local onTakePic = function(filepath)
    		if device.platform == "windows" then
				filepath = "res/Default/wx_jpg_ewm.jpg"
			end
			
    		if utils.IsValidCCObject(self) then
    			self:DestroyTimer("tmr_takephoto")
    			self:CreateTimerDelay("tmr_takephoto", 4, function()
    				logger.normal("头像路径：", filepath)
		    		cc.Director:getInstance():getTextureCache():removeTextureForKey(filepath)
					self.HeadIcon:SetHeadImg(filepath)
					self:UploadHead(filepath)
    			end)
	    	end
    	end
    	local cfm = ClsUIManager.GetInstance():PopConfirmDlg("CFM_CHG_MYINFO", 
					"提示", 
					"请选择头像选取方式？", 
					function(mnuId)
						if mnuId == 1 then
							SalmonUtils:captureImage("face_"..UserEntity.GetInstance():Get_username()..".jpg", onTakePic)
						else
							SalmonUtils:openGallery(onTakePic, "face_"..UserEntity.GetInstance():Get_username()..".jpg")
						end
					end, "拍照", "相册")
		if cfm then cfm:SetCloseWhenClickMask(true) end
	end)
	
	self.EditEmail:registerScriptEditBoxHandler(function(evenName, sender)
		if evenName == "return" then
			if self.EditEmail:getString() == UserEntity.GetInstance():Get_email() then return end
			self:DestroyTimer("tmr_chginfo")
			self:CreateTimerDelay("tmr_chginfo", 1, function()
				if self.EditEmail:getString() ~= "" then
					local function callback(mnuId)
						if mnuId == 1 then
							UserEntity.GetInstance():ReqChangeInfo("email", self.EditEmail:getString())
						else
							self.EditEmail:setString(UserEntity.GetInstance():Get_email() or "")
                            if self.EditEmail:getString() == "" then
                                self.EmailPlaceHolder:setVisible(true)
                            end
						end
                        if not UserEntity.GetInstance():IsModifyed("nickname") then
                            self.EditNick:setTouchEnabled(true)
                        end
                        if not UserEntity.GetInstance():IsModifyed("phone") then
                            self.EditPhone:setTouchEnabled(true)
                        end
                        if not UserEntity.GetInstance():IsModifyed("birthday") then
                            self.BtnBirthday:setTouchEnabled(false)
                        end
                        if not UserEntity.GetInstance():IsModifyed("sex") then
                            self.BtnSex:setTouchEnabled(true)
                        end
                        self.BtnHead:setTouchEnabled(true)
					end
					ClsUIManager.GetInstance():PopConfirmDlg("CFM_CHG_MYINFO", 
							"温馨提示", 
							"注意：邮箱一经保存将无法再修改！是否设置邮箱？",
							callback)
				end
			end)
        elseif evenName == "began" then
            self.EmailPlaceHolder:setVisible(false)
            self.BtnBirthday:setTouchEnabled(false)
            self.BtnSex:setTouchEnabled(false)
            self.EditPhone:setTouchEnabled(false)
            self.EditNick:setTouchEnabled(false)
            self.BtnHead:setTouchEnabled(false)
        elseif evenName == "ended" then
            if not UserEntity.GetInstance():IsModifyed("nickname") then
                self.EditNick:setTouchEnabled(true)
            end
            if not UserEntity.GetInstance():IsModifyed("phone") then
                self.EditPhone:setTouchEnabled(true)
            end
            if not UserEntity.GetInstance():IsModifyed("birthday") then
                self.BtnBirthday:setTouchEnabled(false)
            end
            if not UserEntity.GetInstance():IsModifyed("sex") then
                self.BtnSex:setTouchEnabled(true)
            end
            if self.EditEmail:getString() == "" then
                self.EmailPlaceHolder:setVisible(true)
            end
--            self.BtnBirthday:setTouchEnabled(true)
--            self.BtnSex:setTouchEnabled(true)
--            self.EditPhone:setTouchEnabled(true)
--            self.EditNick:setTouchEnabled(true)
            self.BtnHead:setTouchEnabled(true)
		end
	end)
	self.EditPhone:registerScriptEditBoxHandler(function(evenName, sender)
		if evenName == "return" then
			if self.EditPhone:getString() == UserEntity.GetInstance():Get_phone() then return end
			self:DestroyTimer("tmr_chginfo")
			self:CreateTimerDelay("tmr_chginfo", 1, function()
				if self.EditPhone:getString() ~= "" then
					local function callback(mnuId)
						if mnuId == 1 then
							UserEntity.GetInstance():ReqChangeInfo("phone", self.EditPhone:getString())
						else
							self.EditPhone:setString(UserEntity.GetInstance():Get_phone() or "")
                            if self.EditPhone:getString() == "" then
                                self.PhonePlaceHolder:setVisible(true)
                            end
						end
                        if not UserEntity.GetInstance():IsModifyed("nickname") then
                            self.EditNick:setTouchEnabled(true)
                        end
                        if not UserEntity.GetInstance():IsModifyed("birthday") then
                            self.BtnBirthday:setTouchEnabled(false)
                        end
                        if not UserEntity.GetInstance():IsModifyed("email") then
                            self.EditEmail:setTouchEnabled(true)
                        end
                        if not UserEntity.GetInstance():IsModifyed("sex") then
                            self.BtnSex:setTouchEnabled(true)
                        end
                        self.BtnHead:setTouchEnabled(true)
					end
					ClsUIManager.GetInstance():PopConfirmDlg("CFM_CHG_MYINFO", 
							"温馨提示", 
							"注意：电话一经保存将无法再修改！是否设置电话？",
							callback)
				end
			end)
        elseif evenName == "began" then
            self.PhonePlaceHolder:setVisible(false)
            self.BtnBirthday:setTouchEnabled(false)
            self.BtnSex:setTouchEnabled(false)
            self.EditEmail:setTouchEnabled(false)
            self.EditNick:setTouchEnabled(false)
            self.BtnHead:setTouchEnabled(false)
        elseif evenName == "ended" then
            if not UserEntity.GetInstance():IsModifyed("nickname") then
                self.EditNick:setTouchEnabled(true)
            end
            if not UserEntity.GetInstance():IsModifyed("birthday") then
                self.BtnBirthday:setTouchEnabled(false)
            end
            if not UserEntity.GetInstance():IsModifyed("email") then
                self.EditEmail:setTouchEnabled(true)
            end
            if self.EditPhone:getString() == "" then
                self.PhonePlaceHolder:setVisible(true)
            end
            if not UserEntity.GetInstance():IsModifyed("sex") then
                self.BtnSex:setTouchEnabled(true)
            end
            self.BtnHead:setTouchEnabled(true)
		end
	end)
	self.EditNick:registerScriptEditBoxHandler(function(evenName, sender)
		if evenName == "return" then
			if self.EditNick:getString() == UserEntity.GetInstance():Get_nickname() then return end
			self:DestroyTimer("tmr_chginfo")
			self:CreateTimerDelay("tmr_chginfo", 1, function()
				if self.EditNick:getString() ~= "" then
					local function callback(mnuId)
						if mnuId == 1 then
							UserEntity.GetInstance():ReqChangeInfo("nickname", self.EditNick:getString())
						else
							self.EditNick:setString(UserEntity.GetInstance():Get_nickname() or "")
                            if self.EditNick:getString() == "" then
                                self.NickPlaceHolder:setVisible(true)
                            end
						end
                        if not UserEntity.GetInstance():IsModifyed("birthday") then
                           self.BtnBirthday:setTouchEnabled(true)
                        end
                        if not UserEntity.GetInstance():IsModifyed("phone") then
                            self.EditPhone:setTouchEnabled(true)
                        end
                        if not UserEntity.GetInstance():IsModifyed("email") then
                            self.EditEmail:setTouchEnabled(true)
                        end
                        if not UserEntity.GetInstance():IsModifyed("sex") then
                            self.BtnSex:setTouchEnabled(true)
                        end
                        self.BtnHead:setTouchEnabled(true)
					end
					ClsUIManager.GetInstance():PopConfirmDlg("CFM_CHG_MYINFO", 
							"温馨提示", 
							"注意：昵称一经保存将无法再修改！是否设置昵称？",
							callback)
				end
			end)
        elseif evenName == "began" then
            self.NickPlaceHolder:setVisible(false)
            self.BtnBirthday:setTouchEnabled(false)
            self.BtnSex:setTouchEnabled(false)
            self.EditEmail:setTouchEnabled(false)
            self.EditPhone:setTouchEnabled(false)
            self.BtnHead:setTouchEnabled(false)
        elseif evenName == "ended" then
            if not UserEntity.GetInstance():IsModifyed("birthday") then
                self.BtnBirthday:setTouchEnabled(false)
            end
            if not UserEntity.GetInstance():IsModifyed("phone") then
                self.EditPhone:setTouchEnabled(true)
            end
            if not UserEntity.GetInstance():IsModifyed("email") then
                self.EditEmail:setTouchEnabled(true)
            end
            if not UserEntity.GetInstance():IsModifyed("sex") then
                self.BtnSex:setTouchEnabled(true)
            end
            if self.EditNick:getString() == "" then
                self.NickPlaceHolder:setVisible(true)
            end
            self.BtnHead:setTouchEnabled(true)
		end
	end)
end

function clsMyInfoView:UploadHead(filepath)
	if not filepath or filepath == "" then
		utils.TellMe("请选择头像")
		return
	end
	
	if device.platform == "android" then
		local function succCallback(resp_data)
			utils.TellMe("头像更新成功")
			proto.req_user_info()
		end
		local function failCallback(resp_data)
			utils.TellMe("头像更新失败")
		end
		local function loadingCallback(resp_data)
			
		end
		HttpHelper:uploadHeadImg(SERVER_URL.."/user/user/user_head", filepath, succCallback, failCallback, loadingCallback)
	else
		local contentType = "Image/png"
		if utils.is_png_file(filepath) then
			contentType = "Image/png"
		elseif utils.is_jpg_file(filepath) then
			contentType = "Image/jpeg"
		else
			utils.TellMe("请上传PNG格或JPG格式的图片")
			return
		end
		
		extra_network.uploadFile(function(evt)
				if evt.name == "completed" then
					local request = evt.request
					printf("REQUEST getResponseStatusCode() = %d", request:getResponseStatusCode())
					printf("REQUEST getResponseHeadersString() =\n%s", request:getResponseHeadersString())
		 			printf("REQUEST getResponseDataLength() = %d", request:getResponseDataLength())
	                printf("REQUEST getResponseString() =\n%s", request:getResponseString())
	                utils.TellMe("头像更新成功")
					proto.req_user_info()
				end
			end,
			HttpUtil:GetPtoUrl("req_user_upload_headimg", {file=cc.FileUtils:getInstance():fullPathForFilename(filepath)}, nil),
			{
				fileFieldName="file",
				filePath=cc.FileUtils:getInstance():fullPathForFilename(filepath),
				contentType=contentType,
				extra={
					{"act", "upload"},
					{"submit", "upload"},
					{"file", cc.FileUtils:getInstance():fullPathForFilename(filepath)}
				}
			}
		)
	--	proto.req_user_upload_headimg({file=cc.FileUtils:getInstance():fullPathForFilename(filepath)})
	end
end

-- 注册全局事件
function clsMyInfoView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_user_info", self.on_req_user_info, self, true)
	g_EventMgr:AddListener(self, "fail_req_user_info", self.on_req_user_info, self, true)
    g_EventMgr:AddListener(self, "on_req_user_nobility", self.on_req_user_nobility, self, true)
    g_EventMgr:AddListener(self, "on_req_user_update_info", function(thisObj, recvdata)
    	proto.req_user_info()
    end)
--    g_EventMgr:AddListener(self,"showNotice",function()
--        self.notice:setVisible(true)
--    end)
--    g_EventMgr:AddListener(self,"hiddenNotice",function()
--        self.notice:setVisible(false)
--    end)
end

function clsMyInfoView:on_req_user_info(recvdata)
	self._bAskedUserInfo = true
	local userObj = UserEntity.GetInstance()
	self.EditNick:setString( userObj:Get_nickname() or "" )
	self.lblZhanghao:setString( userObj:Get_username() or "" )
	self.EditPhone:setString( userObj:Get_phone() or "" )
	self.EditEmail:setString( userObj:Get_email() or "" )
	
	self.HeadIcon:SetHeadImg(userObj:Get_img())
    if UserEntity.GetInstance():IsModifyed("nickname") then
        self.EditNick:setTouchEnabled(false)
        self.Sprite_1_2:setVisible(false)
        self.NickPlaceHolder:setVisible(false)
    end
    if UserEntity.GetInstance():IsModifyed("phone") then
        self.EditPhone:setTouchEnabled(false)
        self.Sprite_1_0:setVisible(false)
        self.PhonePlaceHolder:setVisible(false)
    end
    if UserEntity.GetInstance():IsModifyed("email") then
        self.EditEmail:setTouchEnabled(false)
        self.Sprite_5:setVisible(false)
        self.EmailPlaceHolder:setVisible(false)
    end
    if UserEntity.GetInstance():IsModifyed("sex") then
        self.BtnSex:setTouchEnabled(false)
        self.Sprite_7:setVisible(false)
        self.lblSex:setString( userObj:Get_sex() == "1" and "男" or "女" )
    else
        self.BtnSex:setTouchEnabled(true)
        self.Sprite_7:setVisible(true)
        self.lblSex:setString( "未设置" )
    end
    if UserEntity.GetInstance():IsModifyed("birthday") then
        self.BtnBirthday:setTouchEnabled(false)
        self.Sprite_6:setVisible(false)
        if tonumber(userObj:Get_birthday()) ~= 0 and os.date( "%Y-%m-%d %H:%M:%S", tonumber(userObj:Get_birthday()) )~=nil then
	        self.lblBirthday:setString( os.date( "%Y/%m/%d", tonumber(userObj:Get_birthday()) ) or "未设置" )
        end
    else
        self.BtnBirthday:setTouchEnabled(true)
        self.Sprite_6:setVisible(true)
        self.lblBirthday:setString("未设置")
    end
--	self.lblBirthday:setString( os.date( "%Y-%m-%d %H:%M:%S", tonumber(userObj:Get_birthday()) ) )
	print("----- 生日：", userObj:Get_birthday(), os.date( "%Y/%m/%d", tonumber(userObj:Get_birthday()) ))
	print("----- 生日：", userObj:Get_birthday(), os.date( "%Y-%m-%d", tonumber(userObj:Get_birthday()) ))
	print("----- 生日：", userObj:Get_birthday(), os.date( "%Y-%m-%d %H:%M:%S", tonumber(userObj:Get_birthday()) ))
end

function clsMyInfoView:on_req_user_nobility(recvdata)
	self._bAskedUserNobility = true
    local userObj = ClsTitleMgr.GetInstance():getTitleData() or {}
    self.headicon:SetHeadImg(userObj.img)
    self.username:setString(userObj.username or "")
    self.VipLevel:setString(userObj.VipID or "")
    self.title:setString("头衔："..(userObj.VipName or ""))
    self.GrowthValue:setString("成长值："..(userObj.integral or ""))
    self.Text_9:setString("距离下一级需要"..(userObj.juli or "").."分，每充值1元加1分")
    self.Text_10:setString(userObj.VipID or "")
    self.Text_12:setString(userObj.NextVipIP or "")
    if userObj.integral and userObj.juli then
	    local percent = userObj.integral / (userObj.juli + userObj.integral)
	    self.LoadingBar_1:setPercent(percent*100 or "")
	    self.perecent:setString((math.modf(percent*100) or "").."%") 
	end
end

function clsMyInfoView:SwitchTo(iPage)
	if iPage == 1 then
		if not self._bAskedUserInfo then
			proto.req_user_info()
		end
		self.BtnPersonal:setColor(cc.c3b(255,255,255))
        self.Text_3:setTextColor(cc.c3b(255,0,0))
        self.BtnGrade:setColor(cc.c3b(220,59,64))
        self.Text_4:setTextColor(cc.c3b(255,255,255))
        self.Title_Level:setVisible(false)
        self.Person_Data:setVisible(true)
    else
    	if not self._bAskedUserNobility then
    		proto.req_user_nobility()
    	end
    	self.BtnPersonal:setColor(cc.c3b(220,59,64))
        self.Text_3:setTextColor(cc.c3b(255,255,255))
        self.BtnGrade:setColor(cc.c3b(255,255,255))
        self.Text_4:setTextColor(cc.c3b(255,0,0))
        self.Title_Level:setVisible(true)
        self.Person_Data:setVisible(false)
    end
end