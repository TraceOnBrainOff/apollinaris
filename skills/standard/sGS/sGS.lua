local sGS = newAbility()
TEMP_HOLDER = sGS --REQUIRED PLEASE DON'T TOUCH

function sGS:assign()
	local self = {}
    setmetatable(self, sGS)
    return self
end

function sGS:init()
    self.parameters = {
		easing = easing.outQuad,
		targetPos = {0,0},
		dashRange = 10,
		timer = 0,
		isAttacking = false,
		target = 0,
		oldPos = mcontroller.position(),
		windupStreaks = {
			outerRange = 20,
			innerRange = 1,
			length = 3,
			size = 1.5,
			lengthVariation = 3
		},
		seekRange = 3,
		timings = { -- util.checkBoundry: <a,b)
			38,-- 0 - 38, nothing 
			63, -- 38 - 63, letters
			91, -- 63 - 91, travel
		},
		attackTimings = {
			331, -- 0 - 331 - attack
			359, -- 331 - 359 - wait
			550 -- 359 - 550 - symbol
		},
		attackKeyframes = {34,69,110,144,159,171,181,193,204,214,224,233,240,245,252,257,263,268,273,278,283,288,293,298,304,309,314,318,324,330},
		eyeTrail = {
			circleRatio = {1,0.4},
			radius = 2.5,
			easing = easing.inQuad,
			angleDiff = 90
		},
		comboCount = 0,
		failsaves = {
			windupSound = false,
			letters = false,
			blackScreen = false,
			postAttack = false,
			symbol = false
		},
		postAttackBlinkDist = 10,
		explosionRadius = 7.5,
		afterImages = {}
	}
	local params = self.parameters
	params.targetPos = util.trig(mcontroller.position(), self.parameters.dashRange, aimAngle())
	params.afterImages = self:afterImageCreator()
end

function sGS:stop()
	tech.setParentState()
end

