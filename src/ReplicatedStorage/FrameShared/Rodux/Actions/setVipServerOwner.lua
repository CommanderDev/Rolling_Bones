--[[
    Author: Dev0mar

    Description: gives the id of the VIP Server owner
]]

return function(OwnerID)
    return {
        type = "setVipServerOwner",
        ID = OwnerID,
        replicationTarget = "all"
    }
end