-- @Author: Spynaz
-- Handles large amounts of events at the same time
-- Works with both custom events and events part of the ROBLOX API (exampe: event = part.Touched:connect(function))

-- Methods
	--[[
		Name: EventHandler.new()
		Parameters:	Type	Name	Desc
					----	----	----
				 	tuple	 --		Paramaters passed in that are events
		
		Description: Creates a new handler
		
		
		Name: EventHandler:add()
		Parameters:	Type	Name	Desc
					----	----	----
				 	tuple	 --		Event objects passed in as parameters that will be added to the handler
		
		Description: Adds a new event to the handler
		
		
		Name: EventHandler:cleanup()
		Parameters:	void
		Description: Disconnects all the events
	--]]
	
-- Other modules used by this class:
	-- EventHandler

-- EventHandler class
local EventHandler = {}
EventHandler.__index = EventHandler

-- Creates a new handler. Events param must be a table of events
function EventHandler.new(...)
	local self 	= {}
	self.ClassName	= "EventHandler"
	self.Events 	= {...}
	
	setmetatable(self, EventHandler)
	
	return self
end

-- Adds a the given events to the handler
function EventHandler:add(...)
	for _, event in pairs({...}) do
		table.insert(self.Events, event)
	end
end

-- Disconnects all the events
function EventHandler:cleanup()
	for _, event in pairs(self.Events) do
		event:disconnect()
	end
	
	-- Resets events table
	self.Events = {}
end

return EventHandler
