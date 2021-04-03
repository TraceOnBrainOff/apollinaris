Page = {}

-- Have the pages store ids of buttons and call them that way. The page class will serve as a simplified way of calling functions on all buttons on a pane
-- add a check if the background is being pressed or something, could be useful for something!

function Page:new()
    self._index = self
    
    return self
end