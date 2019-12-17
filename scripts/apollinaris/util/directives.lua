DirectiveHandler = {}
DirectiveHandler.__index = DirectiveHandler

function DirectiveHandler:assign()
    local self = {}
    setmetatable(self, DirectiveHandler)
    self.database = {}
    return self
end

function DirectiveHandler:update()
    table.sort( self.database, function(a,b) return a.priority<b.priority end ) -- >= - higher priority goes to the beginning, <= goes to the end
	local tempHolder = {}
	for i=1,#self.database do
		tempHolder[i] = self.database[i].directive
	end
	tempHolder = table.concat(tempHolder, "")
	tech.setParentDirectives(tempHolder)
	self.database = {}
end

function DirectiveHandler:new(directive, priority)
    priority = priority or 100
	table.insert(self.database, {directive = directive, priority = priority})
end