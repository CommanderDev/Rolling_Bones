--[[
    Author: Spynaz
    Description: Easily create OOP type classes
    Example:

        local Server    = require(game.ServerScriptService.CloudFrameServer.Main)
        local Class     = Server.loadLibrary("Class")

        local SomeClass = Class.new()
        
        function SomeClass.new()
            local self = {}

            setmetatable(self, SomeClass)

            return self
        end

        local object = SomeClass.new()

        print(object:IsA(SomeClass)) -- Should print true
        print(object:IsA(Class)) -- Should print true
--]]

local Class = {}
Class.__index = Class
Class.class = Class

--[[
    Description: Creates a new class used for OOP

    Parameters:
        (optional) superClass [Class]: The superclass to inherit from
--]]
function Class.new(superClass)
    local self = {}
    self.__index = self
    self.superClass = superClass or Class
    self.class = self
    
    setmetatable(self, superClass or Class)
    
    return self
end

--[[
    Description: Returns true if the caller is an instance of theClass

    Parameters:
        theClass [Class]: The class to check against
--]]
function Class:IsA(theClass)
    local isA = false
    local curClass = self

    while curClass ~= nil and isA == false do
        if curClass.class == theClass then
            isA = true
        else
            curClass = curClass.superClass
        end
    end

    return isA
end

return Class