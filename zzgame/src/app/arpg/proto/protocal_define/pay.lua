return {
	{
		desc = "支付-网站信息文章内容接口",
		name = "req_pay_siteinfo_article",
		reqType = "GET",
	--	domain = "",
		addr = "rules/game_rules/get_game_article_content",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "int" },
		}
	},
	{
		desc = "获取支付通道信息",
		name = "req_pay_get_pay_channel_info",
		reqType = "GET",
	--	domain = "",
		addr = "index.php/pay/pay/pay_method",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "快捷支付 步骤1",
		name = "req_pay_quick_pay_step1",
		reqType = "POST",
	--	domain = "",
		addr = "pay/pay/pay_do",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },
			{ "code", "string" },
			{ "bank_type", "string" },
			{ "money", "float" },
			{ "cardNo", "string" },
			{ "cardType", "int" },
			{ "cardName", "string" },
			{ "idCardNo", "string" },
			{ "cnv2", "string", true },
			{ "validData", "string" },
			{ "step", "int" },
		}
	},
	{
		desc = "快捷支付 步骤2",
		name = "req_pay_quick_pay_step2",
		reqType = "POST",
	--	domain = "",
		addr = "pay/pay/pay_do",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },
			{ "code", "string" },
			{ "bank_type", "string" },
			{ "order_num", "string" },
			{ "pwd", "string" },
			{ "step", "int" },
		}
	},
	{
		desc = "提交支付",
		name = "req_pay_commit",
		reqType = "POST",
	--	domain = "",
		addr = "pay/pay/pay_do",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "id", "string" },				--gc_bank_online_pay的id
			{ "code", "string" },				--支付通道(gc_bank_online表分配的pay_code)
			{ "money", "float" },			--
			{ "card_pwd", "string", true },	--优惠卡密
			{ "bank_type", "string", true },	--银行类型，code为7时必传
			{ "bank_style", "string", true },	--转账方式
			{ "name", "string", true },		--转款人姓名
			{ "data", "int", true },		--存款时间
			{ "confirm", "string", true },		--确认订单号
			--下面参数在快捷支付时必传，详见快捷支付接口文档
			{ "cardNo", "string", true },	--银行卡卡号
			{ "cardType", "int", true },	--卡号类型：1借记卡 2贷记卡(暂不支持)
			{ "cardName", "string", true },	--开户姓名
			{ "idCardNo", "string", true },	--身份证号
			{ "cnv2", "string", true },		--信用卡安全码，信用卡必填
			{ "validData", "string", true },--信用卡有效期，格式为YYMM
			{ "step", "int", true },		--步骤，固定值1
			{ "jump_mode", "int", true },		--步骤，固定值1
			{ "from_way", "string", true},
			{ "qrcode", "string", true},
		}
	},
	{
		desc = "提现方式获取",
		name = "req_pay_withdraw_type",
		reqType = "POST",
	--	domain = "",
		addr = "pay/Out_mamage/out_type",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "money", "string" },
		}
	},
	{
		desc = "提现",
		name = "req_pay_withdraw",
		reqType = "POST",
	--	domain = "",
		addr = "pay/Out_mamage/member_out",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "money", "string" },
			{ "bank_pwd", "string" },
			{ "out_type", "string" },
		}
	},
}