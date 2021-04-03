local cMR = newAbility()
TEMP_HOLDER = cMR --REQUIRED PLEASE DON'T TOUCH

function cMR:assign()
    local self = {}
    setmetatable(self, cMR)
    return self
end

function cMR:init()
    self.parameters = {}
end

function cMR:stop()

end

function cMR:update(args)
end

function cMR:uninit()

end