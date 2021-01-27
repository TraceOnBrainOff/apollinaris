require "/scripts/vec2.lua"

function init()
    message.setHandler("applyStatusEffect", function(_, sameClient, effectConfig, duration, sourceEntityId)
        if not sameClient then
            return
        end
        status.addEphemeralEffect(effectConfig, duration, sourceEntityId)
    end)
end

function applyDamageRequest(damageRequest)
  return {}
end

function knockbackMomentum(momentum)
  return {0,0}
end

function update(dt)
  if mcontroller.atWorldLimit(true) then
    status.setResourcePercentage("health", 0)
  end
end