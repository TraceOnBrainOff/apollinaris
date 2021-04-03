local sGS = newAbility()
TEMP_HOLDER = sGS --Required for the engine to load the skill into memory due to starbound's shitty require(). Lack of this declare will crash it.

function sGS:assign()
	local self = {}
    setmetatable(self, sGS)
    return self
end

function sGS:init()
    self.parameters = {
		windupStreaks = {
			outerRange = 20,
			innerRange = 1,
			length = 3,
			size = 1.5,
			lengthVariation = 3
		}
	}
	self.targetPosition = util.trig(mcontroller.position(), self.metadata.settings.dashRange, aimAngle())
	self.coroutines = {self.dashStage, self.attackStage}
	self.coroutine = coroutine.create(self.coroutines[1])
	self.metadata.settings.persistent = false --hard reset it as it's a mutable variable in this instance (pose is cancellable)
end

function sGS:coroutineCallback(index)
	if index > #self.coroutines then
		self:stop()
		return
	end
	self.coroutine = coroutine.create(self.coroutines[index])
end

function sGS:stop()
	tech.setParentHidden(false)
	if self.monsterAnimator then
		self.monsterAnimator:kill()
	end
	if self.pose_projectile then
		self.pose_projectile:callScriptedEntity("projectile.setTimeToLive", 0)
	end
	tech.setParentState()
	self.pose_projectile = nil
	self.monsterAnimator = nil
	self.after_images = nil
end

function sGS:dashStage()
	util.playShortSound({"/sfx/melee/charge_up6.ogg"}, 2, math.random(18, 22)/10, 0)
	for i=1, self.metadata.settings.timings.chargeUp do
		self:spawnWindupStreak(self.metadata.settings.timings.chargeUp-i)
		mcontroller.setVelocity({0,0})
		coroutine.yield()
	end

	self:weebyLetters()
	util.playShortSound({"/sfx/instruments/nylonguitar/a7.ogg"}, 3, 1.05, 0)
	util.playShortSound({"/sfx/instruments/nylonguitar/a6.ogg"}, 3, 1.05, 0)

	for i=1, self.metadata.settings.timings.letters do --all this here actually does is wait out the letters animation
		mcontroller.setVelocity({0,0})
		coroutine.yield()
	end

	self.startingPosition = mcontroller.position()
	util.playShortSound({"/sfx/tech/tech_rocketboots_thrust2.ogg"}, 2, 0.65, 0)
	tech.setParentState("fly")
	self:computeAfterimages()
	for i=1, self.metadata.settings.timings.dash do --dash
		local x = easing[self.metadata.settings.easing](i, self.startingPosition[1], self.targetPosition[1]-self.startingPosition[1], self.metadata.settings.timings.dash)
		local y = easing[self.metadata.settings.easing](i, self.startingPosition[2], self.targetPosition[2]-self.startingPosition[2], self.metadata.settings.timings.dash)
		mcontroller.setPosition({x,y})
		mcontroller.setVelocity({0,0})
		self.after_images:keepProjectileAlive()
		mcontroller.controlFace(util.toDirection(self.targetPosition[1]-self.startingPosition[1]))
		local targetId = world.entityQuery(mcontroller.position(), self.metadata.settings.queryRange, {withoutEntityId = entity.id(), boundMode = "position", includedTypes = {"monster", "npc", "vehicle", "player"}})[1]
		if targetId then
			self.targetId = targetId
			self:coroutineCallback(2)
			return
		end
		coroutine.yield()
	end
	self:coroutineCallback(3)--insta stops the ability
	return
end

