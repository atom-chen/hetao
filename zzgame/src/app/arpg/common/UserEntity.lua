-----------------------------------------
-- 用户（我）
-----------------------------------------
UserEntity = class("UserEntity", clsCoreObject)
UserEntity.__is_singleton = true

UserEntity:RegSaveVar("username", TYPE_CHECKER.STRING)		--用户账号
UserEntity:RegSaveVar("pwd", TYPE_CHECKER.STRING)			--账号密码
UserEntity:RegSaveVar("token", TYPE_CHECKER.STRING)			--用户token
UserEntity:RegSaveVar("type", TYPE_CHECKER.ANY)				--账号类型 1：普通玩家 2：代理

UserEntity:RegSaveVar("birthday", TYPE_CHECKER.STRING)		--生日
UserEntity:RegSaveVar("img", TYPE_CHECKER.ANY )				--头像
UserEntity:RegSaveVar("phone", TYPE_CHECKER.STRING)			--电话号码
UserEntity:RegSaveVar("nickname", TYPE_CHECKER.STRING)		--昵称
UserEntity:RegSaveVar("sex", TYPE_CHECKER.SEX)				--性别：1男 2女
UserEntity:RegSaveVar("email", TYPE_CHECKER.STRING)			--邮箱
UserEntity:RegSaveVar("modify", TYPE_CHECKER.STRING)		--是否已修改 nickname,phone,emali,sex,birthday    0为未修改，1为已修改

UserEntity:RegSaveVar("balance", TYPE_CHECKER.INT)			--余额
UserEntity:RegSaveVar("bank_name", TYPE_CHECKER.STRING)		--银行卡真实姓名
UserEntity:RegSaveVar("bank_pwd", TYPE_CHECKER.INT)			--支付密码是否已绑定 1有
UserEntity:RegSaveVar("dengji", TYPE_CHECKER.STRING)		--等级，VIP几
UserEntity:RegSaveVar("binding", TYPE_CHECKER.INT)			--是否绑定银行卡 1有


function UserEntity:ctor()
	clsCoreObject.ctor(self)
end

function UserEntity:dtor()

end

function UserEntity:IsAgent()
	return self:Get_type() == 2 or self:Get_type() == "2"
end

local Key2Modify = {
	nickname = 1,
	phone = 2,
	email = 3,
	sex = 4,
	birthday = 5,
}
function UserEntity:IsModifyed(key)
	local oldModify = UserEntity.GetInstance():Get_modify() or ""
	if oldModify == "" then oldModify = "0,0,0,0,0" end
	
	local idxList = {}
	if string.find(oldModify, "k") then
		idxList = string.split(oldModify, "k")
	else
		idxList = string.split(oldModify, ",")
	end
	
	return idxList[ Key2Modify[key] ] == "1"
end

function UserEntity:ReqChangeInfo(key, value)
	local oldModify = self:Get_modify() or ""
	if oldModify == "" then oldModify = "0,0,0,0,0" end
	print("--------", os.date( "%Y/%m/%d", tonumber(self:Get_birthday()) ) )
	local param = {
		nickname = self:Get_nickname(),
		phone = self:Get_phone(),
		email = self:Get_email(),
		sex = self:Get_sex(),
		birthday = os.date( "%Y/%m/%d", tonumber(self:Get_birthday()) ) or "",
		modify = oldModify,
	}
	param[key] = value
	
	local idxList = {}
	if string.find(oldModify, "k") then
		idxList = string.split(oldModify, "k")
	else
		idxList = string.split(oldModify, ",")
	end
	for i=1, 5 do
		if not idxList[i] then idxList[i] = "0" end
	end
	
	local modifyIdx = Key2Modify[key]
	idxList[modifyIdx] = "1"
	local newModify = table.concat(idxList, ",")
	param.modify = newModify
	
	proto.req_user_update_info(param)
end

function UserEntity:SetAttr(VarName, Value)
    if VarName == "birthday" then
        Value = tostring(tonumber(Value)/1000)
    end
    clsCoreObject.SetAttr(self, VarName, Value)
end
