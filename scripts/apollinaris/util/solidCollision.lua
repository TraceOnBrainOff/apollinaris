SolidCollision = {}
SolidCollision.__index = SolidCollision

function SolidCollision:assign()
    local self = {}
    setmetatable(self, SolidCollision)
    self.physicsCollisions = {}
	local mcontrollerParams = mcontroller.baseParameters()
	self.physicsCollisions.standingPoly = self:createPhysicsCollision(mcontrollerParams.standingPoly)
    self.physicsCollisions.crouchingPoly = self:createPhysicsCollision(mcontrollerParams.crouchingPoly)

    self.currentForce = Force:assign(mcontroller.position(), {physicsCollisions = self.physicsCollisions}) -- self.physicsCollisions {standingPoly = poly1, crouchingPoly = poly2}
    self.currentForce.currentAngle = 0
    self.currentForce.isCrouching = mcontroller.crouching()
	self.currentForce:vehicleSetMovingCollisionEnabled("standingPoly", true)
    self.currentForce:vehicleSetMovingCollisionEnabled("crouchingPoly", false)
    return self
end

function SolidCollision:update()
    if self.currentForce then
        if abilityHandler:isUsingAbility() and self.currentForce:exists() then -- if an ability is turned on and thing still exists
            self.currentForce:softDestroy() -- just removes the vehicle, not the class
            return -- do not continue as an ability has just started
        end

        if not self.currentForce:exists() then
            if not abilityHandler:isUsingAbility() then
                self.currentForce:recreate()
                local currentState = self.currentForce.isCrouching and "crouchingPoly" or "standingPoly"
                local previousState = not self.currentForce.isCrouching and "crouchingPoly" or "standingPoly"
                self.currentForce:vehicleSetMovingCollisionEnabled(currentState, true)
                self.currentForce:vehicleSetMovingCollisionEnabled(previousState, false)
            else
                return -- do not continue as the ability is still in progress
            end
        end
        -- now you can assume it exists
        self.currentForce:mcontrollerSetPosition(mcontroller.position())
        local playerRotation = (math.floor(math.deg(mcontroller.rotation())))%360 -- Offset by 180 for the range to switch from -180 - 179 to 0 - 359

        if self.currentForce.currentAngle ~= playerRotation then
            self.currentForce.currentAngle = playerRotation
            self.currentForce:rotatePhysicsForces(math.rad(playerRotation))
        end
        if self.currentForce.isCrouching ~= mcontroller.crouching() then
            local currentState = mcontroller.crouching() and "crouchingPoly" or "standingPoly"
            local previousState = self.currentForce.isCrouching and "crouchingPoly" or "standingPoly"
            self.currentForce:vehicleSetMovingCollisionEnabled(currentState, true)
            self.currentForce:vehicleSetMovingCollisionEnabled(previousState, false)
            self.currentForce.isCrouching = mcontroller.crouching()
        end
	end
end

function SolidCollision:createPhysicsCollision(vec, kind)
    local finalTable = {
        attachToPart = "collisionPart",
        collisionKind = kind or "block",
        collision = vec
    }
    return finalTable
end