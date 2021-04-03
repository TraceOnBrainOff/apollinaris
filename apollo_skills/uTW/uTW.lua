local uTW = newAbility()
TEMP_HOLDER = uTW --REQUIRED PLEASE DON'T TOUCH

function uTW:assign()
    local self = {}
    setmetatable(self, uTW)
    return self
end

function uTW:init()
    self.parameters = {
        general = {},
        bladeImg = "/assetMissing.png?setcolor=ffffff?replace;00000000=ffffff;ffffff00=ffffff?setcolor=ffffff?scalenearest=1?crop=0;0;53;16?blendmult=/objects/outpost/customsign/signplaceholder.png;0;0?replace;11000801=472B13FF;12000801=472B13FF;13000501=555555FF;13000601=151515FF;13000701=151515FF;13000801=151515FF;14000501=555555FF;14000601=838383FF;14000701=838383FF;14000801=838383FF;15000601=555555FF;15000701=555555FF;15000801=555555FF;16000701=6F2919FF;16000801=E0975CFF;17000701=6F2919FF;17000801=E0975CFF;18000701=6F2919FF;18000801=E0975CFF;19000701=6F2919FF;19000801=E0975CFF;20000601=6F2919FF;20000701=E0975CFF;20000801=E0975CFF;21000601=6F2919FF;21000701=E0975CFF;21000801=A85636FF;22000601=6F2919FF;22000701=E0975CFF;22000801=A85636FF;23000601=6F2919FF;23000701=E0975CFF;23000801=A85636FF;24000501=6F2919FF;24000601=E0975CFF;24000701=E0975CFF;24000801=A85636FF;25000501=6F2919FF;25000601=E0975CFF;25000701=A85636FF;25000801=FFCA8AFF;26000501=6F2919FF;26000601=E0975CFF;26000701=A85636FF;26000801=FFCA8AFF;27000501=6F2919FF;27000601=E0975CFF;27000701=A85636FF;27000801=A85636FF;28000401=6F2919FF;28000501=E0975CFF;28000601=E0975CFF;28000701=A85636FF;28000801=FFCA8AFF;29000401=6F2919FF;29000501=E0975CFF;29000601=A85636FF;29000701=FFCA8AFF;29000801=FFCA8AFF;30000401=6F2919FF;30000501=E0975CFF;30000601=A85636FF;30000701=FFCA8AFF;30000801=FFCA8AFF;31000401=6F2919FF;31000501=E0975CFF;31000601=A85636FF;31000701=FFCA8AFF;31000801=FFCA8AFF;32000301=6F2919FF;32000401=E0975CFF;32000501=E0975CFF;32000601=A85636FF;32000701=A85636FF;32000801=FFCA8AFF?fade;80ff80;0.0001518?blendmult=/objects/outpost/customsign/signplaceholder.png;0;-8?replace;01000201=555555FF;01000301=151515FF;01000401=151515FF;02000101=555555FF;02000201=838383FF;02000301=151515FF;03000101=555555FF;03000201=838383FF;03000301=555555FF;04000101=555555FF;04000201=838383FF;04000301=838383FF;04000401=151515FF;05000101=555555FF;05000201=838383FF;05000301=838383FF;05000401=151515FF;06000201=472B13FF;06000301=754C23FF;06000401=472B13FF;07000201=754C23FF;07000301=B0885FFF;07000401=472B13FF;08000101=754C23FF;08000201=B0885FFF;08000301=754C23FF;08000401=472B13FF;09000101=754C23FF;09000201=B0885FFF;09000301=472B13FF;10000101=754C23FF;10000201=B0885FFF;10000301=472B13FF;11000101=754C23FF;11000201=754C23FF;11000301=472B13FF;12000101=151515FF;12000201=151515FF;12000301=151515FF;12000401=151515FF;12000501=151515FF;12000601=151515FF;13000101=838383FF;13000201=838383FF;13000301=838383FF;13000401=838383FF;13000501=838383FF;13000601=838383FF;13000701=555555FF;14000101=838383FF;14000201=838383FF;14000301=838383FF;14000401=838383FF;14000501=838383FF;14000601=555555FF;14000701=555555FF;15000101=838383FF;15000201=838383FF;15000301=838383FF;15000401=838383FF;15000501=151515FF;16000101=555555FF;16000201=555555FF;16000301=838383FF;16000401=838383FF;16000501=838383FF;16000601=151515FF;17000101=A85636FF;17000201=E0975CFF;17000301=555555FF;17000401=555555FF;17000501=838383FF;17000601=838383FF;17000701=555555FF;18000101=A85636FF;18000201=FFCA8AFF;18000301=E0975CFF;18000401=6F2919FF;18000501=555555FF;18000601=555555FF;18000701=555555FF;19000101=A85636FF;19000201=FFCA8AFF;19000301=6F2919FF;20000101=A85636FF;20000201=FFCA8AFF;20000301=6F2919FF;21000101=FFCA8AFF;21000201=FFCA8AFF;21000301=A85636FF;22000101=FFCA8AFF;22000201=A85636FF;23000101=FFCA8AFF;23000201=A85636FF;24000101=FFCA8AFF;24000201=A85636FF;25000101=FFCA8AFF;25000201=FFCA8AFF;25000301=A85636FF;26000101=FFCA8AFF;26000201=FFCA8AFF;26000301=A85636FF;27000101=FFCA8AFF;27000201=FFCA8AFF;27000301=A85636FF;27000401=A85636FF;28000101=FFCA8AFF;28000201=E0975CFF;28000301=E0975CFF;28000401=A85636FF;29000101=FFCA8AFF;29000201=6F2919FF;29000301=6F2919FF;30000101=FFCA8AFF;30000201=6F2919FF;30000301=A85636FF;30000401=6F2919FF;31000101=FFCA8AFF;31000201=6F2919FF;31000301=A85636FF;31000401=A85636FF;31000501=6F2919FF;32000101=FFCA8AFF;32000201=FFCA8AFF;32000301=6F2919FF;32000401=6F2919FF;32000501=6F2919FF?fade;80ff80;0.0001518?blendmult=/objects/outpost/customsign/signplaceholder.png;-32;0?replace;01000301=6F2919FF;01000401=E0975CFF;01000501=A85636FF;01000601=FFCA8AFF;01000701=FFCA8AFF;01000801=A85636FF;02000301=6F2919FF;02000401=E0975CFF;02000501=A85636FF;02000601=FFCA8AFF;02000701=FFCA8AFF;02000801=FFCA8AFF;03000201=6F2919FF;03000301=E0975CFF;03000401=E0975CFF;03000501=A85636FF;03000601=FFCA8AFF;03000701=FFCA8AFF;03000801=FFCA8AFF;04000101=6F2919FF;04000201=E0975CFF;04000301=E0975CFF;04000401=E0975CFF;04000501=A85636FF;04000601=FFCA8AFF;04000701=FFCA8AFF;04000801=FFCA8AFF;05000101=6F2919FF;05000201=E0975CFF;05000301=E0975CFF;05000401=A85636FF;05000501=FFCA8AFF;05000601=A85636FF;05000701=FFCA8AFF;05000801=FFCA8AFF;06000101=6F2919FF;06000201=E0975CFF;06000301=E0975CFF;06000401=A85636FF;06000501=FFCA8AFF;06000601=FFCA8AFF;06000701=A85636FF;06000801=FFCA8AFF;07000101=6F2919FF;07000201=E0975CFF;07000301=E0975CFF;07000401=A85636FF;07000501=FFCA8AFF;07000601=FFCA8AFF;07000701=FFCA8AFF;07000801=FFCA8AFF;08000101=6F2919FF;08000201=E0975CFF;08000301=E0975CFF;08000401=A85636FF;08000501=FFCA8AFF;08000601=FFCA8AFF;08000701=FFCA8AFF;08000801=FFCA8AFF;09000101=6F2919FF;09000201=E0975CFF;09000301=E0975CFF;09000401=E0975CFF;09000501=A85636FF;09000601=FFCA8AFF;09000701=A85636FF;09000801=A85636FF;10000201=6F2919FF;10000301=E0975CFF;10000401=E0975CFF;10000501=A85636FF;10000601=FFCA8AFF;10000701=A85636FF;10000801=6F2919FF;11000201=6F2919FF;11000301=E0975CFF;11000401=E0975CFF;11000501=A85636FF;11000601=FFCA8AFF;11000701=FFCA8AFF;11000801=A85636FF;12000201=6F2919FF;12000301=E0975CFF;12000401=E0975CFF;12000501=E0975CFF;12000601=A85636FF;12000701=FFCA8AFF;12000801=A85636FF;13000301=6F2919FF;13000401=E0975CFF;13000501=E0975CFF;13000601=A85636FF;13000701=FFCA8AFF;13000801=A85636FF;14000401=6F2919FF;14000501=E0975CFF;14000601=A85636FF;14000701=FFCA8AFF;14000801=FFCA8AFF;15000401=A85636FF;15000501=E0975CFF;15000601=E0975CFF;15000701=A85636FF;15000801=FFCA8AFF;16000501=6F2919FF;16000601=E0975CFF;16000701=E0975CFF;16000801=FFCA8AFF;17000601=A85636FF;17000701=E0975CFF;17000801=FFCA8AFF;18000701=A85636FF;18000801=E0975CFF;19000701=A85636FF;19000801=E0975CFF;20000801=A85636FF?fade;80ff80;0.0001518?blendmult=/objects/outpost/customsign/signplaceholder.png;-32;-8?replace;01000101=A85636FF;01000201=FFCA8AFF;01000301=FFCA8AFF;01000401=A85636FF;02000101=FFCA8AFF;02000201=FFCA8AFF;02000301=FFCA8AFF;02000401=FFCA8AFF;02000501=A85636FF;03000101=6F2919FF;03000201=6F2919FF;03000301=FFCA8AFF;03000401=E0975CFF;03000501=E0975CFF;03000601=A85636FF;04000101=6F2919FF;04000201=A85636FF;04000301=6F2919FF;04000401=A85636FF;04000501=A85636FF;04000601=A85636FF;05000101=6F2919FF;05000201=A85636FF;05000301=A85636FF;05000401=6F2919FF;06000101=FFCA8AFF;06000201=6F2919FF;06000301=A85636FF;06000401=A85636FF;06000501=6F2919FF;07000101=FFCA8AFF;07000201=A85636FF;07000301=6F2919FF;07000401=6F2919FF;07000501=6F2919FF;08000101=FFCA8AFF;08000201=FFCA8AFF;08000301=A85636FF;09000101=E0975CFF;09000201=FFCA8AFF;09000301=FFCA8AFF;09000401=A85636FF;10000101=A85636FF;10000201=E0975CFF;10000301=FFCA8AFF;10000401=A85636FF;11000101=6F2919FF;11000201=A85636FF;11000301=E0975CFF;11000401=FFCA8AFF;11000501=A85636FF;12000101=6F2919FF;12000301=A85636FF;12000401=E0975CFF;12000501=A85636FF;13000401=A85636FF;13000501=A85636FF;14000101=A85636FF;15000101=A85636FF;16000101=FFCA8AFF;16000201=A85636FF;17000101=FFCA8AFF;17000201=A85636FF;18000101=FFCA8AFF;18000201=A85636FF;19000101=FFCA8AFF;19000201=A85636FF;20000101=E0975CFF;20000201=A85636FF;21000101=A85636FF;21000201=A85636FF?fade;80ff80;0.0001518?replace;ffffffff=00000000"
    }
    local params = self.parameters
    local bladeMoveParams = {
	    mass = 80.0,
	    gravityMultiplier = 1,
	    bounceFactor = 0.0,
	    maxMovementPerStep = 1,
	    ignorePlatformCollision = true,
	    stickyCollision = true,
	    stickyForce = 2000.0,
	    airFriction = 3.0,
	    liquidFriction = 8.0,
	    groundFriction = 15.0,
	    maximumCorrection = 0.75
	}
    world.spawnProjectile("boltguide", vec2.add(mcontroller.position(), {0,2}), entity.id(), {mcontroller.facingDirection(),0}, false, {processing = "?setcolor=00000000", speed = 40, movementSettings = bladeMoveParams,
        periodicActions = {
            {
                time = 0,
                action = "particle",
                rotate = true,
                specification = {
                    type = "textured",
                    image = params.bladeImg,
                    rotation = 180,
                    size = 0.5,
                    fullbright = true,
                    timeToLive = 0,
                    destructionTime = 0,
                    destructionAction = "shrink",
                    layer = "middle"
                }
            }
        }
    })
end

function uTW:stop()
end

function uTW:update(args)
end

function uTW:uninit()

end

--[[
    LMB - Sword Spawn + launch
    LMB + SHIFT - Rain swords w/ physics
    RMB - Levitate existing swords off of the ground and launch them towards the cursor
    RMB + SHIFT - util.trig existing swords around a target and launch them towards the target

    SHIFT + F - Rho Aias
    G - Caladbolg
    H - Trace On / Copy Weapon (Big question here is whether or not to use copied weapons' assets)

    LMB - When held, begin (interval based) spawning blades behind character (update according to facingDirection)
    Blades face the cursor
]]