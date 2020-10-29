--[[
    Author: Isosta
    Description: Handles authentication for all special permissions, such as admin, chat tags, etc.
--]]

local Server = require(game.ServerScriptService.CloudFrameServer.Main)

--Libraries
local Class = Server.loadLibrary("Class")

--DataStreams
--local ValidateUser = Server.getDataStream("ValidateUser", "RemoteFunction")  --Fetch user validation on the client?

--local Authenticators = {}
local Authenticator = Class.new()

--[[
    Description: Creates an Authenticator object used to validate users based on their group standing.

    Parameters:
            Name (string) - Name of the authenticator. Serves no purpose other than identification. 
            groupId (number) - the Id of the group related to the parameters.
            parameters (table) - Group ranking assignments related to the authenticator.

    Example Usage

    Authenticator.new("ChatTags", 1038305, {
            [250] = 4,
            [220] = 3,
            [205] = 2,
            [5] = 1
        }
    )
--]]
function Authenticator.new(Name, groupId, parameters)
    assert(groupId, "Authenticator must have a group Id")
	    assert(parameters, "Authenticator must have rank parameters")
	
	local self = {
		Name = Name, 
		GroupId = groupId, 
		GroupAssignments = parameters
	}
	
	setmetatable(self, Authenticator)

    return self
end


--[[
    Description: Returns the role assignment of a user based on the Authenticator called.

    Parameters:
            player (instance) - Player object
--]]
function Authenticator:validateUser(player)
	local Rank = player:GetRankInGroup(self.GroupId or 1038305)

	return self.GroupAssignments[Rank]
end


--[[
    Description: Returns whether Player1 is a higher authority than player 2.

    Parameters:
            Player1 (instance) - Player object
            Player2 (instance) - Player object
--]]
function Authenticator:isHigherAuthority(player1, player2)
	if player1 and player2 then
	    local rankAuthorityLevel1 = player1:GetRankInGroup(self.GroupId)
		local rankAuthorityLevel2 = player2:GetRankInGroup(self.GroupId)
		
		if rankAuthorityLevel1 ~= nil then
			if rankAuthorityLevel2 ~= nil then
				return rankAuthorityLevel2 > rankAuthorityLevel1
			else
				return false
			end
		else
			return true
		end
	else
		return true
	end
end

--[[
    Description: Returns whether the player has access the authority provided.

    Parameters:
            Player (instance) - Player object
            Authority (number) - Value determining the required authority.
--]]
function Authenticator:hasAuthority(player, authority)
    local Rank = player:GetRankInGroup(self.GroupId or 1038305)

	if Rank ~= nil then
		--print("AuthorityLevel:", Rank, "Authority required:", authority)
		if Rank >= authority then
			return true
		end
	end
	
	return false
end

--[[
    function ValidateUser.OnServerInvoke(Player, AuthenticatorName)

    end
]]--

return Authenticator
