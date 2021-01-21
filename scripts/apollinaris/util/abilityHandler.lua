--require("/scripts/util.lua")

AbilityHandler = {}
AbilityHandler.__index = AbilityHandler

AbilitySlot = {}
AbilitySlot.__index = AbilitySlot

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

function AbilitySlot:new(ability, keybind, tag)
    local self = {}
    setmetatable(self, AbilitySlot)
	self.keybind = keybind
	self.tag = tag
	self.updateCoroutine = nil
	self.ability = ability:assign()
	self:applyMetadataOverrides(tag)
    return self
end

function AbilitySlot:applyMetadataOverrides(tag)
	local defaultMetadata = root.assetJson("/skills/defaultMetadata.json", {})
    local defaultSettings = root.assetJson("/skills/defaultSettings.json", {})
    self.ability.metadata = defaultMetadata
    self.ability.metadata.settings = defaultSettings
	local folder = util.tagToPath(tag)
	local path = string.format("/skills/%s%s/%s.config", folder, tag, tag)
	local abilityConfig = root.assetJson(path)
	self.ability.metadata = util.mergeTable(self.ability.metadata, abilityConfig) -- takes the default settings and overrides every key that's specified in the ability
end

function AbilitySlot:startUpdateCoroutine()
	if not self.ability then
		error(string.format("%s %s has no ability!", self.slot, self.tag))
	end
	self.updateCoroutine = coroutine.create(function(self, args)
		self.ability:init()
		while true do
			local self, args = coroutine.yield()
			self.ability:update(args)
			if self.ability.finished == true then
				break
			end
		end
		self.ability.finished = nil
		self.ability:uninit()
		return
	end)
	self:coroutineUpdate() -- performing init immediately after starting the ability
end

function AbilitySlot:forceStop()
	self.updateCoroutine = nil
end

function AbilitySlot:coroutineUpdate(args)
	if self.updateCoroutine then
		local noErrors, returnValue = coroutine.resume(self.updateCoroutine, self, args)
		if noErrors == false then
			error(returnValue)
		end
		if coroutine.status(self.updateCoroutine) == "dead" then
			self.updateCoroutine = nil
		end
	end
end

function AbilitySlot:isBusy()
	return self.updateCoroutine ~= nil
end

-------------------------------------------------------------------------------------------------------

function AbilityHandler:assign()
    local self = {}
    setmetatable(self, AbilityHandler)
	self.slotKeybinds = root.assetJson("/skills/defaultKeybinds.json", {}) -- key: slot, value: array of [args.moves key]
	self:loadAbilities()
	self:equipAbilities()
	self.swapQueue = {}
    return self
end

function AbilityHandler:update(args)
    self:handleInputs(args)
	self:abilityUpdates(args)
	self.pieMenu:setPosition(mcontroller.position())
	self.pieMenu:update(args)
end

function AbilityHandler:uninit()
end

function AbilityHandler:startAbility(keybind)
	local slot = self.slots[keybind] -- This is nil somehow
	if energy:isLocked() then
		return
	end
	energy:changeEnergy(-slot.ability.metadata.settings.energyConsumption.amount) -- jesus fuck
	slot:startUpdateCoroutine()
end

function AbilityHandler:handleInputsForKeybinds(keybinds)
	local index = 0
	for i, keybind in pairs(keybinds) do
		local state, busy_slot = self:isBusy()
		world.debugText(string.format("%s : %s", keybind, tostring(args.moves[keybind])), vec2.add(mcontroller.position(),index), {255,255, 255})
		world.debugText(string.format("%s : %s", keybind, tostring(args.failsaves[keybind])), vec2.add(mcontroller.position(),-index), {255,0, 0})
		if args.failsaves[keybind] and not args.moves[keybind] then --state and not args.failsaves[keybind]
			if not state then
				self:startAbility(keybind)
				args.failsaves[keybind] = not args.failsaves[keybind]
				return true
			else
				if busy_slot.ability.metadata.settings.persistent then
					busy_slot:forceStop()
				end
			end
		end
		index = index + 1
	end
end

