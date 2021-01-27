MonsterChain = {}
MonsterChain.__index = MonsterChain

--[[
    chain structure:
    chain = {
        targetEntityId = entityid, --overrides endPosition if not nil, endPart has higher priority and will override this if it's also not nil
        (vec2F) sourcePart = partName, --(str), --overrides startPosition if not nil
        (vec2F) endPart = partName, --(str),--overrides endPosition if not nil
        startPosition = pos, --(vec2F),
        endPosition = pos, --(vec2F),
        startOffset = offset, --(vec2F), --same as doing vec2.add on startPosition
        endOffset = offset, --(vec2F), same as doing vec2.add on endPosition
        maxLength = i, --(number), --if not nil, gives the line a max length
        testCollision = b, --(bool), --if not nil, does a hitscan calculation for blocks and stops the line from penetrating
        bounces = i, --(int), --requires testCollision to be true, makes the laser bounce i amount of times after colliding
        arcRadius = i, --(number), --makes the line bend over the specified radius(I THINK?)
        overdrawLength = i, --(number), --flat increase to the line making it extend past the intended end position
        segmentSize = i, --(number) --defines how large individual lines that make up the whole line are
        drawPercentage = f, --(float?) --how much of the image % to draw. Takes values from 0 to 1 i think.
        segmentImage =  path, --(string) --image of the chain to draw. Takes in path to file
        startSegmentImage = path, --(string), image override for the first segment. optional
        endSegmentImage = path, --(string), image override for the last segment. optional
        taper = i, --(number), optional, if present, makes the image expand/contract horizontally the further the distance
        jitter = i, --(number), optional, applies a random vertical jitter if present
        waveform = { --OPTIONAL, if the table is present, performs a sinus waveform pattern on the images
            movement = num, --(number), optional. horizontal movement of the wave. defaults to 0
            frequency = num, --(number), frequency.
            amplitude = num, --(number), amplitude.
        },
        fullbright = b, --(bool), sets the fullbright param, defaults to false
        renderLayer = layer, --(string, renderlayer), the render layer for the localAnimator call
        light = clr, --(RGB color), optional, adds a localAnimator lightsource.
    }
]]

function MonsterChain:new()
    local self = {}
    setmetatable(self, MonsterChain)
    self:spawnMonster()
    return self
end

function MonsterChain:spawnMonster()
    self.id = world.spawnMonster("punchy", mcontroller.position(), root.assetJson("/monsters/unsorted/monsterChain/monsterChain.config", {}))
end

function MonsterChain:callScriptedEntity(...)
    if self.id and world.entityExists(self.id) then
        world.callScriptedEntity(self.id, ...)
    else
        self:spawnMonster()
        world.callScriptedEntity(self.id, ...)
    end
end

function MonsterChain:drawChain(chain)
    world.sendEntityMessage(self.id, "monsterAnimator.addChain", chain)
end

function MonsterChain:clearChains()
    world.sendEntityMessage(self.id, "monsterAnimator.clearChains")
end

function MonsterChain:kill()
    self:callScriptedEntity("status.setResource", "health", 0)
end

MonsterLightning = {}
MonsterLightning.__index = MonsterLightning

function MonsterLightning:new()
    local self = {}
    setmetatable(self, MonsterLightning)
    self:spawnMonster()
    return self
end

function MonsterLightning:spawnMonster()
    self.id = world.spawnMonster("punchy", mcontroller.position(), root.assetJson("/monsters/unsorted/monsterLightning/monsterLightning.config", {}))
end

function MonsterLightning:callScriptedEntity(...)
    if self.id and world.entityExists(self.id) then
        world.callScriptedEntity(self.id, ...)
    else
        self:spawnMonster()
        world.callScriptedEntity(self.id, ...)
    end
end

function MonsterLightning:kill()
    self:callScriptedEntity("status.setResource", "health", 0)
end

--[[
  bolt = {
    worldStartPosition = vec,
    worldEndPosition = vec,
    endPointDisplacement = vec, --optional, randomizes the end point by this variable
    displacement = number, --important note, if given displacement<minDisplacement from the get go, it just draws a line
    minDisplacement = number, --if displacement>minDisplacement, it creates a midpoint between startPoint and endPoint with does a random angle offset and connects the two lines. next recursion call has half displacement.
    forks = number, if > 0, creates branches that make their own lightning. passes forks-1 into the next recursion call
    forkAngleRange = rad, -- maximum range deviation from the main branch for the fork
    width = number,
    color = rgbcolor
  }
]]

function MonsterLightning:drawLightning(bolt)
    world.sendEntityMessage(self.id, "monsterAnimator.addLightning", bolt)
end

--[[
    line = {
        worldStartPosition = vec,
        worldEndPosition = vec,
        width = num,
        color = rgbcolor
    }
]]

function MonsterLightning:drawLine(line)
    line.forks = 0
    line.displacement = 0
    line.minDisplacement = 1

    world.sendEntityMessage(self.id, "monsterAnimator.addLightning", line)
end

function MonsterLightning:clearLightning()--clears the table for the monster animator
    world.sendEntityMessage(self.id, "monsterAnimator.clearLightning")
end