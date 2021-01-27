local JTr = newAbility()
TEMP_HOLDER = JTr --REQUIRED PLEASE DON'T TOUCH

--jitter dash
function JTr:assign() -- called when it's equipped if you need that bind for whatever reason
    local self = {}
    setmetatable(self, JTr)
    --metadata was moved to a .config file
    return self
end

function JTr:init() -- called when it's activated
    self.parameters = {}
end

function JTr:stop() -- this will stop the ability on next tick (no matter the contents of this function)
end

function JTr:update(args) -- called every tick when activated
end

function JTr:uninit() -- called after stop right before the coroutine running the ability is discarded
end