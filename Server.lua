---------------------------
-- Quick Click Server
-- Joshua
-- 2013-05-21 20:05:01
---------------------------
require("socket")
require("cjson")
require("coding")

local port = tonumber(coding.debase64("MTUzNzQ="))

function LogPrint(...)
	io.write("|",os.date(),"| ",...)
	io.write("\n")
end

function ToLua(k,v,n)
	local r={}
	n=n or 0
	if type(v)~='table' then
		table.insert(r,table.concat{('\t'):rep(n),'[',type(k)=='string' and '"'..k..'"' or k,']\t= ',type(v)=='string' and '"'..tostring(v)..'"' or tostring(v),',\n'})
	else
		if n~=0 then
			table.insert(r,table.concat{('\t'):rep(n),'[',type(k)=='string' and '"'..k..'"' or k,']\t= {\n'})
		else
			table.insert(r,table.concat{k,"{\n"})
		end
		for i,t in pairs(v) do
			table.insert(r,ToLua(i,t,n+1))
		end
		if n~=0 then
			table.insert(r,table.concat{('\t'):rep(n),'},\n'})
		else
			table.insert(r,table.concat{"}"})
		end
	end
	return table.concat(r)
end

function Error(...)
	local str=table.concat({...})
	local f=io.open("error.log","a")
	f:write("|",os.date(),"| ",str,"\n")
	f:close()
	error(str)
end

function LoadData(fn)
	local file=io.open(fn,"r")
	if not file then
		Error("读取文件",fn,"时失败，找不到该文件或者没有读取权限。")
	end
	local str=file:read("*all")
	file:close()
	local a,b=pcall(loadstring(str))
	if a and b then
		return b
	elseif not a and b then
		Error("文件",fn,"数据失效，无法正常读取。")
	end
end

function SaveData(fn,t)
	local file = io.open(fn,"w")
	file:write(ToLua("return ",t))
	file:close()
end

function Assert(id)
	local t = LoadData("user.ldb")
	return t[id] and 1 or 0
end

function Register(id, nick)
	local t = LoadData("user.ldb")
	t[id]={nick = nick}
	SaveData("user.ldb", t)
end

function PushPoint(id, pt)
	local t = LoadData("user.ldb")
	if pt < 0.2 then
		for i=1,5 do
			t.list[i] = t.list[i] or {}
			t.list[i].nick = t.list[i].nick or "--"
			t.list[i].time = t.list[i].time and string.format("%0.3f",t.list[i].time) or "-----"
		end
		t.list[6] = string.format("%0.3f\n\t\t  the time is too short, so it not be recorded." ,t[id].best)
		return t.list
	else
		if not t[id].best or t[id].best > pt then
			t[id].best = pt
		end	
		t.list[#t.list+1]={nick = t[id].nick, time = pt}
		table.sort(t.list,function(a,b) return tonumber(a.time) < tonumber(b.time) end)
		for i=6, #t.list do
			t.list[i] = nil
		end
		SaveData("user.ldb", t)
		for i=1,5 do
			t.list[i] = t.list[i] or {}
			t.list[i].nick = t.list[i].nick or "--"
			t.list[i].time = t.list[i].time and string.format("%0.3f",t.list[i].time) or "-----"
		end
		t.list[6] = string.format("%0.3f",t[id].best)
		return t.list
	end
end

function StartServer()
	LogPrint("server: start")
	local Server=socket.tcp()
	Server:bind("*",port)
	Server:listen(8)
	Server:settimeout(10)
	while true do
		socket.select({Server})
		local obj = Server:accept()
		obj:settimeout(1)
		local r, s = obj:receive("*l")
		if s ~= "closed" and type(r) == "string" then
			local t = cjson.decode(coding.debase64(coding.debase64(r)))
			if type(t) == "table" then
				if t.type == "assert" then
					local st = {retcode = Assert(t.id)}
					LogPrint("assert: id - ", t.id, ", res - ", st.retcode)
					obj:send(coding.base64(coding.base64(cjson.encode(st))).."\n")
					obj:close()
				elseif t.type == "register" then
					LogPrint("register: id - ", t.id, ", nick - ", t.nick)
					Register(t.id, t.nick)
					obj:close()
				elseif t.type == "pushpoint" then
					if t.time < 0.2 then
						LogPrint("push: id - ", t.id, ", point - ", t.time, ", no recode")
					else
						LogPrint("push: id - ", t.id, ", point - ", t.time)
					end
					local st = PushPoint(t.id, t.time)
					obj:send(coding.base64(coding.base64(cjson.encode(st))).."\n")
					obj:close()
				end
			end
		end
	end
end

StartServer()