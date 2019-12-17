tRO = {}
tRO.__index = tRO

function tRO:assign()
    local self = {}
    setmetatable(self, tRO)
    self.metadata = {
		name = "Tracing",
		type = "aux",
        tag = "tRO",
        settings = {
			energyConsumption = {
				type = "instant",
				amount = 10
			},
			stopPassiveVisuals = false,
			disableSolidHitbox = true
		}
	}
    return self
end

function tRO:init()
    self.parameters = {}
    self.parameters = {
		isOn = false
	}
end

function tRO:start()
end

function tRO:stop()
end

function tRO:update(args)
    local params = self.parameters
	if params.isOn then
		
    end
    return params.isOn
end

function tRO:uninit()

end