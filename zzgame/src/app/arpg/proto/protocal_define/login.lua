return {
	{
		desc = "获取IP",
		name = "req_get_ipinfo",
		reqType = "GET",
		domain = "http://ip.taobao.com/service/getIpInfo.php?ip=myip",
		addr = "",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "是否可注册",
		name = "req_login_can_regist",
		reqType = "POST",
	--	domain = "",
		addr = "login/is_user_add",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "获取验证码图片",
		name = "req_login_code",
		reqType = "XHRGET",
	--	domain = "",
		addr = "login/code",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "token_private_key", "string" },
		}
	},
	{
		desc = "获取token_private_key",
		name = "req_login_get_token_private_key",
		reqType = "POST",
	--	domain = "",
		addr = "login/get_token_private_key",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {}
	},
	{
		desc = "登录",
		name = "req_login_logon",
		reqType = "POST",
	--	domain = "",
		addr = "login/token",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "username", "string" },
			{ "pwd", "string" },
			{ "token_private_key", "string" },
			{ "code", "string", true }
		}
	},
	{
		desc = "注册",
		name = "req_login_regist",
		reqType = "POST",
	--	domain = "",
		addr = "login/user_register",
		respType = "XMLHTTPREQUEST_RESPONSE_STRING",
		params = {
			{ "invite_code", "string" },
			{ "username", "string" },
			{ "pwd", "string" },
			{ "bank_name", "string", true },
			{ "token_private_key", "string" },
			{ "yzm", "string", true },
			{ "ip", "string", true },
			{ "from_way", "string", true },
		}
	},
    {
        desc = "登出",
        name = "req_login_logout",
        reqType = "GET",
        addr = "login/logout",
        respType = "XMLHTTPREQUEST_RESPONSE_STRING",
        params = {}
    },
}