portrait = {}

function portrait:split(inputstr, sep) 
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
		HeadHumanoid = 3, 
		HairHumanoid = 4,
		FaceHumanoid = 5,
		BrandHumanoid = 6,
		BeardHumanoid = 7,
		FluffHumanoid = 8,
		BeaksHumanoid = 9
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
	["/fsleeve.png"] = "FrontArmArmor",
	["/bsleeve.png"] = "BackArmArmor",
	["/Fsleeve.png"] = "FrontArmArmor",
	["/Bsleeve.png"] = "BackArmArmor",
	["/FSleeve.png"] = "FrontArmArmor",
	["/BSleeve.png"] = "BackArmArmor",
	["/back.png"] = "BackArmor",
	["/Back.png"] = "BackArmor"
}

portrait.species = {
	human = {
		male = {
			["/humanoid/human/malehead.png"] = "HeadHumanoid",
			["/humanoid/human/emote.png"] = "FaceHumanoid",
			["/humanoid/human/hair/"] = "HairHumanoid",
			["/humanoid/human/malebody.png"] = "BodyHumanoid",
			["/humanoid/human/backarm.png"] = "BackArmHumanoid",
			["/humanoid/human/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/human/femalehead.png"] = "HeadHumanoid",
			["/humanoid/human/emote.png"] = "FaceHumanoid",
			["/humanoid/human/hair/"] = "HairHumanoid",
			["/humanoid/human/femalebody.png"] = "BodyHumanoid",
			["/humanoid/human/backarm.png"] = "BackArmHumanoid",
			["/humanoid/human/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	avian = {
		male = {
			["/humanoid/avian/malehead.png"] = "HeadHumanoid",
			["/humanoid/avian/emote.png"] = "FaceHumanoid",
			["/humanoid/avian/hair/"] = "HairHumanoid",
			["/humanoid/avian/malebody.png"] = "BodyHumanoid",
			["/humanoid/avian/backarm.png"] = "BackArmHumanoid",
			["/humanoid/avian/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/avian/fluff/"] = "FluffHumanoid",
			["/humanoid/avian/beaks/"] = "BeaksHumanoid"
		},
		female = {
			["/humanoid/avian/femalehead.png"] = "HeadHumanoid",
			["/humanoid/avian/emote.png"] = "FaceHumanoid",
			["/humanoid/avian/hair/"] = "HairHumanoid",
			["/humanoid/avian/femalebody.png"] = "BodyHumanoid",
			["/humanoid/avian/backarm.png"] = "BackArmHumanoid",
			["/humanoid/avian/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/avian/fluff/"] = "FluffHumanoid",
			["/humanoid/avian/beaks/"] = "BeaksHumanoid"
		}
	},
	apex = {
		male = {
			["/humanoid/apex/malehead.png"] = "HeadHumanoid",
			["/humanoid/apex/emote.png"] = "FaceHumanoid",
			["/humanoid/apex/hairmale/"] = "HairHumanoid",
			["/humanoid/apex/malebody.png"] = "BodyHumanoid",
			["/humanoid/apex/backarm.png"] = "BackArmHumanoid",
			["/humanoid/apex/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/apex/beardmale/"] = "BeardHumanoid"
		},
		female = {
			["/humanoid/apex/femalehead.png"] = "HeadHumanoid",
			["/humanoid/apex/emote.png"] = "FaceHumanoid",
			["/humanoid/apex/hairfemale/"] = "HairHumanoid",
			["/humanoid/apex/femalebody.png"] = "BodyHumanoid",
			["/humanoid/apex/backarm.png"] = "BackArmHumanoid",
			["/humanoid/apex/frontarm.png"] = "FrontArmHumanoid",
			["/humanoid/apex/beardfemale/"] = "BeardHumanoid"
		}
	},
	floran = {
		male = {
			["/humanoid/floran/malehead.png"] = "HeadHumanoid",
			["/humanoid/floran/emote.png"] = "FaceHumanoid",
			["/humanoid/floran/hair/"] = "HairHumanoid",
			["/humanoid/floran/malebody.png"] = "BodyHumanoid",
			["/humanoid/floran/backarm.png"] = "BackArmHumanoid",
			["/humanoid/floran/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/floran/femalehead.png"] = "HeadHumanoid",
			["/humanoid/floran/emote.png"] = "FaceHumanoid",
			["/humanoid/floran/hair/"] = "HairHumanoid",
			["/humanoid/floran/femalebody.png"] = "BodyHumanoid",
			["/humanoid/floran/backarm.png"] = "BackArmHumanoid",
			["/humanoid/floran/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	hylotl = {
		male = {
			["/humanoid/hylotl/malehead.png"] = "HeadHumanoid",
			["/humanoid/hylotl/emote.png"] = "FaceHumanoid",
			["/humanoid/hylotl/hair/"] = "HairHumanoid",
			["/humanoid/hylotl/malebody.png"] = "BodyHumanoid",
			["/humanoid/hylotl/backarm.png"] = "BackArmHumanoid",
			["/humanoid/hylotl/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/hylotl/femalehead.png"] = "HeadHumanoid",
			["/humanoid/hylotl/emote.png"] = "FaceHumanoid",
			["/humanoid/hylotl/hair/"] = "HairHumanoid",
			["/humanoid/hylotl/femalebody.png"] = "BodyHumanoid",
			["/humanoid/hylotl/backarm.png"] = "BackArmHumanoid",
			["/humanoid/hylotl/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	novakid = {
		male = {
			["/humanoid/novakid/malehead.png"] = "HeadHumanoid",
			["/humanoid/novakid/emote.png"] = "FaceHumanoid",
			["/humanoid/novakid/hair/"] = "HairHumanoid",
			["/humanoid/novakid/brand/"] = "BrandHumanoid",
			["/humanoid/novakid/malebody.png"] = "BodyHumanoid",
			["/humanoid/novakid/backarm.png"] = "BackArmHumanoid",
			["/humanoid/novakid/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/novakid/femalehead.png"] = "HeadHumanoid",
			["/humanoid/novakid/emote.png"] = "FaceHumanoid",
			["/humanoid/novakid/hair/"] = "HairHumanoid",
			["/humanoid/novakid/brand/"] = "BrandHumanoid",
			["/humanoid/novakid/femalebody.png"] = "BodyHumanoid",
			["/humanoid/novakid/backarm.png"] = "BackArmHumanoid",
			["/humanoid/novakid/frontarm.png"] = "FrontArmHumanoid"
		}
	},
	glitch = {
		male = {
			["/humanoid/glitch/malehead.png"] = "HeadHumanoid",
			["/humanoid/glitch/emote.png"] = "FaceHumanoid",
			["/humanoid/glitch/hair/"] = "HairHumanoid",
			["/humanoid/glitch/malebody.png"] = "BodyHumanoid",
			["/humanoid/glitch/backarm.png"] = "BackArmHumanoid",
			["/humanoid/glitch/frontarm.png"] = "FrontArmHumanoid"
		},
		female = {
			["/humanoid/glitch/femalehead.png"] = "HeadHumanoid",
			["/humanoid/glitch/emote.png"] = "FaceHumanoid",
			["/humanoid/glitch/hair/"] = "HairHumanoid",
			["/humanoid/glitch/femalebody.png"] = "BodyHumanoid",
			["/humanoid/glitch/backarm.png"] = "BackArmHumanoid",
			["/humanoid/glitch/frontarm.png"] = "FrontArmHumanoid"
		}
	}
}

function portrait:speciesDir(sp, gen, part)
	for i,v in pairs(self.species[sp][gen]) do
		if v == part then
			return i
		end
	end
end

function portrait:auto(id)
	return self:speciesParts(world.entityPortrait(id, "full"), world.entitySpecies(id), world.entityGender(id))
end

function portrait:speciesParts(p, spe, gender)
	local tab = {}
	if not spe then
		return tab
	end
	
	if not self.species[spe] or not self.species[spe][gender] then --if not found EDIT: It will now guess the directories
		self.species[spe] = {
			male = {
				["/humanoid/"..spe.."/malehead.png"] = "HeadHumanoid",
				["/humanoid/"..spe.."/emote.png"] = "FaceHumanoid",
				["/humanoid/"..spe.."/hair/"] = "HairHumanoid",
				["/humanoid/"..spe.."/malebody.png"] = "BodyHumanoid",
				["/humanoid/"..spe.."/backarm.png"] = "BackArmHumanoid",
				["/humanoid/"..spe.."/frontarm.png"] = "FrontArmHumanoid",
				["/humanoid/"..spe.."/fluff/"] = "FluffHumanoid",
				["/humanoid/"..spe.."/beaks/"] = "BeaksHumanoid",
				["/humanoid/"..spe.."/beardfemale/"] = "BeardHumanoid"
			},
			female = {
				["/humanoid/"..spe.."/femalehead.png"] = "HeadHumanoid",
				["/humanoid/"..spe.."/emote.png"] = "FaceHumanoid",
				["/humanoid/"..spe.."/hair/"] = "HairHumanoid",
				["/humanoid/"..spe.."/femalebody.png"] = "BodyHumanoid",
				["/humanoid/"..spe.."/backarm.png"] = "BackArmHumanoid",
				["/humanoid/"..spe.."/frontarm.png"] = "FrontArmHumanoid",
				["/humanoid/"..spe.."/fluff/"] = "FluffHumanoid",
				["/humanoid/"..spe.."/beaks/"] = "BeaksHumanoid",
				["/humanoid/"..spe.."/beardfemale/"] = "BeardHumanoid"
			}
		}
		--return tab
	end
	for i,v in pairs(p) do
		local splited = self:split(v.image, ":")
		for i2,v2 in pairs(self.species[spe][gender]) do
			if string.match(splited[1], i2) then
				v.zLevel = i
				tab[v2] = v
			end
		end
		for i2,v2 in pairs(self.armor) do
			if splited[1] and string.match(splited[1], i2) then
				v.zLevel = i
				tab[v2] = v
			end
		end
	end
	return tab
end

function portrait:filterHead(p)--filtering 
	return { 
		HeadArmor = p["HeadArmor"],
		HeadHumanoid = p["HeadHumanoid"], 
		HairHumanoid = p["HairHumanoid"],
		FaceHumanoid = p["FaceHumanoid"],
		BrandHumanoid = p["BrandHumanoid"],
		BeardHumanoid = p["BeardHumanoid"],
		FluffHumanoid = p["FluffHumanoid"],
		BeaksHumanoid = p["BeaksHumanoid"]
	}
end

function portrait:skinDirectives(p) --Skin color
	if p.HeadHumanoid then
		local splited = self:split(p.HeadHumanoid.image, "?")
		local str2 = ""
		for i,v in pairs(splited) do
			if i ~= 1 then
				str2 = str2.."?"..v
			end
		end
		return str2
	else
		return nil
	end
end

function portrait:getDirectives(p, pic)
	if p[pic] then
		local splited = self:split(p[pic].image, "?")
		local str2 = ""
		for i,v in pairs(splited) do
			if i ~= 1 then
				str2 = str2.."?"..v
			end
		end
		return str2
	else
		return nil
	end
end

function portrait:getPath(p, pic)
	if p[pic] then
		local splited = self:split(p[pic].image, ":")
		return splited[1]
	else
		return nil
	end
end

function portrait:getFrame(p, pic)
	if p[pic] then
		local splited = self:split(p[pic].image, ":")
		local split2 = self:split(splited[2], "?")
		return split2[1]
	else
		return nil
	end
end

function portrait:getArmPersonality(p)
	if p.FrontArmHumanoid then
		local splited = self:split(p.FrontArmHumanoid.image, ":")
		local split2 = self:split(splited[2], "?")
		return split2[1]
	else
		return nil
	end
end

function portrait:getBodyPersonality(p)
	if p.BodyHumanoid then
		local splited = self:split(p.BodyHumanoid.image, ":")
		local split2 = self:split(splited[2], "?")
		return split2[1]
	else
		return nil
	end
end

function portrait:getHairType(p, hg)
	if p.HairHumanoid then
		local splited = self:split(p.HairHumanoid.image, ":")
		local splited2 = self:split(p.HairHumanoid.image, ".")
		return string.gsub(splited2[1], hg, "")
	else
		return nil
	end
end

function portrait:getFacialHairType(p, hg)
	if p.BeardHumanoid then
		local splited = self:split(p.BeardHumanoid.image, ":")
		local splited2 = self:split(p.BeardHumanoid.image, ".")
		return string.gsub(splited2[1], hg, "")
	elseif p.FluffHumanoid then
		local splited = self:split(p.FluffHumanoid.image, ":")
		local splited2 = self:split(p.FluffHumanoid.image, ".")
		return string.gsub(splited2[1], hg, "")
	else
		return nil
	end
end

function portrait:getFacialMaskType(p, hg)
	if p.BrandHumanoid then
		local splited = self:split(p.BrandHumanoid.image, ":")
		local splited2 = self:split(p.BrandHumanoid.image, ".")
		return string.gsub(splited2[1], hg, "")
	elseif p.BeaksHumanoid then
		local splited = self:split(p.BeaksHumanoid.image, ":")
		local splited2 = self:split(p.BeaksHumanoid.image, ".")
		return string.gsub(splited2[1], hg, "")
	else
		return nil
	end
end

function portrait:getHairGroup(spe, gen)
	local splited = self:split(self:speciesDir(spe,gen, "HairHumanoid"), "/")
	return splited[#splited]
end

function portrait:getFacialHairGroup(spe, gen)
	if spe == "apex" then
		local splited = self:split(self:speciesDir(spe,gen, "BeardHumanoid"), "/")
		return splited[#splited]
	elseif spe == "avian" then
		local splited = self:split(self:speciesDir(spe,gen, "FluffHumanoid"), "/")
		return splited[#splited]
	else
		return nil
	end
end

function portrait:getFacialMaskGroup(spe, gen)
	if spe == "novakid" then
		local splited = self:split(self:speciesDir(spe,gen, "BrandHumanoid"), "/")
		return splited[#splited]
	elseif spe == "avian" then
		local splited = self:split(self:speciesDir(spe,gen, "BeaksHumanoid"), "/")
		return splited[#splited]
	else
	return nil
	end
end