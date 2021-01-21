local iNF = newAbility()
TEMP_HOLDER = iNF --REQUIRED PLEASE DON'T TOUCH

function iNF:assign()
	local self = {}
    setmetatable(self, iNF)
    return self
end

function iNF:init()
    self.parameters = {
		castRadius = 3,
		primaryLightning = {
			timer = {0,0.5},
			knockback = 45,
			burstTimer = {0,0.25},
			burstCooldown = {0,0.175},
			magnumRange = 30,
			magnumFailsafe = false
		},
		grenade = {
			projTable = {},
			cooldown = {0,0.5},
			movementParams = {
				mass = 50.0,
				gravityMultiplier = 1,
				bounceFactor = 0.0,
				maxMovementPerStep = 1,
				ignorePlatformCollision = true,
				stickyCollision = true,
				stickyForce = 1.0,
				airFriction = 3.0,
				liquidFriction = 8.0,
				groundFriction = 15.0,
				maximumCorrection = 0.75
			},
			throwMultiplier = 2.5,
			explosionRadius = 7,
			stickRadius = 2,
			timeToLive = 1.75,
			shape = draw.shape({0.5, 6}, {0.5, 3})
		},
		storm = {
			currXPos = 0,
			inaccuracy = 3,
			movespeed = 0.1,
			isOn = false,
			range = 50,
			timer = {0,5},
			cloudProj = {
				id = nil,
				yDist = 25
			},
			lightningCooldown = {0,0.1}
		},
		passive = {
			chance = 4,
			range = {1,2}
		},
		rocket = {
			miniRocket = {
				forkAngle = 75,
				seekRadius = 10,
				multiplier = 5,
				controlForce = 120,
				timeToLive = 2,
				t = {},
				explosionThreshold = 1.5,
				explosionRadius = 2.5,
				initialVelocity = 30
			},
			speedMultiplier = 2,
			fork = 15,
			cooldown = {0,0.5},
			timeToLive = 1.75,
			t = {},
			shape = draw.shape({0.75, 3, {angleOffset = 30}}, {0.1, 2, {angleOffset = 30}})
		}
	}
end

function iNF:stop()
end

function iNF:update(args)
    local params = self.parameters
	self:primaryLightning(args, params)
	self:grenade(args,params)
	self:storm(args,params)
	self:rocket(args, params)
	self:miniRockets(args,params)
	self:passiveEffect(params)
end

function iNF:uninit()

end

function iNF:primaryLightning(args, params)
	local castPos = util.trig(mcontroller.position(), params.castRadius, aimAngle())
	if args.moves.primaryFire and not args.moves.altFire and not args.moves["down"] and not args.moves.run then
		if params.primaryLightning.burstTimer[1] == 0 then
			self:handCast()
			for i=1,5 do
				draw.lightning(castPos, util.trig(mcontroller.position(),params.primaryLightning.magnumRange,aimAngle()), 9, 1, 0, 200, 1.25, color:random(true), "front")
			end
			mcontroller.setVelocity({math.cos(aimAngle()+math.pi)*params.primaryLightning.knockback, math.sin(aimAngle()+math.pi)*params.primaryLightning.knockback})
			util.playShortSound({"/sfx/gun/brainextractor_hit.ogg"}, 1,1,0)
			params.primaryLightning.magnumFailsafe = true
			params.primaryLightning.burstTimer[1] = params.primaryLightning.burstTimer[2]
			mcontroller.controlFace(util.toDirection(tech.aimPosition()[1]-mcontroller.position()[1]))
		else
			params.primaryLightning.burstTimer[1] = params.primaryLightning.burstTimer[2]
			if params.primaryLightning.burstCooldown[1] == 0 and not params.primaryLightning.magnumFailsafe then
				self:handCast()
				for i=1,3 do
					draw.lightning(castPos, tech.aimPosition(), 3, 0.3, 0, 200, 0.1, color:random(true), "front")
				end
				util.playShortSound({"/sfx/gun/elemental_lance.ogg", "/sfx/gun/electricrailgun1.ogg"}, 1,math.random(10,13)/10,0)
				params.primaryLightning.burstCooldown[1] = params.primaryLightning.burstCooldown[2]
			end
		end
	end
	params.primaryLightning.magnumFailsafe = false
	params.primaryLightning.burstCooldown[1] = math.max(params.primaryLightning.burstCooldown[1]-args.dt,0)
	params.primaryLightning.burstTimer[1] = math.max(params.primaryLightning.burstTimer[1]-args.dt,0)
end

