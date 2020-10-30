
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")
local Haptic = game:GetService("HapticService")
local Context = game:GetService("ContextActionService")
local Keybind	=	require(script.Parent.KeybindController)

local Input 	= 	{}
Input.Device 	= 	require(script.Parent.InputDevice)
Input.Rumbler 	= 	require(script.Parent.Rumbler)
--Input.Image 	= 	require(script.Image)
Input.DetectedDevices = {}
Input.DetectedDevices.xbox = GuiService:IsTenFootInterface()
--[[ 
	
	GUIDELINE
	http://wiki.roblox.com/index.php?title=Xbox_Featuring_Checklist
	http://wiki.roblox.com/index.php?title=Inverse_kinematics
	http://wiki.roblox.com/index.php?title=Verlet_integration
	
	TUTORIALS
	http://wiki.roblox.com/index.php?title=Radial_Menu
	http://wiki.roblox.com/index.php?title=Bézier_curves
	
	IMAGES
	http://wiki.roblox.com/index.php?title=Libraries_and_Samples/ImageInputLibrary
	
	HAPTIC: RUMBLERS API
	
	Large 
	in the left side of the controller. 
	Good for generic rumble.
	
	Small 
	in the right side of the controller. 
	Good for more subtle rumbles(tire slipping, electric shock, etc.)
	
	Left Trigger 
	underneath the left trigger. 
	Good for braking, gun reloading, etc.
	
	Right Trigger 
	underneath the right trigger. 
	Good for recoil, acceleration, etc.
	
	===============================================================================================================

	GUI INPUT API
	http://wiki.roblox.com/index.php?title=API:Class/GuiService
	
	Properties:	
		[Related: Gamepad]		
		[Bool] AutoSelectGuiEnabled 	- 	The 'Select' will auto-select a UI, turning this off means you need to set the 'SelectedObject'
		[Bool] CoreGuiNavigationEnabled - 	Gamepad Only.
		[Bool] GuiNavigationEnabled 	- 	Regular GuiService.
		[Guis] SelectedObjet			-	Set Selected UI for Gamepad.
			
		[Related: General]
		[Bool] MenuIsOpen 				-	Is Core Menu Open?
		
	Functions:
		-- ADD LATER
		
	Events:
		MenuClosed()
		MenuOpened()
		
	===============================================================================================================
	ROBLOX INPUT API
	http://wiki.roblox.com/index.php?title=API:Enum/UserInputType
	http://wiki.roblox.com/index.php?title=API:Enum/KeyCode
	http://wiki.roblox.com/index.php?title=API:Class/InputObject -- Joystick
	
	GENERAL
	----------------------------------------------------
	Functions: 
		GetFocusedTextBox()
		GetLastInputType()
		GetKeysPressed() -- Includes Gamepad
	
	GAMEPAD
	-----------------------------------------------------
	Enums:
		[UserInputType] Gamepad1 (of 8) - Input from plugged in Gamepad
	
		[KeyCode] ButtonX
		[KeyCode] ButtonY
		[KeyCode] ButtonA
		[KeyCode] ButtonB
		
		[KeyCode] ButtonR1
		[KeyCode] ButtonR2
		[KeyCode] ButtonR3
		
		[KeyCode] ButtonL1
		[KeyCode] ButtonL2	
		[KeyCode] ButtonL3	

		[KeyCode] ButtonStart	
		[KeyCode] ButtonSelect	
		
		[KeyCode] DPadLeft	
		[KeyCode] DPadRight	
		[KeyCode] DPadUp	
		[KeyCode] DPadDown
			
		[KeyCode] Thumbstick1	
		[KeyCode] Thumbstick2	

	Property:
		[Bool] GamepadEnabled
			
	Functions:
		[Bool] 					GamepadSupports(Gamepad, Key) 	- Supports Key?
		[Array-InputType] 		GetConnectedGamepads()
		[Array-InputObject] 	GetGamepadState(Gamepad) 		- Gets each input objects state
		[Array-InputType] 		GetNavigationGamepads()
		[Array-?]				GetSupportedGamepadKeyCodes
		[Bool]					IsNavigationGamepad 
		[Void] 					SetNavigationGamepad
		


		B Button on Gamepad has to always close a menu.
--]]

