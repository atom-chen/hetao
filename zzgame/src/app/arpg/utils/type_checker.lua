-------------------------
--类型检查扩展
-------------------------
function TYPE_CHECKER.SEX(v) 
	return v==const.GENDER.MALE or v==const.GENDER.FEMALE, "性别值应该为【\"1\"或\"2\"】，当前为 " .. v
end

function TYPE_CHECKER.BILL_TYPE(v) 
	local flag = false
	for _, billType in pairs(const.BILL_TYPE) do
		if billType == v then 
			flag = true 
			break 
		end
	end
	return flag, "无效的订单类型：" .. v
end