local function tablecopy(t)
	if type(t) ~= "table" then return t end
	local nt = {}
	for i,v in pairs(t) do
		if type(v) == "table" then
			nt[i] = tablecopy(v)
		else
			nt[i] = v
		end
	end
	setmetatable(nt, getmetatable(t))
	return nt
end

local function stringsplit(inputstr, sep) 
	if sep == nil then
		sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str
		i = i + 1
	end
return t
end

portrait = {}
portrait._parts = {}
-- do not touch these unless its needed
portrait.sleeveframe = {
	["idle.1"]		=	1 ,
	["idle.2"]		=	2 ,
	["idle.3"]		=	3 ,
	["idle.4"]		=	4 ,
	["idle.5"]		=	5 ,
	["duck.1"]		=	6 ,
	["walk.1"]		=	7 ,
	["walk.2"]		=	8 ,
	["walk.3"]		=	9 ,
	["walk.4"]		=	10,
	["walk.5"]		=	11,
	["rotation"]	=	12,
	["run.1"]		=	13,
	["run.2"]		=	14,
	["run.3"]		=	15,
	["run.4"]		=	16,
	["run.5"]		=	17,
	["jump.1"]		=	18,
	["jump.2"]		=	19,
	["jump.3"]		=	20,
	["jump.4"]		=	21,
	["fall.1"]		=	22,
	["fall.2"]		=	23,
	["fall.3"]		=	24,
	["fall.4"]		=	25,
	["swimIdle.1"]	=	26,
	["swimIdle.2"]	=	27,
	["swim.1"]		=	28,
	["swim.2"]		=	29,
	["swim.3"]		=	30,
	["swim.4"]		=	31,
	["swim.5"]		=	32,
	["idleMelee"]	=	33,
	["duckMelee"]	=	34
}

portrait.chestframe = {
	["chest.1"] 	=	1,
	["chest.2"] 	=	2,
	["chest.3"] 	=	3,
	["run"]			=	4,
	["duck"]		=	5,
	["swim"] 		=	6
}

portrait.zLevelHead = { 
	HeadArmor = 10,
	Head = 3, 
	Hair = 4,
	Face = 5,
	FacialHair = 6,
	FacialMask = 7,
}

portrait.armor = {
	["/pants.png"] = "LegArmor",
	["/Pants.png"] = "LegArmor",
	["/pantsf.png"] = "LegArmor",
	["/pantsm.png"] = "LegArmor",
	["/pantsF.png"] = "LegArmor",
	["/pantsM.png"] = "LegArmor",
	["/PantsF.png"] = "LegArmor",
	["/PantsM.png"] = "LegArmor",

	["/chest.png"] = "BodyArmor",
	["/Chest.png"] = "BodyArmor",
	["/chestm.png"] = "BodyArmor",
	["/chestf.png"] = "BodyArmor",
	["/chestM.png"] = "BodyArmor",
	["/chestF.png"] = "BodyArmor",
	["/ChestM.png"] = "BodyArmor",
	["/ChestF.png"] = "BodyArmor",

	["/head.png"] = "HeadArmor",
	["/Head.png"] = "HeadArmor",
	["/headm.png"] = "HeadArmor",
	["/Headm.png"] = "HeadArmor",
	["/headM.png"] = "HeadArmor",
	["/HeadM.png"] = "HeadArmor",
	["/headf.png"] = "HeadArmor",
	["/Headf.png"] = "HeadArmor",
	["/headF.png"] = "HeadArmor",
	["/HeadF.png"] = "HeadArmor",

	["/fsleeve.png"] = "FrontArmArmor",
	["/Fsleeve.png"] = "FrontArmArmor",
	["/FSleeve.png"] = "FrontArmArmor",

	["/Bsleeve.png"] = "BackArmArmor",
	["/bsleeve.png"] = "BackArmArmor",
	["/BSleeve.png"] = "BackArmArmor",
	
	["/back.png"] = "BackArmor",
	["/Back.png"] = "BackArmor"
}

