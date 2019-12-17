require "/scripts/vec2.lua"

draw = {}

function draw.rawHexToDec(_hex)
	if type(_hex) == "string" then
		local h = _hex:lower()
		local charray = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f"}
		local total = 0
		for i = 1, h:len(), 1 do
			local c = h:sub(h:len() - i + 1, - 1 * i)
			for v, x in ipairs(charray) do
				if c == x then
					total = total + ((v - 1) * 16 ^ (i - 1))
				end
			end
		end
		return total
	else
		return 0
	end
end

function draw.rgbToHex(rgb)
	local stringo = ""
	local function hexConverter(input)
		local hexCharacters = '0123456789abcdef'
		local output = ''
		while input > 0 do
			local mod = math.fmod(input, 16)
			output = string.sub(hexCharacters, mod+1, mod+1) .. output
			input = math.floor(input / 16)
		end
		if output == '' then
			output = '0'
		end
		if string.len(output) == 1 then 
			output = "0"..output
		end
		return output
	end
	for i=1, #rgb, 1 do
		stringo = stringo..hexConverter(math.max(0,math.min(rgb[i],255)))
	end
	return stringo
end

function draw.hexToRGB(_hex)
	if type(_hex) == "string" then
		local h = _hex
		local r, g, b = 0, 0, 0
		if h:len() == 6 then
			local red = h:sub(1, 2)
			local green = h:sub(3, - 3)
			local blue = h:sub( - 2, - 1)
			r = draw.rawHexToDec(red)
			g = draw.rawHexToDec(green)
			b = draw.rawHexToDec(blue)
			return {r, g, b}
		elseif h:len() == 8 then
			return {0, 0, 0}
		end
	else
		return {0, 0, 0}
	end
end

function draw.line(_pos,_point1, _point2, _size, _color, _layer, _tTL, _descT, _descAct, _wiggle, _jitter, _sizeJitter)
	if type(_color) == "string" then 
		_color = draw.hexToRGB(_color)
	elseif type(_color) == "table" then 
		_color = _color
	end

	if _wiggle then
		if type(_wiggle) == "table" then
			if #_wiggle == 2 then
				sb.logError("{".. _wiggle[1]..", ".._wiggle[2].."}")
				vec2.add({0,0}, _wiggle)
			else
				sb.logError("draw.line: #_wiggle is not 2!")
				return
			end
		elseif type(_wiggle) == "number" then
			_wiggle = {_wiggle, _wiggle}
		else
			sb.logError("You put in some weird fucking type: ".. type(_wiggle))
			return
		end
	end
	varianceT = {position = _wiggle or {0,0}, length = _jitter or 0, size = _sizeJitter or 0}
	local thing = {
		action = "particle",
		time = 0.01,
		rotate = true,
		specification = {
			type = "streak",
			color = _color,
			light = _color,
			timeToLive = _tTL or 0,
			fullbright = true,
			rotate = true,
			position = _pos,
			destructionTime = _descT or 0,
			destructionAction = _descAct or "fade",
			velocity = vec2.mul(world.distance(_point1, _point2),0.001),
			size = _size,
			length = world.magnitude(_point1, _point2)*8,
			layer= _layer,
			variance = varianceT
		}
	}
	return thing
end

function draw.LSDaction(_pos,_point1, _point2, _size, _color, _layer, _tTL, _descT, _descAct, _wiggle)
	if _tTL == nil then _tTL = 2 end
	if _descT == nil then _descT = 2 end
	if _descAct == nil then _descAct = "shrink" end
	if _wiggle == nil then _wiggle = 0 end
	if type(_color) == "string" then _color = draw.hexToRGB(_color)
	elseif type(_color) == "table" then _color = _color
	end
	local thing = {
		action = "particle",
		time = 0.01,
		rotate = true,
		specification = {
			type = "streak",
			color = _color,
			rotate = true,
			light = _color,
			timeToLive = _tTL,
			fullbright = true,
			destructionTime = _descT,
			destructionAction = _descAct,
			position = _pos,
			velocity = world.distance(_point1, _point2),
			size = _size,
			length = world.magnitude(_point1, _point2)*0.6,
			layer= _layer,
			variance = {
				velocity = {_wiggle, _wiggle}
			}
		}
	}
	return thing
end

