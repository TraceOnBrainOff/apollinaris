glD = {}
glD.__index = glD

--[[
Naming schematics depending on type:
Skills (Hold F,G,H,Shift) - aAA
Blink (F) - Aaa
Fly (Double Up) - aaA
Jump (Double Jump) - aAa
Dash (Double Left/Right) - aaA
]]

function glD:assign()
    local self = {}
    setmetatable(self, glD)
    self.metadata = {
        name = "Glide",
        type = "fly", -- skill/ultimate/passive/blink/fly/jump/dash
        tag = "glD", -- ease of access ftw
        series = "standard", -- standard, curse, aeternum
        energyConsumption = {
            type = "instant",
            amount = 0
        }
    }
    return self
end

function glD:init()
    self.parameters = {}
    self.parameters = {
        isOn = false
    }
    sb.logInfo("loaded glide")
end

function glD:start()

end

function glD:stop()

end

function glD:update(args)
    local params = self.parameters
    if params.isOn then
        -- Active
    end
    return params.isOn
end

function glD:uninit()

end