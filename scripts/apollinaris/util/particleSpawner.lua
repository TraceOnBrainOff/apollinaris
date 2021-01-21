require "/scripts/util.lua"
require "/scripts/apollinaris/util/util.lua"

ParticleSpawner = {}
ParticleSpawner.__index = ParticleSpawner

function ParticleSpawner:new()
    local self = {}
    setmetatable(self, ParticleSpawner)
    self.actions = {}
    self.options = {}
    self.loops = {}
    self.merged = {}
    self.assembled = false -- the spawnProjectile() call merges all the tables together etc so to avoid unnecessary table operations it'll only do that if there are changes made in any of the tables
    return self
end

function ParticleSpawner.createParticle(specification, time, rpt)
    local newAction = {
        action = "particle",
        specification = specification,
        time = time or 0,
        rotate = true,
        ['repeat'] = rpt or false
    }
    return newAction
end

function ParticleSpawner:addParticle(specification, time, rpt) -- definition of the particle in 'specification'
    self.assembled = false
    table.insert(self.actions, ParticleSpawner.createParticle(specification, time, rpt))
end

function ParticleSpawner:addSound(sounds, time, rpt) -- array of strings {"", "", "", ""...}
    self.assembled = false
    local newAction = {
        action = "sound",
        options = sounds,
        time = time or 0,
        ['repeat'] = rpt or false
    }
    table.insert(self.actions, newAction)
end

function ParticleSpawner:addLoopAction(count, array_of_action_bodies, time, rpt)
    self.assembled = false
    local newLoop = {
        action = "loop",
        count = count,
        body = table.unpack(body),
        time = time or 0,
        ['repeat'] = rpt or false
    }
    table.insert(self.options, newOption)
end

function ParticleSpawner:addOptionAction(array_of_action_bodies, time, rpt)
    self.assembled = false
    local newOption = {
        action = "option",
        count = count,
        body = table.unpack(body),
        time = time or 0,
        ['repeat'] = rpt or false
    }
    table.insert(self.options, newOption)
end

function ParticleSpawner:spawnProjectile(position, aimVector)
    if not self.assembled then
        self.merged = util.mergeTable(util.mergeTable(self.actions, self.loops), self.options)
        self.assembled = true
    end
    self.id = world.spawnProjectile("boltguide", position, entity.id(), aimVector, false, {timeToLive = 1, processing = "?crop=0;0;0;0", damageType = "noDamage", power=0, speed=0, actionOnReap=jarray(), movementSettings={gravityMultiplier=0}, periodicActions=self.merged, piercing=true})
    return self.id
end

function ParticleSpawner:keepProjectileAlive()
    if self.id and world.entityExists(self.id) then
        world.callScriptedEntity(self.id, "projectile.setTimeToLive", 0.5)
        self.lastPos = world.callScriptedEntity(self.id, "mcontroller.position")
    else
        ParticleSpawner:spawnProjectile(position, aimVector)
    end
end

function ParticleSpawner:callScriptedEntity(...) --important to call keepProjectileAlive before this method
    world.callScriptedEntity(self.id, ...)
end

function ParticleSpawner.entityPortraitActions(flipped, color)
	local actions = {}
    local flip_str = flipped and "?flipx" or ""
    for i,v in ipairs(world.entityPortrait(entity.id(), "full")) do	
        local new_action = {
            type = "textured",
            image = v.image.. "?setcolor="..color.."?multiply=ffffff50"..flip_str,
            size = 1,
            position = {0,0},
            flippable = true,
            orientationLocked = false,
            destructionAction = "fade",
            destructionTime = 0.075,
            initialVelocity = {0,0},
            finalVelocity = {0,0},
            approach = {0,0},
            timeToLive = 0,
            layer = "back",
            fullbright = true,
            rotate = true
        }
        table.insert(actions, new_action)
    end
	return actions
end

function ParticleSpawner.regularPolygon(sides, radius, angle_offset, thickness, color) -- wielokąt foremny jebany mózgu
    local actions = {}
    local flip_str = flipped and "?flipx" or ""
    for i=1, sides do
        local angle_range = (2*math.pi)/sides
        local _point1 = util.trig({0,0}, radius, angle_range*i+angle_offset)
        local _point2 = util.trig({0,0}, radius, angle_range*(i+1)+angle_offset)
        local new_action = {
            type = "streak",
            color = color,
            rotate = true,
            light = color,
            timeToLive = 0.1,
            fullbright = true,
            destructionTime = 0.15,
            destructionAction = "shrink",
            position = _point1,
            velocity = vec2.mul(world.distance(_point1, _point2),0.001),
            size = thickness,
            length = world.magnitude(_point1, _point2)*8,
            layer= "front",
            variance={
                length = 0
            }
        }
        table.insert(actions, new_action)
    end
    return actions
end

--[[
Example:

newProjectile = ParticleSpawner:new()
newProjectile:addSound({"/sfx/cinematics/apex_frame1.ogg"})
newProjectile:addParticle(
    {
        type = "text",
        layer = "front", -- front / middle / back
        position = {0,0},
        size = 1,
        text = "i have copied mayor lewis' pants with quantum entanglement",
        timeToLive = 5
    }
)
newProjectile:spawnProjectile(mcontroller.position(), {0,0})
]]