function draw.lightning(startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, layer)
	local function randomInRange(range)
		return - range + math.random() * 2 * range
	end

	local function randomOffset(range)
		return {randomInRange(range), randomInRange(range)}
	end
	local lightningTable = {}
	local refP = startLine
	local function drawLightningBase(refPoint,startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, layer)
		if displacement < minDisplacement then
			table.insert(lightningTable, draw.line(vec2.sub(startLine,refPoint),vec2.sub(startLine,refPoint), vec2.sub(endLine,refPoint), width, color, layer, 0.01, math.random(10,50)/100, "shrink", 0, 0, 1))
		else
			local mid = {(startLine[1] + endLine[1]) * 0.5 , (startLine[2] + endLine[2]) * 0.5 }
			mid = vec2.add(mid, randomOffset(displacement))
			drawLightningBase(refPoint,startLine, mid, displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, width, color, layer)
			drawLightningBase(refPoint,mid, endLine, displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, width, color, layer)

			if forks > 0 then
				local direction = vec2.sub(mid, startLine)
				local length = vec2.mag(direction) * 0.5
				local angle = math.atan(direction[2], direction[1]) + randomInRange(forkAngleRange)
				forkEnd = vec2.mul({math.cos(angle), math.sin(angle)}, length)
				drawLightningBase(refPoint, mid, vec2.add(mid, forkEnd), displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, math.max(width - 1, 1), color, layer)
			end
		end
	end
	drawLightningBase(refP,startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, layer)
	world.spawnProjectile("boltguide", refP, entity.id(), {0,0}, false, {periodicActions = lightningTable, persistentAudio = "/sfx/projectiles/guidedrocket_electric_loop.ogg", processing = "?multiply=FFFFFF00",timeToLive = 0.1, damageType = "NoDamage", movementSettings = {collisionPoly = jarray(), collisionEnabled = false}})
end

function draw.lightningAction(refP,startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, layer)
	local function randomInRange(range)
		return - range + math.random() * 2 * range
	end

	local function randomOffset(range)
		return {randomInRange(range), randomInRange(range)}
	end
	local lightningTable = {}
	local function drawLightningBase(refPoint,startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, layer)
		if displacement < minDisplacement then
			table.insert(lightningTable, draw.line(vec2.sub(startLine,refPoint),vec2.sub(startLine,refPoint), vec2.sub(endLine,refPoint), width, color, layer, 0.01, 0.05, "shrink", 0, 0))
		else
			local mid = {(startLine[1] + endLine[1]) * 0.5 , (startLine[2] + endLine[2]) * 0.5 }
			mid = vec2.add(mid, randomOffset(displacement))
			drawLightningBase(refPoint,startLine, mid, displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, width, color, layer)
			drawLightningBase(refPoint,mid, endLine, displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, width, color, layer)

			if forks > 0 then
				local direction = vec2.sub(mid, startLine)
				local length = vec2.mag(direction) * 0.5
				local angle = math.atan(direction[2], direction[1]) + randomInRange(forkAngleRange)
				forkEnd = vec2.mul({math.cos(angle), math.sin(angle)}, length)
				drawLightningBase(refPoint, mid, vec2.add(mid, forkEnd), displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, math.max(width - 1, 1), color, layer)
			end
		end
	end
	drawLightningBase(refP,startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, layer)
	return lightningTable
end

function draw.shape(...) --draw.shape({radius, color, amntOfSides, [lineConfig]}, ...)
	local t = {...}
	if type(t) == "table" then
		if #t > 0 then
			local a = {}
			for i=1, #t, 1 do
				local currShape = t[i]
				--_layer, _tTL, _descT, _descAct, _wiggle, _jitter, _sizeJitter, _size
				-- currShape = {radius, amntOfSides, [lineConfig]}
				local lineConfigDefault = {
					color = mainHex or "FFFFFF",
					layer = "front",
					timeToLive = 0.1,
					destructionTime = 0.15,
					destructionAction = "shrink",
					wiggle = 0,
					lengthJitter = 0,
					sizeJitter = 0,
					size = 1,
					angleOffset = 0
				}
				local lineConfig = currShape[3] or {}
				for key, value in pairs(lineConfigDefault) do
					if not lineConfig[key] then
						lineConfig[key] = value
					end
				end
				local offsetAngle = lineConfig.angleOffset
				local angleRef = 360 / currShape[2]
				local baseOffset = -30
				for i=1, currShape[2], 1 do
					a[#a+1] = draw.line(circle({0,0}, currShape[1],i*angleRef+baseOffset+offsetAngle),circle({0,0}, currShape[1],i*angleRef+baseOffset+offsetAngle), circle({0,0}, currShape[1], (i+1)*angleRef+baseOffset+offsetAngle), lineConfig.size, lineConfig.color, lineConfig.layer, lineConfig.timeToLive, lineConfig.destructionTime, lineConfig.destructionAction, lineConfig.wiggle, lineConfig.lengthJitter, lineConfig.sizeJitter)
				end
			end
			return a
		end
	end
end