local tMP = newAbility()
TEMP_HOLDER = tMP --REQUIRED PLEASE DON'T TOUCH

--[[
Naming schematics depending on type:
Skills (Hold F,G,H,Shift) - aAA
Blink (F) - Aaa
Fly (Double Up) - aaA
Jump (Double Jump) - aAa
Dash (Double Left/Right) - aaA
]]

function tMP:assign() -- called when it's equipped if you need that bind for whatever reason
    local self = {}
    setmetatable(self, tMP)
    --metadata was moved to a .config file
    return self
end

function tMP:init(keybind) -- called when it's activated
    self.parameters = {}
end

function tMP:stop() -- this will stop the ability on next tick (no matter the contents of this function)
end

function tMP:update(args) -- called every tick when activated
end

function tMP:uninit() -- called after stop right before the coroutine running the ability is discarded
end