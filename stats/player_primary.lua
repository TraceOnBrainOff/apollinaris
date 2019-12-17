playerPrimary = {}
require "/scripts/status.lua"
require "/scripts/achievements.lua"

function init()
	self.lastYPosition = 0
	self.lastYVelocity = 0
	self.fallDistance = 0
	self.hitInvulnerabilityTime = 0
	self.shieldHitInvulnerabilityTime = 0
	self.suffocateSoundTimer = 0

	playerPrimary.setOuchNoise()

	self.inflictedDamage = damageListener("inflictedDamage", inflictedDamageCallback)

	message.setHandler("applyStatusEffect", function(_, sameClient, effectConfig, duration, sourceEntityId)
        if sameClient then
            status.addEphemeralEffect(effectConfig, duration, sourceEntityId)
        end
	end)
	setAutoHandlers({"playerPrimary"})
end

function inflictedDamageCallback(notifications) -- I can use this for some wacky shit when killing entities!
	for _,notification in ipairs(notifications) do
		if notification.hitType == "Kill" then
			if world.entityExists(notification.targetEntityId) then
				local entityType = world.entityType(notification.targetEntityId)
				local eventFields = entityEventFields(notification.targetEntityId)
				util.mergeTable(eventFields, worldEventFields())
				eventFields.damageSourceKind = notification.damageSourceKind

				if entityType == "object" then
					recordEvent(entity.id(), "killObject", eventFields)

				elseif entityType == "npc" or entityType == "monster" or entityType == "player" then
					recordEvent(entity.id(), "kill", eventFields)
				end
			else
				-- TODO: better method for getting data on killed entities
				sb.logInfo("Skipped event recording for nonexistent entity %s", notification.targetEntityId)
			end
		end
	end
end

function applyDamageRequest(damageRequest) -- Has to return a table as far as I can see
	
	local finalDamageRequest = {
		sourceEntityId = damageRequest.sourceEntityId,
		targetEntityId = entity.id(),
		position = mcontroller.position(),
		damageDealt = damageRequest.damage,
		healthLost = 5,
		hitType = damageRequest.hitType,
		damageSourceKind = damageRequest.damageSourceKind,
		targetMaterialKind = status.statusProperty("targetMaterialKind")
	}
	world.sendEntityMessage(entity.id(), "damageRequest", finalDamageRequest)
	return {}
end

function notifyResourceConsumed(resourceName, amount)
	if resourceName == "energy" and amount > 0 then
		status.setResourcePercentage("energyRegenBlock", 1.0)
	end
end

function update(dt)
	local minimumFallDistance = 14
	local fallDistanceDamageFactor = 3
	local minimumFallVel = 40
	local baseGravity = 80
	local gravityDiffFactor = 1 / 30.0

	local curYPosition = mcontroller.yPosition()
	local yPosChange = curYPosition - (self.lastYPosition or curYPosition)

	if self.fallDistance > minimumFallDistance and -self.lastYVelocity > minimumFallVel and mcontroller.onGround() then
		local damage = (self.fallDistance - minimumFallDistance) * fallDistanceDamageFactor
		damage = damage * (1.0 + (world.gravity(mcontroller.position()) - baseGravity) * gravityDiffFactor)
		damage = damage * status.stat("fallDamageMultiplier")
		status.applySelfDamageRequest({
				damageType = "IgnoresDef",
				damage = damage,
				damageSourceKind = "falling",
				sourceEntityId = entity.id()
			})
	end

	if mcontroller.yVelocity() < -minimumFallVel and not mcontroller.onGround() then
		self.fallDistance = self.fallDistance + -yPosChange
	else
		self.fallDistance = 0
	end

	self.lastYPosition = curYPosition
	self.lastYVelocity = mcontroller.yVelocity()

	local mouthPosition = vec2.add(mcontroller.position(), status.statusProperty("mouthPosition"))
	--[[if status.statPositive("breathProtection") or world.breathable(mouthPosition) then
		status.modifyResource("breath", status.stat("breathRegenerationRate") * dt)
	else
		status.modifyResource("breath", -status.stat("breathDepletionRate") * dt)
	end
	]]

	if not status.resourcePositive("breath") then
		self.suffocateSoundTimer = self.suffocateSoundTimer - dt
		if self.suffocateSoundTimer <= 0 then
			self.suffocateSoundTimer = 0.5 + (0.5 * status.resourcePercentage("health"))
			animator.playSound("suffocate")
		end
		status.modifyResourcePercentage("health", -status.statusProperty("breathHealthPenaltyPercentageRate") * dt)
	else
		self.suffocateSoundTimer = 0
	end

	self.hitInvulnerabilityTime = math.max(self.hitInvulnerabilityTime - dt, 0)
	local flashTime = status.statusProperty("hitInvulnerabilityFlash")

	if self.hitInvulnerabilityTime > 0 then
		if math.fmod(self.hitInvulnerabilityTime, flashTime) > flashTime / 2 then
			status.setPrimaryDirectives(status.statusProperty("damageFlashOffDirectives"))
		else
			status.setPrimaryDirectives(status.statusProperty("damageFlashOnDirectives"))
		end
	else
		status.setPrimaryDirectives()
	end

	if status.resourceLocked("energy") and status.resourcePercentage("energy") == 1 then
		animator.playSound("energyRegenDone")
	end

	if status.resource("energy") == 0 then
		if not status.resourceLocked("energy") then
			animator.playSound("outOfEnergy")
			animator.burstParticleEmitter("outOfEnergy")
		end

		status.setResourceLocked("energy", true)
	elseif status.resourcePercentage("energy") == 1 then
		status.setResourceLocked("energy", false)
	end

	if not status.resourcePositive("energyRegenBlock") then
		status.modifyResourcePercentage("energy", status.stat("energyRegenPercentageRate") * dt)
	end

	self.shieldHitInvulnerabilityTime = math.max(self.shieldHitInvulnerabilityTime - dt, 0)
	if not status.resourcePositive("shieldStaminaRegenBlock") then
		status.modifyResourcePercentage("shieldStamina", status.stat("shieldStaminaRegen") * dt)
		status.modifyResourcePercentage("perfectBlockLimit", status.stat("perfectBlockLimitRegen") * dt)
	end

	self.inflictedDamage:update()

	if mcontroller.atWorldLimit(true) then
		status.setResourcePercentage("health", 0)
	end
end

function overheadBars()
	local bars = {}

	if status.statPositive("shieldHealth") then
		table.insert(bars, {
			percentage = status.resource("shieldStamina"),
			color = status.resourcePositive("perfectBlock") and {255, 255, 200, 255} or {200, 200, 0, 255}
		})
	end

	return bars
end

function setAutoHandlers(t) -- Used to create handlers for usage in the main script
	for i, stringT in ipairs(t) do
		local keyArray = {}
		for key, value in pairs(_ENV[stringT]) do
			table.insert(keyArray, key)
			message.setHandler(stringT.."."..key, function(_, sameClient, args)
				if sameClient then
					if args ~= nil then
						return value(table.unpack(args))
					else
						return value()
					end
				end
			end)
		end
		message.setHandler(stringT.."KeyArrayHandler", function(_, sameClient, _)
			if sameClient then
				return keyArray
			end
		end)
	end
end

function playerPrimary.setOuchNoise()
	local ouchNoise = status.statusProperty("ouchNoise")
	if ouchNoise then
		animator.setSoundPool("ouch", {ouchNoise})
	end
end

