local tRO = newAbility()
TEMP_HOLDER = tRO --REQUIRED PLEASE DON'T TOUCH

function tRO:assign()
    local self = {}
    setmetatable(self, tRO)
    return self
end

function tRO:init()
end

function tRO:stop()
end

function tRO:update(args)
end

function tRO:uninit()

end