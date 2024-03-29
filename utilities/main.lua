_math_round = function(number, precision)
	local _mul = 10^precision
	return math.floor(number*_mul) / _mul
end

_table_extract = function(t, e)
	for i, v in next, t do
		if v == e then
			return table.remove(t, i)
		end
	end
end

distance = function(ax, ay, bx, by)
	return math.sqrt((bx-ax)^2 + (by-ay)^2)
end

varify = function(args, pattern)
	local vars = {}
	args:gsub(" ", "")
	for arg in args:gmatch(pattern or "(%d+)?%p") do
		table.insert(vars, arg)
	end
	return table.unpack(vars)
end

toBase = function(n, b)
	n = math.floor(n)
	if not b or b==10 then return tostring(n) end
	local dg = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
	local t={}
	local sign = n < 0 and "-" or ""
	if sign == "-" then n = -n end
	
	repeat
		local d = (n%b)+1
		n = math.floor(n/b)
		table.insert(t, 1, dg:sub(d, d))
	until n == 0

	return sign .. table.concat(t, "")
end

linearInterpolation = function(r1, g1, b1, r2, g2, b2, sep, e)
	local ar = (r2-b1)/sep
	local ag = (g2-b1)/sep
	local ab = (b2-b1)/sep

	return (ar*e)+r1, (ag*e)+g1, (ab*e)+b1
end

cosineInterpolate = function(a, b, x)
	local f = (1-math.cos(x*math.pi))*0.5
	return (a*(1-f)) + (b*f)
end

