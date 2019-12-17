cMR = {}
cMR.__index = cMR

function cMR:assign()
    local self = {}
    setmetatable(self, cMR)
    self.metadata = {
		name = "Clock Mode",
        type = "ultimate", -- skill/ultimate/passive
        tag = "cMR"
	}
    return self
end

function cMR:init()
    self.parameters = {}
    self.parameters = {
        isOn = false
    }
end

function cMR:start()

end

function cMR:stop()

end

function cMR:update()
    local params = self.parameters
    if params.isOn then
        -- Active
    end
    return params.isOn
end

function cMR:uninit()

end