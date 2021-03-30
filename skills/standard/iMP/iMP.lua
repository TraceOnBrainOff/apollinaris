local iMP = newAbility()
TEMP_HOLDER = iMP --REQUIRED PLEASE DON'T TOUCH

function iMP:assign() -- called when it's equipped if you need that bind for whatever reason
    local self = {}
    setmetatable(self, iMP)
    --metadata was moved to a .config file
    return self
end

function iMP:init() -- called when it's activated
    self.parameters = {}
    self.projectiles = nil
    self.currentStage = coroutine.create(self.standbyState, self)
end

function iMP:stop() -- this will stop the ability on next tick (no matter the contents of this function)
end

function iMP:update(args) -- called every tick when activated
    if coroutine.status(self.currentStage) ~= "dead" then
        coroutine.update(self.currentStage, self, args)
    else
        self.currentStage = nil
    end
end

function iMP:uninit() -- called after stop right before the coroutine running the ability is discarded
    self.metadata.settings.persistent = false
    self.projectiles = nil
end

function iMP:precompileProjectiles()
	local projectiles = {
		standby = ParticleSpawner:new(), --standby
		active = ParticleSpawner:new(), --outer_triangle
	}
    local max_time = 60
    local circlesCount = 5
    local resolution = 4
    local step = 1/resolution
	for tick=1, max_time do
		local perc = easing[self.metadata.settings.easing](tick, 0, 1, max_time)
		--local line_overrides = self.metadata.settings.lineConfigOverride
        for circle=1, circlesCount do
            local z_radius = circle/circlesCount
            for i=1, resolution do
                local _3d_point1 = vec3.polar({0,0,0}, self.metadata.settings.radius, z_radius*math.pi, 2*math.pi*step*i)
                local _3d_point2 = vec3.polar({0,0,0}, self.metadata.settings.radius, z_radius*math.pi, 2*math.pi*step*(i+1))
                _3d_point1 = vec3.rotate_around_x(_3d_point1, perc*2*math.pi)
                _3d_point2 = vec3.rotate_around_x(_3d_point2, perc*2*math.pi)
                _3d_point1 = vec3.rotate_around_z(_3d_point1, perc*2*math.pi)
                _3d_point2 = vec3.rotate_around_z(_3d_point2, perc*2*math.pi)
                projectiles.standby:addParticle(
                    ParticleSpawner.lineAction({_3d_point1[1], _3d_point1[2]}, {_3d_point2[1], _3d_point2[2]}, {255,255,255}, 1, {layer=_3d_point1[3]>0 and "front" or "back"}),
                    tick/60, 
                    false
                )
            end
        end
	end
    --projectiles.standby:dump()
	self.projectiles = projectiles
end

function iMP.damageHandlerOverride()

end

function iMP.sendEntityMessageOverride()

end

function iMP.standbyState(self, args)
    self:precompileProjectiles()
    self.projectiles.standby:spawnProjectile(mcontroller.position(), {0,0})
    self.metadata.settings.persistent = true
    local shitty_timer = 0
    while true do
        local self, args = coroutine.yield()
        shitty_timer = shitty_timer + 1
        if shitty_timer==60 then
            self.projectiles.standby:spawnProjectile(mcontroller.position(), {0,0})
            shitty_timer = 0 
        end
        self.projectiles.standby:keepProjectileAlive()
        self.projectiles.standby:callScriptedEntity("mcontroller.setPosition", mcontroller.position())
    end
    self:stop()
    return
    --has some code that swaps out the coroutine of this to the active state when a condition is met
end

function iMP.activeState(self, args)
    
end