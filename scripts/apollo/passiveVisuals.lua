PassiveVisuals = {}
PassiveVisuals.__index = PassiveVisuals

function PassiveVisuals:assign()
    local self = {}
    setmetatable(self, PassiveVisuals)
    self.breathing = {
        headAmplitude = 0.25,
		armAmplitude = 0.375,
		timerCap = 240
    }
    self.chatting = {
        toSay = "",
    }
    self:startBreathingCoroutine()
    return self
end

function PassiveVisuals:update()
    -- Breathing
    self:breathingUpdate()
    -- Chatting
    self:chattingUpdate()
    dll.setNameTag(world.entityName(entity.id()))
    self:showCursors()
end

function PassiveVisuals:showCursors()
    for i,v in pairs(world.playerQuery(mcontroller.position(), 50)) do
        local x,y = dll.getCursorPos(v)
        world.debugLine(world.entityPosition(v), {x,y}, {255,255,255,255})
    end
end

function PassiveVisuals:breathingUpdate()
    local params = self.breathing
    if self.breathingCoroutine then
        local v, errorMsg = coroutine.resume(self.breathingCoroutine, self)
        if not v then
            sb.logError(tostring(errorMsg))
        end
        if coroutine.status(self.breathingCoroutine)=="dead" then
            self.breathingCoroutine = nil
        end
    end
end

function PassiveVisuals:chattingUpdate()
    local params = self.chatting
    if dll.isChatting() and isDefault() then
        params.toSay = string.format("%s: %s", world.entityName(entity.id()), dll.currentChat())
        dll.addChatMessage(params.toSay)
    else
        params.toSay = ""
    end
end

function PassiveVisuals:startBreathingCoroutine()
    self.breathingCoroutine = coroutine.create(function(self)
        local timer = 0
        while true do
            if isDefault() then
                if not storage.savedPersonality then
                    local por = portrait:auto(entity.id())
                    local armPersonality = portrait:getArmPersonality(por)
                    local bodyPersonality = portrait:getBodyPersonality(por)
                    storage.savedPersonality = {bodyPersonality, armPersonality}
                end
                local phase = timer/self.breathing.timerCap * math.pi*2
                local headY = math.sin(phase)*self.breathing.headAmplitude-self.breathing.headAmplitude
                local armY = math.sin(phase)*self.breathing.armAmplitude
                dll.setPersonality(storage.savedPersonality[1], storage.savedPersonality[2], -1, headY, 0, armY)
                timer = (timer%(self.breathing.timerCap+1)) + 1
            end
            coroutine.yield()
        end
    end)
end



function PassiveVisuals:uninit()

end