function sGS:update(args)
    local params = self.parameters
	if not params.isAttacking then -- Everything below is for windup/letters/dash
		params.timer = params.timer + 1
		local stage = util.checkBoundry(params.timings, params.timer)
		if stage == 0 then
			if not params.failsaves.windupSound then
				util.playShortSound({"/sfx/melee/charge_up6.ogg"}, 2, math.random(18, 22)/10, 0)
				params.failsaves.windupSound = true
			end
			self:spawnWindupStreak(math.abs(params.timings[stage+1]-params.timer-1)) -- giving it more leeway
			mcontroller.setVelocity({0,0})
		elseif stage == 1 then
			if not params.failsaves.letters then
				self:weebyLetters()
				util.playShortSound({"/sfx/instruments/nylonguitar/a7.ogg"}, 3, 1.05, 0)
				util.playShortSound({"/sfx/instruments/nylonguitar/a6.ogg"}, 3, 1.05, 0)
				params.failsaves.letters = true
			end
			mcontroller.setVelocity({0,0})
		elseif stage == 2 then
			if not params.startPos then
				params.startPos = mcontroller.position()
				tech.setParentState("fly")
				util.playShortSound({"/sfx/tech/tech_rocketboots_thrust2.ogg"}, 2, 0.65, 0)
			end
			local x = params.easing(params.timer-params.timings[2], params.startPos[1], params.targetPos[1]-params.startPos[1], params.timings[3] - params.timings[2])
			local y = params.easing(params.timer-params.timings[2], params.startPos[2], params.targetPos[2]-params.startPos[2], params.timings[3] - params.timings[2])
			mcontroller.setPosition({x,y})
			mcontroller.setVelocity({0,0})
			self:afterImage()
			self:spawnEyeTrail(mcontroller.position(), params.oldPos)
			mcontroller.controlFace(util.toDirection(params.targetPos[1]-params.startPos[1]))
			local enQuery = world.entityQuery(mcontroller.position(), params.seekRange, {withoutEntityId = entity.id(), boundMode = "position", includedTypes = {"monster", "npc", "vehicle", "player"}})[1]
			if enQuery then
				params.isAttacking = true
				params.timer = 0
				params.target = enQuery
			end
		elseif stage > 2 and params.target == 0 then
			tech.setParentState()
			self:stop()
		end
	else -- if isAttacking 
		params.timer = params.timer + 1
		local stage = util.checkBoundry(params.attackTimings, params.timer)
		if stage == 0 then -- attack
			if not params.failsaves.blackScreen then
				params.failsaves.blackScreen = true
				tech.setParentState("fall")
				self:spawnBlackScreen()
			end
			if not params.eyeTrail.startPos then
				params.eyeTrail.startPos = world.entityPosition(params.target) or mcontroller.position()
				params.eyeTrail.angle = math.random(0, 360)
				params.eyeTrail.endPos = util.trig(world.entityPosition(params.target) or mcontroller.position(), params.eyeTrail.radius*math.sqrt(params.comboCount), math.rad(params.eyeTrail.angle), params.eyeTrail.circleRatio)
			end
			local elapsedTime = params.timer - (params.attackKeyframes[params.comboCount] or 0)
			local duration = params.attackKeyframes[params.comboCount+1]
			local x = params.eyeTrail.easing(elapsedTime, params.eyeTrail.startPos[1], params.eyeTrail.endPos[1]-params.eyeTrail.startPos[1], duration)
			local y = params.eyeTrail.easing(elapsedTime, params.eyeTrail.startPos[2], params.eyeTrail.endPos[2]-params.eyeTrail.startPos[2], duration)
			local eyeTrailPos = {x,y}
			pcall(mcontroller.setPosition(eyeTrailPos))
			if world.magnitude(mcontroller.position(), params.oldPos) > 0.1 and params.comboCount < 25 then
				--self:spawnEyeTrail(mcontroller.position(), params.oldPos, 0.175, 5)
				--draw.lightning(startLine, endLine, displacement, minDisplacement, forks, forkAngleRange, width, color, layer)
				draw.lightning(mcontroller.position(), params.oldPos, 4, 0.45, 0, 0, 2, color:hex(1), "front")
			end
			for i=1,#params.attackKeyframes do
				if params.timer == params.attackKeyframes[i] then
					if params.comboCount < 25 then
						self:smack(params.eyeTrail.endPos)
						params.eyeTrail.startPos = params.eyeTrail.endPos
						params.eyeTrail.angle = params.eyeTrail.angle+180+math.random(-params.eyeTrail.angleDiff,params.eyeTrail.angleDiff)
						params.eyeTrail.endPos = util.trig(world.entityPosition(params.target) or mcontroller.position(), params.eyeTrail.radius*math.sqrt(params.comboCount), math.rad(params.eyeTrail.angle), params.eyeTrail.circleRatio)
					end
					util.playShortSound({"/sfx/interface/playerstation_place1.ogg"}, 2, 0.85, 0)
					params.comboCount = params.comboCount + 1
				end
			end
		elseif stage == 1 then
			if not params.failsaves.postAttack then
				util.playShortSound({"/sfx/gun/reload/rocket_reload_clip3.ogg"}, 2, 1.4, 0)
				params.failsaves.postAttack = true
				pcall(mcontroller.controlFace(-util.toDirection(world.entityPosition(params.target)[1]-params.startPos[1])))
				pcall(mcontroller.setPosition(vec2.add(world.entityPosition(params.target), {-params.postAttackBlinkDist*mcontroller.facingDirection(),2})))
				mcontroller.setVelocity({0,0})
				tech.setParentState()
			end
		elseif stage == 2 then -- symbol yeah
			if not params.failsaves.symbol then
				params.failsaves.symbol = true
				for i=1,9 do
					local victimPos = world.entityPosition(params.target)
					draw.lightning(victimPos, util.trig(victimPos,params.explosionRadius, math.rad(40*i)), 3, 0.2, 0, 200, 3, color:random(true), "front")
				end
				util.playShortSound({"/sfx/instruments/nylonguitar/a7.ogg"}, 4, 1.25, 0)
				util.playShortSound({"/sfx/instruments/nylonguitar/a6.ogg"}, 4, 1.25, 0)
				util.playShortSound({"/sfx/cinematics/opengate/opengate_blast.ogg"}, 2, 1.05, 0)
				crash(params.target)
			end
		elseif stage == 3 then
			tech.setParentState()
			self:stop()
		end
	end
	params.oldPos = mcontroller.position()
