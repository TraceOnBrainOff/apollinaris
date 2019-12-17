function init()
	message.setHandler("despawnMech", fake) -- Just ilb shit
	vehicle.setLoungeEnabled("seat", false)
	mcontroller.applyParameters(
		{
			collisionPoly = jarray(),
			gravityEnabled = false,
			mass = 0,
			frictionEnabled = false,
			enableSurfaceSlopeCorrection = false,
			collisionEnabled = false
		}
	)
end

function update(dt)

end

function uninit()
	vehicle.destroy()
end

function fake()
end

function rotatePhysicsForces(rotation)
	animator.resetTransformationGroup("collision")
	animator.rotateTransformationGroup("collision", rotation)
end