-----------------------------------
-- 脚本层性能分析
-----------------------------------
local string_format = string.format
local os_clock = os.clock
local debug_getinfo = debug.getinfo

--表中的函数名将不会受到监控
local ignore_tbl = {
	["print"] = true,
	["clock"] = true,
	["pairs"] = true,
	["ipairs"] = true,
	["type"] = true,
}


profiler = {}

function profiler:_func_title(funcinfo)
	local name = funcinfo.name or  "unknown_func"
	local line = funcinfo.linedefined or 0
	local source = funcinfo.short_src or "unknown_path"
	return string_format("【%s:%s:%d】", name, source, line)
end

function profiler:_func_report(funcinfo)
	if ignore_tbl[funcinfo.name] then 
--		print("ignore: ",funcinfo.name) 
		return nil 
	end 
	
	local title = self:_func_title(funcinfo)
	local report = self._REPORTS_BY_TITLE[title]
	if not report then
		report = {
			title = title,   
			callcount = 0,   
			totaltime = 0,
        }
		self._REPORTS_BY_TITLE[title] = report
		table.insert(self._REPORT_LIST, report)
	end
	return report
end

--调用函数时的钩子
function profiler:_profiling_call(funcinfo)
	local report = self:_func_report(funcinfo)
--	print("++++",funcinfo.name)
	if report then 
    	report.calltime = os_clock()
    	report.callcount = report.callcount + 1
    end 
end

--函数返回时的钩子
function profiler:_profiling_return(funcinfo)
	local stoptime = os_clock()
	local report = self:_func_report(funcinfo)
--	print("----",funcinfo.name)
	if report and report.calltime and report.calltime > 0 then 
		report.totaltime = report.totaltime + (stoptime - report.calltime)
		report.calltime = 0
		if stoptime-report.calltime > 1000 then
			table.insert(self._WARN_TBL, string_format("高耗时函数：%f,  %s", stoptime-report.calltime, report.title))
		end 
	end
end

--钩子
function profiler._profiling_handler(hooktype)
	local funcinfo = debug_getinfo(2, 'nS')
	if hooktype == "call" then
		profiler:_profiling_call(funcinfo)
	elseif hooktype == "return" then
		profiler:_profiling_return(funcinfo)
	end
end


--开始监控
function profiler:start()
	if device.platform ~= "windows" then return end --windows下才监控
	print("+++++++++++ 开始监控 +++++++++++")
	self._REPORT_LIST = {}
	self._REPORTS_BY_TITLE = {}
	self._WARN_TBL = {}
	self._STARTIME = os_clock()
	debug.sethook(profiler._profiling_handler, 'cr', 0)
end

--停止监控
function profiler:stop()
	if device.platform ~= "windows" then return end --windows下才监控
	if not self._STARTIME then return end
	print("+++++++++++ 停止监控 +++++++++++")
	debug.sethook()
	self:show("profiler.txt")
end

--打印
function profiler:show(filepath)
	if device.platform ~= "windows" then return end --windows下才监控
	if not self._STARTIME then return end
	
	self._STOPTIME = os_clock()
	local totaltime = self._STOPTIME - self._STARTIME
	
	local clonelist = {}
	for k,v in ipairs(self._REPORT_LIST) do 
		clonelist[k] = v 
	end 
	table.sort(clonelist, function(a, b)
		return a.totaltime > b.totaltime
	end)
	
	print("----------------------------------------------")
	--打印高耗时信息
	local fout = filepath and io.open(filepath, "w")
	for _, strwarn in ipairs(self._WARN_TBL) do 
		print(strwarn)
		if fout then
			fout:write(string_format("%s\n", strwarn))
		end
	end 
	--打印所有调用信息
	if fout then 
		fout:write( string_format("%-20s  %-20s  %-20s    %s\n", "占时", "占时百分比", "调用次数", "函数信息") )
	end 
	for _, report in ipairs(clonelist) do
		local percent = 100 * report.totaltime / totaltime
		print( string_format("%10.3f, %10.2f%%, %10d, %s", report.totaltime, percent, report.callcount, report.title) )
		if fout then
			fout:write(string_format("%-20.3f  %-20.2f  %-10d %s\n", report.totaltime, percent, report.callcount, report.title))
		end 
		if percent < 0.1 then break end
	end
	if fout then fout:close() end 
	print("----------------------------------------------")
end
