require("/scripts/vec2.lua")
require("/scripts/rect.lua")
require("/scripts/util.lua")
require("/interface/apollinaris/scripts/cursor.lua")
require("/interface/apollinaris/scripts/display.lua") -- display class for sizes etc. not sure what else
require("/interface/apollinaris/scripts/color.lua") -- color class for gradients, setting up etc
require("/interface/apollinaris/scripts/buttons.lua") -- base class for standard buttons

function init()
    mainCanvas = widget.bindCanvas("mainCanvas")
    widget.focus("mainCanvas")
    cursor = Cursor:new()
    display = Display:new()
    color = Color:new()
    local id = Button:newButton({50,50}, {70, 50}, 1, {anchors = {horizontal = "left"}})
    local ret = world.entityPosition(player.id())
    sb.logInfo(sb.printJson(ret))
end

function update(dt)
    mainCanvas:clear()
    cursor:setPosition(mainCanvas:mousePosition())
    for i, button in ipairs(buttons) do
        button:update()
        button:render(mainCanvas)
    end
    cursor:resetClick()
end

function uninit()

end

function canvasClickEvent(position, button, isButtonDown)
    cursor:registerClick(position, button, isButtonDown)
end

function canvasKeyEvent(key, isKeyDown)

end

function inheritsFrom( baseClass )
    -- http://lua-users.org/wiki/InheritanceTutorial
    -- The following lines are equivalent to the SimpleClass example:

    -- Create the table and metatable representing the class.
    local new_class = {}
    local class_mt = { __index = new_class }

    -- Note that this function uses class_mt as an upvalue, so every instance
    -- of the class will share the same metatable.
    --
    function new_class:create()
        local newinst = {}
        setmetatable( newinst, class_mt )
        return newinst
    end

    -- The following is the key to implementing inheritance:

    -- The __index member of the new class's metatable references the
    -- base class.  This implies that all methods of the base class will
    -- be exposed to the sub-class, and that the sub-class can override
    -- any of these methods.
    --
    if baseClass then
        setmetatable( new_class, { __index = baseClass } )
    end

    return new_class
end

function deepCopy(object) -- trusty fucker
    local lookup_table = {}
    local function _copy(object)
        if type(object) ~= "table" then
            return object
        elseif lookup_table[object] then
            return lookup_table[object]
        end
        local new_table = {}
        lookup_table[object] = new_table
        for index, value in pairs(object) do
            new_table[_copy(index)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(object))
    end
    return _copy(object)
end