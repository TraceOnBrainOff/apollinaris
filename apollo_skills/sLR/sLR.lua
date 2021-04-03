local sLR = newAbility()
TEMP_HOLDER = sLR --REQUIRED PLEASE DON'T TOUCH

function sLR:assign() -- called when it's equipped if you need that bind for whatever reason
    local self = {}
    setmetatable(self, sLR)
    --metadata was moved to a .config file
    self.buffer = false
    local swooshes = {
        {--swoosh 1
            inner = {
                {-3,3},
                {8,5.5},
                {7,-5},
                {4,-3}
            },
            outer = {
                {-3,3},
                {4,5},
                {15,2},
                {8.5,-6}
            }
        },
        {
            inner = {
                {-2,2},
                {12,2.0},
                {4,-2.5},
                {-5,-3}
            },
            outer = {
                {-2,2},
                {12,3},
                {14,-4},
                {-10,-7}
            }
        }
    }
    local overrides = {}
    local projectile_pairs = {}
    util.each(swooshes, function(i, conf) table.insert(projectile_pairs, self.createSwooshes(conf.inner, conf.outer, overrides)) end)
    local overrides_right = {
        inner_radius = 6,
        outer_radius = 9,
        angle_range = -1.5*math.pi,
        angle_offset = -math.pi/1.5,
        steps = 40,
        maxTime = 0.25,
        resolution = 16,
    }
    local overrides_left = {
        inner_radius = 6,
        outer_radius = 9,
        angle_range = 1.5*math.pi,
        angle_offset = math.pi+math.pi/1.5,
        steps = 40,
        maxTime = 0.25,
        resolution = 16,
    }
    local polar_pair = {
        ParticleSpawner.createSwooshPolar({0,0}, overrides_right),
        ParticleSpawner.createSwooshPolar({0,0}, overrides_left)
    }
    local ass = ParticleSpawner.createSwooshPolar({0,0}, overrides_right)
    table.insert(projectile_pairs, polar_pair)
    self.projectile_pairs = projectile_pairs
    return self
end

function sLR.mirrorVertices(vertex_list)
    local local_copy = table.copy(vertex_list)
    local result_list = {}
    util.each(local_copy, function(i, vertex) result_list[i] = {-vertex[1], vertex[2]} end)
    return result_list
end

function sLR.createSwooshes(inner, outer, overrides)
    local inner_mirror = sLR.mirrorVertices(inner)
    local outer_mirror = sLR.mirrorVertices(outer)
    return {
        ParticleSpawner.createSwooshBezier(inner, outer, overrides),
        ParticleSpawner.createSwooshBezier(inner_mirror, outer_mirror, overrides)
    }
end

function sLR.createCoroutine(self, swoosh_pair, duration, combo_buffer)
    local pair = swoosh_pair
    local duration = duration
    local combo_buffer = combo_buffer --duration - combo buffer
    local a = function(self)
        local side = mcontroller.facingDirection()==-1 and 2 or 1
        pair[side]:spawnProjectile(mcontroller.position(), {0,0})
        animator.setSoundPool("activate", {
            "/sfx/melee/charge_traildash1.ogg",
            "/sfx/melee/charge_traildash2.ogg",
            "/sfx/melee/charge_traildash3.ogg",
            "/sfx/melee/charge_traildash4.ogg"
        })
        animator.setSoundVolume("activate", 1.0, 0)
        animator.setSoundPitch("activate", 0.75, 0.2)
        animator.playSound("activate", 0)
        for delay=1, duration do
            self, args = coroutine.yield(delay>duration-combo_buffer)
        end
        self:stop()
        return
    end
    return coroutine.create(a, self)
end

function sLR:init(keybind) -- called when it's activated
    local stages = {}
    for i, pair in pairs(self.projectile_pairs) do
        table.insert(stages, sLR.createCoroutine(self, pair, 30, 20))
    end
    self.stages = stages
    self.index = 1
    self.keybind = keybind
end

function sLR:stop() -- this will stop the ability on next tick (no matter the contents of this function)

end

function sLR:update(args) -- called every tick when activated
    if coroutine.status(self.stages[self.index])~="dead" then
        if self.buffer then
            self:incrimentStage()
            self.buffer = false
        end
        local canCancel = coroutine.update(self.stages[self.index], self, args)
        if args.failsaves[self.keybind] and not args.moves[self.keybind] then
            if canCancel then
                self.buffer = true
            else
                self:incrimentStage()
            end
        end
        
    end
end

function sLR:incrimentStage()
    self.index = self.index+1>#self.stages and 1 or self.index+1
end

function sLR:uninit() -- called after stop right before the coroutine running the ability is discarded
end