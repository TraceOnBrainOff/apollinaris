local rCS = newAbility()
TEMP_HOLDER = rCS --REQUIRED PLEASE DON'T TOUCH

--[[
	things this will def need (private):
	
	humanoid overrides (bodyFullbright)[OK]
	(add a handler to refresh hurt sounds in player primary) [OK]
	ouchNoises from both genders[ok]
	effectDirectives
	gender
	facialHairGroup
	facialMaskGroup (thanks furries)
	all base colors [done]
	import set colors from settings or don't allow to transform
		overwrite colors
		hair (+ color)
		undy colors
	hair directives (OPTIONAL!)


	novakid = {
		name = "^shadow;^#51acff;S^#4faaff;e^#4ca7ff;v^reset;",
		gender = 0,
		personality = {
			idle = "idle.4",
			armIdle = "idle.4",
			headOffset = {-1, 0},
			armOffset = {0,0}
		},
		hair = "male1",
		facialHair = "3"
	}
	things this will import:
	name
	gender
	personality
	hair
	facialHair
	facialMask
	colors (body, hair, undies)
	hair directives (OPTIONAL)
]]

function rCS:assign()
	local self = {}
	setmetatable(self, rCS)
    return self
end

function rCS:init()
    self.parameters = {
		stageDuration = 30, -- refers to the duration of stage1 and stage3 in ticks
	}
	self:loadSpeciesData()
	self.coroutines = {self.stage1, self.stage2, self.stage3}
	self.coroutine = coroutine.create(self.coroutines[1])
	self.portrait_projectiles = {}
	self.saved_position = mcontroller.position()
end

function rCS:loadSpeciesData() --loads all the predefined configs for species into memory and creates a virtual pie menu for selection
	local speciesList = {"apex","avian","floran","glitch","human","hylotl","novakid"}
	self.species_configs = {}
	local newRing = VirtualPie_Ring:new()
	for i, species in ipairs(speciesList) do
		local species_config = root.assetJson(string.format("/skills/standard/rCS/%s.json", species), {})
		local new_button = VirtualButton:new(species_config.name, function()
			local species = species
			self:setTargetSpecies(species)
		end)
		new_button.isLocked = species==world.entitySpecies(entity.id()) and true or false --locks the button for current race so you cannot shift into current race
		if type(species_config.body_directives) == "table" then --convert the dict into a list of `RGBPair`s if the user put a table into the config
			local RGBPair_list = {}
			for key, value in pairs(species_config.body_directives) do
				table.insert(RGBPair_list, RGBPair:new(Color.hex2rgb(key), Color.hex2rgb(value))) --converts the hex into rgb
			end
			species_config.body_directives = RGBPair_list --replace the dict 
		end
		self.species_configs[species] = species_config
		newRing:addButton(new_button)
	end
	self.speciesSelectMenu = VirtualPie:new(root.assetJson("/skills/standard/rCS/speciesSelectMenu.config", {}), {newRing})
end

function rCS:setTargetSpecies(species)
	self.targetSpecies = species
end

function rCS.concatIntoDirectives(RGBPair_list)
	local result = "?replace="
	for i, RGBpair in ipairs(RGBPair_list) do
		result = result..RGBpair:toHex()..";"
	end
	return result:sub(1, -2)
end

function rCS:coroutineCallback(index)
	if index > #self.coroutines then
		self:stop()
		return
	end
	self.coroutine = coroutine.create(self.coroutines[index])
end

function rCS:stop()

end

function rCS:update(args)
	local params = self.parameters
	self.speciesSelectMenu:update(args)
	self.speciesSelectMenu:setPosition(mcontroller.position())
	mcontroller.setPosition(self.saved_position)
	mcontroller.setVelocity({0,0})
	if coroutine.status(self.coroutine) ~= "dead" then
		coroutine.update(self.coroutine, self, args)
	end
end

function rCS:uninit()
	self.portrait_projectiles = nil
	self.targetSpecies = nil -- NEED to remove it otherwise if you close the menu after the first one it'd load the last targeted race
	tech.setParentState()
end

function rCS:saveOutfit(species)
	local sPName = species.."OutfitSet"
	if status.statusProperty(sPName) == nil then
		status.setStatusProperty(sPName, {})
	end
	local outfit = {}
	local slots = {"headCosmetic","head","chestCosmetic","chest","legsCosmetic","legs","backCosmetic","back"}
	for i, value in ipairs(slots) do
		outfit[value] = player.equippedItem(value) or "none"
	end
	status.setStatusProperty(sPName, outfit)
end

function rCS:loadOutfit(species)
	local sPName = species.."OutfitSet"
	local outfit = status.statusProperty(sPName)
	sb.logInfo(util.tableToString(outfit))
	if outfit ~= nil then
		for key, value in pairs(outfit) do
			if value == "none" then
				player.setEquippedItem(key, nil)
			else
				player.setEquippedItem(key, value)
			end
		end
	end
end

function rCS:spawnProjectiles(color_index, offset)
	local t = {}
	local portrait_projectile = ParticleSpawner:new()
	util.each(ParticleSpawner.entityPortraitActions(mcontroller.facingDirection()==-1, color:hex(color_index)), function(k,v) portrait_projectile:addParticle(v, 0, true) end)
	
	local geometric_shape_projectile = ParticleSpawner:new()
	util.each(ParticleSpawner.regularPolygon(4, 4, offset, 1, color:rgb(color_index)), function(k,v) geometric_shape_projectile:addParticle(v, 0, true) end)

	table.insert(t, portrait_projectile)
	table.insert(t, geometric_shape_projectile)
	util.each(t, function(k,v) v:spawnProjectile(mcontroller.position(), {0,0}) end)
	return t
