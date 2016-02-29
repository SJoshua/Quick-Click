---------------------------
-- Quick Click
-- Joshua
-- 2013-05-11 11:53:14
---------------------------
require("lcon")
require("socket")
require("cjson")
require("coding")
require("blink")

local host = coding.debase64("THVhQ0MuNTRkZi5uZXQ=")
local port = tonumber(coding.debase64("MTUzNzU="))
local cnet = true

local lcos = {
	black = 0,
	blue = 1,
	green = 2,
	lgreen = 3,
	red = 4,
	purple = 5,
	yellow = 6,
	white = 7,
	gray = 8,
	lblue = 9,
	lgreen = 10,
	lsgreen = 11,
	lred = 12,
	lpurple = 13,
	lyellow = 14,
	bwhite = 15
}

local function send(t, get)
	local msg = coding.base64(coding.base64(cjson.encode(t)))
	local link = socket.tcp()
	link:settimeout(3)
	local res, tip = link:connect(host, port)
	if not res then
		cls()
		cwrite(lcos.lred, "\t\t\tNetwork error: Server is closed.")
		wait()
		cls()
		cnet = false
		return false
	else
		link:send(msg .. "\n")
		if get then
			local r = link:receive("*l")
			if type(r) == "string" then
				local k = cjson.decode(coding.debase64(coding.debase64(r)))
				link:close()
				return k
			end
		end
		link:close()
		return true
	end
end

function cwrite(color, ...)
	lcon.set_color((type(color) == "number" and color >= 0 and color <= 15) and color or lcos.white)
	io.write(...)
	lcon.set_color(lcos.white)
end

function wait()
	while lcon.getch() ~= 13 do end
end

function pause(msg, color)
	lcon.set_color((type(color) == "number" and color >= 0 and color <= 15) and color or lcos.white)
	io.write(msg or "please press any key.")
	lcon.set_color(lcos.white)
	lcon.getch()
end 

function cls()
	os.execute("cls")
end

function wtime(t)
	while t > 0 do
		cwrite(lcos.bwhite, "\r\t\t\t\t", t)
		if t ~= 0 then
			blink.rand(1, 1000)	
		end
		t = t - 1
	end
	cwrite(lcos.lred, "\r\t\t\t\tStart!\n")
	blink.on(300)
end

function clean_enter()
	local flag = false
	while lcon.kbhit() == 1 do
		lcon.getch()
		flag = true
	end
	return flag
end

io.mread = io.read