function sGS:attackStage()
	tech.setParentHidden(true)
	tech.setParentState()
	self:spawnBlackScreen()
	local hit_specification_copy = copy(self.metadata.settings.hitParticleSpecification)
	hit_specification_copy.animation = string.format("/animations/1hswordhitspark/1hswordhitspark.animation?brightness=20?border=1;%s80;%s00", color:hex(1), color:hex(3))
	local projectile = ParticleSpawner:new() -- contains the lightning and punch particles predefined that happen during periodic actions
	for i, keyframe in ipairs(self.metadata.settings.attackKeyframes) do --pre-defines the projecitle
		local endPosition = util.trig({0,0}, i/2, math.rad(math.random(360)), self.metadata.settings.positionTrigRatio) --random polar coordinates
		local new_bolts = ParticleSpawner.lightningActions( --lightning trail from one spot to another
			self.last_bolt_position or mcontroller.position(), 
			endPosition, 
			4, --displacement
			1, --min displacement
			0, --forks
			math.pi/4, --forkanglerange
			1, 
			color:rgb(6), --can add overrides down below
			self.metadata.settings.lightningOverrides
		)
		hit_specification_copy.size = math.max(3,i/5)
		hit_specification_copy.position = endPosition
		sb.logInfo(util.tableToString(endPosition))
		projectile:addParticle(copy(hit_specification_copy), keyframe/60, false)
		util.each(new_bolts, function(i,action) projectile:addParticle(action, keyframe/60, false) end)
		self.last_bolt_position = endPosition
	end

	projectile:spawnProjectile(mcontroller.position(), {0,0})
	for i=0, self.metadata.settings.attackKeyframes[#self.metadata.settings.attackKeyframes]+1 do --blackscreen + attack. idk if it needs to be +1 ticks to make sure the last one renders
		if self.targetId and world.entityExists(self.targetId) then--add sounds i guess
			if util.count(self.metadata.settings.attackKeyframes,i)>0 then --pretty much check if it's inside the table
				util.playShortSound({"/sfx/interface/playerstation_place1.ogg"}, 2, 0.85, 0)
			end
			mcontroller.setPosition(world.entityPosition(self.targetId))
			projectile:keepProjectileAlive()
			projectile:callScriptedEntity("mcontroller.setPosition", mcontroller.position())
		else
			break
		end
		coroutine.yield()
	end
	self.monsterAnimator:clearChains()
	self.monsterAnimator:kill()

	util.playShortSound({"/sfx/gun/reload/rocket_reload_clip3.ogg"}, 2, 1.4, 0)
	mcontroller.controlFace(-util.toDirection(self.lastPosition[1]-self.startingPosition[1]))
	mcontroller.setPosition(vec2.add(self.lastPosition, {-self.metadata.settings.postAttackBlinkDist*mcontroller.facingDirection(),2}))
	self.lastPosition = mcontroller.position() --gotta update it here
	util.playShortSound({"/sfx/instruments/nylonguitar/a7.ogg"}, 4, 1.25, 0)
	util.playShortSound({"/sfx/instruments/nylonguitar/a6.ogg"}, 4, 1.25, 0)
	util.playShortSound({"/sfx/cinematics/opengate/opengate_blast.ogg"}, 2, 1.05, 0)
	crash(self.targetId)
	tech.setParentHidden(false)

	self.metadata.settings.persistent = true
	self:spawnPoseProjectile()
	for i=1, self.metadata.settings.timings.pose do
		self.pose_projectile:keepProjectileAlive()
		self.pose_projectile:callScriptedEntity("mcontroller.setPosition", mcontroller.position())
		mcontroller.setPosition(self.lastPosition)
		mcontroller.setVelocity({0,0})
		coroutine.yield()
	end
	self:stop()
end

function sGS:update(args)
	if coroutine.status(self.coroutine)~="dead" then
		coroutine.update(self.coroutine, self, args)
		self.lastPosition = mcontroller.position()
	end
end

function sGS:uninit()

end

function sGS:spawnPoseProjectile()
	local pose_projectile = ParticleSpawner:new()
	local sign = copy(self.metadata.settings.poseParticleSpecification)
	pose_projectile:addParticle(sign, 0, true)

	local particle_angle_range = 2*math.pi/self.metadata.settings.LSD_particle_density
	for i=1, self.metadata.settings.LSD_particle_density do
        local particle_list = {}
		util.each(color:rgb(), function(j,rgb_color)
		table.insert(particle_list,
			ParticleSpawner.createParticle( 
				ParticleSpawner.LSDAction(
					sign.position,
					{0,0}, 
					util.trig({0,0}, self.metadata.settings.LSD_particle_len, particle_angle_range*i),
					self.metadata.settings.LSD_particle_mul,
					rgb_color,
					5,
					self.metadata.settings.LSD_particle_override
				),
				j*5/60, 
				false
			)
		)
		end)
		pose_projectile:addLoopAction(particle_list, #color:rgb()/60, true, 10)
	end
	
	pose_projectile:spawnProjectile(mcontroller.position(), {0,0})
	self.pose_projectile = pose_projectile
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
					    timeToLive = self.metadata.settings.timings.letters/60,
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

function sGS:computeAfterimages()
	local after_images = ParticleSpawner:new()
	local portrait_actions = ParticleSpawner.entityPortraitActions(util.toDirection(self.targetPosition[1]-self.startingPosition[1])==-1, color:hex(1))
	local gradient = util.map(color:gradient(self.metadata.settings.timings.dash), function(rgb_color) return Color.rgb2hex(rgb_color) end)
	for tick=1, self.metadata.settings.timings.dash do
		local local_copy = copy(portrait_actions)
		local x = easing[self.metadata.settings.easing](tick, 0, self.targetPosition[1]-self.startingPosition[1], self.metadata.settings.timings.dash)
		local y = easing[self.metadata.settings.easing](tick, 0, self.targetPosition[2]-self.startingPosition[2], self.metadata.settings.timings.dash)
		local prev_x = tick ~= 1 and easing[self.metadata.settings.easing](tick-1, 0, self.targetPosition[1]-self.startingPosition[1], self.metadata.settings.timings.dash) or nil
		local prev_y = tick ~= 1 and easing[self.metadata.settings.easing](tick-1, 0, self.targetPosition[2]-self.startingPosition[2], self.metadata.settings.timings.dash) or nil
		util.each(local_copy, function(i, action) 
			action.position = vec2.add(action.position, {x,y})
			action.image = action.image.."?setcolor="..gradient[tick]
			action.timeToLive = 0.1
			action.destructionTime = 0.3
			after_images:addParticle(action, tick/60, false)
		end)
		after_images:addParticle(ParticleSpawner.lineAction(
			prev_x and {prev_x, prev_y+self.metadata.settings.eyeTrailVerticalOffset} or {0,self.metadata.settings.eyeTrailVerticalOffset},
			{x,y+self.metadata.settings.eyeTrailVerticalOffset},
			color:rgb(1),
			2.5,
			self.metadata.settings.eyeTrailOverrides
		), tick/60, false)
	end
	after_images:spawnProjectile(mcontroller.position(), {0,0})
	self.after_images = after_images
end

function sGS:spawnBlackScreen()
	self.monsterAnimator = MonsterChain:new()
	local new_chain = {
		startPosition = mcontroller.position(),
		endPosition = vec2.add(mcontroller.position(), {0.125, 0})
	}
	self.monsterAnimator:drawChain(util.mergeTable(self.metadata.settings.blackScreenChain, new_chain)) --make the screen go black
end