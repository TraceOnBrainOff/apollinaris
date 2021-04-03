Force = {}
Force.__index = Force
local vh = {["rotatePhysicsForces"] = "rotatePhysicsForces", ["mcontrollerStickingDirection"] = "mcontroller.stickingDirection",["mcontrollerZeroG"] = "mcontroller.zeroG",["mcontrollerSetPosition"] = "mcontroller.setPosition",["mcontrollerRotation"] = "mcontroller.rotation",["mcontrollerRotate"] = "mcontroller.rotate",["mcontrollerApproachXVelocity"] = "mcontroller.approachXVelocity",["mcontrollerParameters"] = "mcontroller.parameters",["vehicleEntityLoungingIn"] = "vehicle.entityLoungingIn",["mcontrollerCollisionBody"] = "mcontroller.collisionBody",["vehicleSetDamageSourceEnabled"] = "vehicle.setDamageSourceEnabled",["vehicleSetDamageTeam"] = "vehicle.setDamageTeam",["vehicleSetLoungeEnabled"] = "vehicle.setLoungeEnabled",["vehicleControlHeld"] = "vehicle.controlHeld",["mcontrollerYPosition"] = "mcontroller.yPosition",["mcontrollerAtWorldLimit"] = "mcontroller.atWorldLimit",["mcontrollerForce"] = "mcontroller.force",["mcontrollerApproachVelocity"] = "mcontroller.approachVelocity",["vehicleSetLoungeStatusEffects"] = "vehicle.setLoungeStatusEffects",["vehicleAimPosition"] = "vehicle.aimPosition",["mcontrollerIsColliding"] = "mcontroller.isColliding",["mcontrollerAddMomentum"] = "mcontroller.addMomentum",["mcontrollerVelocity"] = "mcontroller.velocity",["mcontrollerApproachYVelocity"] = "mcontroller.approachYVelocity",["mcontrollerXPosition"] = "mcontroller.xPosition",["mcontrollerSetXPosition"] = "mcontroller.setXPosition",["vehicleSetLoungeEmote"] = "vehicle.setLoungeEmote",["mcontrollerLiquidId"] = "mcontroller.liquidId",["vehicleSetPersistent"] = "vehicle.setPersistent",["mcontrollerCollisionBoundBox"] = "mcontroller.collisionBoundBox",["mcontrollerIsNullColliding"] = "mcontroller.isNullColliding",["mcontrollerIsCollisionStuck"] = "mcontroller.isCollisionStuck",["mcontrollerResetParameters"] = "mcontroller.resetParameters",["vehicleSetInteractive"] = "vehicle.setInteractive",["vehicleSetLoungeOrientation"] = "vehicle.setLoungeOrientation",["mcontrollerSetXVelocity"] = "mcontroller.setXVelocity",["mcontrollerSetRotation"] = "mcontroller.setRotation",["mcontrollerApplyParameters"] = "mcontroller.applyParameters",["mcontrollerLocalBoundBox"] = "mcontroller.localBoundBox",["mcontrollerTranslate"] = "mcontroller.translate",["mcontrollerMass"] = "mcontroller.mass",["vehicleSetLoungeDance"] = "vehicle.setLoungeDance",["mcontrollerAccelerate"] = "mcontroller.accelerate",["mcontrollerXVelocity"] = "mcontroller.xVelocity",["mcontrollerOnGround"] = "mcontroller.onGround",["mcontrollerSetYVelocity"] = "mcontroller.setYVelocity",["mcontrollerApproachVelocityAlongAngle"] = "mcontroller.approachVelocityAlongAngle",["mcontrollerLiquidPercentage"] = "mcontroller.liquidPercentage",["vehicleSetMovingCollisionEnabled"] = "vehicle.setMovingCollisionEnabled",["mcontrollerCollisionPoly"] = "mcontroller.collisionPoly",["mcontrollerYVelocity"] = "mcontroller.yVelocity",["mcontrollerSetYPosition"] = "mcontroller.setYPosition",["mcontrollerPosition"] = "mcontroller.position",["mcontrollerSetVelocity"] = "mcontroller.setVelocity",["vehicleDestroy"] = "vehicle.destroy",["vehicleSetForceRegionEnabled"] = "vehicle.setForceRegionEnabled"}



function Force:assign(position, polys) -- polys = { physicsForces = {name = poly...}, physicsCollisions = {name = poly...} }
    self = {}
    setmetatable(self, Force)
    position = position or mcontroller.position()
    polys = polys or {}
    self.conf = root.assetJson("/vehicles/force/force.config")
    self.conf.physicsForces = polys.physicsForces or {}
    self.conf.physicsCollisions = polys.physicsCollisions or {}
    self.id = world.spawnVehicle("modularmech", position, self.conf)
    return self
end

for key, value in pairs(vh) do -- Creates the methods as soon as the module is loaded
    Force[key] = function(self, ...)
        if self.id then
            return world.callScriptedEntity(self.id, value, ...)
        end
    end
end

function Force:softDestroy()
    self:vehicleDestroy()
    self.id = nil
end

function Force:recreate(position)
    self.id = world.spawnVehicle("modularmech", position or mcontroller.position(), self.conf)
end

function Force:exists()
    if self.id and world.entityExists(self.id) then
        return true
    end
    return false
end

function createDefaultPhysicsCollision(vec, kind)
    local finalTable = {
        attachToPart = "collisionPart",
        collisionKind = kind or "block",
        collision = vec,
        categoryBlacklist = {"itemDrop"}
    }
    return finalTable
end