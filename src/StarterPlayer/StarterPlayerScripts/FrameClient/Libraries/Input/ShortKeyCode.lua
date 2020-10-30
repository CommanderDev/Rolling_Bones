local Main = require(game.ReplicatedStorage.CloudFrameShared.Main)
local Input = Main.loadLibrary("Input")
local Actions = Main.loadLibrary("Actions")

local ShortKeyCode = {}
ShortKeyCode.Gamepad 				= 	{}
ShortKeyCode.Mouse					=	{}

local devices = {}
for name,device in pairs(ShortKeyCode) do
    if typeof(device) == "table" then
        devices[name] = device
    end
end

function ShortKeyCode:getDevices()
    return devices
end

function ShortKeyCode:getShortKeyCodeByAction(action)
    if typeof(action) == "string" then
        action = Actions[action]
    end
    local enabledDevices = Input.DetectedDevices.Enabled
    for deviceName,enabled in pairs(enabledDevices) do
        local keybind = action[deviceName]
        if enabled and keybind then
            local device = self[deviceName] or {}
            return device[keybind] or keybind.Name
        end
    end
    return "nil"
    --[[if currentDevice then
        local device = self[currentDevice] or {}
        local keybind = action[currentDevice]
        if keybind then
            return device[keybind] or keybind.Name
        else
            return "nil"
        end
    end
    return "nil"]]
end

--[[

    Used to organize input buttons to an easier to understand context based on device.

]]

ShortKeyCode.Mouse[Enum.UserInputType.MouseButton1] = 'Left'	
ShortKeyCode.Mouse[Enum.UserInputType.MouseButton2] = 'Right'
ShortKeyCode.Mouse[Enum.UserInputType.MouseButton3] = 'Middle'
ShortKeyCode.Mouse[Enum.UserInputType.MouseMovement] = 'Move'	
ShortKeyCode.Mouse[Enum.UserInputType.MouseWheel] = 'Scroll'

ShortKeyCode.Gamepad[Enum.KeyCode.ButtonA] = 'A'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonB] = 'B'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonX] = 'X'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonY] = 'Y'

ShortKeyCode.Gamepad[Enum.KeyCode.ButtonR1] = 'R1'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonR2] = 'R2'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonR3] = 'R3' -- Analog

ShortKeyCode.Gamepad[Enum.KeyCode.ButtonL1] = 'L1'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonL2] = 'L2'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonL3]	= 'L3'-- Analog

ShortKeyCode.Gamepad[Enum.KeyCode.ButtonStart] = 'Start'
ShortKeyCode.Gamepad[Enum.KeyCode.ButtonSelect] = 'Select'

ShortKeyCode.Gamepad[Enum.KeyCode.DPadLeft] = 'Left'
ShortKeyCode.Gamepad[Enum.KeyCode.DPadRight] = 'Right'
ShortKeyCode.Gamepad[Enum.KeyCode.DPadUp] = 'Up'
ShortKeyCode.Gamepad[Enum.KeyCode.DPadDown] = 'Down'

ShortKeyCode.Gamepad[Enum.KeyCode.Thumbstick1] = 'Left Analog'
ShortKeyCode.Gamepad[Enum.KeyCode.Thumbstick2] = 'Right Analog'

return ShortKeyCode