local glD = newAbility()
TEMP_HOLDER = glD --REQUIRED PLEASE DON'T TOUCH

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
    return self
end

function glD:init(keybind)
    self.parameters = {}
    self.parameters = {
        speed = 20,
        control = 10
    }
    self.parameters.glideCoroutine = coroutine.create(function(self, args)
        while true do
            local self, args = coroutine.yield()
            self:glideCoroutine(args)
        end
    end)
    mcontroller.setVelocity({0,10})

    self.projectile = ParticleSpawner:new()
    local particle_angle_range = 2*math.pi/self.metadata.settings.LSD_particle_density
    for i=1, self.metadata.settings.LSD_particle_density do
        local array_of_action_bodies = {}
        util.each(color:rgb(), function(j,rgb_color)
            table.insert(array_of_action_bodies,
                ParticleSpawner.createParticle( 
                    ParticleSpawner.LSDAction(
                        util.trig({0,0}, self.metadata.settings.big_trail_len/2, particle_angle_range*i), 
                        {0,0},
                        util.trig({0,0}, self.metadata.settings.LSD_particle_len, particle_angle_range*i),
                        self.metadata.settings.LSD_particle_mul,
                        rgb_color,
                        2,
                        self.metadata.settings.LSD_particle_override
                    ),
                    0, 
                    true
                )
            )
        end)
        self.projectile:addOptionAction(array_of_action_bodies, 0.05, true)
    end
    self.projectile:addParticle(
        ParticleSpawner.lineAction({-self.metadata.settings.big_trail_len/2,0}, {self.metadata.settings.big_trail_len/2,0}, color:rgb(1), 5, self.metadata.settings.big_trail_overrides),
        0,
        true
    )
    sb.logInfo(util.tableToString(self.projectile.actions))
    self.projectile:spawnProjectile(mcontroller.position(), {0,0})
end

function glD:stop()
    tech.setParentState()
    mcontroller.setRotation(0)
    self.parameters.glideCoroutine = nil
end

function glD:update(args)
    if self.parameters.glideCoroutine then
        coroutine.update(self.parameters.glideCoroutine, self, args)
        if coroutine.status(self.parameters.glideCoroutine)=="dead" then
            self.parameters.glideCoroutine = nil
        end
    end
end

function glD:glideCoroutine(args)
    self.projectile:keepProjectileAlive()
    --self.projectile:callScriptedEntity("mcontroller.setPosition", vec2.add(mcontroller.position(), {0,-2}))
    self.projectile:callScriptedEntity("mcontroller.setRotation", math.pi*2*math.sin(os.clock()))

    local rotation = vec2.angle(util.trig({0,0}, 1, mcontroller.xVelocity()*math.pi/16+math.pi+math.pi/2))
    mcontroller.setRotation(rotation-math.pi/2)
    local pos = util.trig({0,0}, -self.metadata.settings.big_trail_len, rotation)
    self.projectile:callScriptedEntity("mcontroller.setPosition", vec2.add(mcontroller.position(), pos))
    if args.moves.run then
        if mcontroller.velocity()[1] ~= 0 or mcontroller.velocity()[2] ~= 0 then
            mcontroller.controlApproachVelocity({0, 0}, self.parameters.control)
        end
    else
        local speed = {0,0}
        speed[1] = (args.moves.right~=args.moves.left) and (args.moves.right and self.parameters.speed or -self.parameters.speed) or 0
        if speed[1] ~= 0  then
            mcontroller.controlApproachXVelocity(speed[1], self.parameters.control)
        end
    end
    mcontroller.controlParameters(
        {
            gravityEnabled = true,
            gravityMultiplier = 0.1,
            ignorePlatformCollision = true,
            enableSurfaceSlopeCorrection = false,
            collisionEnabled = true,
            frictionEnabled = false
        }
    )
end

function glD:uninit()

end