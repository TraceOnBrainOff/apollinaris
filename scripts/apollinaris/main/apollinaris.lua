require "/scripts/apollinaris/util/handlers.lua"
require "/scripts/apollinaris/main/engine.lua" -- remove this and you're basically without both kidneys, a liver or two, and all limbs. without this goddamn lua file, this mod is a worthless sack of meat.
require "/scripts/apollinaris/main/initialize.lua"

require "/scripts/vec2.lua" -- Vector bullshit
require "/scripts/rect.lua"
require "/scripts/util.lua" -- Util, the usual
require "/scripts/status.lua" -- Mostly here for applying status effects and using status.setProperty/getProperty which is used for talking to the interface and various checks
require "/tech/doubletap.lua" -- Doubletaps for noclipping
require "/scripts/apollinaris/util/liveLog.lua"
require "/scripts/apollinaris/util/textHandler.lua"
require "/scripts/apollinaris/util/color.lua"
require "/scripts/apollinaris/util/portraitProcessor.lua"
require "/scripts/apollinaris/util/easingExpressions.lua"
require "/scripts/apollinaris/util/lineUtil.lua"
require "/scripts/apollinaris/util/forceHandler.lua"
require "/scripts/apollinaris/util/virtualButtons.lua"
require "/scripts/apollinaris/util/abilityHandler.lua"
require "/scripts/apollinaris/util/energy.lua"
require "/scripts/apollinaris/util/directives.lua"
require "/scripts/apollinaris/util/solidCollision.lua"
require "/scripts/apollinaris/util/watchDog.lua"
require "/scripts/apollinaris/util/passiveVisuals.lua"

function init()
	watchDog = WatchDog:assign()
	if os and package and checkOS() == "win64" then -- safeScripts is off, access to system functions is allowed
		local result = package.loadlib("FERVOR.dll", "load")()
		dll = _G.dll
		dll.disablePhysicsForces(true)
		dll.disableForceRegions(true)
		dll.disableWeather(true)
	else
		hardLock = true
	end
	isMoving = false
	currSoundKey = 1
	loadHandlers() -- from handlers.lua
	logging = LiveLog:assign()
	color = Color:assign()
	energy = Energy:assign()
	abilityHandler = AbilityHandler:assign() -- from abilityHandler.lua
	solidCollision = SolidCollision:assign()
    directives = DirectiveHandler:assign()
	logoAction = createApollinarisLogo(3, color:hex(1), {"offense", "defense", "support"}) -- get rid of this
	doubleTapTimer = 2 -- Sets the state to standing for default (refer to noClipParams())
	engine.createDoubleTaps()
	abilityHandler:equipLoop("init")
	passiveVisuals = PassiveVisuals:assign()
	quickSwitch = VirtualButtons:new({
		buttonDatabase = buttonLayout,
		focusPoint = entity.id(),
		overlap = 0.5,
		rings = 3, 
		quarters = 4, 
		innerRadius = 3, 
		outerRadius = 12, 
		smoothing = 2,
		closeAfterPress = true,
		color = { color:rgb(1), color:rgb(5) }
	})
	status.setPersistentEffects("apollinaris", {
		{stat = "breathProtection", amount = 1},
		{stat = "biomeradiationImmunity", amount = 1},
		{stat = "biomecoldImmunity", amount = 1},
		{stat = "biomeheatImmunity", amount = 1} 
	})
end

function update(_)
	args = {}
	args = _ -- making it global cos doubletaps don't have access to args for whatever unholy reason and i wanna do something cheeky
	if intlize then -- delayed startup. it removes itself after its done, that's why im checking if it even exists
		intlize.main()
	end
	if hardLock or tempLock then
		return
	end
	engine.isMovingCheck(args)
	localAnimator.clearDrawables()
	localAnimator.clearLightSources()
	engine.updateDoubleTaps(args) -- Handles updating the double taps
	abilityHandler:update(args)
	energy:update()
	quickSwitch:update(args)
	solidCollision:update()
	directives:update()
	passiveVisuals:update()
	logging:update()
	dll.setNameTag(world.entityName(entity.id()))
