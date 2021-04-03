local flT = newAbility()
TEMP_HOLDER = flT --REQUIRED PLEASE DON'T TOUCH
--[[
Naming schematics depending on type:
Skills (Hold F,G,H,Shift) - aAA
Blink (F) - Aaa
Fly (Double Up) - aaA
Jump (Double Jump) - aAa
Dash (Double Left/Right) - aaA
]]

function flT:assign()
    local self = {}
    setmetatable(self, flT)
    return self
end

function flT:init()
    self.parameters = {}
    self.parameters = {
        speed = 10,
        control = 10
    }
    self.parameters.glideCoroutine = coroutine.create(function(self, args)
        while true do
            local self, args = coroutine.yield()
            self:glideCoroutine(args)
        end
    end)
end

function flT:stop()
    tech.setParentState()
    mcontroller.setRotation(0)
    self.parameters.glideCoroutine = nil
end

function flT:update(args)
    if self.parameters.glideCoroutine then
        local v, errorMsg = coroutine.resume(self.parameters.glideCoroutine, self, args)
        if not v then
            error(errorMsg)
        end
        if coroutine.status(self.parameters.glideCoroutine)=="dead" then
            self.parameters.glideCoroutine = nil
        end
    end
end

function flT:glideCoroutine(args)
    if mcontroller.xVelocity() == 0 and mcontroller.yVelocity() == 0 then
        mcontroller.setRotation(0)
    else
        local angle = vec2.angle(mcontroller.velocity())-math.pi/2
        mcontroller.setRotation(angle)
    end
    if args.moves.run then
        if mcontroller.velocity()[1] ~= 0 or mcontroller.velocity()[2] ~= 0 then
            mcontroller.controlApproachVelocity({0, 0}, self.parameters.control)
        end
    else
        local speed = {0,0}
        speed[1] = (args.moves.right~=args.moves.left) and (args.moves.right and self.parameters.speed or -self.parameters.speed) or 0
        speed[2] = (args.moves.up~=args.moves.down) and (args.moves.up and self.parameters.speed or -self.parameters.speed) or 0
        if speed[1] ~= 0  then
            mcontroller.controlApproachXVelocity(speed[1], self.parameters.control)
        end
        if speed[2] ~= 0 then
            mcontroller.controlApproachYVelocity(speed[2], self.parameters.control)
        end
    end
    mcontroller.controlParameters(
        {
            gravityEnabled = false,
            ignorePlatformCollision = true,
            enableSurfaceSlopeCorrection = false,
            airFriction = 10,
            collisionEnabled = false,
            frictionEnabled = false
        }
    )
end

function flT:uninit()

end