function iNF:grenade(args, params)
	local castPos = util.trig(mcontroller.position(), self.parameters.castRadius, aimAngle())
	if args.moves.primaryFire and args.moves.run and params.grenade.cooldown[1] == 0 then
		self:handCast()
		local grenadeID = world.spawnProjectile("boltguide", castPos, entity.id(), {math.cos(aimAngle()), math.sin(aimAngle())}, false, {processing = "?scale=0",speed = params.grenade.throwMultiplier*world.magnitude(mcontroller.position(), tech.aimPosition()),movementSettings = params.grenade.movementParams, periodicActions = params.grenade.shape})
		params.grenade.cooldown[1] = params.grenade.cooldown[2]
		params.grenade.projTable[tostring(grenadeID)] = {enId = "empty", timeToLive = params.grenade.timeToLive}
		util.playShortSound({"/sfx/projectiles/throw_item_big.ogg"}, 1, 0.75, 0)
	end
	params.grenade.cooldown[1] = math.max(params.grenade.cooldown[1]-args.dt,0)

	for key, value in pairs(params.grenade.projTable) do
		if world.entityPosition(key) ~= nil then
			world.debugText("timeToLive: ".. value.timeToLive, world.entityPosition(key), {255,255,255})
			if value.timeToLive > 0 then
				world.callScriptedEntity(key, "projectile.setTimeToLive", 1)
				self:grenadeStick(world.entityPosition(key), value)
				if value.enId ~= "empty" then
					world.callScriptedEntity(key, "mcontroller.setPosition", world.entityPosition(value.enId))
					world.callScriptedEntity(key, "mcontroller.setVelocity", {0,0})
				end
				value.timeToLive = math.max(value.timeToLive-args.dt,0)
			else
				for i=1,9 do
					local projPos = world.entityPosition(key)
					draw.lightning(projPos, util.trig(projPos,params.grenade.explosionRadius, 40*i), 3, 1, 0, 200, 2, color:random(true), "front")
				end
				util.playShortSound({"/sfx/melee/travelingslash_electric2.ogg"}, 1.5, math.random(8, 11)/10, 0)
				world.callScriptedEntity(key, "projectile.die")
				params.grenade.projTable[key] = nil
			end
		end
	end
end

function iNF:handCast()
	local castPos = util.trig(mcontroller.position(), self.parameters.castRadius, aimAngle())
	for i=1,3 do
		local playerPos = {mcontroller.position()[1] + math.random(1,5)/10, mcontroller.position()[2] + math.random(1,10)/10}
		draw.lightning(playerPos, castPos, 1, 0.5, 0, 200, 0.05, color:random(true), "front")
	end
end

function iNF:grenadeStick(projPos, paramTable)
	if paramTable.enId == "empty" then
		local enQuery = world.entityQuery(projPos, self.parameters.grenade.stickRadius, {withoutEntityId = entity.id(), order = "nearest", boundMode = "position", includedTypes = {"player", "monster", "npc", "vehicle"}})[1]
		if enQuery ~= nil then
			paramTable.enId = enQuery
		end
	end
end

function iNF:storm(args, params)
	if args.moves.primaryFire and args.moves["down"] then
		params.storm.timer[1] = math.min(params.storm.timer[1]+args.dt,params.storm.timer[2])
		self:iceStormClouds()
		if params.storm.timer[1] == params.storm.timer[2] then
			local ground = world.lineCollision({tech.aimPosition()[1], mcontroller.yPosition()+params.storm.cloudProj.yDist}, {tech.aimPosition()[1], mcontroller.yPosition()+params.storm.cloudProj.yDist-100}) or {tech.aimPosition()[1], mcontroller.yPosition()+params.storm.cloudProj.yDist-100}
			if params.storm.lightningCooldown[1] == 0 then
				for i=1,2 do
					draw.lightning({tech.aimPosition()[1], mcontroller.yPosition()+params.storm.cloudProj.yDist}, vec2.add(ground,{math.random(-params.storm.inaccuracy, params.storm.inaccuracy),0}), 8, 1, 1, 200, math.random(75,250)/100, color:random(true), "middle")
					params.storm.lightningCooldown[1] = params.storm.lightningCooldown[2]
				end
				util.playShortSound({"/sfx/melee/travelingslash_electric4.ogg","/sfx/melee/travelingslash_electric5.ogg","/sfx/melee/travelingslash_electric6.ogg"}, 1, math.random(12, 15)/10,0)
			end
			if mcontroller.xPosition()+params.storm.currXPos > tech.aimPosition()[1] then
				params.storm.currXPos = math.min(params.storm.currXPos - params.storm.movespeed,-params.storm.range)
			else
				params.storm.currXPos = math.min(params.storm.currXPos + params.storm.movespeed, params.storm.range)
			end
			params.storm.lightningCooldown[1] = math.max(params.storm.lightningCooldown[1]-args.dt,0)
			-- local animator crosshair
		end
	else
		params.storm.timer[1] = 0
		self.parameters.storm.cloudProj.id = nil
		params.storm.lightningCooldown[1] = 0
	end
