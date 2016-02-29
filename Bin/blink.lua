----------------------------------
-- Blink1-Tool Lua Moudle
-- By Joshua
-- At 2013-05-18 18:44:41
----------------------------------
local io = io
local os = os
local string = string

module(...)

local function shell(str)
	local obj = io.popen("blink1-tool.exe " .. str)
	local res = obj:read("*a")
	obj:close()
	return res:sub(1,-2)
end

function rgb(r, g, b, t)
	return shell(string.format("-m %d --rgb %d,%d,%d", t or 300, r, g, b))
end

function on(t)
	return shell(string.format("-m %d --on", t or 300))
end

function off(t)
	return shell(string.format("-m %d --off", t or 300))
end

function red(t)
	return shell(string.format("-m %d --red", t or 300))
end

function blue(t)
	return shell(string.format("-m %d --blue", t or 300))
end

function green(t)
	return shell(string.format("-m %d --green", t or 300))
end

function rand(n, m, t)
	local fstr = ("--random %d"):format(n or 10)
	if m then
		fstr = fstr .. (" -m %d"):format(m)
	end
	if t then
		fstr = fstr .. (" -t %d"):format(t)
	end
	return shell(fstr)
end

function version()
	return shell("--version")
end

function list()
	return shell("--list")
end
