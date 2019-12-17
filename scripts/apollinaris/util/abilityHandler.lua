AbilityHandler = {}
AbilityHandler.__index = AbilityHandler
require("/scripts/apollinaris/util/positioningGrid.lua")

--[[
	ultimate indicator:
	several things to note here while making this:
	this has to be offset by a multiplier (just like the passive indicator) since i don't want this thing to appear during short taps for blinking, so 0.2 should be a good number
	charge timer has to be increased for the animation to play out slower, plus it will look cooler

	to the meat of the shit
	making a topographic-esque effect with three waves  with decreasing sharpness and alpha as it gets further away (do it via panty dropping recursion buddy)

	[optional but might copy the shockwave framework from that one animtion thing i made in the past (the loading incidator's shockwave for the interface) to signal that it's ready, just one shockwave on a failsafe when timer reaches full]
	^ bonus weeaboo points

	add sound effects to this, but it will require MATHS (and probably failsaves)

	add local animator particle effects maybe?

	also make ubw an ultimate and racechanging an ability

	parameter for edge count should also be a thing

	a variable for cycle multiplier and offset for the wave effect


]]

function AbilityHandler:assign()
    local self = {}
    setmetatable(self, AbilityHandler)
    self.activeAbility = {}
    self.swapQueue = {}
	self.blinkChargeup = {0, 60}
	self.defaultSettings = root.assetJson("/skills/defaultSettings.json", {})
	self:loadAbilities()
	self.positioningGrid = PositioningGrid:assign()
	self.positioningGrid:open()
    return self
end

function AbilityHandler:update(args)
	self:liveSwap()
	--self.positioningGrid:update()
    self:handleInputs(args)
    self:equipLoop("update", args)
end

function AbilityHandler:uninit()
    self:equipLoop("uninit")
end

function AbilityHandler:equipLoop(mode, args)
    for sequence, skill in pairs(self.equippedAbilities) do
		local working, returnValue = pcall(skill[mode], skill, args)
		if working then
			self.activeAbility[sequence] = returnValue and true or false
		else
			log("error", string.format("%s has errored on %s with %s", skill.metadata.name, mode, returnValue))
		end
    end
end

function AbilityHandler:loadAbilities()
    status.setStatusProperty("abilityClasses", { -- debug, no interface yet
		auxiliary = {"tRO"},
		ultimate = {"uTW", "iNF", "cMR"},
		skill1 = {"rCS"},
		skill2 = {"sGS", "tPB"},
		blink = {"Rol"} -- size MUST be 1 on this one and all movement/aux abilities
	})
	status.setStatusProperty("equipmentLoadout", { -- debug, no interface yet
		auxiliary = "tRO", 
		ultimate = "iNF", 
		skill1 = "rCS",
		skill2 = "sGS",
		blink = "Rol"
	})
	
	local equipmentLoadout = status.statusProperty("equipmentLoadout", {})
	local toUnload = {}
	local toLoad = {}

	for slotName, array in pairs((self.loadedClasses or {})) do
		for i, abilityTag in ipairs(array) do
			toUnload[#toUnload+1] = abilityTag
		end
	end
	
	self.loadedClasses = status.statusProperty("abilityClasses", {}) -- all of the loaded classes
	for slotName, array in pairs(self.loadedClasses) do
		for i, abilityTag in ipairs(array) do
			toLoad[#toLoad+1] = abilityTag
		end
	end

	for i=#toUnload, 1, -1 do -- unload contains all previously loaded classes
		for j=#toLoad, 1, -1 do -- load contains all newly loaded classes (well to be loaded)
			if toUnload[i] == toLoad[j] then -- when a class is in both in the previous loadout and new loadout, leave it there
				table.remove(toUnload, i)
				table.remove(toLoad, j)
			end
		end
	end

	self.equippedAbilities = self.equippedAbilities or {}
	for i, tag in ipairs(toUnload) do -- doing stuff for all the classes to be removed
		for slotName, ability in pairs(self.equippedAbilities) do -- for all currently equipped abilities (is nil during true init)
			if tag == ability.metadata.tag then -- if the ability tag matches the tag of an ability to be removed, do
				self.equippedAbilities[slotName] = nil -- removing the ability from equipped tags
				equipmentLoadout[slotName] = nil -- removing them from the saved equipped slots
			end
		end
		_ENV[tag] = nil -- getting rid of the entire class
		for key, value in pairs(_SBLOADED) do -- run through the entire SBLOADED and remove the entry with the path of the ability to allow for future re-requiring. SB shitty require again
			if key:find(tag) ~= nil then -- if the path of a tag contains the name of the tag do
				_SBLOADED[key] = nil -- remove the path of the ability from SBLOADED
			end
		end
	end
	status.setStatusProperty("equipmentLoadout", equipmentSetup) -- save the equips after this

	for i, tag in ipairs(toLoad) do
		local folder = self:tagToPath(tag)
		local path = string.format("/skills/%s%s/%s.lua", folder, tag, tag)
		require(path)
		sb.logInfo(string.format("Loaded %s from path %s", tag, path))
	end
	
	for slotName, abilityTag in pairs(equipmentLoadout) do
		if _ENV[abilityTag] then
			self.equippedAbilities[slotName] = _ENV[abilityTag]:assign()
			self:applyDefaultSettings(self.equippedAbilities[slotName]) -- Check for lack of default settings and add them if necessary!
            self.activeAbility[slotName] = false -- making activeAbility actually have something
		else
			self.equippedAbilities = {} -- failsaving against force swapping the equipped tags so it doesn't try to assign a class that isn't loaded
			sb.logError(string.format("Attempting to assign an ability that doesn't exist. Tag: %s", abilityTag))
			break
		end
	end
	self:createQuickswapButtons()
end

function AbilityHandler:applyDefaultSettings(slot)
	if not slot.metadata.settings then -- failsaving against outdated abilities not having the settings table in their metadata
		slot.metadata.settings = {}
		log("warn", string.format("%s lacks settings in metadata!", slot.metadata.tag)) -- for ease of knowing what's up
	end
	local abilitySettings = slot.metadata.settings
	for setting, defaultValue in pairs(self.defaultSettings) do -- take defaultSettings as a base, so it's vital to update it whenever additions to the engine occur!
		if abilitySettings[setting] == nil then -- If the setting declared in defaultSettings doesn't exist do
			abilitySettings[setting] = defaultValue -- apply the default value to the specified setting
		end
	end
end

function AbilityHandler:tagToPath(tag)
	-- assume tag is 3 chars long
	--[[
		Naming schematics depending on type:
		Skills (Hold F,G,H,Shift) - aAA
		Blink (F) - Aaa
		Fly (Double Up) - aaA
		Jump (Double Jump) - aAa
		Dash (Double Left/Right) - aaA
	]]
	local namingSchematic = {
		aAA = "standard/",
		Aaa = "movement/blink/",
		aaA = "movement/fly/",
		aAa = "movement/jump/",
		aaA = "movement/dash/"
	}
	local split = {tag:match('(%a)(%a)(%a)')} -- splits aAA into {"a", "A", "A"} for example
	local finalSTR = ""
	for i, character in ipairs(split) do
		if character == string.lower(character) then -- if the character is the same as the lowercase version of itself, do
			finalSTR = finalSTR.."a"
		else
			finalSTR = finalSTR.."A"
		end
	end
	return namingSchematic[finalSTR]
end

function AbilityHandler:isUsingAbility()
    for slotName, bool in pairs(self.activeAbility) do
		if bool then
			energy:showRegenBar() -- isUsingAbility is called every tick so im just using it for that
			return true, slotName, self.equippedAbilities[slotName].metadata.tag
		end
	end
end

function AbilityHandler:createQuickswapButtons()
	local functionT = {}
	local slotCount = status.statusProperty("skillSlotCount") or 3
	local quarterToSlot = {"ultimate", "skill1", "auxiliary", "skill2"}
	for quarter = 1, 4 do -- quarters, this is a constant
		functionT[#functionT+1] = {}
		local currentQuarter = functionT[#functionT]
		for ring = 1, slotCount do -- leaving room for expanding this shit << good call
			local currentTag = self.loadedClasses[quarterToSlot[quarter]][ring]
			currentQuarter[#currentQuarter+1] = {}
			local currentButton = currentQuarter[#currentQuarter]
			if currentTag then
				local tempSkill = _ENV[currentTag]:assign()
				currentButton.name = tempSkill.metadata.name
				currentButton.abilityTag = currentTag
				currentButton.image = tempSkill.metadata.image
				currentButton.func = swapAbility
			else
				currentButton.name = "Empty Slot"
				currentButton.func = function() log("info", "No Skill assigned.") end
			end
		end
	end
	if quickSwitch then
		quickSwitch:setButtons(functionT)
	end
	buttonLayout = functionT
end

function AbilityHandler:handleInputs(args)
	if quickSwitch then
		if not args.moves.run and args.moves.up then
			quickSwitch:open()
			return
		end
	end
	if isDefault() and quickSwitch:isClosed() then
		if self.equippedAbilities.blink then -- special case, so it's handled differently than the rest
			if args.moves.special1 then
				self.blinkChargeup[1] = math.min(self.blinkChargeup[1]+1, self.blinkChargeup[2])
				return
			else -- tldr below, if fully charged, execute ultimate, if under a quarter of the full charge, do a blink
				if self.blinkChargeup[1] == self.blinkChargeup[2] then
					self:startAbility("ultimate")
				elseif self.blinkChargeup[1] < self.blinkChargeup[2]/4 and self.blinkChargeup[1] > 0 then 
					self:startAbility("blink")
				end
				self.blinkChargeup[1] = 0 --debug
			end
		end

		local sp = {
			doubleShift = "auxiliary",
			special2 = "skill1",
			special3 = "skill2"
		}
		for keyBind, slotName in pairs(sp) do
			if args.moves[keyBind] and self.equippedAbilities[slotName] then
				self:startAbility(slotName)
				self.blinkChargeup[1] = 0 -- resetting the animation to nothing to not interfere with anything visually
				break
			end
		end
	end
end

function AbilityHandler:startAbility(slot)
	local currentAbility = self.equippedAbilities[slot]
	if energy:isLocked() then
		return
	end
	if not currentAbility.metadata.settings.allowCustomClothing then
		if not watchDog:checkCustomClothing() then -- making it like this won't make checkCustomClothing() get called every startAbility() call, only when it's necessary
			log("warn", string.format("%s does not allow for equipped custom clothing!", currentAbility.metadata.name))
			return
		end
	end
	local working, returnValue = pcall(currentAbility.start, currentAbility)
	energy:changeEnergy(-currentAbility.metadata.settings.energyConsumption.amount) -- jesus fuck
	if not working then
		log("error", string.format("%s error @ start: %s", slot, returnValue))
		local workingStop, returnValueStop = pcall(currentAbility.stop, currentAbility)
		if not workingStop then
			log("error", string.format("%s error @ stop: %s", slot, returnValueStop))
		end
	end
end

function AbilityHandler:liveSwap() -- Review
	local usingAbility, usingSlot, abilityInUse = self:isUsingAbility() -- usingAbility: nil/true, slotInUse: nil/slotName
	for slotName, tag in pairs(self.swapQueue) do
		if (slotName ~= usingSlot) or (not usingAbility) then
			local oldAbilityTag = self.equippedAbilities[slotName].metadata.name
			self.equippedAbilities[slotName] = nil -- making sure it's safe to assign a new one
			self.equippedAbilities[slotName] = _ENV[tag]:assign()
			self:applyDefaultSettings(self.equippedAbilities[slotName]) -- Apply default settings if the ability lacks them
			self.equippedAbilities[slotName]:init()
			local newAbilityTag = self.equippedAbilities[slotName].metadata.name
			local savedEquips = status.statusProperty("equipmentLoadout") or {}
			savedEquips[slotName] = tag
			status.setStatusProperty("equipmentLoadout", savedEquips)
			self.swapQueue[slotName] = nil
			log("info", string.format("%s has been swapped to %s", oldAbilityTag, newAbilityTag))
		end
	end
end

function swapAbility(button, boundries)
	local abilityTag = button.abilityTag
	local boundryToSlot = {"ultimate", "skill1", "auxiliary", "skill2"} -- passing slot names into an array to then know which slot to assign the func based on the boundries
	boundryToSlot = boundryToSlot[boundries.angleBoundry]
	if _ENV[abilityTag] ~= nil and abilityTag ~= abilityHandler.equippedAbilities[boundryToSlot].metadata.tag then
		abilityHandler.swapQueue[boundryToSlot] = button.abilityTag
	end
end