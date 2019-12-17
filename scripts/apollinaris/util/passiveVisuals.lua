PassiveVisuals = {}
PassiveVisuals.__index = PassiveVisuals

function PassiveVisuals:assign()
    local self = {}
    setmetatable(self, PassiveVisuals)
    self.breathing = {
        headAmplitude = 0.25,
		armAmplitude = 0.375,
		timer = {0,240}
    }
    self.chatting = {
        trueChat = true,
        currChar = 0,
        toSay = "",
        speed = 0.5,
        baseColor = 97,
        peakColor = 135,
        offset = math.pi/3,
        phaseMultiplier = 2
    }
    return self
end

function PassiveVisuals:update()
    -- Breathing
    self:breathingUpdate()
    -- Chatting
    self:chattingUpdate()
end

function PassiveVisuals:breathingUpdate()
    local params = self.breathing
    if params.timer[1] > params.timer[2] then
        params.timer[1] = 1
    end
    if params.timer[1] == params.timer[2]/2 and isDefault() then
        local path = string.format("/parallax/images/glitters/base/%i.png?setcolor=898989", math.random(7))
        world.spawnProjectile("boltguide", vec2.add(mcontroller.position(), {mcontroller.facingDirection()*0.6,mcontroller.crouching() and -0.7 or 0.3}), entity.id(), {0, 0}, true, {processing = "?scale=0", timeToLive = params.timer[2]/60, movementSettings = {mass = math.huge, collisionPoly = jarray(), physicsEffectCategories = jarray(), collisionEnabled = false},
            periodicActions = {
                {
                    time = 0,
                    ["repeat"] = false,
                    action = "particle",
                    specification = {
                        type = "textured",
                        image = path,
                        position = {0,0},
                        initialVelocity = {mcontroller.facingDirection()*0.75, 0},
                        finalVelocity = {0, 0},
                        approach = {1, 0},
                        destructionAction = "fade",
                        destructionTime = 0.8,
                        size = 0.01,
                        layer = "middle",
                        timeToLive = 0.1,
                        variance = {
                            rotation = 360,
                            initialVelocity = {0,0}
                        }
                    }
                }
            } 
        })
    end
    if not storage.savedPersonality then
        local por = portrait:auto(entity.id())
        local armPersonality = portrait:getArmPersonality(por)
        local bodyPersonality = portrait:getBodyPersonality(por)
        storage.savedPersonality = {bodyPersonality, armPersonality}
    end
    local phase = params.timer[1]/params.timer[2] * math.pi*2
    local headY = math.sin(phase)*params.headAmplitude-params.headAmplitude
    local armY = math.sin(phase)*params.armAmplitude
    dll.setPersonality(storage.savedPersonality[1], storage.savedPersonality[2], -1, headY, 0, armY)
    params.timer[1] = params.timer[1] + 1
end

function PassiveVisuals:chattingUpdate()
    if dll.isChatting() and (not abilityHandler:isUsingAbility()) then
        local params = self.chatting
        if not params.trueChat then
            local hexValues = {}
            for i=0,2 do
                local sin = math.max(0, math.sin(os.clock()*params.phaseMultiplier - i*params.offset))
                local color = math.floor(params.baseColor + params.peakColor*sin)
                hexValues[#hexValues+1] = draw.rgbToHex({color,color,color})
            end
            local toChatRaw = "^#"..hexValues[1]..";@^#"..hexValues[2]..";@^#"..hexValues[3]..";@^reset; "..world.entityName(entity.id()).." is typing..."
            local skips = {}
            local currentSearch = 0
            while string.find(toChatRaw, "%b^;", currentSearch) ~= nil do
                local begin, finish = string.find(toChatRaw, "%b^;", currentSearch)
                if begin ~= nil and finish ~= nil then
                    skips[tostring(begin)] = finish
                end
                currentSearch = finish
            end
            params.currChar = math.min(params.currChar + params.speed, toChatRaw:len())
            for begin, finish in pairs(skips) do
                if math.ceil(params.currChar) == tonumber(begin) then
                    params.currChar = finish
                end
            end
            params.toSay = string.sub(toChatRaw, 0, math.ceil(params.currChar))
        else
            params.toSay = string.format("[%s]: %s", world.entityName(entity.id()), dll.currentChat())
        end
        dll.addChatMessage(params.toSay)
    else
        local params = self.chatting
        params.currChar = 0
        params.toSay = ""
    end
end

function PassiveVisuals:uninit()

end

