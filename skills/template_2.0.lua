tMP = {}
tMP.__index = tMP

--[[
Naming schematics depending on type:
Skills (Hold F,G,H,Shift) - aAA
Blink (F) - Aaa
Fly (Double Up) - aaA
Jump (Double Jump) - aAa
Dash (Double Left/Right) - aaA
]]

function tMP:assign()
    local self = {}
    setmetatable(self, tMP)
    self.metadata = {
        name = "Template",
        type = "skill", -- skill/ultimate/passive/blink/fly/jump/dash
        tag = "tMP", -- ease of access ftw
        series = "standard" -- standard / curse / aeternum
    }
    return self
end

function tMP:init()
    self.parameters = {}
    self.parameters = {
        isOn = false
    }
end

function tMP:start() 

end

function tMP:stop() -- this is a trigger, so it doesn't necessarily mean that the ability will stop instantly.

end

function tMP:update(args)
    local params = self.parameters
    if params.isOn then
        -- Active
    end
    return params.isOn
end

function tMP:uninit()

end