function io.read(Max, pw, Min)
	if not Max then
		return io.mread()
	end
	local res={}
	local point = 1
	local x, y = lcon.cur_x(),lcon.cur_y()
	while true do
		local key = lcon.getch()
		if key == 13 then
			if #res > (Min or pw or 0) then
				break
			else
				local nx, ny = lcon.cur_x(),lcon.cur_y()
				lcon.gotoXY(x, ny + 2)
				cwrite(lcos.lred,  "Tips: need " .. (Min or pw) .. " chars.")
				lcon.gotoXY(nx, ny)
			end
		elseif key == 8 then
			if point >= 1 then
				if res[point - 2] and res[point - 2]:byte() > 127 and res[point - 1]:byte() > 127 then
					point = point - 1
					table.remove(res, point)
				end
				if point > 1 then
					point = point - 1
				end
				table.remove(res, point)
				lcon.gotoXY(x, y)
				if pw then
					io.write(("*"):rep(#res),"  ")
				else
					io.write(table.concat(res),"  ")
				end
				lcon.gotoXY(x + point - 1, y)
			end
		elseif key == 224 or key == 0 then
			local key2 = lcon.getch()
			if key2 == 75 then
				if point > 1 then
					if res[point - 2] and res[point - 2]:byte() > 127 and res[point - 1]:byte() > 127 then
						point = point - 1
					end
					point = point - 1
					lcon.gotoXY(x + point - 1, y)
				end
			elseif key2 == 77 then
				if point <= #res then
					if res[point + 2] and res[point + 2]:byte() > 127 and res[point + 1]:byte() > 127 then
						point = point + 1
					end
					point = point + 1
					lcon.gotoXY(x + point - 1, y)
				end
			elseif key2 == 71 then
				point = 1
				lcon.gotoXY(x, y)
			elseif key2 == 79 then
				point = #res + 1
				lcon.gotoXY(x + point - 1, y)			
			elseif key2 == 83 then
				if res[point + 1] and res[point + 1]:byte() > 127 and res[point]:byte() > 127 then
					table.remove(res, point)
				end
				table.remove(res, point)
				lcon.gotoXY(x, y)
				if pw then
					io.write(("*"):rep(#res),"  ")
				else
					io.write(table.concat(res),"  ")
				end
				lcon.gotoXY(x + point - 1, y)
			elseif key2 == 72 or key2 == 80 or key2 == 82 or key2 == 81 or key2 == 73 then
			else
				if #res < Max then
					table.insert(res, point, string.char(key))
					point = point + 1
					table.insert(res, point, string.char(key2))
					point = point + 1
					lcon.gotoXY(x, y)
					if pw then
						io.write(("*"):rep(#res),"  ")
					else
						io.write(table.concat(res),"  ")
					end
					lcon.gotoXY(x + point - 1, y)
				end
			end
		else
			if #res < Max then
				table.insert(res, point, string.char(key))
				point = point + 1
				lcon.gotoXY(x, y)
				if pw then
					io.write(("*"):rep(#res),"  ")
				else
					io.write(table.concat(res),"  ")
				end
				lcon.gotoXY(x + point - 1, y)
			end
		end
	end
	return table.concat(res)
end

function main(login)
	if not login then
		cwrite(lcos.gray, "\t\t  ===  Quick Click with Blink  === \n\n")
		cwrite(lcos.bwhite, "\t Please enter your ID: ")
		local id = io.read(20, false, 5):gsub("%c","")
		local res = send({type = "assert", id = id}, true)
		if type(res) == "table" then
			if res.retcode == 1 then
				userid = id
			elseif res.retcode == 0 then
				cwrite(lcos.bwhite, "\t Please enter your nick: ")
				usernick = io.read(20, false, 3):gsub("%c","")
				userid = id
				local gres = send({type = "register", id = id, nick = usernick})
			end
		else
			cnet = false
		end
		cls()
	end
	cwrite(lcos.gray, "\t\t  ===  Quick Click with Blink === \n\n")
	cwrite(lcos.bwhite, "\t Are you ready? \n\n")
	cwrite(lcos.lsgreen, "\t\t\t   > Yes, I'm ready!")
	wait()
	cls()
	io.write("\t\t    Press ")
	cwrite(lcos.lsgreen, "[Enter]")
	io.write(" when you see ")
	cwrite(lcos.lred, "[red]")
	io.write(".\n\n\n")
	wtime(3)
	io.write("\n\t\t\t")
	math.randomseed((os.time() + os.clock() * 100) + math.random() * os.clock())
	local wait_time = math.random(4.01,10.01)
	local times = 0
	while wait_time > 0 do
		times = times+1
		local sleep_time = math.random(0.49,1.01)
		socket.sleep(sleep_time)
		wait_time = wait_time - sleep_time
		if clean_enter() and wait_time < 2 then
			wait_time = wait_time + math.random(1,2.5)
		end
	end
	cwrite(lcos.lred, "click now! ... ")
	blink.red(0)
	local point = 0
	local start_time = os.clock()
	while true do
		point = point+1
		if lcon.kbhit() == 1 and lcon.getch() == 13 then
			break
		else
			point = point+1
		end
	end
	cwrite(lcos.lsgreen, "... !")
	local qctime = os.clock() - start_time
	blink.rgb(qctime < 0.145 and (0.145 - qctime) * 1000 or 0, (4 - qctime) * 1000 , qctime > 0.4 and (qctime - 0.4) * 1000 or 0)
	cwrite(lcos.yellow, "\n\n\t\t\t    your point: ", point, "\n\t\t\t    your time : ", qctime, "\n")
	if cnet then
		local list = send({type = "pushpoint", time = qctime, id = userid}, true)
		if type(list) == "table" then
			cwrite(lcos.gray, "\n\t\t\t  ===  Point List  === \n\n")
			cwrite(lcos.lred, "\t\t\t  1st | ", list[1].time, " | ", list[1].nick,"\n")
			cwrite(lcos.yellow, "\t\t\t  2nd | ", list[2].time, " | ", list[2].nick,"\n")
			cwrite(lcos.lblue, "\t\t\t  3rd | ", list[3].time, " | ", list[3].nick,"\n")
			cwrite(lcos.white, "\t\t\t  4th | ", list[4].time, " | ", list[4].nick,"\n")
			cwrite(lcos.white, "\t\t\t  5th | ", list[5].time, " | ", list[5].nick,"\n\n")
			cwrite(lcos.bwhite, "\t\t\t  your best time: ", list[6], "\n")
		end
	end
	pause("\n\t\t\t\tplay again?", lcos.lgreen)
	cls()
	return main(true)
end

main()