end

function iNF:iceStormClouds()
	if self.parameters.storm.cloudProj.id == nil then
		self.parameters.storm.cloudProj.id = world.spawnProjectile("boltguide", vec2.add(mcontroller.position(), {0,self.parameters.storm.cloudProj.yDist}), entity.id(), {0,0},true, {
			movementSettings = {mass = math.huge, collisionPoly = jarray(), physicsEffectCategories = jarray(), collisionEnabled = false},
			processing = "?scale=0",
			persistentAudio = "/sfx/weather/blizzard.ogg",
			periodicActions = {
				{
					action = "particle",
					time = 0.01,
					specification = {
						type = "animated",
						animation = "/animations/groundmist/groundmist.animation?multiply=000000",
						fullbright =true,
						layer = "front",
						destructionAction = "fade",
						timeToLive = 5,
						position = {0,0},
						destructionTime = 4,
						initialVelocity = {0,0},
						size = 2,
						variance = {
							angularVelocity = 60,
							position = {self.parameters.storm.range/2,5},
							initialVelocity = {3,1}
						}
					}
				},
				{
					action = "particle",
					time = 0.05,
					specification = {
						type = "ember",
						color = {212, 219, 247},
						velocity = {0, -12},
						angularVelocity = 0,
						timeToLive = 20,
						size = 1,
						collidesForeground = true,
						collidesLiquid = true,
						ignoreWind = false,
						variance = {
							position = {self.parameters.storm.range/2,5}
						}
					}
				},
				{
					action = "particle",
					time = 0.05,
					specification = {
						type = "ember",
						color = {239, 242, 254},
						velocity = {0, -11},
						angularVelocity = 0,
						timeToLive = 20,
						size = 1,
						collidesForeground = true,
						collidesLiquid = true,
						ignoreWind = false,
						variance = {
							position = {self.parameters.storm.range/2,5}
						}
					}
				},
				{
					action = "particle",
					time = 0.05,
					specification = {
						type = "ember",
						color = {246, 250, 250},
						velocity = {0, -14},
						angularVelocity = 0,
						timeToLive = 20,
						size = 1,
						collidesForeground = true,
						collidesLiquid = true,
						ignoreWind = false,
						variance = {
							position = {self.parameters.storm.range/2,5}
						}
					}
				},
				{
					action = "particle",
					time = 0.1,
					specification = {
						type = "textured",
						image = "/particles/fog/1.png",
						velocity = {0, -15},
						approach = {15,15},
						angularVelocity = 0,
						timeToLive = 20,
						collidesForeground = true,
						collidesLiquid = true,
						ignoreWind = false,
						variance = {
							position = {self.parameters.storm.range/2,5},
							velocity = {3, 0}
						}
					}
				}
			}
		})
	else
		world.callScriptedEntity(self.parameters.storm.cloudProj.id, "mcontroller.setPosition", {mcontroller.position()[1], mcontroller.position()[2]+self.parameters.storm.cloudProj.yDist})
		world.callScriptedEntity(self.parameters.storm.cloudProj.id, "projectile.setTimeToLive", 1)
	end
end

function iNF:passiveEffect(params)
	if math.random(1,100) >= 100-params.passive.chance then
		draw.lightning(vec2.add(mcontroller.position(), {math.random(-params.passive.range[1],params.passive.range[1]), math.random(-params.passive.range[2],params.passive.range[2])}), vec2.add(mcontroller.position(), {math.random(-params.passive.range[1],params.passive.range[1]), math.random(-params.passive.range[2],params.passive.range[2])}), 1, 0.15, 0, 200, 0.05, color:random(true), "front")
	end 
end

