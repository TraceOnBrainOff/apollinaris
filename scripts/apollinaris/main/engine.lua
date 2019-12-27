engine = {}

function engine.portBridge(t) -- Streamlined
    for i, name in ipairs(t) do
        local keyArray = world.sendEntityMessage(entity.id(), name.."KeyArrayHandler"):result()
        _ENV[name] = {}
        for j, funcName in ipairs(keyArray) do
            _ENV[name][funcName] = function(...)
                local args = {...}
                return world.sendEntityMessage(entity.id(), name.."."..funcName, args):result()
            end
        end
    end
end

function engine.noClip(args, state) -- rework into a movement skill!!!
	local selfPos = mcontroller.position()
	if state == 1 or state == 0 then -- If sitting then
		if inputs[7] then -- The failsafes here are for keeping noClippling out of other functions' ways, so that we don't run into weird errors down the line.
			if state == 1 then
				tech.setParentState("sit")
			else
				tech.setParentState("fall")
			end
			noClipParams.proj = {}
		end
		if args.moves.primaryFire and args.moves.altFire then
			mcontroller.setRotation(math.rad(aimAngle()))
		end
		local addPos = {0,0}
		addPos[1] = (args.moves.right ~= args.moves.left) and (args.moves.right and noClipParams.sitSpeed or -noClipParams.sitSpeed) or 0
		addPos[2] = (args.moves.up ~= args.moves.down) and (args.moves.up and noClipParams.sitSpeed or -noClipParams.sitSpeed) or 0
		mcontroller.setVelocity({0, 0})
		mcontroller.controlParameters({collisionEnabled = false})
		mcontroller.setPosition(vec2.add(selfPos, addPos))
	elseif state == 2 then -- If standing then
		if inputs[7] then
			tech.setParentState()
			mcontroller.setRotation(0)
			noClipParams.proj = {}
		end
	elseif state == 3 then -- If NoClipping
		if inputs[7] then
			tech.setParentState("fly")
			mcontroller.setVelocity({0,0})
			for i=1, #logoAction do
				local id = world.spawnProjectile("boltguide", mcontroller.position(), entity.id(), {0,0}, false, {processing = "?scale=0", movementSettings = {mass = math.huge, collisionPoly = jarray(), physicsEffectCategories = jarray(), collisionEnabled = false}, periodicActions = logoAction[i]})
				noClipParams.proj[#noClipParams.proj+1] = id
			end
		end
		for i=#noClipParams.proj, 1, -1 do
			if world.entityPosition(noClipParams.proj[i]) ~= nil then
				world.callScriptedEntity(noClipParams.proj[i], "projectile.setTimeToLive", 0.05)
				world.callScriptedEntity(noClipParams.proj[i], "mcontroller.setPosition", mcontroller.position())
				if i%2== 0 then
					world.callScriptedEntity(noClipParams.proj[i], "mcontroller.rotate", math.rad(10*i)*util.toDirection(mcontroller.xVelocity()))
				else
					world.callScriptedEntity(noClipParams.proj[i], "mcontroller.rotate", math.rad(-10*i)*util.toDirection(mcontroller.xVelocity()))
				end
			else
				noClipParams.proj[i] = nil 
				noClipParams.proj[i] = world.spawnProjectile("boltguide", mcontroller.position(), entity.id(), {0,0}, false, {processing = "?scale=0", movementSettings = {mass = math.huge, collisionPoly = jarray(), physicsEffectCategories = jarray(), collisionEnabled = false}, periodicActions = logoAction[i]})
			end
		end
		if mcontroller.xVelocity() == 0 and mcontroller.yVelocity() == 0 then
			mcontroller.setRotation(0)
		else
			local angle = vec2.angle(mcontroller.velocity())-math.pi/2
			mcontroller.setRotation(angle)
		end
		if not args.moves.run then
			if mcontroller.velocity()[1] ~= 0 or mcontroller.velocity()[2] ~= 0 then
				mcontroller.controlApproachVelocity({0, 0}, noClipParams.control)
			end
		else
			local speed = {0,0}
			speed[1] = (args.moves.right ~= args.moves.left) and (args.moves.right and noClipParams.speed or -noClipParams.speed) or 0
			speed[2] = (args.moves.up ~= args.moves.down) and (args.moves.up and noClipParams.speed or -noClipParams.speed) or 0
			if speed[1] ~= 0  then
				mcontroller.controlApproachXVelocity(speed[1], noClipParams.control)
			end
			if speed[2] ~= 0 then
				mcontroller.controlApproachYVelocity(speed[2], noClipParams.control)
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
end

isMoving = false
function engine.isMovingCheck(args)
	if args.moves.up or args.moves.down or args.moves.left or args.moves.right or args.moves.jump then
		isMoving = true
	else
		isMoving = false
	end
end

function engine.createDoubleTaps(doubleTapTime) -- Streamlined
    local toCreate = {
        up = function(noClipKey) -- Sets up double taps for the W key
            noClipKey = "up"
            args.moves.doubleUp = true
        end,
        down = function(downKey) -- Sets up double taps for the S key
            downKey = "down"
            args.moves.doubleDown = true
        end,
		run = function(shiftKey) -- Sets up double taps for the shift key
			shiftKey = "run"
			args.moves.doubleShift = true
        end,
        left = function(leftKey) -- ditto
			leftKey = "left"
			args.moves.doubleLeft = true
        end,
        right = function(rightKey) -- ditto
			rightKey = "right"
			args.moves.doubleRight = true
        end
    }

    doubleTaps = {}
    local doubleTapTime = doubleTapTime or 0.15
    for key, value in pairs(toCreate) do 
        doubleTaps[#doubleTaps+1] = DoubleTap:new({tostring(key)}, doubleTapTime, value)
    end
end

function engine.updateDoubleTaps(args) -- Streamlined
    for i=1, #doubleTaps do
        doubleTaps[i]:update(args.dt, args.moves)
    end
end