portrait.species = {
	human = {
		male = {
			["/humanoid/human/malehead.png"] = "Head",
			["/humanoid/human/emote.png"] = "Face",
			["/humanoid/human/hair/"] = "Hair",
			["/humanoid/human/malebody.png"] = "Body",
			["/humanoid/human/backarm.png"] = "BackArm",
			["/humanoid/human/frontarm.png"] = "FrontArm"
		},
		female = {
			["/humanoid/human/femalehead.png"] = "Head",
			["/humanoid/human/emote.png"] = "Face",
			["/humanoid/human/hair/"] = "Hair",
			["/humanoid/human/femalebody.png"] = "Body",
			["/humanoid/human/backarm.png"] = "BackArm",
			["/humanoid/human/frontarm.png"] = "FrontArm"
		}
	},
	avian = {
		male = {
			["/humanoid/avian/malehead.png"] = "Head",
			["/humanoid/avian/emote.png"] = "Face",
			["/humanoid/avian/hair/"] = "Hair",
			["/humanoid/avian/malebody.png"] = "Body",
			["/humanoid/avian/backarm.png"] = "BackArm",
			["/humanoid/avian/frontarm.png"] = "FrontArm",
			["/humanoid/avian/fluff/"] = "FacialHair",
			["/humanoid/avian/beaks/"] = "FacialMask"
		},
		female = {
			["/humanoid/avian/femalehead.png"] = "Head",
			["/humanoid/avian/emote.png"] = "Face",
			["/humanoid/avian/hair/"] = "Hair",
			["/humanoid/avian/femalebody.png"] = "Body",
			["/humanoid/avian/backarm.png"] = "BackArm",
			["/humanoid/avian/frontarm.png"] = "FrontArm",
			["/humanoid/avian/fluff/"] = "FacialHair",
			["/humanoid/avian/beaks/"] = "FacialMask"
		}
	},
	apex = {
		male = {
			["/humanoid/apex/malehead.png"] = "Head",
			["/humanoid/apex/emote.png"] = "Face",
			["/humanoid/apex/hairmale/"] = "Hair",
			["/humanoid/apex/malebody.png"] = "Body",
			["/humanoid/apex/backarm.png"] = "BackArm",
			["/humanoid/apex/frontarm.png"] = "FrontArm",
			["/humanoid/apex/beardmale/"] = "FacialHair"
		},
		female = {
			["/humanoid/apex/femalehead.png"] = "Head",
			["/humanoid/apex/emote.png"] = "Face",
			["/humanoid/apex/hairfemale/"] = "Hair",
			["/humanoid/apex/femalebody.png"] = "Body",
			["/humanoid/apex/backarm.png"] = "BackArm",
			["/humanoid/apex/frontarm.png"] = "FrontArm",
			["/humanoid/apex/beardfemale/"] = "FacialHair"
		}
	},
	floran = {
		male = {
			["/humanoid/floran/malehead.png"] = "Head",
			["/humanoid/floran/emote.png"] = "Face",
			["/humanoid/floran/hair/"] = "Hair",
			["/humanoid/floran/malebody.png"] = "Body",
			["/humanoid/floran/backarm.png"] = "BackArm",
			["/humanoid/floran/frontarm.png"] = "FrontArm"
		},
		female = {
			["/humanoid/floran/femalehead.png"] = "Head",
			["/humanoid/floran/emote.png"] = "Face",
			["/humanoid/floran/hair/"] = "Hair",
			["/humanoid/floran/femalebody.png"] = "Body",
			["/humanoid/floran/backarm.png"] = "BackArm",
			["/humanoid/floran/frontarm.png"] = "FrontArm"
		}
	},
	hylotl = {
		male = {
			["/humanoid/hylotl/malehead.png"] = "Head",
			["/humanoid/hylotl/emote.png"] = "Face",
			["/humanoid/hylotl/hair/"] = "Hair",
			["/humanoid/hylotl/malebody.png"] = "Body",
			["/humanoid/hylotl/backarm.png"] = "BackArm",
			["/humanoid/hylotl/frontarm.png"] = "FrontArm"
		},
		female = {
			["/humanoid/hylotl/femalehead.png"] = "Head",
			["/humanoid/hylotl/emote.png"] = "Face",
			["/humanoid/hylotl/hair/"] = "Hair",
			["/humanoid/hylotl/femalebody.png"] = "Body",
			["/humanoid/hylotl/backarm.png"] = "BackArm",
			["/humanoid/hylotl/frontarm.png"] = "FrontArm"
		}
	},
	novakid = {
		male = {
			["/humanoid/novakid/malehead.png"] = "Head",
			["/humanoid/novakid/emote.png"] = "Face",
			["/humanoid/novakid/hair/"] = "Hair",
			["/humanoid/novakid/brand/"] = "FacialHair",
			["/humanoid/novakid/malebody.png"] = "Body",
			["/humanoid/novakid/backarm.png"] = "BackArm",
			["/humanoid/novakid/frontarm.png"] = "FrontArm"
		},
		female = {
			["/humanoid/novakid/femalehead.png"] = "Head",
			["/humanoid/novakid/emote.png"] = "Face",
			["/humanoid/novakid/hair/"] = "Hair",
			["/humanoid/novakid/brand/"] = "FacialHair",
			["/humanoid/novakid/femalebody.png"] = "Body",
			["/humanoid/novakid/backarm.png"] = "BackArm",
			["/humanoid/novakid/frontarm.png"] = "FrontArm"
		}
	},
	glitch = {
		male = {
			["/humanoid/glitch/malehead.png"] = "Head",
			["/humanoid/glitch/emote.png"] = "Face",
			["/humanoid/glitch/hair/"] = "Hair",
			["/humanoid/glitch/malebody.png"] = "Body",
			["/humanoid/glitch/backarm.png"] = "BackArm",
			["/humanoid/glitch/frontarm.png"] = "FrontArm"
		},
		female = {
			["/humanoid/glitch/femalehead.png"] = "Head",
			["/humanoid/glitch/emote.png"] = "Face",
			["/humanoid/glitch/hair/"] = "Hair",
			["/humanoid/glitch/femalebody.png"] = "Body",
			["/humanoid/glitch/backarm.png"] = "BackArm",
			["/humanoid/glitch/frontarm.png"] = "FrontArm"
		}
	}
}
--