generateNoiseMap = function(height, width, coberture, strenght, variety)
    local matrix = {}
    coberture = coberture or 0.5
	strenght = strenght or 0
	variety = variety or {0}
    local rand = math.random
    for y=1, height do
        matrix[y] = {}
	end
	
	local setStrenght = function(xs, ys, factor, inst)
		local array, cell
		for y=-1, 1 do
			array = matrix[y+ys]
			if array then
				for x=-1, 1 do
					cell = array[x+xs]
					if cell then
						cell = (rand() < factor and inst or false)
					end
				end
			end
		end
	end
	
	local dot
	
    for y=1, height do
        for x=1, width do
			dot = (rand() < coberture and variety[math.random(#variety)] or false)
			if dot then
				setStrenght(x, y, strenght, dot)
			end
            matrix[y][x] = dot
        end
    end
    
    return matrix
end

generatePerlinHeightMap = function(amplitude, waveLength, surfaceStart, width, heightMid)
	local _math_random = math.random
	local _math_floor = math.floor
	local _cosInt = cosineInterpolate
	
	local heightMap = {}
	local amp = amplitude or 30 -- 172
	local wl = waveLength or 24 -- 64
	local x, y = 0, surfaceStart or 128 -- 1, 128
	local hval = heightMid or 128
	local a, b = _math_random(), _math_random()
	
	while x < width do
		if x%wl == 0 then
			a = b
			b = _math_random()
			y = hval + (a*amp)
		else
			y = hval + (_cosInt(a, b, (x%wl)/wl) * amp)
		end
		
		heightMap[x+1] = _math_floor(y+0.5) or 1
		
		x = x + 1
	end

	return heightMap
end

dump = function(var, nest, except)
  local avoid = {}
  
  if except then
    for _, key in next, except do
      avoid[key] = true
    end
	
	avoid["__index"] = true
  end
  
	nest = nest or 1
	if type(var) == "table" then
		if nest > 8 then return "" end
		local str = (nest == 1 and tostring(var):gsub("table: ", "") .. " =" or "") .. " {\n"
		for k, v in pairs(var) do
      local retVal = (avoid[k] or k=="__index") and "exceptionValue" or dump(v, nest+1, except)
			local isNumber = type(k) == "number"
			k = "<CEP>" .. k .. "</CEP>"
			if isNumber then k = "["..k.."]" end
			str = str .. string.rep("\t", nest) .. k .. " = " .. retVal .. ",\n"--( and ",\n" or "\n")
		end
		
		return (str .. string.rep("\t", nest-1) .. '}'):gsub(",\n\t*}", "\n"..string.rep('\t', nest-1).."}")
	else
		local color = 'N'
		local st = var
		local type = type(var)
		if type == "string" then
			st = '"' .. var:gsub("<", "&lt;"):gsub(">", "&gt;") .. '"'
			color = 'T'
		elseif type == "number" then
			color = 'V'
		elseif type == "boolean" then
			color = var and 'CH' or 'CH2'
		elseif type == "function" then
			color = 'D'
		end
		
		return "<"..color..">".. tostring(st) .."</"..color..">"
	end
end

printt = function(var, except)
	local _, val = pcall(dump, var, 1, except)
	print("<N2>" .. val .. "</N2>")
end

local _math_floor = math.floor
getPosChunk = function(x, y, passObject)
	if x < 0 then x = 0
	elseif x > worldPixelWidth then x = worldPixelWidth end
	if y < 0 then y = 0
	elseif y > worldPixelHeight then y = worldPixelHeight end
	local _mf = _math_floor
	
	local yc = chunkRows * _mf((y/blockSize)/chunkHeight)
	local xc = _mf((x/blockSize)/chunkWidth)
	local eq = yc + xc + 1
	
	return passObject and map.chunk[eq] or eq
end

getPosBlock = function(x, y)
	if x < 0 then x = 0
	elseif x > worldPixelWidth then x = worldPixelWidth end
	if y < 0 then y = 0
	elseif y > worldPixelHeight then y = worldPixelHeight end

	local Chunk = getPosChunk(x, y, true)
	if Chunk then
		return Chunk.block[1+(_math_floor(y/blockSize)%chunkHeight)][1+(_math_floor(x/blockSize)%chunkWidth)]
	end
end

getTruePosMatrix = function(chunk, x, y)
	local ch = chunk-1
	return ((ch%chunkRows)*chunkWidth)+(x-1), (_math_floor(ch/chunkRows)*chunkHeight)+(y-1)
end

spreadParticles = function(particles, amount, kind, xor, yor)
	particles = (type(particles) == "number" and {particles} or (particles or 0))
	local ax, bx, ay, by
	if type(xor) == "table" then
		ax = xor[1]
		bx = xor[2]
	else
		ax = xor
		bx = xor
	end
	if type(yor) == "table" then
		ay = yor[1]
		by = yor[2]
	else
		ay = yor
		by = yor
	end
	
	local xs, ys, xa, ya
	local lpar = #particles
	
	local _rand = math.random
	local _displayParticle = tfm.exec.displayParticle
	for j=1, amount do
		if kind == "drop" then
			xs = _rand(-6, 6)/8
			xa = -xs/8
			ys = _rand(-9, -12)/8
			ya = -ys/7.5--13.33
		end
		_displayParticle(
			particles[_rand(#particles)],
			_rand(ax, bx), _rand(ay, by),
			xs, ys,
			xa, ya,
			nil
		)
	end
end

local _table_insert = table.insert

getBlocksAround = function(self, include, cross)
	local condition
	local blockList = {}
	
	local _getPosBlock = getPosBlock
	local xp, yp = self.dx + blockHalf, self.dy - (worldVerticalOffset - blockHalf)
	
	for y=-1, 1 do
		for x=-1, 1 do
			condition = (not cross and (true) or (x==0 or y==0))
			if ((not (y==0 and x==0)) or include) and condition then
				blockList[#blockList+1] = _getPosBlock(xp+(blockSize*x), yp+(blockSize*y))
			end
		end
	end
	
	return blockList
end

local _tfm_exec_addPhysicObject = tfm.exec.addPhysicObject
addPhysicObject = function(id, x, y, bodydef)
	_tfm_exec_addPhysicObject(id, x, y, bodydef)
	globalGrounds = globalGrounds + 1
end

local _tfm_exec_removePhysicObject = tfm.exec.removePhysicObject
removePhysicObject = function(id)
	_tfm_exec_removePhysicObject(id)
	globalGrounds = globalGrounds - 1
end

local _tfm_exec_movePlayer = tfm.exec.movePlayer
local _movePlayer = function(playerName, xPosition, yPosition, positionOffset, xSpeed, ySpeed, speedOffset)
	_tfm_exec_movePlayer(playerName, xPosition, yPosition, positionOffset, xSpeed, ySpeed, speedOffset)
	local Player = room.player[playerName]
	if Player then
		Player.x = (positionOffset and Player.x + xPosition or xPosition)
		Player.y = (positionOffset and Player.y + yPosition or yPosition)
		Player.vx = (speedOffset and Player.vx + xSpeed or xSpeed)
		Player.vy = (speedOffset and Player.vy + ySpeed or ySpeed)
	end
end

local setWorldGravity = function(windForce, gravityForce)
	tfm.exec.setWorldGravity(windForce, gravityForce)
	map.windForce = windForce or 0
	map.gravityForce = gravityForce or 0
end

unreference = function(val)
	local retvl

	if type(val) == "table" then
		retvl = {}
		for k, v in next, val do
			retvl[k] = unreference(v)
		end
	else
		retvl = val
	end
	
	return retvl
end

inherit = function(tbl, ex)
	local obj = unreference(tbl)
	
	local deep
	
	if type(obj) ~= "table" then
		obj = {}
	end
	
	for k, v in next, ex do
		if type(v) == "table" then
			obj[k] = inherit(obj[k], v)
		else
			obj[k] = unreference(v)
		end
	end
	
	return obj
end

appendEvent = function(executionTime, loop, callback, ...)
	local exec = os.time() + executionTime
	
	local args = {...}
	
	if loop then
		local recall = function(time, execute, ...)
			execute(...)
			appendEvent(time, true, execute, ...)
		end
		
		table.insert(args, 1, executionTime)
		table.insert(args, 2, callback)
		callback = recall
	end
	
	actionsCount = actionsCount + 1
	actionsHandle[#actionsHandle + 1] = {
		exec, callback, args, actionsCount
	}
	
	return actionsCount
end

removeEvent = function(id)
	local pos
	for i, obj in next, actionsHandle do
		if id == obj[4] then
			pos = i
			break
		end
	end
	
	if pos then
		return table.remove(actionsHandle, pos)
	end
end