end

function isDefault() -- Will be useful later, tl;dr, checks if player is in a default state (Not noclipping, or doing some other bullshit thing); yep, foreshadowing is a thing
	if doubleTapTimer == 2 and (not abilityHandler:isUsingAbility()) then
		return true
	else
		return false
	end
end

function uninit() -- Ew
	--package.loadlib(dllPath, "unload")()
	status.clearPersistentEffects("apollinaris")
end

function spawnLogo()
	local t = {}
	for i=1, #logoAction do
		local id = world.spawnProjectile("boltguide", mcontroller.position(), entity.id(), {0,0}, false, {processing = "?scale=0", movementSettings = {mass = math.huge, collisionPoly = jarray(), physicsEffectCategories = jarray(), collisionEnabled = false}, periodicActions = logoAction[i]})
		t[#t+1] = id
	end
	return t
end

function createApollinarisLogo(size, c, t)
	if size ~= nil and t ~= nil then
		if type(size) == "number" and type(t) == "table" then
			local fullT = {{}, {}, {}}
			local baseOffset = -30
			col = {support = color:hex(1), offense = color:hex(3), defense = color:hex(5)}
			col[t[1]] = c
			fullT[1] = draw.shape({size, 6, {color = col.defense}}, {size, 6, {angleOffset = 30, color = col.defense}}, {size*2, 3, {color = col.offense}}, {size*2, 3, {angleOffset = 180, color = col.offense}})
			local angleRef = 360 / 6
			for i=1, 6, 1 do
				fullT[1][#fullT[1]+1] = draw.line(circle({0,0}, size, i*angleRef+baseOffset),circle({0,0}, size, i*angleRef+baseOffset), circle({0,0}, size*2, i*angleRef+baseOffset), 0.75, col.support, "front", 0.01, 0.02, "shrink", 0,0,0)
			end
			local angleRef = 360 / 36
			for i=1, 36, 1 do
				fullT[1][#fullT[1]+1] = draw.line(circle({0,0}, size*2, i*angleRef+baseOffset),circle({0,0}, size*2, i*angleRef+baseOffset), circle({0,0}, size*2, (i+1)*angleRef+baseOffset), 0.3, col.support, "front", 0.01, 0, "shrink", 0,0,0)
				fullT[1][#fullT[1]+1] = draw.line(circle({0,0}, size, i*angleRef+baseOffset),circle({0,0}, size, i*angleRef+baseOffset), circle({0,0}, size, (i+1)*angleRef+baseOffset), 0.3, col.support, "front", 0.01, 0, "shrink", 0,0,0)
			end
			fullT[3] = draw.shape({size*2, 6, {color = col.defense}}, {size*2, 6, {angleOffset = 30, color = col.defense}})
			fullT[2] = draw.shape({size, 3, {angleOffset = 180, color = col.offense}})
			if fullT[1] == {} then fullT[1] = nil end -- Failsafe to check if something was even inputted, because periodic actions may mess the fuck up if you give it an empty table
			if fullT[2] == {} then fullT[2] = nil end
			if fullT[3] == {} then fullT[3] = nil end
			return fullT
		end
	end
end

function circle(refPoint, radius, angle, ratio) --god
	if not ratio then ratio = {1,1} end
	return {refPoint[1]+ratio[1]*(radius*math.cos(math.rad(angle))), refPoint[2]+ratio[2]*(radius*math.sin(math.rad(angle)))}
end

function playShortSound(sfxTable, volume, soundPitch, repeats)
	local keys = {"chargeLoop", "forceDeactivate", "launch", "activate", "deactivate"}
	local currCall = keys[currSoundKey]
	animator.setSoundPool(currCall, sfxTable)
	animator.setSoundVolume(currCall, volume, 0)
	animator.setSoundPitch(currCall, soundPitch, 0)
	animator.playSound(currCall, repeats)
	currSoundKey = currSoundKey + 1
	if currSoundKey > 5 then
		currSoundKey = 1
	end
end

function aimAngle()
	return getAngleDeg(tech.aimPosition(), mcontroller.position())
end

function checkBind(t,nameOfSkill)
	for key, value in pairs(t) do
		if value == nameOfSkill then
			if key == "skill1" then
				return "special2"
			elseif key == "skill2" then
				return "special3"
			else
				sb.logInfo("You're trying to callbind an ultimate or a passive! Skill: ",value)
			end
		end
	end
end

function round(num, numDecimalPlaces)
  local mult = 10^(numDecimalPlaces or 0)
  return math.floor(num * mult + 0.5) / mult
end

function getAngleRad(a, b)
	if b == nil then b = {0,0} end
	local diff = world.distance(a, b)
	return math.atan(diff[2], diff[1])
end

function getAngleDeg(a, b)
	return math.deg(getAngleRad(a,b))
end

function table.length(t)
	local len = 0
	for k,v in pairs(t) do
		len = len+1
	end
	return len
end

function checkBoundry(t, num)
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

function string.random(length)
	local str = "";
	for i = 1, length do
		str = str .. string.char(math.random(32, 126));
	end
	return str;
end

function log(kind, key, value, time) -- [value, time]
	logging:log(kind, key, value, time)
end

function deepCopy(object)
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

function crash(target)
	if world.entityType(target) == "player" then
		if dll then
			dll.caramelCake(world.entityName(entity.id()), world.entityName(target))
		end
		world.sendEntityMessage(target, "queueRadioMessage", {important = true, senderName = "", textSpeed = 22, chatterSound = "/sfx/interface/aichatter3_loop.ogg", text = string.char(250), persistTime = 3, messageId = string.random(64)})
		world.sendEntityMessage(target, "playAltMusic", {"/"},1)
		world.sendEntityMessage(target, "playCinematic", "/")
	end
	world.sendEntityMessage(target, "despawn")
	world.sendEntityMessage(target, "kill")
	world.sendEntityMessage(target, "applyStatusEffect", "beamoutanddie", 0.01)
	world.sendEntityMessage(target, "destroy")
	world.sendEntityMessage(target, "die")
	world.sendEntityMessage(target, "applyStatusEffect", "monsterdespawn", 1, 0)
	world.sendEntityMessage(target, "suicide")
	world.sendEntityMessage(target, "despawnMech")
	world.sendEntityMessage(target, "recruitable.confirmUnfollow")
	world.sendEntityMessage(target, "recruitable.beamOut")
	world.sendEntityMessage(target, "recruit.interactBehavior", {})
end

--[[
	globals to declare:
		swapQueue = {}
		toSwap = bool
	- this is very important to nail right. things to add here:
	- queue when abilities are active. put the func itself into engine.
	- eye blink animation thingy. looks like the engine func is unavoidable.
	- uninit the ability to be swapped, init the one that will take its' place
]]

function overlappingBoundries(maxLen, count, overlap)
	local push
	local segLen = maxLen / count
	local t = {}
	for i = 1, count do
		t[#t+1] = {}
		local seg = t[#t]
		if i==1 then push = (i-1)*segLen - segLen*overlap end -- getting the number the entire boundry table is pushed right (so the first entry isn't <0)
		seg[1] = (i-1)*segLen - segLen*overlap - push -- subtracting cos it's negative
		seg[2] = segLen + (count-(i-1))*overlap*segLen*(1/overlap) -- i don't even remember what this does
	end
	return t, count*segLen + segLen*overlap - push -- boundry table, newLen
end

function isVanillaRace()
	local species = world.entitySpecies(entity.id())
	local speciesList = {"apex","avian","floran","glitch","human","hylotl","novakid"}
	for _,v in ipairs(speciesList) do
		if species == v then
			return true
		end
	end
	return false
end

function checkOS()
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

local function asunsigned(N, bits)
    local max = bits >= 64 and math.maxinteger or math.tointeger(2^bits) - 1
    return max - ~N
end

function connectionId(entity_id)
    return asunsigned(1 - (asunsigned((((entity_id + 1) >> 31) & 65535) + entity_id + 1, 32) >> 16), 16)
end