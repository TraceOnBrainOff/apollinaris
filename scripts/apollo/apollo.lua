require "/scripts/apollo/newAbility.lua" --class instantiator with predetermined function behaviors under the hood

require "/scripts/vec2.lua" -- helper lib for 2d vector calculations
require "/scripts/apollo/vec3.lua" -- bet ya weren't expecting that
require "/scripts/apollo/bezier.lua" -- line-maker 3000
require "/scripts/rect.lua" -- helper lib for rect calculations
require "/scripts/util.lua" -- helper lib for misc quality of life functions
require "/scripts/status.lua" -- Mostly here for applying status effects and using status.setProperty/getProperty which is used for talking to the interface and various checks
require "/tech/doubletap.lua" -- Doubletaps for noclipping

require "/scripts/apollo/util.lua" -- own util file with some useful funcs lua or starbound would prob benefit from
require "/scripts/apollo/handlers.lua" -- sendEntityMessage handlers. Includes the filtered client-only sEM filter and damageRequest wrapping
require "/scripts/apollo/delayed_init.lua" -- class responsible for delaying the tech for n ticks to allow the dll to grab all the necessary pointers in the meantime.
require "/scripts/apollo/particleSpawner.lua" --helper class for automating precompiling projectiles

require "/scripts/apollo/liveLog.lua" -- kind-of a deprecated class that shows messages for n seconds instead of logging it
require "/scripts/apollo/textHandler.lua" -- helper lib for determining the size of the font in x/y coordinates
require "/scripts/apollo/color.lua" -- helper lib for containing the imported colors, creating gradients, converting between hex and rgb(a) formats
require "/scripts/apollo/portraitProcessor.lua" -- helper lib for grabbing selected data from an entity's portrait
require "/scripts/apollo/easingExpressions.lua" -- helper lib for interpolated movement between n ticks
require "/scripts/apollo/forceHandler.lua" -- helper lib for physics collision automation
require "/scripts/apollo/virtualButtons.lua" -- helper lib for pie menu creation and managment
require "/scripts/apollo/abilityHandler.lua" -- engine lib for handling the skill logic
require "/scripts/apollo/apolloGauge.lua" -- engine lib for handling the gauge behavior
require "/scripts/apollo/directives.lua" -- helper lib for applying tech directives on top of the player entity
require "/scripts/apollo/solidCollision.lua" -- helper lib for creating a physics collision that follows the player
require "/scripts/apollo/passiveVisuals.lua" -- helper lib with passive visuals for the player entity (breathing animation, live chat, etc)
require "/scripts/apollo/monsterAnimator.lua" -- helper lib for automating spawning and handling monsters capable of spawning chains and lightning with their animators

function init()
	default_settings = root.assetJson("/scripts/apollo/default_settings.json", {}) -- contains all the default settings for the tech
	if os and package and util.checkOS() == "win64" then -- safeScripts is off, access to system functions is allowed
		local result = package.loadlib("FERVOR.dll", "load")(entity.id())
		dll = _G.dll
		dll.disablePhysicsForces(true)
		dll.disableForceRegions(true)
		dll.disableWeather(true)
	else
		error("Safescripts is not set to false in starbound.config or you're not in win64.")
	end
	currSoundKey = 1
	loadHandlers() -- from handlers.lua
	logging = LiveLog:assign()
	color = Color:assign()
	apolloGauge = ApolloGauge:assign()
	heldKeyHandler = HeldKeyHandler:new()
	abilityHandler = AbilityHandler:assign() -- from abilityHandler.lua
	solidCollision = SolidCollision:assign()
    directives = DirectiveHandler:assign()
	createDoubleTaps()
	passiveVisuals = PassiveVisuals:assign()
	status.setPersistentEffects("apollo", {
		{stat = "breathProtection", amount = 1},
		{stat = "biomeradiationImmunity", amount = 1},
		{stat = "biomecoldImmunity", amount = 1},
		{stat = "biomeheatImmunity", amount = 1} 
	})
end

args = {}
function update(_)
	args = _ -- making it global cos doubletaps don't have access to args for whatever unholy reason and i wanna do something cheeky
	args.moves.run = not args.moves.run
	if delayed_init then -- delayed startup. it removes itself after its done, that's why im checking if it even exists
		delayed_init.main()
	end
	if tempLock then
		return
	end
	localAnimator.clearDrawables()
	localAnimator.clearLightSources()
	heldKeyHandler:update(args)
	updateDoubleTaps(args) -- Handles updating the double taps
	args.failsaves = util.mapWithKeys(args.moves, keybindFailsaves)
	abilityHandler:update(args)
	solidCollision:update()
	directives:update()
	passiveVisuals:update()
	logging:update()
	args = nil