end

function sGS:uninit()

end

function sGS:weebyLetters()
	local positions = {
		{2,5.5},
		{-2,5.5},
		{-5,0.5},
		{5,0.5}
	}
	for i=1,4 do
		world.spawnProjectile("doomexplosion", vec2.add(mcontroller.position(), positions[i]), entity.id(), {0,0}, true, {timeToLive = 0.1,damageType = "NoDamage", processing = "?scalenearest=2",movementSettings = {collisionPoly = jarray(), collisionEnabled = false},periodicActions = {{action = "sound", time = 1, ["repeat"] = false, options = {"/sfx/gun/plasma_shotgun2.ogg"}}},
			actionOnReap = {
				{
					action = "particle",
					specification = {
						type = "textured",
						image = "/objects/hylotl/hylotlcalligraphy"..i.."/hylotlcalligraphy"..i..".png?replace;4B2E10FF=00000000;70481EFF=00000000;8D6132FF=00000000;A1B7A2FF=00000000;DEECDFFF=00000000;789078FF=00000000;404C40FF=FFFFFFFF",
						size = 3,
						position = {0,0},
						destructionAction = "shrink",
						fullbright = true,
						destructionTime = 0.05,
						initialVelocity = {0,0},
					    finalVelocity = {0,0},
					    approach = {0,0},
					    timeToLive = (self.parameters.timings[3]-self.parameters.timings[2])/60,
					    layer = "front"
					}
				}
			}
		})
	end
end

function sGS:spawnWindupStreak(remainingTime)
	--(self.parameters.windupStreaks.outerRange-self.parameters.windupStreaks.innerRange)/(remainingTime/60) -> calculating the velocity vector's length
	local angle = math.random(0,360)
	local speedVector = util.trig({0,0}, (self.parameters.windupStreaks.outerRange-self.parameters.windupStreaks.innerRange)/(remainingTime/60), math.rad(angle))
	local position = util.trig({0,0}, self.parameters.windupStreaks.outerRange, math.rad(angle+180))
	local streak = {
		action = "particle",
		time = 0,
		rotate = true,
		specification = {
			type = "streak",
			color = {255,255,255},
			light = {255,255,255},
			timeToLive = 0,
			fullbright = true,
			rotate = true,
			position = position,
			destructionTime = remainingTime/60,
			destructionAction = "shrink",
			velocity = speedVector,
			size = self.parameters.windupStreaks.size,
			length = self.parameters.windupStreaks.length*8,
			layer= "front",
			variance = {
				length = self.parameters.windupStreaks.lengthVariation
			}
		}
	}
	world.spawnProjectile("boltguide", mcontroller.position(), entity.id(), {0,0}, true, {timeToLive = 0.1,damageType = "NoDamage", processing = "?scalenearest=0",movementSettings = {collisionPoly = jarray(), collisionEnabled = false}, actionOnReap = {streak}})
end

function sGS:afterImage()
	if mcontroller.facingDirection() == 1 then
		world.spawnProjectile("invisibleprojectile", mcontroller.position(), entity.id(), {mcontroller.facingDirection(),0}, true, {timeToLive = 0.01, damageType = "NoDamage", movementSettings = {collisionPoly = jarray(), collisionEnabled = false}, actionOnReap = self.parameters.afterImages[1]})
	elseif mcontroller.facingDirection() == -1 then
		world.spawnProjectile("invisibleprojectile", mcontroller.position(), entity.id(), {mcontroller.facingDirection(),0}, true, {timeToLive = 0.01, damageType = "NoDamage", movementSettings = {collisionPoly = jarray(), collisionEnabled = false}, actionOnReap = self.parameters.afterImages[2]})
	end