function AbilityHandler:handleInputs(args)
	if args.moves.run and args.moves.up and not self:isBusy() then
		self.pieMenu:open()
		return
	end
	for i, keybind_table in ipairs(self.keybinds) do
		for j, keybind in pairs(keybind_table) do
			local state, busy_slot = self:isBusy()
			--world.debugText(string.format("%s : %s", keybind, tostring(args.moves[keybind])), vec2.add(mcontroller.position(),index), {255,255, 255})
			--world.debugText(string.format("%s : %s", keybind, tostring(args.failsaves[keybind])), vec2.add(mcontroller.position(),-index), {255,0, 0})
			if args.failsaves[keybind] and not args.moves[keybind] then --state and not args.failsaves[keybind]
				if not state then
					self:startAbility(keybind)
					args.failsaves[keybind] = not args.failsaves[keybind]
					return
				else
					if busy_slot.ability.metadata.settings.persistent then
						busy_slot.ability:stop()
						return
					end
				end
			end
		end
	end
end

function AbilityHandler:abilityUpdates(args) --
	local busyState, abilitySlot = self:isBusy()
	if busyState then
		abilitySlot:coroutineUpdate(args)
	end
end

function AbilityHandler:isBusy()
	for keybind, abilitySlot in pairs(self.slots) do
		if abilitySlot:isBusy() then
			return true, abilitySlot
		end
	end
	return false
end


function AbilityHandler:loadAbilities()
    status.setStatusProperty("loadedSkills", { -- debug, no interface yet
		double_run = {"tRO"},
		held_special1 = {"uTW", "iNF", "cMR"},
		special2 = {"rCS"},
		special3 = {"sGS", "tPB"},
		special1 = {"Rol"}, -- size MUST be 1 on this one and all movement/aux abilities
		double_up = {"glD"}
	})
	status.setStatusProperty("equippedSkills", { -- debug, no interface yet
		double_run = 1, --INDEXES IN THE THING ABOVE
		held_special1 = 2, 
		special2 = 1,
		special3 = 1,
		special1 = 1, -- Grabs the tag of the first index from the other table
		double_up = 1
	})

	self.loadedSkills = {}
	local maxSize = 0
	for keybind, tag_array in pairs(status.statusProperty("loadedSkills", {})) do
		self.loadedSkills[keybind] = {}
		maxSize = #tag_array>maxSize and #tag_array or maxSize -- gets the max size of any array
		for i, tag in ipairs(tag_array) do
			local folder = util.tagToPath(tag)
			local path = string.format("/skills/%s%s/%s.lua", folder, tag, tag)
			require(path)
			table.insert(self.loadedSkills[keybind], AbilitySlot:new(_ENV.TEMP_HOLDER, keybind, tag))
			TEMP_HOLDER = nil
		end
	end
	self.maxSlots = maxSize
	local keybinds = util.keys(self.loadedSkills)
	local held_keybinds = {}
	local double_keybinds = {}
	local normal_keybinds = {}
	for i, keybind in ipairs(keybinds) do
		if string.startsWith(keybind, "held_") then
			table.insert(held_keybinds, keybind)
		elseif string.startsWith(keybind, "double_") then
			table.insert(double_keybinds, keybind)
		else
			table.insert(normal_keybinds, keybind)
		end
	end
	self.keybinds = {held_keybinds, double_keybinds, normal_keybinds}
	self:createPieMenu()
end

function AbilityHandler:equipAbilities()
	local equippedSkills = status.statusProperty("equippedSkills", {}) --INDEXES IN loadedAbilities
	self.slots = {}
	for keybind, skill_index in pairs(equippedSkills) do
		self.slots[keybind] = self.loadedSkills[keybind][skill_index]
	end
end

function AbilityHandler:swapToSkill(keybind, index)
	self.slots[keybind]:forceStop()
	self.slots[keybind] = self.loadedSkills[keybind][index]
end

function AbilityHandler:createPieMenu() --needs sorting as loadedSkills is parsed using pairs() which randomizes the placment
	local functionT = {}
	local ring_count = self.maxSlots
	local skill_keybinds = util.keys(self.loadedSkills)
	local slice_count = #skill_keybinds
	local rings = {}
	for i=1, ring_count do
		local newRing = VirtualPie_Ring:new()
		for j, skill_keybind in ipairs(skill_keybinds) do
			local skillSlot = self.loadedSkills[skill_keybind][i]
			local newButton = VirtualButton:new()
			if skillSlot then
				newButton.name = skillSlot.ability.metadata.name
				local function swapToThisSkill()
					self:swapToSkill(skill_keybind, i)
				end
				newButton.func = swapToThisSkill
			end
			newRing:addButton(newButton)
		end
		table.insert(rings, newRing)
	end
	self.pieMenu = VirtualPie:new(root.assetJson("/skills/pie_menu.config"), rings)
end