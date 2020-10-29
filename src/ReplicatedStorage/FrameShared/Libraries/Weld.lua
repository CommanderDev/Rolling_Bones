-- @Authors: Spynaz, Scriptos
-- Provides welding functions

-- Methods
	--[[
		Name: Weld.Model()
		Parameters:	Type		Name	Desc
					----		----	----
				 	Model		Model	The model to weld
					BasePart	Core	The part that the model will weld to
		
		Description: Welds a whole model together
		
		
		Name: Weld.BaseParts()
		Parameters:	Type		Name		Desc
					----		----		----
				 	BasePart	BasePart1	Part 1 (the weld will be parented to this part)
					BasePart	BasePart2	Part 2
		d
		Description: Welds to parts together
	--]]

    local Weld = {}

    -- Welds a model together relative to the offsets of the objects within.
    function Weld:relative(Model, Center)
        local Objects = Model:GetDescendants();
        for i = 1,#Objects do -- Using classic for loop for speed reasons.
            local Object = Objects[i];
            if Object~=Center and Object:IsA("BasePart") then 
                Object.CanCollide 	= false;
                local w 	= Instance.new("ManualWeld");
                w.C0 		= Center.CFrame:inverse()*Object.CFrame;
                w.Part0 	= Center;
                w.Part1 	= Object;
                w.Parent	 = Center;
    end end end;
    
    -- Welds a whole model together
    function Weld.model(Model, Core, Recursive, Type)
        for i, part in pairs(Model:GetChildren()) do
            if part:IsA("BasePart") and part ~= Core then
                if not part:findFirstChild("DoNotWeld") then
                    
                    -- Setup weld
                    local w = Instance.new(Type or "Weld")
                    w.Name = part.Name
                    w.Part0 = Core
                    w.Part1 = part
                    
                    local CJ = CFrame.new(Core.Position)
                    local C0 = Core.CFrame:inverse()*CJ
                    local C1 = part.CFrame:inverse()*CJ
                    
                    w.C0 = C0
                    w.C1 = C1
                    w.Parent = Core
                end
                
                Core.Anchored = false
                part.Anchored = false
            elseif part:IsA("Model") and Recursive then
                Weld.model(part, Core, Recursive, Type)
            end
        end
    end
    
    -- Welds two parts together
    function Weld.baseParts(BasePart1, BasePart2)
        local w 	= Instance.new("Weld")
        w.Name 		= BasePart2.Name
        w.Part0 	= BasePart1
        w.Part1 	= BasePart2
        
        local CJ = CFrame.new(BasePart1.Position)
        local C0 = BasePart1.CFrame:inverse()*CJ
        local C1 = BasePart2.CFrame:inverse()*CJ
        
        w.C0 		= C0
        w.C1 		= C1
        w.Parent 	= BasePart1
        
        BasePart1.Anchored = false
        BasePart2.Anchored = false
    end
    
    return Weld
    