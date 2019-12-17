rCS = {}
rCS.__index = rCS

function rCS:assign()
	local self = {}
	setmetatable(self, rCS)
    self.metadata = {
		name = "Racechanging",
		type = "normal",
		tag = "rCS",
		settings = {
			energyConsumption = {
				type = "instant",
				amount = 10
			},
			stopPassiveVisuals = false,
			disableSolidHitbox = true
		}
	}
    return self
end

function rCS:init()
    self.parameters = {}
    self.parameters = {
		isOn = false,
		stageDuration = 30, -- in ticks
		name = {
			novakid = "^shadow;^#51acff;S^#4faaff;e^#4ca7ff;v^reset;", 
			human = "^shadow;^#9e9e9e;A^#919191;r^#848484;s^#777777;y^#696969;n^reset;"
		},
		personality = {
			novakid = {
				idle = "idle.4",
				armIdle = "idle.4",
				headOffset = {-1, 0},
				armOffset = {0,0}
			},
			human = {
				idle = "idle.2",
				armIdle = "idle.2",
				headOffset = {-1, 0},
				armOffset = {0,0}
			}
		},
		pick = "",
		bodyColors = {
			novakid = {"01579B", "03A9F4", "81D4FA", "E1F5FE", "ffffff"}, 
			human = {"b37c5d", "fff7ec", "f9d3a9", "d3a57c"}
		}, 
		baseBody= {
			novakid = {"806319", "F6B919", "FDE03F", "FFF8B5", "ffffff"}, 
			human = {"c7815b", "ffe2c5", "ffc181", "d39c6c"}
		}, 
		hairBase = {
			novakid = "?replace;806319=0c2b4b;f6b919=12c2e8;fde03f=56ebf8;fff8b5=c7feff", 
			human = "?crop;0;0;1;1?setcolor=fff?replace;fff0=fff?border=1;fff;000?scale=1.15;1.12?crop;1;1;3;3?replace;fbfbfb=000;eaeaea=2a0000;e4e4e4=00002a;6a6a6a=2a002a?multiply=fff0?scale=43?crop=1;1;44;44?replace;0e001b00=111;0f001900=111;0f001b00=334;0f001c00=111;0f001e00=111;10001600=111;10001800=111;10001900=334;10001a00=111;10001b00=334;10001c00=334;10001d00=111;10001e00=559;10001f00=111;11001600=334;11001700=111;11001800=111;11001900=334;11001a00=559;11001b00=111;11001c00=111;11001d00=559;11001e00=559;11001f00=111;12001600=559;12001700=334;12001800=111;12001900=334;12001a00=559;12001b00=334;12001c00=65a;12001d00=65a;12001e00=65a;12001f00=76a;12002000=111;13001800=111;13001900=335;13001a00=65a;13001b00=75a;13001c00=335;13001d00=86b;13001e00=87b;13001f00=97b;13002000=111;14001900=335;14001a00=87b;14001b00=97b;14001c00=a8b;14001d00=b8c;14001e00=b9c;14001f00=c9b;14002000=335;15001900=a8c;15001a00=335;15001b00=c9b;15001c00=335;15001d00=dab;15001e00=eaa;15001f00=fba;15002000=435;16001a00=335;16001b00=fba;16001c00=fdb;16001d00=436;16001e00=ffb;16001f00=ffc;16002000=546;17001a00=436;17001b00=ffc;17001c00=ffc;17001d00=ffd;17001e00=546;17001f00=656;17002000=111;18001b00=656;18001c00=fff;18001d00=fff;18001e00=fff;18001f00=111;19001a00=756;19001b00=fff;19001c00=766;19001d00=866;19001e00=111;1a001900=111;1a001a00=111;1a001b00=a76;1a001c00=b87;1a001d00=644"
		}, 
		emoteBase = {
			novakid = "?replace;951500=7E3F38;BE1B00=C1695F;F32200=FFDCC4;DC1F00=FFB98F", 
			human = "?replace;dc1f00=9e9e9e;951500=434343;be1b00=6e6e6e"
		}
	}
	local speciesList = {"apex","avian","floran","glitch","human","hylotl","novakid"}
	for i, race in ipairs(speciesList) do
		local raceConfig = root.assetJson(string.format("/species/%s.species", race))
		local tempStore = {
			bodyColor = {}, -- the names match the one in the racial config
			hairColor = {},
			undyColor = {}
		}
		for name, colorStore in pairs(tempStore) do
			for baseColor, replaceColor in pairs(raceConfig[name]) do
				colorStore[#colorStore+1] = baseColor
			end
		end
		if raceConfig.humanoidOverrides then
			tempStore.bodyFullbright = raceConfig.humanoidOverrides.bodyFullbright or false
		end
		tempStore.ouchNoises = raceConfig.ouchNoises -- two element array for genders (1 male, 2 female)
	end
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
end

function rCS:start()
	local params = self.parameters
	if world.entitySpecies(entity.id()) == "novakid" then
		params.pick = "human"
	elseif world.entitySpecies(entity.id()) == "human" then
		params.pick = "novakid"
	end
	self.co = coroutine.create(self.stage1)
	params.currentStage = 1
	params.isOn = true
end

function rCS:stop()

end

function rCS:update(args)
	local params = self.parameters
    if params.isOn then
		if coroutine.status(self.co) ~= "dead" then
			local working, isDone = coroutine.resume(self.co, self)
			if not working then
				sb.logError(isDone) -- isDone changes to an error return traceback
				log("error", "rCS error", isDone)
			else -- if it is working
				if isDone then -- if isDone returns true (stage finished)
					params.currentStage = params.currentStage + 1
					if params.currentStage > 3 then -- if it's completed
						params.isOn = false -- then done
						dll.setBodyDirectives("?replace;"..params.baseBody[world.entitySpecies(entity.id())][1].."="..params.bodyColors[world.entitySpecies(entity.id())][1]..";"..params.baseBody[world.entitySpecies(entity.id())][2].."="..params.bodyColors[world.entitySpecies(entity.id())][2]..";"..params.baseBody[world.entitySpecies(entity.id())][3].."="..params.bodyColors[world.entitySpecies(entity.id())][3]..";"..params.baseBody[world.entitySpecies(entity.id())][4].."="..params.bodyColors[world.entitySpecies(entity.id())][4]..params.emoteBase[world.entitySpecies(entity.id())])
						dll.setHairDirectives(params.hairBase[world.entitySpecies(entity.id())])
						self:init()
					else
						self.co = coroutine.create(self[string.format("stage%i",params.currentStage)]) -- assign new stage
					end
				end
			end
		end
    end
    return params.isOn
end

function rCS:uninit()

end

function rCS:nameChange()
	function math.randomchoice(t) --Selects a random item from a table
	    local keys = {}
	    for key, value in pairs(t) do
	        keys[#keys+1] = key --Store keys in another table
	    end
	    index = keys[math.random(1, #keys)]
	    return t[index]
	end
	local nameTable = {}
	local nameScramble = "fake"
	local chTable = {["a"] = {"A", "a","À", "Á", "Â", "Ã", "Ä", "Å", "Æ", "Д"}, ["b"]={"B", "b", "ь", "Ъ", "Ь", "Ҍ", "ҍ", "ß"}, ["c"]= {"c", "C", "¢", "Ć", "ć", "Ĉ", "ĉ", "Ċ", "ċ", "Č", "č", "Ҫ", "ҫ"}, ["d"] = {"d", "D", "Ð", "đ", "ԁ", "ԃ"}, ["e"] = {"e", "E", "È", "É", "Ê", "Ë", "è", "é", "ê", "ë", "Ē", "ē", "Ĕ", "ĕ", "Ė", "ė", "Ę", "ę", "Ě", "ě", "є", "Ҽ", "ҽ", "Ҿ", "ҿ", "Ә", "ә", "Ӛ", "ӛ"}, ["f"] = {"F", "f", "Ғ", "ғ", "Ӻ", "ӻ"}, ["g"] = {"g", "G"}, ["k"] = {"k", "K", "Ķ", "ķ", "ĸ", "к", "ќ", "Қ", "қ", "Ҝ", "ҝ", "Ҟ", "ҟ", "Ҡ", "ҡ"}}
	for i=1, string.len(nameScramble), 1 do
		table.insert(nameTable, math.randomchoice(chTable[string.sub(nameScramble, i, i)]))
	end
	--dll.setName(table.concat(nameTable, ""))
end

function rCS:saveOutfit(race)
	local sPName = race.."OutfitSet"
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

function rCS:equipOutfit(race)
	local sPName = race.."OutfitSet"
	local outfit = status.statusProperty(sPName)
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

function rCS.stage1(self)
	local params = self.parameters
	local currentRace = world.entitySpecies(entity.id())
	for i=0, params.stageDuration do
		local bodyReplaces = {}
		for currentReplace = 1, #params.baseBody[currentRace] do
			local a = {} -- a 3 element array with rgb values of the replace
			for currentColor = 1, 3 do -- for r, g, b do
				a[#a+1] = math.floor(
					draw.hexToRGB(
						params.bodyColors[currentRace][currentReplace]
					)[currentColor]
					- 
					draw.hexToRGB(
						params.bodyColors[currentRace][currentReplace]
					)[currentColor]
					*i/params.stageDuration
				)
			end
			bodyReplaces[#bodyReplaces+1] = string.format("%s=%s", params.baseBody[currentRace][currentReplace], draw.rgbToHex(a))
		end
		dll.setBodyDirectives(string.format("?replace;%s;%s", table.concat(bodyReplaces, ";"), params.emoteBase[currentRace]))

		local emoteReplaces = {}
		for currentReplace = 1, #params.baseBody[currentRace] do
			emoteReplaces[#emoteReplaces+1] = string.format("%s=%s", params.baseBody[currentRace][currentReplace], params.bodyColors[currentRace][currentReplace])
		end
		dll.setEmoteDirectives(string.format("?replace;%s?multiply=FF%s", table.concat(emoteReplaces, ";"), draw.rgbToHex({255,255,math.floor(255*(params.stageDuration-i)/params.stageDuration)})))
		dll.setHairDirectives(string.format("%s?multiply=FF%s",params.hairBase[currentRace], draw.rgbToHex({255,255,math.floor(255*(params.stageDuration-i)/params.stageDuration)})))
		coroutine.yield()
	end
	return true
end

function rCS.stage2(self)
	local params = self.parameters
	self:saveOutfit(world.entitySpecies(entity.id()))
	dll.setSpecies(params.pick) -- new race from here on
	local currentSpecies = world.entitySpecies(entity.id())
	dll.setBodyDirectives("?setcolor=000000")
	dll.setHairDirectives("?setcolor=00000000")
	self:equipOutfit(currentSpecies)
	dll.setName(params.name[currentSpecies])
	dll.sendChatMessage(string.format("/nick %s", params.name[currentSpecies]), 1)
	storage.savedPersonality = {params.personality[currentSpecies].idle, params.personality[currentSpecies].armIdle}
	dll.renetwork(entity.id())
	return true
end

function rCS.stage3(self)
	local params = self.parameters
	local currentRace = world.entitySpecies(entity.id())
	for i=0, params.stageDuration do
		local bodyReplaces = {}
		for currentReplace = 1, #params.baseBody[currentRace] do
			local temp = {} -- a 3 element array with rgb values of the replace
			for currentColor = 1, 3 do -- for r, g, b do
				temp[#temp+1] = math.floor(
					draw.hexToRGB(
					params.bodyColors[world.entitySpecies(entity.id())][currentReplace]
				)[currentColor]
				*i/params.stageDuration
				)
			end
			bodyReplaces[#bodyReplaces+1] = string.format("%s=%s", params.baseBody[currentRace][currentReplace], draw.rgbToHex(temp))
		end
		dll.setBodyDirectives(string.format("?replace;%s;%s", table.concat(bodyReplaces, ";"), params.emoteBase[currentRace]))

		local emoteReplaces = {}
		for currentReplace = 1, #params.baseBody[currentRace] do
			emoteReplaces[#emoteReplaces+1] = string.format("%s=%s", params.baseBody[currentRace][currentReplace], params.bodyColors[currentRace][currentReplace])
		end
		dll.setEmoteDirectives(string.format("?replace;%s?multiply=FF%s", table.concat(emoteReplaces, ";"), draw.rgbToHex({255,255,math.floor(255*i/params.stageDuration)})))
		dll.setHairDirectives(string.format("%s?multiply=FF%s",params.hairBase[currentRace], draw.rgbToHex({255,255,math.floor(255*i/params.stageDuration)})))
		coroutine.yield()
	end
	return true
end