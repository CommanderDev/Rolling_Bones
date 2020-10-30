return {
	--[[ 

	This module is used to create Action binds for the Input manager; used with: Input:is("ActionName")

	ActionName = {
		Keyboard = KEY (string),
		Gamepad = BUTTON (string), // See 'ShortKeyCode.lua'
		Mouse = BUTTON (string), // See 'ShortKeyCode.lua'
		Vibrations = {
			Length = SECONDS (Integer),
			Rumblers = { 
				Large = NUMBER, (Integer: Scale of [0-1])
				Small = NUMBER,
				LeftHand = NUMBER,
				RightHand = NUMBER,
				LeftTrigger = NUMBER,
				RightTrigger = NUMBER
			}
		}
	}

	ExampleAction = {
		Keyboard = Enum.KeyCode.K,
		Gamepad = Enum.KeyCode.ButtonX,
		Mouse = Enum.UserInputType.MouseButton1, 
		Vibrations = {
			Length = .3,
			Rumblers = { 
				Large = .5,
				Small = .5,
				LeftHand = .3,
				RightHand = .3,
				LeftTrigger = .2,
				RightTrigger = .2
			}
		}
	}

	--]]
	Sprint = {
		Keyboard = Enum.KeyCode.LeftShift, --used to be F but that gets sunk by Studio shortcuts :upside-down:
	},
	Reload = {
		Gamepad = Enum.KeyCode.ButtonA,
		Keyboard = Enum.KeyCode.R
	},
	Interact = {
		Gamepad = Enum.KeyCode.ButtonB,
		Keyboard = Enum.KeyCode.E
	},
	Fire = {
		Mouse = Enum.UserInputType.MouseButton1,
		Gamepad = Enum.KeyCode.ButtonA
	}
}