end

function rCS.stage1(self)
	
	local current_race = world.entitySpecies(entity.id())
	local species_config_copy = copy(self.species_configs[current_race])
	self.speciesSelectMenu:open()
	while not self.speciesSelectMenu:isClosed() do
		coroutine.yield()
	end
	if self.targetSpecies==nil then --if the menu was clicked out of without confirming anything
		self:stop()
		coroutine.yield()
	end

	self.portrait_projectiles.stage1 = rCS:spawnProjectiles(1,0)
	tech.setParentState("fly")
	for i=0, self.parameters.stageDuration do
		local theEasedOne = easing.inSine(i, 0, 1, self.parameters.stageDuration)
		util.each(self.portrait_projectiles.stage1, function(k,v) 
			v:keepProjectileAlive() 
			v:callScriptedEntity("mcontroller.setPosition", vec2.add(mcontroller.position(), {-theEasedOne*8,0}))
			v:callScriptedEntity("mcontroller.setRotation", mcontroller.rotation())
		end)
		mcontroller.setRotation(math.pi*theEasedOne)
		local modified_RGBPairs = {}
		for j, RGBpair in ipairs(species_config_copy.body_directives) do
			table.insert(modified_RGBPairs, RGBpair*(1-theEasedOne))
		end
		local body_directives = rCS.concatIntoDirectives(modified_RGBPairs)
		local hair_and_emote_alpha = Color.rgb2hex({math.floor(255*(1-theEasedOne))})
		dll.setBodyDirectives(body_directives)
		dll.setEmoteDirectives(string.format("%s?multiply=FFFFFF%s", species_config_copy.emote_directives, hair_and_emote_alpha))
		dll.setHairDirectives(string.format("%s?multiply=FFFFFF%s", species_config_copy.hair_directives, hair_and_emote_alpha))
		coroutine.yield()
	end
	self:coroutineCallback(2) --moves onto the stage2 coroutine
	return true
end

function rCS.stage2(self)
	util.each(self.portrait_projectiles.stage1, function(k,v) 
		v:keepProjectileAlive() 
	end)
	self:saveOutfit(world.entitySpecies(entity.id()))
	dll.setSpecies(self.targetSpecies) -- new race from here on
	local species_config_copy = copy(self.species_configs[self.targetSpecies])
	dll.setHairDirectives(species_config_copy.hair_directives)
	self:loadOutfit(self.targetSpecies)
	dll.setBodyDirectives("?setcolor=000000")
	dll.setEmoteDirectives("?setcolor=00000000")
	dll.setHairDirectives("?setcolor=00000000")
	coroutine.yield()
	self.portrait_projectiles.stage2 = rCS:spawnProjectiles(6, math.pi/4)
	dll.setBodyDirectives("?setcolor=000000")
	dll.setEmoteDirectives("?setcolor=00000000")
	dll.setHairDirectives("?setcolor=00000000")
	dll.setName(self.species_configs[self.targetSpecies].name)
	dll.sendChatMessage(string.format("/nick %s", self.species_configs[self.targetSpecies].name), 1)
	storage.savedPersonality = {self.species_configs[self.targetSpecies].personality.idle, self.species_configs[self.targetSpecies].personality.armIdle}
	dll.renetwork(entity.id())
	self:coroutineCallback(3) --moves onto the stage3 coroutine
	return true
end


function rCS.stage3(self)
	local current_race = world.entitySpecies(entity.id())
	local species_config_copy = copy(self.species_configs[current_race])
	for i=0, self.parameters.stageDuration do
		local theEasedOne = easing.outSine(i, 0, 1, self.parameters.stageDuration)
		util.each(self.portrait_projectiles.stage1, function(k,v) 
			v:keepProjectileAlive() 
			v:callScriptedEntity("mcontroller.setPosition", vec2.add(mcontroller.position(), {-8,0}))
			v:callScriptedEntity("mcontroller.setRotation", mcontroller.rotation())
		end)
		util.each(self.portrait_projectiles.stage2, function(k,v) 
			v:keepProjectileAlive() 
			v:callScriptedEntity("mcontroller.setPosition", vec2.add(mcontroller.position(), {8-theEasedOne*8,0}))
			v:callScriptedEntity("mcontroller.setRotation", mcontroller.rotation())
		end)
		mcontroller.setRotation(math.pi+math.pi*theEasedOne)
		local modified_RGBPairs = {}
		for j, RGBpair in ipairs(species_config_copy.body_directives) do
			table.insert(modified_RGBPairs, RGBpair*theEasedOne)
		end
		local body_directives = rCS.concatIntoDirectives(modified_RGBPairs)
		local hair_and_emote_alpha = Color.rgb2hex({math.floor(255*theEasedOne)})
		dll.setBodyDirectives(body_directives)
		dll.setEmoteDirectives(string.format("%s?multiply=FFFFFF%s", species_config_copy.emote_directives, hair_and_emote_alpha))
		dll.setHairDirectives(string.format("%s?multiply=FFFFFF%s", species_config_copy.hair_directives, hair_and_emote_alpha))
		coroutine.yield()
	end
	dll.setBodyDirectives(rCS.concatIntoDirectives(species_config_copy.body_directives))
	dll.setEmoteDirectives(species_config_copy.emote_directives)
	dll.setHairDirectives(species_config_copy.hair_directives)
	self:coroutineCallback(4) --moves onto the stage2 coroutine
	return true
end