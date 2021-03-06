require "/scripts/util.lua"
require "/scripts/vec2.lua"

function init()
  self.spawnTimer = config.getParameter("spawnDelay")

  message.setHandler("updateProjectile", function(_, sameClient, aimPosition)
      if sameClient then
        self.aimPosition = aimPosition
        if self.secondaryProjectile then
          local res = {entity.id(), self.secondaryProjectile}
          self.secondaryProjectile = nil
          return res
        else
          return entity.id()
        end
      end
    end)

  message.setHandler("INSERTHANDLERHERE", function(_,sameClient,_)
      if sameClient then
        projectile.die()
      end
    end)
end

function update(dt)
  if self.spawnTimer > 0 then
    self.spawnTimer = math.max(0, self.spawnTimer - dt)
    if self.spawnTimer == 0 then
      local params = config.getParameter("spawnParams", {})
      params.power = projectile.power()
      params.powerMultiplier = projectile.powerMultiplier()

      self.secondaryProjectile = world.spawnProjectile(
        config.getParameter("spawnProjectile"),
        mcontroller.position(),
        projectile.sourceEntity(),
        {0, 0},
        false,
        params
      )
    end
  end
end
