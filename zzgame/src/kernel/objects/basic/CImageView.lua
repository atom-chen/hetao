-------------------------
-- 扩展
-------------------------
local _InstTextureCache = cc.Director:getInstance():getTextureCache()
local _InstSpriteFrameCache = cc.SpriteFrameCache:getInstance()
local _InstAnimationCache = cc.AnimationCache:getInstance()
local _InstArmatureDataMgr = ccs.ArmatureDataManager:getInstance()

local ImageView = ccui.ImageView

ImageView.__origin_create = ImageView.create
function ImageView:create(respath, resType)
	if resType then
		return ImageView:__origin_create(respath, resType)
	end
	
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		return ImageView:__origin_create(respath, ccui.TextureResType.plistType)
	else
		return ImageView:__origin_create(respath)
	end
end

ImageView.__origin_loadTexture = ImageView.loadTexture
function ImageView:loadTexture(respath)
	if not respath then return end
	local sprFrame = _InstSpriteFrameCache:getSpriteFrame(respath)
	if sprFrame then
		self:__origin_loadTexture(respath, ccui.TextureResType.plistType)
	else
		self:__origin_loadTexture(respath)
	end
	if self._isCircle then
		utils.Clip2Circle(self, self:getContentSize().width)
	end
end

function ImageView:EnableTouch(callback)
	if self._touch_enabled then return end
	self._touch_enabled = true
	self._touchCallback = callback
	self:setTouchEnabled(true)
	utils.RegClickEvent(self, function()
		if self._touchCallback then 
			self._touchCallback() 
		end
	end)
end 

function ImageView:SetMaxSize(wid,hei)
	self:setScale9Enabled(false)
	self:setContentSize(wid,hei)
	self:ignoreContentAdaptWithSize(false)
end

function ImageView:SetCircle(enable)
	self._isCircle = enable
	if self._isCircle then
		utils.Clip2Circle(self, self:getContentSize().width)
	end
end

function ImageView:SetLoadedCallback(func)
	self._loadCallback = func 
end 

function ImageView:LoadTextureSync(url)
	if not url or url == "" then return end
	if type(url) ~= "string" then return end

	local s, e = string.find(url, "http")
	if s and s == 1 then
		if device.platform == "ios" then
			local originUrl = url
			url = SalmonUtils:fixUrl2utf8(url) 
			local s1, e1 = string.find(url or "", "http")
			if not s1 or not url or url == "" then url = originUrl end
		end
		
		self.callback = function(filepath)
			if utils.IsValidCCObject(self) then
				if string.sub(url, -3, -1) == "gif" then
					if createCacheGif then
						local cacheGif = createCacheGif(cc.FileUtils:getInstance():fullPathForFilename(filepath))
						if cacheGif then
							cacheGif:setPosition(self:getContentSize().width/2,self:getContentSize().height/2)  
							self:addChild(cacheGif)
							self._gifSprite = cacheGif
						end
					end
					if self._loadCallback then self._loadCallback(self) end
				else
					self:do_load_texture(filepath)
				end
				self.callback = nil
			end
		end
		if not ClsImageDownloader.GetInstance():GetImage(url, self.callback) then
			self:EnableNodeEvents()
			self:AddScriptHandler(const.CORE_EVENT.exit, function()
				ClsImageDownloader.GetInstance():RemoveListener(self.callback)
				self.callback = nil
			end)
		end
	else
		self:do_load_texture(url)
	end
end

function ImageView:do_load_texture(respath)
	self:loadTexture(self:CheckImge(respath))
	if self._loadCallback then self._loadCallback(self) end
end

function ImageView:CheckImge(filename)
	local image = cc.Image:new()
	local ret = image:initWithImageFile(filename)
	if ret then return filename end
	if _InstSpriteFrameCache:getSpriteFrame(filename) then return filename end
	logger.error("图片不存在", filename)
	return "uistu/common/null.png"
end