end

function sGS:afterImageCreator()
	local store = {{},{}}
	local flip = ""
	for a=1, 2 do
		if a==2 then
			flip = "?flipx"
		end
		for i,v in ipairs(world.entityPortrait(entity.id(), "full")) do	
			store[a][#store[a]+1]= {
				action = "particle",
				specification = {
					type = "textured",
					image = v.image.. "?setcolor="..color:hex(1).."?multiply=ffffff50?scale=0.9"..flip,
					size = 1,
					position = {0,0},
					flippable = true,
					orientationLocked = false,
					destructionAction = "fade",
					destructionTime = 0.075,
					initialVelocity = {0,0},
					finalVelocity = {0,0},
					approach = {0,0},
					timeToLive = 0,
					layer = "back",
					fullbright = true
				}
			}
		end
	end
	return store
end

function sGS:spawnBlackScreen()
	local timeToLive = self.parameters.attackTimings[1]/60
	world.spawnProjectile("boltguide", vec2.add(mcontroller.position(), {0, 10}), entity.id(), {0,0}, true, {processing = "?scale=0",timeToLive = 0.5, damageType = "NoDamage", movementSettings = {collisionPoly = jarray(), collisionEnabled= false},
		periodicActions = {
			{
				action = "particle",
				time = 0.1,
				specification = {
					type = "ember",
					size = 10000,
					color = {0,0,0},
					fullbright = true,
					position = {0,0},
					destructionAction = "fade",
					destructionTime = 0,
					initialVelocity = {0,0},
					finalVelocity = {0,0},
					approach = {0,0},
					timeToLive = timeToLive-0.5,
					layer = "front"
				}
			}
		},
		actionOnReap = {
			{
				action = "particle",
				specification = {
					type = "ember",
					size = 10000,
					color = {0,0,0},
					fullbright = true,
					position = {0,0},
					destructionAction = "fade",
					destructionTime = 0,
					initialVelocity = {0,0},
					finalVelocity = {0,0},
					approach = {0,0},
					timeToLive = timeToLive-0.25,
					layer = "front"
				}
			}
		}
	})
end

function sGS:smack(pos)
	world.spawnProjectile("boltguide", pos, entity.id(), {0,0}, true, {processing = "?multiply=FFFFFF00",timeToLive = 0, damageType = "NoDamage", movementSettings = {collisionPoly = jarray(), collisionEnabled = false},
		actionOnReap = {
			{
				action = "particle",
				specification = {
					type = "animated",
					animation = string.format("/animations/1hswordhitspark/1hswordhitspark.animation?brightness=20?border=1;%s80;%s00", color:hex(1), color:hex(3)),
					size = math.max(3,self.parameters.comboCount/3),
					position = {0,0},
					animationCycle = 0.2,
					destructionAction = "fade",
					destructionTime = 0.2,
					initialVelocity = {0,0},
					finalVelocity = {0,0},
					approach = {0,0},
					timeToLive = 0.51,
					fullbright = true,
					layer = "front",
					variance = {
						rotation= 45,
						size = 0.5,
						angularVelocity = 180
					}
				}
			}
		}})
end

function sGS:spawnEyeTrail(pos, oldPos, destructionTime, size)
	world.spawnProjectile("boltguide", vec2.add(mcontroller.position(), {0.14*mcontroller.facingDirection(), 0.56}), entity.id(), {0,0}, false, {processing = "?multiply=FFFFFF00",timeToLive = 0.03, damageType = "NoDamage", movementSettings = {collisionPoly = jarray(), collisionEnabled = false},
		periodicActions = {draw.line({0,0},{0,0}, vec2.sub(oldPos,pos), size or 1.5, color:hex(1), "front", 0, destructionTime or 0.25, "shrink")}
	})
end