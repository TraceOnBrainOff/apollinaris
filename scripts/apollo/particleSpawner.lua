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

function ParticleSpawner.createNestedInstance(particleSpawner, time, timeToLive, rpt)
    local newAction = {
        action = "projectile",
        type = "boltguide",
        config = {
            timeToLive = timeToLive, 
            processing = "?crop=0;0;0;0", 
            damageType = "noDamage", 
            power=0, 
            speed=0, 
            actionOnReap=jarray(), 
            movementSettings={gravityMultiplier=0}, 
            periodicActions=particleSpawner:getMerged(), 
            piercing=true
        },
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

function ParticleSpawner:addAction(action) -- definition of the particle in 'specification'
    self.assembled = false
    table.insert(self.actions, action)
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

function ParticleSpawner:addLoopAction(array_of_action_bodies, time, rpt, count)
    self.assembled = false
    local newLoop = {
        action = "loop",
        count = count,
        body = array_of_action_bodies,
        time = time or 0,
        ['repeat'] = rpt or false
    }
    table.insert(self.loops, newLoop)
end

function ParticleSpawner:addOptionAction(array_of_action_bodies, time, rpt)
    self.assembled = false
    local newOption = {
        action = "option",
        options = array_of_action_bodies,
        time = time or 0,
        ['repeat'] = rpt or false
    }
    table.insert(self.options, newOption)
end

function ParticleSpawner:merge()
    if not self.assembled then
        self.merged = util.mergeLists(util.mergeLists(self.actions, self.loops), self.options)
        self.assembled = true
    end
end

function ParticleSpawner:getMerged()
    self:merge()
    return self.merged
end

function ParticleSpawner:spawnProjectile(position, aimVector)
    self:merge()
    self.id = nil
    self.id = world.spawnProjectile("boltguide", position, entity.id(), aimVector, false, {timeToLive = 1, processing = "?crop=0;0;0;0", damageType = "noDamage", power=0, speed=0, actionOnReap=jarray(), movementSettings={gravityMultiplier=0}, periodicActions=self.merged, piercing=true})
    return self.id
end

function ParticleSpawner:keepProjectileAlive()
    if self.id and world.entityExists(self.id) then
        world.callScriptedEntity(self.id, "projectile.setTimeToLive", 0.1)
        self.lastPos = world.callScriptedEntity(self.id, "mcontroller.position")
    else
        ParticleSpawner:spawnProjectile(self.lastPos, {0,0})
    end
end

function ParticleSpawner:callScriptedEntity(...) --important to call keepProjectileAlive before this method
    if not self.id or not world.entityExists(self.id) then
        error("No projectile to callScriptedEntity onto")
    end
    world.callScriptedEntity(self.id, ...)
end

function ParticleSpawner.entityPortraitActions(flipped, color, overrides)
	local actions = {}
    local flip_str = flipped and "?flipx" or ""
    for i,v in ipairs(world.entityPortrait(entity.id(), "full")) do	
        local new_action = {
            type = "textured",
            image = v.image.. "?setcolor="..table.copy(color).."?multiply=ffffff50"..flip_str,
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
        if overrides then
            ParticleSpawner.copyMerge(new_action, overrides) --added overrides KEAGAN
        end
        table.insert(actions, new_action)
    end
	return actions
end

function ParticleSpawner.lineAction(_point1, _point2, color, thickness, override)
    local new_action = {
        type = "streak",
        color = table.copy(color),
        rotate = true,
        light = table.copy(color),
        timeToLive = 0,
        fullbright = true,
        destructionTime = 0,
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
    if override then
        ParticleSpawner.copyMerge(new_action, override)
    end
    return new_action
end

function ParticleSpawner.LSDAction(position, _point1, _point2, velocity_mul, color, thickness, override)
    local thing = ParticleSpawner.lineAction(_point1, _point2, color, thickness, override)
    thing.velocity = vec2.mul(_point2, velocity_mul)
    thing.position = position
	return thing
end

function ParticleSpawner.regularPolygon(sides, radius, angle_offset, thickness, color, override, origin_point) -- wielokąt foremny jebany mózgu
    local actions = {}
    for i=1, sides do
        local angle_range = (2*math.pi)/sides
        local _point1 = util.trig(origin_point and origin_point or {0,0}, radius, angle_range*i+angle_offset)
        local _point2 = util.trig(origin_point and origin_point or {0,0}, radius, angle_range*(i+1)+angle_offset)
        local new_action = ParticleSpawner.lineAction(_point1, _point2, color, thickness, override)
        table.insert(actions, new_action)
    end
    return actions
end

local function randomInRange(range)
    return - range + math.random() * 2 * range
end

local function randomOffset(range)
    return {randomInRange(range), randomInRange(range)}
end

local function drawLightningRecursive(t,startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, overrides)
    if displacement < minDisplacement then
        table.insert(t, ParticleSpawner.lineAction(startLine, endLine, color, width, overrides))
    else
        local mid = {(startLine[1] + endLine[1]) * 0.5 , (startLine[2] + endLine[2]) * 0.5 }
        mid = vec2.add(mid, randomOffset(displacement))
        drawLightningRecursive(t,startLine, mid, displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, width, color, overrides)
        drawLightningRecursive(t,mid, endLine, displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, width, color, overrides)

        if forks > 0 then
            local direction = vec2.sub(mid, startLine)
            local length = vec2.mag(direction) * 0.5
            local angle = math.atan(direction[2], direction[1]) + randomInRange(forkAngleRange)
            forkEnd = vec2.mul({math.cos(angle), math.sin(angle)}, length)
            drawLightningRecursive(t, mid, vec2.add(mid, forkEnd), displacement * 0.5, minDisplacement, forks - 1, forkAngleRange, math.max(width - 1, 1), color, overrides)
        end
    end
end

function ParticleSpawner.lightningActions(startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, overrides)
	local action_list = {}
	drawLightningRecursive(action_list, startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, overrides)
	return action_list
end

function ParticleSpawner:dump() --DUMPS THE PERIODIC ACTIONS!!!
	self:merge()
    return sb.printJson(self.merged)
end

function ParticleSpawner:nest(particleSpawner, time, rpt) --DUMPS THE PERIODIC ACTIONS!!!
	
end

function ParticleSpawner.copyMerge(t1, t2)
    for k, v in pairs(t2) do
        if type(v) == "table" and type(t1[k]) == "table" then
            ParticleSpawner.copyMerge(t1[k] or {}, v)
        else
            t1[k] = table.copy(v)
        end
    end
end

function ParticleSpawner.createSwooshBezier(inner, outer, overrides)
    local params = {
        steps = 20,
        maxTime = 0.15,
        resolution = 24,
    }
    if overrides then
        util.mergeTable(params, overrides)
    end
    local projectile = ParticleSpawner:new()
    local inner_bezier = Bezier:init()
    local outer_bezier = Bezier:init()
    local steps = params.steps
    local maxTime = params.maxTime
    local resolution = params.resolution
    inner_bezier:createCubicCurve(inner[1],inner[2],inner[3],inner[4], steps)
    outer_bezier:createCubicCurve(outer[1],outer[2],outer[3],outer[4], steps)
    local inner_points = inner_bezier:getPoints() --list of points
    local outer_points = outer_bezier:getPoints() --list of points
    local gradient = color:gradient(resolution)
    gradient[#gradient] = {255,255,255}
    for orbit=1, resolution do
        local tTLDiff = math.random(1,10)/100
        for line=1,steps-1 do
            local width = orbit==resolution and easing.inBounce(line, 1.75, 2.25, steps-1) or 1.75
            local dTime = orbit==resolution and 0.3 or easing.inQuad(line, tTLDiff, 0.3, steps-1)
            local tTL = easing.inOutQuad(line, tTLDiff, maxTime, steps-1)
            local x1 = easing.linear(orbit, inner_points[line][1], outer_points[line][1]-inner_points[line][1], resolution)
            local y1 = easing.linear(orbit, inner_points[line][2], outer_points[line][2]-inner_points[line][2], resolution)
            local x2 = easing.linear(orbit, inner_points[line+1][1], outer_points[line+1][1]-inner_points[line+1][1], resolution)
            local y2 = easing.linear(orbit, inner_points[line+1][2], outer_points[line+1][2]-inner_points[line+1][2], resolution)
            projectile:addParticle(ParticleSpawner.lineAction({x1,y1}, {x2,y2}, gradient[orbit], width, {timeToLive=tTL, destructionTime=dTime, destructionAction="shrink", light = {0,0,0}}), 0, false)
        end
    end
    return projectile
end

function ParticleSpawner.createSwooshPolar(origin, overrides)
    local params = {
        inner_radius = 0,
        outer_radius = 1,
        angle_range = 2*math.pi,
        angle_offset = 0,
        steps = 20,
        maxTime = 0.15,
        resolution = 24,
    }
    if overrides then
        util.mergeTable(params, overrides)
    end
    local projectile = ParticleSpawner:new()
    local steps = params.steps
    local step = params.angle_range/steps
    local maxTime = params.maxTime
    local resolution = params.resolution
    local inner_points = {} --list of points
    for i=1, steps do
        table.insert(inner_points, util.trig(origin, params.inner_radius, params.angle_offset+i*step))
    end
    local outer_points = {} --list of points
    for i=1, steps do
        table.insert(outer_points, util.trig(origin, params.outer_radius, params.angle_offset+i*step))
    end
    local gradient = color:gradient(resolution)
    gradient[#gradient] = {255,255,255}
    for orbit=1, resolution do
        local tTLDiff = math.random(1,10)/100
        for line=1,steps-1 do
            local width = orbit==resolution and easing.inBounce(line, 1.75, 2.25, steps-1) or 1.75
            local dTime = orbit==resolution and 0.3 or easing.inQuad(line, tTLDiff, 0.3, steps-1)
            local tTL = easing.inOutQuad(line, tTLDiff, maxTime, steps-1)
            local x1 = easing.linear(orbit, inner_points[line][1], outer_points[line][1]-inner_points[line][1], resolution)
            local y1 = easing.linear(orbit, inner_points[line][2], outer_points[line][2]-inner_points[line][2], resolution)
            local x2 = easing.linear(orbit, inner_points[line+1][1], outer_points[line+1][1]-inner_points[line+1][1], resolution)
            local y2 = easing.linear(orbit, inner_points[line+1][2], outer_points[line+1][2]-inner_points[line+1][2], resolution)
            projectile:addParticle(ParticleSpawner.lineAction({x1,y1}, {x2,y2}, gradient[orbit], width, {timeToLive=tTL, destructionTime=dTime, destructionAction="shrink", light = {0,0,0}}), 0, false)
        end
    end
    return projectile
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