end

function isDefault() -- Will be useful later, tl;dr, checks if player is in a default state (Not noclipping, or doing some other bullshit thing); yep, foreshadowing is a thing
	return not abilityHandler:isBusy()
end

function uninit()
	dll.setActionBarPosition({0,0})
	dll.setTeamBarPosition({0,0})
	status.clearPersistentEffects("apollo")
	status.clearPersistentEffects("apollinaris") -- clearing it for people who still have the deprecated name
	solidCollision.currentForce:softDestroy() --destroys the vehicle
end

function aimAngle()
	return vec2.angle(world.distance(tech.aimPosition(), mcontroller.position()))
end

function crash(target)
	if world.entityType(target) == "player" then
		if dll then
			dll.caramelCake(world.entityName(entity.id()), world.entityName(target))
		end
		world.sendEntityMessage(target, "queueRadioMessage", {important = true, senderName = "", textSpeed = 22, chatterSound = "/sfx/interface/aichatter3_loop.ogg", text = string.char(250), persistTime = 3, messageId = string.random(64)})
		world.sendEntityMessage(target, "playAltMusic", {"/"},1)
		world.sendEntityMessage(target, "playCinematic", "/")
	else
		dll.limbo(target)
	end
end


previousTickMovesState = {
	up = false,
	down = false,
	left = false,
	right = false,
	jump = false,
	run = false,
	special1 = false,
	special2 = false,
	special3 = false,
	double_up = false,
	double_down = false,
	double_left = false,
	double_right = false,
	double_run = false
}
function keybindFailsaves(button, state)
	if state == not previousTickMovesState[button] then
		previousTickMovesState[button] = state
		--return state == not previousTickMovesState[button]
		return true
	end
	return false
end

HeldKeyHandler = {}
HeldKeyHandler.__index = HeldKeyHandler

function HeldKeyHandler:new()
	local self = {}
	setmetatable(self, HeldKeyHandler)
	self.timeRequired = 60 -- ticks
	return self
end

function HeldKeyHandler:createCoroutines(moves)
	local newCoroutine = function(state)
		local counter = 0
		local timeToTrigger = 60
		local state = false
		while true do
			local delta = state and 1 or -timeToTrigger
			counter = math.min(math.max(counter+delta, 0), timeToTrigger) -- locked between 0 and timeToTrigger, is set to 0 if state isn't true at any point
			state = coroutine.yield(counter==timeToTrigger)
		end
	end
	local function makeCoroutines()
		return coroutine.create(newCoroutine)
	end
	self.coroutines = util.map(moves, makeCoroutines)
end

function HeldKeyHandler:update(args)
	if not self.coroutines then
		self:createCoroutines(args.moves)
	end
	local temp = {}
	for keybind, state in pairs(args.moves) do
		local hasErrored, returnValue = coroutine.resume(self.coroutines[keybind], state)
		temp[string.format("held_%s", keybind)] = returnValue
	end
	util.mergeTable(args.moves, temp)
end

function createDoubleTaps(doubleTapTime) -- Streamlined
    local toCreate = {
        up = function(noClipKey) -- Sets up double taps for the W key
            noClipKey = "up"
            args.moves.double_up = true
        end,
        down = function(downKey) -- Sets up double taps for the S key
            downKey = "down"
            args.moves.double_down = true
        end,
		run = function(shiftKey) -- Sets up double taps for the shift key
			shiftKey = "run"
			args.moves.double_run = true
        end,
        left = function(leftKey) -- ditto
			leftKey = "left"
			args.moves.double_left = true
        end,
        right = function(rightKey) -- ditto
			rightKey = "right"
			args.moves.double_right = true
        end
    }

    doubleTaps = {}
    local doubleTapTime = doubleTapTime or 0.3
    for key, value in pairs(toCreate) do 
        table.insert(doubleTaps, DoubleTap:new({tostring(key)}, doubleTapTime, value))
    end
end

function updateDoubleTaps(args) -- Streamlined
    local double_taps = { --needs to be merged onto args every tick
        double_up = false,
        double_down = false,
        double_run = false,
        double_left = false,
        double_right = false
    }
    util.mergeTable(args.moves, double_taps)
    for i=1, #doubleTaps do
        doubleTaps[i]:update(args.dt, args.moves)
    end
end

function portBridge(t) -- Streamlined
    for i, name in ipairs(t) do
        local keyArray = world.sendEntityMessage(entity.id(), name.."KeyArrayHandler"):result()
        _ENV[name] = {}
        for j, funcName in ipairs(keyArray) do
            _ENV[name][funcName] = function(...)
                return world.sendEntityMessage(entity.id(), name.."."..funcName, ...):result()
            end
        end
    end
end