function iNF:rocket(args, params)
	params.rocket.cooldown[1] = math.max(params.rocket.cooldown[1]-args.dt, 0)
	local castPos = util.trig(mcontroller.position(), params.castRadius, aimAngle())
	if args.moves.altFire and not args.moves.primaryFire and params.rocket.cooldown[1] == 0 then
		params.rocket.cooldown[1] = params.rocket.cooldown[2]
		local aimAng = aimAngle()
		local rocketID = world.spawnProjectile("boltguide", castPos, entity.id(), {math.cos(aimAng), math.sin(aimAng)}, false, {speed = world.magnitude(mcontroller.position(), tech.aimPosition()), periodicActions = params.rocket.shape, processing = "?scale=0"})
		params.rocket.t[tostring(rocketID)] = {timeToLive = params.rocket.timeToLive}
		self:handCast()
		util.playShortSound({"/sfx/gun/grenadeblast_small_electric2.ogg"}, 1,1,0)
	end
	for id, t in pairs(params.rocket.t) do
		local projPos = world.entityPosition(id)
		if projPos ~= nil then
			if t.timeToLive > 0 then
				t.timeToLive = math.max(t.timeToLive-args.dt, 0)
				world.callScriptedEntity(id, "projectile.setTimeToLive",1)
			else
				local projVelocity = world.callScriptedEntity(id, "mcontroller.velocity")
				local velocityAngle = vec2.angle(projVelocity, {0,0})
				table.insert(params.rocket.miniRocket.t,self:spawnMiniRockets(projPos, velocityAngle, params))
				draw.lightning(projPos, util.trig(projPos,world.magnitude({0,0}, projVelocity), math.deg(velocityAngle)), 3, 1, 0, 200, 2, color:random(true), "front")
				util.playShortSound({"/sfx/gun/omnicannon_shot2.ogg"}, 1,1.75,0)
				world.callScriptedEntity(id, "projectile.die")
				params.rocket.t[id] = nil
			end
		end
	end
end

function iNF:spawnMiniRockets(pos, angle, params)
	local sequence = {
		idTable = {},
		timeToLive = params.rocket.miniRocket.timeToLive,
		target = "empty"
	}
	for i=1, params.rocket.fork do
		local angleRandom = math.rad(math.deg(angle)+math.random(-params.rocket.miniRocket.forkAngle, params.rocket.miniRocket.forkAngle))
		local id = world.spawnProjectile("boltguide", pos, entity.id(), {math.cos(angleRandom), math.sin(angleRandom)}, false, {speed = params.rocket.miniRocket.initialVelocity})
		table.insert(sequence.idTable, id)
	end
	return sequence
end

function iNF:miniRockets(args,params)
	for i, sequence in ipairs(params.rocket.miniRocket.t) do
		sequence.timeToLive = math.max(sequence.timeToLive-args.dt, 0)
		for j, miniRocket in ipairs(sequence.idTable) do
			local projPos = world.entityPosition(miniRocket)
			if projPos ~= nil then
				if sequence.timeToLive > 0 then
					world.callScriptedEntity(miniRocket, "projectile.setTimeToLive", math.random(5, 15)/10)
					if sequence.target == "empty" then
						local enQuery = world.entityQuery(projPos, params.rocket.miniRocket.seekRadius, {withoutEntityId=entity.id(), order="nearest",includedTypes = {"player", "monster", "npc"}})[1]
						if enQuery ~= nil then
							sequence.target = enQuery
						end
					else
						local targetPos = world.entityPosition(sequence.target)
						if targetPos ~= nil then
							sequence.timeToLive = 1
							local dist = world.magnitude(projPos, targetPos)
							if dist > params.rocket.miniRocket.explosionThreshold then
								local targetVelocity = {math.ceil(world.distance(targetPos, projPos)[1]*params.rocket.miniRocket.multiplier), math.ceil(world.distance(targetPos, projPos)[2]*params.rocket.miniRocket.multiplier)}
								world.callScriptedEntity(miniRocket, "mcontroller.approachVelocity", targetVelocity, params.rocket.miniRocket.controlForce)
							else
								local randomAngleOffset = math.random(360)
								draw.lightning(projPos, mcontroller.position(), 3, 1, 0, 200, 1, color:random(true), "front")
								util.playShortSound({"/sfx/melee/travelingslash_electric2.ogg"}, 1.5, math.random(8, 11)/10, 0)
								world.callScriptedEntity(miniRocket, "projectile.die")
								table.remove(params.rocket.miniRocket.t[i].idTable, j)
							end
						end
					end
				else
					table.remove(params.rocket.miniRocket.t,i)
				end
			else
				table.remove(params.rocket.miniRocket.t[i].idTable, j)
			end
		end
		if #sequence.idTable == 0 then
			table.remove(params.rocket.miniRocket.t,i)
		end
	end
end

function iNF:shield(args, params)

end