-- Gamepad
Input.Gamepad 	= 	{}
Input.Gamepad.Supports = {}
Input.Gamepad.Supports.Vibration = false
Input.Gamepad.Enabled = UserInputService.GamepadEnabled

--[[


	Select an object, mostly used for Xbox.

	Parameters 
	- object (UI Element)

	Ex: Input:select(gui.Button)

]]

function Input:select(object)
	GuiService.SelectedObject = object
end

--[[

	NOTE: MAKE THIS AUTOMATIC --> for  TechSpectrum

]]

function Input:updateSupports()
	local Supports = Input.Gamepad.Supports
	Supports.Vibration = Haptic:IsVibrationSupported(Enum.UserInputType.Gamepad1)
	if Supports.Vibration then
		Supports['Large'] = Haptic:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Large)
		Supports['Small'] = Haptic:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small)
		Supports['Left Hand'] = Haptic:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.LeftHand)
		Supports['Right Hand']  = Haptic:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.RightHand)
		Supports['Left Trigger'] = Haptic:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.LeftTrigger)
		Supports['Right Trigger']  = Haptic:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.RightTrigger)
	end
	return Supports
end

--[[

	Runs the vibrations of a controller based on the Action settings.

	Parameters 
	- action (string)

	Ex: Input:vibrate("FireGun")
]]

function Input:vibrate(action)
	local Supports = Input.Gamepad.Supports
	local Action = Keybind:getAction(action)
	local Vibrations = Action.Vibrations
	local Length = Vibrations.Length.Value
	local Rumblers = Vibrations.Rumblers:GetChildren()
	if Supports.Vibration then
		for _, rumbler in pairs(Rumblers) do
			local name = rumbler.Name
			local set = rumbler.Value
			if Supports[name] then
				Haptic:SetMotor(Enum.UserInputType.Gamepad1, Input.Rumbler[name], set)
				if Length ~= 0 then
					wait(Length)
					Haptic:SetMotor(Enum.UserInputType.Gamepad1, Input.Rumbler[name], 0)
				end
			end
		end
	end
end

--[[

	Toggles whether Roblox’s mobile controls are hidden on mobile devices
	https://developer.roblox.com/api-reference/property/UserInputService/ModalEnabled

	Parameters 
	- value (bool)

]]

function Input:hideMobileControls(value)
	Input.ModalEnabled = value
end

--[[

	Confirms if the input object matches an existing action bind in 'Actions.lua'

	Parameters 
	- input (InputObject)
	- name (string)

	Ex: Input:isAction(inputObject, "ExampleAction")

]]

function Input:isAction(input, name) 
	return Keybind:is(input, name)
end

--[[

	Confirms if the input object matches an existing action bind in 'Actions.lua'

	Parameters 
	- input (InputObject)
	- name (string)

	Ex: Input:isAction(inputObject, "ExampleAction")

]]

function Input:updateDeviceDetection(inputType)
	local keyboardEnabled = (UserInputService.KeyboardEnabled)
	local gamepadEnabled = (UserInputService.GamepadEnabled)
	local mouseEnabled = (UserInputService.MouseEnabled)
	local touchEnabled = (UserInputService.TouchEnabled)

	Input.DetectedDevices.Enabled = {
		Keyboard = keyboardEnabled or nil;
		Gamepad = gamepadEnabled or nil;
		Mouse = mouseEnabled or nil;
		Touch = touchEnabled or nil;
	}
	
	Input.DetectedDevices.mobile = touchEnabled and not keyboardEnabled
	Input.DetectedDevices.pc = keyboardEnabled and mouseEnabled
	Input.DetectedDevices.gamepad = gamepadEnabled
	Input.DetectedDevices.touch = touchEnabled
	if inputType then
		Input.DetectedDevices.currentDevice = Input.Device[inputType] or "Keyboard"
	elseif Input.DetectedDevices.pc then
		Input.DetectedDevices.currentDevice = "Keyboard"
	elseif Input.DetectedDevices.xbox then
		Input.DetectedDevices.currentDevice = "Gamepad"
	elseif Input.DetectedDevices.mobile then
		Input.DetectedDevices.currentDevice = "Mobile"
	end
end

UserInputService.LastInputTypeChanged:Connect(function(inputType)
	Input:updateDeviceDetection(inputType)
end)

Input:updateDeviceDetection()

return Input
