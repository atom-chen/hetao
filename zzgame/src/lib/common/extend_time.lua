-------------------------
-- 时间库扩展
-------------------------
module("libtime", package.seeall)

--根据日期时间，得到需要的以秒计算的单位
--传入的参数和返回的秒数的时区均为北京时间
function MkTime(year, mon, day, hour, min, sec)
	mon = mon - 2
	if 0 >= mon then   --1..12 -> 11,12,1..10 
		mon = mon + 12 -- Puts Feb last since it has leap day 
		year = year - 1
	end

	return (((
		(math.floor(year/4) - math.floor(year/100) + math.floor(year/400) + math.floor(367*mon/12) + day) +
			year*365 - 719499
	    )*24 + hour --/* now have hours */
	  )*60 + min    --/* now have minutes */
	)*60 + sec      --/* finally seconds */
end

 --计算今天是周几
function CalWeekNo(y,m,d)                                                     
	y = tonumber(y)                                                              
	m = tonumber(m)                                                              
	d = tonumber(d)                                                              
	
	if m==1 or m==2 then                                                        
		m= m + 12                                                                  
		y= y -1
	end
	
	return (math.floor( ((d+2*m+3*(m+1)/5+y+y/4-y/100+y/400)+1)%7 ))
end

--将"2006-06-01 10:00:00"这样的时间转换为秒
function sDate2Sec(sDateTime)
	return os.time(sDate2Table(sDateTime))
end

 --将"2005-06-01 00:00:00"格式的日期转换为time table形式                      
function sDate2Table(sDateTime)                                                            
	if type(sDateTime) ~= "string" or                                                      
		string.match(sDateTime, "^%d+%-%d+%-%d+ %d+:%d+:%d+$") == nil then        
		return nil
	end                                                                                            
	
	local MatchTable = {}                                                                     
	
	for item in string.gmatch(sDateTime, "%d+") do                                      
		table.insert(MatchTable, item)                                                     
	end                                                                                            
	
	local TimeTable = {}                                                                       
	TimeTable.year = MatchTable[1]   
	TimeTable.month = MatchTable[2]  
	TimeTable.day = MatchTable[3]     
	TimeTable.hour = MatchTable[4]   
	TimeTable.min = MatchTable[5]     
	TimeTable.sec = MatchTable[6]     
	return TimeTable                                                                           
end

local M = {1,3,5,7,8,10,12}
function ValidDate (y,m,d)
	local nMaxDay = 30
	if m == 2 then
		if (y %4 == 0) and (y % 100 ~= 0) then
			nMaxDay = 29
		elseif y % 400 == 0 then
			nMaxDay = 29
		else
			nMaxDay = 28
		end
	end
	if table.has_value (M, m) then
		nMaxDay = 31
	end
	
	if d < 1 or d > nMaxDay then
		return false
	end

	return true	
end

function ValidDayNum(y, m)
	y = tonumber(y)
	m = tonumber(m)
	local nMaxDay = 30
	if m == 2 then
		if (y %4 == 0) and (y % 100 ~= 0) then
			nMaxDay = 29
		elseif y % 400 == 0 then
			nMaxDay = 29
		else
			nMaxDay = 28
		end
	end
	if table.has_value (M, m) then
		nMaxDay = 31
	end
	
	return nMaxDay
end

--将秒数转换成 00:00:00
function ChangeSToH(Time, NotShowHour)
	Time = math.max(0, Time or 0)
	local h = math.floor(Time/3600)
	Time = Time % 3600
	local m = math.floor(Time/60)
	local s = math.floor(Time % 60)
	if NotShowHour then
		return string.format("%02d : %02d", m, s)
	else
		return string.format("%02d : %02d : %02d", h, m, s)
	end
end

function ChangeSToTbl(Time)
	Time = math.max(0, Time or 0)
	local h = math.floor(Time/3600)
	Time = Time % 3600
	local m = math.floor(Time/60)
	local s = math.floor(Time % 60)
	return h,m,s
end

TIME_BASE = 1072886400
function GetRelaDayNo(Time)
	local TotalDay = 0
	local Standard = TIME_BASE		--2004年1月1日 00:00
	if not Time then
		Time = os.time()
	end
	if Time > Standard then
		TotalDay = (Time - Standard)/3600/24
	else
		TotalDay = (Standard - Time )/3600/24
	end
	return math.floor(TotalDay) + 1
end

function IsRYear(year)
	if year%400 == 0 or (year % 4 == 0 and year % 100 ~= 0) then
		return true
	else
		return false
	end
end

function Days(year,month)
	if month == 1 or month == 3 or month == 5 or month == 7 or month == 8 or month == 10 or month == 12 then 
		return 31
	elseif month == 4 or month == 6 or month == 9 or month == 11 then
		return 30
	else
		if IsRYear(year) then
			return 29
		else
			return 28
		end
	end
end

function IsSameDay(timestamp1, timestamp2)
	if not timestamp1 or not timestamp2 then return false end
	local t1 = os.date("*t", timestamp1)
	local t2 = os.date("*t", timestamp2)
	return t1.year==t2.year and t1.month==t2.month and t1.day==t2.day
end
