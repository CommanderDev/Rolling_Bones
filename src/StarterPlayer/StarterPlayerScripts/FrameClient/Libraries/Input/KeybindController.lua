local Keybind = {}
Keybind.Device = require(script.Parent.InputDevice)
local Actions = require(script.Parent.Actions)

--[[

	Looks up an UserInputType settings, see "InputDevice.lua"

	Parameters:
		- input: UserInputType
]]

function Keybind:getDevice(input)
	return Keybind.Device[input.UserInputType] 
end

--[[

	Looks up an actions settings, see "Actions.lua"

	Parameters:
		- name: string
]]

function Keybind:getAction(name)
	return Actions[name]
end

--[[

	Checks if a InputObject matches an Action bind.

	Parameters: 
		- input (InputObject)

	Returns:
		string or false (bool)
]]

function Keybind:getBindAction(input)
	if input.UserInputType == Enum.UserInputType.Focus then return false end
	
	local device = Keybind:getDevice(input) 		-- Found our Mouse, Gamepad, Keyboard
	for actionName,action in pairs(Actions) do
		local action_bind = action[device]
		if action_bind then
			if device == 'Keyboard' then
				if input.KeyCode == action_bind then return action end
			elseif device == 'Mouse' then
				if input.UserInputType == action_bind then return action end
			elseif device == 'Gamepad' then
				if input.KeyCode == action_bind then return action end
			end
		end
	end
	return false
end

--[[

	Check if all conditions pass for the input, and that you aren't typing in the chat window. 

	Parameters: 
		- input (InputObject)
		- name (string)

	Ex: Keybind:is(inputObject, "ActionExample")

	Returns string or false.
]]

function Keybind:is(input, name)
	if input.UserInputType == Enum.UserInputType.Focus then return false end
	
	local device = Keybind:getDevice(input) 		-- Found our Mouse, Gamepad, Keyboard
	local action = Keybind:getAction(name)
	local action_bind = action[device]
	if action_bind then	
		if device == 'Keyboard' then
			return input.KeyCode == action_bind
		elseif device == 'Mouse' then
			return input.UserInputType == action_bind
		elseif device == 'Gamepad' then
			return input.KeyCode == action_bind
		end
	end
	return false
end


return Keybind
