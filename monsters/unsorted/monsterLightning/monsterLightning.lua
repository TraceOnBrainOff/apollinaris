require("/scripts/util.lua")
require("/scripts/vec2.lua")

monsterAnimator = {}

lightning = {}

function monsterAnimator.clearLightning()
    lightning = {}
    monster.setAnimationParameter("lightning", lightning)
end

function monsterAnimator.addLightning(new_lightning)
    table.insert(lightning, new_lightning)
    --sb.logInfo(util.tableToString(chain))
    monster.setAnimationParameter("lightning", lightning)
end

function init()
    monster.setAnimationParameter("lightning", lightning)
    setAutoHandlers({"monsterAnimator"})
end

function update(dt)
    --sb.logInfo(util.tableToString(chains))
end

function uninit()

end

function setAutoHandlers(t)
	for i, stringT in ipairs(t) do
		local keyArray = {}
		for key, value in pairs(_ENV[stringT]) do
            table.insert(keyArray, key)
			message.setHandler(stringT.."."..key, function(_, sameClient, ...)
				if sameClient then
					value(...)
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