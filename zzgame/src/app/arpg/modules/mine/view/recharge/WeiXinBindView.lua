-------------------------
-- 微信绑定界面
-------------------------
module("ui", package.seeall)

local crypto = require("kernel.framework.crypto")

clsWeiXinBindView = class("clsWeiXinBindView", clsBaseUI)

function clsWeiXinBindView:ctor(parent)
	clsBaseUI.ctor(self, parent, "uistu/WeiXinBindView.csb")
	
	self.EditWxAccount = utils.ReplaceTextField(self.EditWxAccount, "", "FF111111")
	self.EditSecret = utils.ReplaceTextField(self.EditSecret, "", "FF111111")
	self.EditPhone = utils.ReplaceTextField(self.EditPhone, "", "FF111111")
	self:InitUiEvents()
	self:InitGlbEvents()

	proto.req_user_bind_needinfo(nil, {bank_name="user/bank_name"})
end

function clsWeiXinBindView:dtor()
	
end

function clsWeiXinBindView:SetFromInfo(info)
	self._fromInfo = info
end

--注册控件事件
function clsWeiXinBindView:InitUiEvents()
	utils.RegClickEvent(self.BtnClose, function() self:removeSelf() end)
	utils.RegClickEvent(self.BtnSure, function() 
		local filepath = self._erweimaPath
		if not filepath or filepath == "" then
			utils.TellMe("请选择二维码")
			return
		end
		
		local contentType = "Image/png"
		if utils.is_png_file(filepath) then
			contentType = "Image/png"
		elseif utils.is_jpg_file(filepath) then
			contentType = "Image/jpeg"
		else
			utils.TellMe("请上传PNG格或JPG格式的图片")
			return
		end
		
		local needInfo = self._needinfo or {}
		local needPhone = true
		if needInfo.is_phone == "0" or needInfo.is_phone == 0 then
			needPhone = false
		end
		local needPwd = true
		if needInfo.is_pwd == "0" or needInfo.is_pwd == 0 or needInfo.is_pwd == false then
			needPwd = false
		end
		
		local param = {
				phone = self.EditPhone:getString(),
				bank_name = self._fromInfo.name,
				bank_pwd = crypto.md5( self.EditSecret:getString() ),
				num = self.EditWxAccount:getString(),	--微信号
				bank_id = self._fromInfo.bank_id,
				file = cc.FileUtils:getInstance():fullPathForFilename(filepath),
		}
		
		if needPwd and not param.bank_pwd or param.bank_pwd == "" then
			utils.TellMe("请输入资金密码")
			return
		end
		if not param.num or param.num == "" then
			utils.TellMe("请输入微信账号")
			return
		end
		if not param.file or param.file == "" then
			utils.TellMe("请选择要上传的微信二维码")
			return
		end
			
		if device.platform == "android" then
			local strParam = {}
			for k,v in pairs(param) do
				table.insert(strParam, k.."="..v)
			end
			strParam = table.concat(strParam, "&")
			
			local function succCallback(resp_data)
				KE_SetTimeout(2, function()
					HttpUtil:OnRespData("req_user_bind_wx_zfb", false, resp_data, nil, param)
				end)
			end
			local function failCallback(resp_data)
				KE_SetTimeout(2, function()
					utils.TellMe("绑定失败")
				end)
			end
			local function loadingCallback(resp_data)
				
			end
			HttpHelper:bindWxZfb(SERVER_URL.."/user/user_card/card_add", cc.FileUtils:getInstance():fullPathForFilename(filepath), strParam, succCallback, failCallback, loadingCallback)
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
		                utils.TellMe("绑定微信成功")
					end
				end,
				HttpUtil:GetPtoUrl("req_user_bind_wx_zfb", {file=cc.FileUtils:getInstance():fullPathForFilename(filepath)}, nil),
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
			--proto.req_user_bind_wx_zfb(param)
		end
	end)
	
	utils.RegClickEvent(self.PanelQrImg, function() 
		local handler = function(filepath)
			if device.platform == "windows" then
				filepath = "res/Default/wx_jpg_ewm.jpg"
			end
			
			if utils.IsValidCCObject(self) then
				self:DestroyTimer("tmr_erwm")
				self:CreateTimerDelay("tmr_erwm", 4, function()
					logger.normal("二维码路径：", filepath)
					cc.Director:getInstance():getTextureCache():removeTextureForKey(filepath)
					self.ImgErwm:loadTexture(filepath)
					self._erweimaPath = filepath
				end)
			end
		end
		SalmonUtils:openGallery(handler, "wx_erweima.jpg")
	end)
end

-- 注册全局事件
function clsWeiXinBindView:InitGlbEvents()
	g_EventMgr:AddListener(self, "on_req_user_bind_needinfo", function(this, recvdata)
		self._needinfo = recvdata and recvdata.data 
		self:AdjustUI()
	end)
end

function clsWeiXinBindView:AdjustUI()
	local needInfo = self._needinfo or {}
	local needPhone = true
	if needInfo.is_phone == "0" or needInfo.is_phone == 0 then
		needPhone = false
	end
	local needPwd = true
	if needInfo.is_pwd == "0" or needInfo.is_pwd == 0 or needInfo.is_pwd == false then
		needPwd = false
	end
	
	if needPhone then
		self.PanelPhone:setVisible(true)
		self.PanelSec:setPositionY(-363)
		self.BtnSure:setPositionY(-508)
		self.TextTip:setPositionY(-576)
	else
		self.PanelPhone:setVisible(false)
		self.PanelSec:setPositionY(-363+80)
		self.BtnSure:setPositionY(-508+80)
		self.TextTip:setPositionY(-576+80)
	end
	
	self.PanelSec:setVisible(needPwd)
	if not needPwd then
		self.BtnSure:setPositionY(self.BtnSure:getPositionY()+80)
		self.TextTip:setPositionY(self.TextTip:getPositionY()+80)
	end
end