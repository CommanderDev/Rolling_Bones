local Main = require(game.ReplicatedStorage.FrameShared.Main)

local PlayerFinishedRace = Main.getDataStream("PlayerFinishedRace", "RemoteEvent")

local RichText = Main.loadLibrary("RichText")

local PlacementText = Main.require("PlacementText")

local playerObject = game.Players.LocalPlayer
local PlayerGui = playerObject:WaitForChild("PlayerGui")
local Interface = PlayerGui:WaitForChild("Interface")
local TimerLabel = Interface:WaitForChild("TimerLabel")

local PlayerNetworkReceiver = {}

function PlayerNetworkReceiver.init()
    PlayerFinishedRace.OnClientEvent:Connect(function(placement)
        TimerLabel.Visible = true
        local placementValues = {
            text = placement.."th";
            color = Color3.new(1,1,1);
        }
        if PlacementText[placement] then
            placementValues.text = PlacementText[placement].text
            placementValues.color = PlacementText[placement].color
        end 
        local richText = RichText.new(placementValues.text, {
            bold = true;
            font = {
                size = "50";
                color = placementValues.color;
            }
        })
        TimerLabel.Text = "You finished "..richText:get()
        wait(3)
        TimerLabel.Visible = false
    end) 
end
 
return PlayerNetworkReceiver

