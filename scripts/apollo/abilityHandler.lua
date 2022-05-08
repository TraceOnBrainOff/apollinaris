AbilityHandler = {}
AbilityHandler.__index = AbilityHandler

AbilitySlot = {}
AbilitySlot.__index = AbilitySlot

function AbilitySlot:new(abilityHandler, ability, keybind, tag)
    local self = {}
    setmetatable(self, AbilitySlot)
	self.abilityHandler = abilityHandler
	self.keybind = keybind
	self.tag = tag
	self.updateCoroutine = nil
	self.ability = ability
	self:applyMetadataOverrides(tag)
    return self
end

function AbilitySlot:applyMetadataOverrides(tag)
    self.ability.metadata = {
		name = "Default",
		tag = "tMP",
		series = "default"
	}
    self.ability.metadata.settings = table.copy(default_settings.default_skill_settings)
	local path = string.format("/apollo_skills/%s/%s.config", tag, tag)
	local abilityConfig = root.assetJson(path)
	self.ability.metadata = util.mergeTable(self.ability.metadata, abilityConfig) -- takes the default settings and overrides every key that's specified in the ability
	self.ability = self.ability:assign()
end

function AbilitySlot:startUpdateCoroutine()
	if not self.ability then
		error(string.format("%s %s has no ability!", self.slot, self.tag))
	end
	self.updateCoroutine = coroutine.create(function(self, args)
		tech.setToolUsageSuppressed(true)
		status.setPersistentEffects("apolloActive", {{stat = "activeMovementAbilities", amount = 1}})
		self.ability:init(self.keybind)
		while true do
			local self, args = coroutine.yield()
			self.ability:update(args)
			if self.ability.finished == true then
				break
			end
		end
		self.ability.finished = nil
		self.ability:uninit()
		tech.setToolUsageSuppressed(false)
		self.abilityHandler:endAbilityCallback()
		status.clearPersistentEffects("apolloActive")
		return
	end)
	self:coroutineUpdate() -- performing init immediately after starting the ability
end

function AbilitySlot:forceStop()
	self.updateCoroutine = nil
end

function AbilitySlot:coroutineUpdate(args)
	if self.updateCoroutine then
		coroutine.update(self.updateCoroutine, self, args)
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
	self:createActivateProjectile()
	self.slotKeybinds = table.copy(default_settings.key_skill_dict) -- key: slot, value: array of [args.moves key]
	self:loadAbilities()
	self:equipAbilities()
	self.swapQueue = {}
	self.gauge_hidden = true
    return self
end

function AbilityHandler:update(args)
    self:handleInputs(args)
	self:abilityUpdates(args)
	self.pieMenu:setPosition(mcontroller.position())
	self.pieMenu:update(args)
	if self.gauge_animation then
		if coroutine.status(self.gauge_animation) ~= "dead" then
			coroutine.update(self.gauge_animation, self)
		else
			self.gauge_animation = nil
		end
	end
	if not self.gauge_hidden then
		apolloGauge:update(args)
	end
end

function AbilityHandler:uninit()
end

function AbilityHandler:startAbility(keybind)
	local slot = self.slots[keybind] -- This is nil somehow
	--if energy:isLocked() then
	--	return
	--end
	--energy:changeEnergy(-slot.ability.metadata.settings.energyConsumption.amount) -- jesus fuck
	self.activate_projectile:spawnProjectile(mcontroller.position(), {0,0})
	slot:startUpdateCoroutine()
end

function AbilityHandler:endAbilityCallback()
	self:toggleGauges()
end

function AbilityHandler:toggleGauges()
	self.gauge_animation = coroutine.create(function(self)
		local conf --in the end grab those values from the config but for now just fine tune them
		local actionBar_displacement = {0,30}
		local teamBar_displacement = {-30,30}
		local bars_move_max_time = 60
		local easing_type = "outQuart"
		local gauge_easing_type = "inQuad"
		if self.gauge_hidden then --animation for hiding the bars
			self.gauge_hidden = false
			local gauge_line_count = apolloGauge.line_density-1
			for tick=1, bars_move_max_time do
				local actionBar_position = {
					easing[easing_type](tick, 0, actionBar_displacement[1], bars_move_max_time),
					easing[easing_type](tick, 0, actionBar_displacement[2], bars_move_max_time)
				}
				local teamBar_position = {
					easing[easing_type](tick, 0, teamBar_displacement[1], bars_move_max_time),
					easing[easing_type](tick, 0, teamBar_displacement[2], bars_move_max_time)
				}
				local apollo_gauge_value = math.floor(easing[gauge_easing_type](tick, 0, gauge_line_count, bars_move_max_time))
				dll.setActionBarPosition(actionBar_position)
				dll.setTeamBarPosition(teamBar_position)
				apolloGauge:rawSetDisplayedValue(apollo_gauge_value)
				self = coroutine.yield()
			end
			apolloGauge:rawSetDisplayedValue(gauge_line_count)
		else --animation for showing the bars
			self.gauge_hidden = true
			for tick=1, bars_move_max_time do
				local actionBar_position = {
					easing[easing_type](tick, actionBar_displacement[1], -actionBar_displacement[1], bars_move_max_time),
					easing[easing_type](tick, actionBar_displacement[2], -actionBar_displacement[2], bars_move_max_time)
				}
				local teamBar_position = {
					easing[easing_type](tick, teamBar_displacement[1], -teamBar_displacement[1], bars_move_max_time),
					easing[easing_type](tick, teamBar_displacement[2], -teamBar_displacement[2], bars_move_max_time)
				}
				dll.setActionBarPosition(actionBar_position)
				dll.setTeamBarPosition(teamBar_position)
				self = coroutine.yield()
			end
		end
		return
	end, self)
