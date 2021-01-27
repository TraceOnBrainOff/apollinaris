require("/scripts/util.lua")

function table.copy(object)
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end

function string.random(length)
	local str = "";
	for i = 1, length do
		str = str .. string.char(math.random(32, 126));
	end
	return str;
end

function table.length(t)
	local len = 0
	for k,v in pairs(t) do
		len = len+1
	end
	return len
end

function util.trig(origin, radius, angle, ratio) --god
	if not ratio then ratio = {1,1} end
	return {origin[1]+ratio[1]*(radius*math.cos(angle)), origin[2]+ratio[2]*(radius*math.sin(angle))}
end

function util.checkBoundry(t, num)
	if type(t) == "table" and type(num) == "number" then
		if #t > 0 then
			local r = 0
			for i=1, #t, 1 do
				if num >= t[i] then
					r = r+1
				else
					return r
				end
			end
			return r
		else
			return 0
		end
	else
		sb.logError("boundry check failed")
		return
	end
end

function log(kind, key, value, time) -- [value, time]
	logging:log(kind, key, value, time)
end

local function asunsigned(N, bits)
    local max = bits >= 64 and math.maxinteger or math.tointeger(2^bits) - 1
    return max - ~N
end

function util.connectionId(entity_id)
    return asunsigned(1 - (asunsigned((((entity_id + 1) >> 31) & 65535) + entity_id + 1, 32) >> 16), 16)
end

function util.checkOS()
    if not io then return "unknown" end --if safescript is on it will return a safe value
    if os.getenv("APPDATA") then --we are running windows
        local architectures = {
            amd64 = "win64",
            x86_64 = "win64",
            x86 = "win32",
            i386 = "win32"
        }
        local architecture = os.getenv("PROCESSOR_ARCHITECTURE")
        if not architecture or not architectures[architecture:lower()] then return "win32" end
        return architectures[architecture:lower()]
    elseif os.getenv("DISPLAY") then --linux
        return "linux"
    else--if  os.getenv("VISUAL") then --macosX not tested
        return "osx"
    end
    return "unknown"
end

function util.isVanillaRace()
	local species = world.entitySpecies(entity.id())
	local speciesList = {"apex","avian","floran","glitch","human","hylotl","novakid"}
	for _,v in ipairs(speciesList) do
		if species == v then
			return true
		end
	end
	return false
end

function util.playShortSound(sfxTable, volume, soundPitch, repeats)
	local keys = {"chargeLoop", "forceDeactivate", "launch", "activate", "deactivate"}
	local currCall = keys[currSoundKey]
	animator.setSoundPool(currCall, sfxTable)
	animator.setSoundVolume(currCall, volume, 0)
	animator.setSoundPitch(currCall, soundPitch, 0)
	animator.playSound(currCall, repeats)
	currSoundKey = currSoundKey + 1
	if currSoundKey > #keys then
		currSoundKey = 1
	end
end

function util.tagToPath(tag)
	-- assume tag is 3 chars long
	--[[
		Naming schematics depending on type:
		Skills (Hold F,G,H,Shift) - aAA
		Blink (F) - Aaa
		Fly (Double Up) - aaA
		Jump (Double Jump) - aAa
		Dash (Double Left/Right) - AAa
	]]
	local namingSchematic = {
		aAA = "standard/",
		Aaa = "movement/blink/",
		aaA = "movement/fly/",
		aAa = "movement/jump/",
		AAa = "movement/dash/"
	}
	local split = {tag:match('(%a)(%a)(%a)')} -- splits aAA into {"a", "A", "A"} for example
	local finalSTR = ""
	for i, character in ipairs(split) do
		finalSTR = finalSTR..(character == string.lower(character) and "a" or "A")
	end
	return namingSchematic[finalSTR]
end

function string.startsWith(s, word) 
	return s:sub(1, #word) == word
end

function coroutine.update(co, ...)
	local a = {coroutine.resume(co, ...)}
	if not a[1] then
		error(a[2])
	end
	table.remove(a,1)
	return table.unpack(a)
end

--------------------------------------------
--##########################################
--------------------------------------------

RGBPair = {
	__add = function (lhs, rhs) -- adding an RGB value to the RGBPair value
		if #lhs.value ~= #rhs then
			error(string.format("__add: Left hand side and right hand side RGBPair parameters aren't the same length: %s =/= %s", #lhs.value, #rhs.value))
		end
		local newValue = {}
		for i, clr in ipairs(lhs.value) do
			table.insert(newValue, clr+rhs[i])
		end
		return RGBPair:new(lhs.key, newValue)
	end,
	__sub = function (lhs, rhs) -- subtracting an RGB value from the RGBPair value
		if #lhs.value ~= #rhs then
			error(string.format("__sub: Left hand side and right hand side RGBPair parameters aren't the same length: %s =/= %s", #lhs.value, #rhs.value))
		end
		local newValue = {}
		for i, clr in ipairs(lhs.value) do
			table.insert(newValue, clr-rhs[i])
		end
		return RGBPair:new(lhs.key, newValue)
	end,
	__mul = function (lhs, rhs) -- multiplying the RGBPair value by the right hand side
		local newValue = {}
		for i, clr in ipairs(lhs.value) do
			table.insert(newValue, math.floor(clr*rhs))
		end
		return RGBPair:new(lhs.key, newValue)
	end
}
RGBPair.__index = RGBPair

function RGBPair:new(key, value)
	local self = {}
	setmetatable(self, RGBPair)
	self.key = key
	self.value = value
	return self
end

function RGBPair:toHex()
	return string.format("%s=%s", Color.rgb2hex(self.key), Color.rgb2hex(self.value))
end

