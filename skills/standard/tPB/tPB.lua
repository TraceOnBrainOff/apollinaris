tPB = {}
tPB.__index = tPB

function tPB:assign()
    local self = {}
    setmetatable(self, tPB)
    self.metadata = {
        name = "Tile Protection Bypass",
        type = "skill", -- skill/ultimate/passive,
        tag = "tPB", -- ease of access ftw
        energyConsumption = {
            type = "instant",
            amount = 0
        }
    }
    return self
end

function tPB:init()
    self.parameters = {}
    self.parameters = {
        isOn = false,
        timer = {0,180},
        done = false
    }
end

function tPB:start()
    self.parameters.isOn = true
end

function tPB:stop()
    self:init()
end

function tPB:update(args)
    local params = self.parameters
    if params.isOn then
        if not params.done then
            local ent = world.objectQuery(tech.aimPosition(), 1, {order = "nearest"})[1]
            if ent then
                params.done = true
                params.timer[1] = params.timer[2]
                dll.limbo(ent)
                if dll then
                    local toSay = {"Pow!", "Kapow!", "Cha!", "Wallop!", "Whoop!"}
                    local toPrint = toSay[math.random(#toSay)]
                    dll.addChatMessage(toPrint)
                    dll.sendChatMessage(toPrint, 0)
                end
            end
        end
        params.timer[1] = params.timer[1]-1
        if params.timer[1] == 0 then
            self:stop()
        end
    end
    return params.isOn
end

function tPB:uninit()

end