local InputDevice = {}

--[[

    Established which device type the input belongs to because roblox doesn't distinguish properly.

    WHATS NOT INCLUDED 
    - Focus (All)
    - Accelerometer (Mobile)
    - Gyro (Mobile)
    - TextInput (All)
    - None (All)
    - InputMethod (All)
--]]

InputDevice[Enum.UserInputType.Touch] 		    = 	'Mobile'

InputDevice[Enum.UserInputType.Gamepad1] 		= 	'Gamepad'
InputDevice[Enum.UserInputType.Gamepad2] 		= 	'Gamepad'
InputDevice[Enum.UserInputType.Gamepad3] 		= 	'Gamepad'
InputDevice[Enum.UserInputType.Gamepad4] 		= 	'Gamepad'
InputDevice[Enum.UserInputType.Gamepad5] 		= 	'Gamepad'
InputDevice[Enum.UserInputType.Gamepad6] 		= 	'Gamepad'
InputDevice[Enum.UserInputType.Gamepad7] 		= 	'Gamepad'
InputDevice[Enum.UserInputType.Gamepad8] 		= 	'Gamepad'

InputDevice[Enum.UserInputType.Keyboard] 		= 	'Keyboard'

InputDevice[Enum.UserInputType.MouseButton1] 	= 	'Mouse'
InputDevice[Enum.UserInputType.MouseButton2] 	= 	'Mouse'
InputDevice[Enum.UserInputType.MouseButton3] 	= 	'Mouse'
InputDevice[Enum.UserInputType.MouseMovement] 	= 	'Mouse'
InputDevice[Enum.UserInputType.MouseWheel] 		= 	'Mouse'

return InputDevice