function portrait:new(id)
	if world.entityExists(id) then
		local n = tablecopy(self)
		n.specie = world.entitySpecies(id)
		n.portrait = world.entityPortrait(id, "full")
		n.gender = world.entityGender(id)

		if not portrait.species[n.specie] or not portrait.species[n.specie][n.gender] then --if not found EDIT: It will now guess the directories
			local speciesConfig = root.assetJson("/species/"..n.specie..".species")

			portrait.species[n.specie] = {}
			if speciesConfig then
				for i=1,#speciesConfig.genders do
					local gender = speciesConfig.genders[i]
					portrait.species[n.specie][gender.name] = {
						["/humanoid/"..n.specie.."/emote.png"] = "Face",
						["/humanoid/"..n.specie.."/backarm.png"] = "BackArm",
						["/humanoid/"..n.specie.."/frontarm.png"] = "FrontArm",
						["/humanoid/"..n.specie.."/"..(gender.hairGroup or "hair").."/"] = "Hair",
						
						["/humanoid/"..n.specie.."/"..gender.name.."head.png"] = "Head",
						["/humanoid/"..n.specie.."/"..gender.name.."body.png"] = "Body"
					}

					if gender.facialHairGroup then
						portrait.species[n.specie][gender.name]["/humanoid/"..n.specie.."/"..gender.facialHairGroup.."/"] = "FacialHair"
					end
					if gender.facialMaskGroup then
						portrait.species[n.specie][gender.name]["/humanoid/"..n.specie.."/"..gender.facialMaskGroup.."/"] = "FacialMask"
					end

				end
			end
		end

		for i,drawable in pairs(n.portrait) do
			local splited = stringsplit(drawable.image, ":")
			local match = false

			for image,part in pairs(portrait.species[n.specie][n.gender]) do
				if image == drawable.image:sub(1,image:len()) then
					drawable.zLevel = i
					n._parts[part] = drawable
					match = true
					break
				end
			end

			if not match then
				for image,part in pairs(portrait.armor) do
					if splited[1] and string.match(splited[1], image) then
						drawable.zLevel = i
						n._parts[part] = drawable
						break
					end
				end
			end
		end

		return n
	end
end

--portrait:new(entityid)

--returns a named parts list
function portrait:parts()
	return self._parts
end

--returns a named head parts list
function portrait:headParts()
	return { 
		HeadArmor = self._parts["HeadArmor"],
		Head = self._parts["Head"], 
		Hair = self._parts["Hair"],
		Face = self._parts["Face"],
		FacialHair = self._parts["FacialHair"],
		FacialMask = self._parts["FacialMask"],
	}
end

--Skin color
function portrait:skinDirectives() 
	if self._parts.Head then
		local splited = stringsplit(self._parts.Head.image, "?")
		local str2 = ""
		for i,v in pairs(splited) do
			if i ~= 1 then
				str2 = str2.."?"..v
			end
		end
		return str2
	else
		return ""
	end
end

function portrait:armPersonality()
	if self._parts.FrontArm then
		local splited = stringsplit(self._parts.FrontArm.image, ":")
		local split2 = stringsplit(splited[2], "?")
		return split2[1]
	else
		return "idle.1"
	end
end
function portrait:bodyPersonality()
	if self._parts.Body then
		local splited = stringsplit(self._parts.Body.image, ":")
		local split2 = stringsplit(splited[2], "?")
		return split2[1]
	else
		return "idle.1"
	end
end

--parts functions

--[[
PARTS NAMES:
"Head"
"Hair"
"Face"
"Body"
"BackArm"
"FrontArm"
"FacialHair"
"FacialMask"

"HeadArmor"
"BodyArmor"
"LegArmor"
"FrontArmArmor"
"BackArmArmor"
"BackArmor"
]]

--directory only
function portrait:directory(part)
	if self._parts[part] then
		local splits = stringsplit(self._parts[part].image, "/")
		splits[#splits] = nil
		local str = "/"
		for i,v in pairs(splits) do
			str = str..v.."/"
		end
		return str
	else
		return "/"
	end
end

-- file name only with extensions
function portrait:file(part)
	if self._parts[part] then
		local splits = stringsplit(self:image(part), "/")
		return splits[#splits]
	else
		return "/"
	end
end

--image path only no frame no directives
function portrait:image(part) 
	if self._parts[part] then
		return stringsplit(stringsplit(self._parts[part].image, "?")[1], ":")[1]
	else
		return "/"
	end
end

--frame only no directives
function portrait:frame(part)
	if self._parts[part] then
		return stringsplit(stringsplit(self._parts[part].image, ":")[2], "?")[1]
	else
		return nil
	end
end

--directives only no frame no path
function portrait:directives(part)
	if self._parts[part] then
		local str2 = ""
		for i,v in pairs(stringsplit(self._parts[part].image, "?")) do
			if i ~= 1 then
				str2 = str2.."?"..v
			end
		end
		return str2
	else
		return ""
	end
end

