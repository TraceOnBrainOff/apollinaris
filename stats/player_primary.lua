require "/scripts/status.lua"
require "/scripts/achievements.lua"

function init()
	lastYPosition = 0
	lastYVelocity = 0
	fallDistance = 0
	hitInvulnerabilityTime = 0
	shieldHitInvulnerabilityTime = 0
	suffocateSoundTimer = 0
	ouchCooldown = 0

	local ouchNoise = status.statusProperty("ouchNoise")
	if ouchNoise then
		animator.setSoundPool("ouch", {ouchNoise})
	end

	inflictedDamage = damageListener("inflictedDamage", inflictedDamageCallback)

	message.setHandler("applyStatusEffect", function(_, sameClient, effectConfig, duration, sourceEntityId)
		status.addEphemeralEffect(effectConfig, duration, sourceEntityId)
	end)
end

function inflictedDamageCallback(notifications)
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

function applyDamageRequest(damageRequest)
	if world.getProperty("invinciblePlayers") then
		return {}
	end

	local hitInvulnerability = hitInvulnerabilityTime > 0 and damageRequest.damageSourceKind ~= "applystatus"
	if damageRequest.damageSourceKind ~= "falling" and (hitInvulnerability or world.getProperty("nonCombat")) then
		return {}
	end
	
	if world.sendEntityMessage(entity.id(), "player_primary_handshake"):result() == true then
		damageRequest = world.sendEntityMessage(entity.id(), "damageRequest", damageRequest):result()
	end

	status.addEphemeralEffects(damageRequest.statusEffects, damageRequest.sourceEntityId)
	if damageRequest.damageSourceKind == "applystatus" then
		return {}
	end

	local damage = 0
	if damageRequest.damageType == "Damage" or damageRequest.damageType == "Knockback" then
		damage = damage + root.evalFunction2("protection", damageRequest.damage, status.stat("protection"))
	elseif damageRequest.damageType == "IgnoresDef" or damageRequest.damageType == "Environment" then
		damage = damage + damageRequest.damage
	elseif damageRequest.damageType == "Status" then
		-- only apply status effects
		status.addEphemeralEffects(damageRequest.statusEffects, damageRequest.sourceEntityId)
		return {}
	end

	if status.resourcePositive("damageAbsorption") then
		local damageAbsorb = math.min(damage, status.resource("damageAbsorption"))
		status.modifyResource("damageAbsorption", -damageAbsorb)
		damage = damage - damageAbsorb
	end

	if damageRequest.hitType == "ShieldHit" then
		if shieldHitInvulnerabilityTime == 0 then
			local preShieldDamageHealthPercentage = damage / status.resourceMax("health")
			shieldHitInvulnerabilityTime = status.statusProperty("shieldHitInvulnerabilityTime") * math.min(preShieldDamageHealthPercentage, 1.0)

			if not status.resourcePositive("perfectBlock") then
				status.modifyResource("shieldStamina", -damage / status.stat("shieldHealth"))
			end
		end

		status.setResourcePercentage("shieldStaminaRegenBlock", 1.0)
		damage = 0
		damageRequest.statusEffects = {}
		damageRequest.damageSourceKind = "shield"
	end

	local elementalStat = root.elementalResistance(damageRequest.damageSourceKind)
	local resistance = status.stat(elementalStat)
	damage = damage - (resistance * damage)

	local healthLost = math.min(damage, status.resource("health"))
	if healthLost > 0 and damageRequest.damageType ~= "Knockback" then
		status.modifyResource("health", -healthLost)
		if ouchCooldown <= 0 then
			animator.playSound("ouch")
			ouchCooldown = 0.5
		end

		local damageHealthPercentage = damage / status.resourceMax("health")
		if damageHealthPercentage > status.statusProperty("hitInvulnerabilityThreshold") then
			hitInvulnerabilityTime = status.statusProperty("hitInvulnerabilityTime")
		end
	end

	local knockbackFactor = (1 - status.stat("grit"))

	local knockbackMomentum = vec2.mul(damageRequest.knockbackMomentum, knockbackFactor)
	local knockback = vec2.mag(knockbackMomentum)
	if knockback > status.stat("knockbackThreshold") then
		mcontroller.setVelocity({0,0})
		local dir = knockbackMomentum[1] > 0 and 1 or -1
		mcontroller.addMomentum({dir * knockback / 1.41, knockback / 1.41})
	end

	local hitType = damageRequest.hitType
	if not status.resourcePositive("health") then
		hitType = "kill"
	end
	return {{
		sourceEntityId = damageRequest.sourceEntityId,
		targetEntityId = entity.id(),
		position = mcontroller.position(),
		damageDealt = damage,
		healthLost = healthLost,
		hitType = hitType,
		damageSourceKind = damageRequest.damageSourceKind,
		targetMaterialKind = status.statusProperty("targetMaterialKind")
	}}
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
	local yPosChange = curYPosition - (lastYPosition or curYPosition)

	ouchCooldown = math.max(0.0, ouchCooldown - dt)

	if fallDistance > minimumFallDistance and -lastYVelocity > minimumFallVel and mcontroller.onGround() then
		local damage = (fallDistance - minimumFallDistance) * fallDistanceDamageFactor
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
		fallDistance = fallDistance + -yPosChange
	else
		fallDistance = 0
	end

	lastYPosition = curYPosition
	lastYVelocity = mcontroller.yVelocity()

	local mouthPosition = vec2.add(mcontroller.position(), status.statusProperty("mouthPosition"))
	if status.statPositive("breathProtection") or world.breathable(mouthPosition) then
		status.modifyResource("breath", status.stat("breathRegenerationRate") * dt)
	else
		status.modifyResource("breath", -status.stat("breathDepletionRate") * dt)
	end

	if not status.resourcePositive("breath") then
		suffocateSoundTimer = suffocateSoundTimer - dt
		if suffocateSoundTimer <= 0 then
			suffocateSoundTimer = 0.5 + (0.5 * status.resourcePercentage("health"))
			animator.playSound("suffocate")
		end
		status.modifyResourcePercentage("health", -status.statusProperty("breathHealthPenaltyPercentageRate") * dt)
	else
		suffocateSoundTimer = 0
	end

	hitInvulnerabilityTime = math.max(hitInvulnerabilityTime - dt, 0)
	local flashTime = status.statusProperty("hitInvulnerabilityFlash")

	if hitInvulnerabilityTime > 0 then
		if math.fmod(hitInvulnerabilityTime, flashTime) > flashTime / 2 then
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

	shieldHitInvulnerabilityTime = math.max(shieldHitInvulnerabilityTime - dt, 0)
	if not status.resourcePositive("shieldStaminaRegenBlock") then
		status.modifyResourcePercentage("shieldStamina", status.stat("shieldStaminaRegen") * dt)
		status.modifyResourcePercentage("perfectBlockLimit", status.stat("perfectBlockLimitRegen") * dt)
	end

	inflictedDamage:update()

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
