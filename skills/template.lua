tMP = {}
tMP.metadata = {
	name = "Template",
	type = "skill" -- skill/ultimate/passive
}

function tMP.start() -- function called when the bind is pressed in the main tech

end

function tMP.stop() -- function called when the passive all stop is called/or the ultimate's bind is pressed to stop the mode, allows for smooth transitions instead of snapping

end

function tMP.init() -- function called during the init of the tech.
	tMP.parameters = {
		isOn = false
	}
end

function tMP.update(args)-- function called during update of the tech.

	return tMP.parameters.isOn -- important, the engine uses this to determine if the skill is on, on its' end, without losing frames by calling a sendEntityMessage and creating a handler in init
end

function tMP.uninit() -- called during the uninit of the tech

end

function tMP.testFunc1()

end

function tMP.testFunc2()

end