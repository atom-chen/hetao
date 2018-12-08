-------------------------------
-- 管理器
-------------------------------
ClsHelpDocMgr = class("ClsHelpDocMgr")
ClsHelpDocMgr.__is_singleton = true

function ClsHelpDocMgr:ctor()
	self._tContents = {}
end

function ClsHelpDocMgr:dtor()

end

function ClsHelpDocMgr:SaveContent(Type, content)
	if Type == "lhc" or Type == "s_lhc" then
		content = string.gsub(content, "02,04,06,08,10,12,14,16,18,20,22,24,26,28,30,32,34,36,38,40,42,44,46,48", "02, 04, 06, 08, 10, 12, 14, 16, 18, 20, 22, 24, 26, 28, 30, 32, 34, 36, 38, 40, 42, 44, 46, 48")
		content = string.gsub(content, "01,03,05,06,07,09,11,13,15,17,19,21,23,25,27,29,31,33,35,37,39,41,43,45,47", "01, 03, 05, 06, 07, 09, 11, 13, 15, 17, 19, 21, 23, 25, 27, 29, 31, 33, 35, 37, 39, 41, 43, 45, 47")
	end
	self._tContents[Type] = content
end

function ClsHelpDocMgr:GetContent(Type)
	return self._tContents[Type] or self._tContents["s_"..Type]
end