end

function AbilityHandler:skillCancelVisuals()
	self.skill_swap_visuals_coroutine = coroutine.create(function(self)
		
	end)
end

function AbilityHandler:handleInputs(args)
	if args.moves.run and args.moves.up and not self:isBusy() then
		self.pieMenu:open()
		return
	end
	for i, keybind_table in ipairs(self.keybinds) do
		for j, keybind in pairs(keybind_table) do
			local state, busy_slot = self:isBusy()
			if args.failsaves[keybind] and not args.moves[keybind] then --state and not args.failsaves[keybind]
				if not state then
					self:toggleGauges()
					self:startAbility(keybind)
					args.failsaves[keybind] = not args.failsaves[keybind]
					return
				else
					local skill_cancel_check = self.slots[keybind].ability.metadata.settings.canSkillCancel
					if busy_slot.ability.metadata.settings.persistent then
						if skill_cancel_check then
							busy_slot.ability:stop()
							busy_slot.ability.finished = nil
							busy_slot.ability:uninit()
							busy_slot:forceStop()
							self:skillCancelVisuals()
							self:startAbility(keybind)
							return
						elseif busy_slot.keybind == keybind then
							busy_slot.ability:stop()
							return
						end
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
    status.setStatusProperty("loadedSkills", default_settings.default_skill_loadout) --debug
	self.loadedSkills = {}
	local maxSize = 0
	for keybind, tag_array in pairs(status.statusProperty("loadedSkills", {})) do
		self.loadedSkills[keybind] = {}
		maxSize = #tag_array>maxSize and #tag_array or maxSize -- gets the max size of any array
		for i, tag in ipairs(tag_array) do
			local path = string.format("/apollo_skills/%s/%s.lua", tag, tag)
			require(path)
			table.insert(self.loadedSkills[keybind], AbilitySlot:new(self, _ENV.TEMP_HOLDER, keybind, tag))
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
	self.equippedSkills = status.statusProperty("equippedSkills", nil) --INDEXES IN loadedAbilities
	if not self.equippedSkills then
		self.equippedSkills = util.map(self.loadedSkills, function(v) return 1 end) --sets all equipped skills to 1 in case the player doesn't have the table yet
		self:saveEquippedAbilities()
	end
	self.slots = {}
	for keybind, skill_index in pairs(self.equippedSkills) do
		self.slots[keybind] = self.loadedSkills[keybind][skill_index]
	end
end

function AbilityHandler:saveEquippedAbilities()
	status.setStatusProperty("equippedSkills", self.equippedSkills)
end

function AbilityHandler:swapToSkill(keybind, index)
	self.slots[keybind]:forceStop()
	self.slots[keybind] = self.loadedSkills[keybind][index]
	self.equippedSkills[keybind] = index
	self:saveEquippedAbilities()
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
	self.pieMenu = VirtualPie:new(table.copy(default_settings.skill_pie_menu_settings), rings)
end

function AbilityHandler:createActivateProjectile()
	local new_projectile = ParticleSpawner:new()
	local color_dark = color:rgb(1)
	local color_light = color:rgb(6)
	local max_time = 60
	local rotation_delta = 2*math.pi
	local size_delta = 5
	local easing_type = "inOutQuart"
	local line_count = 6
	local angle_step = 2*math.pi/line_count
	local radius = 6
	local line_overrides = {light = {0,0,0}} -- can add
	local elipse_ratio = {2,1}
	for tick = 1, max_time do
		local angle_diff = easing[easing_type](tick, 0, rotation_delta, max_time)
		local size_diff = easing[easing_type](tick, 0, size_delta, max_time)
		local alpha_diff = easing[easing_type](tick, 255, -255, max_time) --fades from full to nothing
		color_dark[4] = alpha_diff
		color_light[4] = alpha_diff
		for i = 0, line_count-1 do
			new_projectile:addParticle(
				ParticleSpawner.lineAction(
					util.trig({0,0}, radius+size_diff, angle_diff+angle_step*i, {1,1.5}), 
					util.trig({0,0}, radius+size_diff, angle_diff+angle_step*(i+1), {1,1.5}), 
					color_dark,
					2.5,
					line_overrides
				), 
				tick/60, 
				false
			)
		end
		for i = 0, line_count-1 do
			new_projectile:addParticle(
				ParticleSpawner.lineAction(
					util.trig({0,0}, radius+size_diff, -angle_diff+angle_step*i+math.pi/2, {1.5,1}), 
					util.trig({0,0}, radius+size_diff, -angle_diff+angle_step*(i+1)+math.pi/2, {1.5,1}), 
					color_light,
					2.5,
					line_overrides
				), 
				tick/60, 
				false
			)
		end
	end
	self.activate_projectile = new_projectile
end