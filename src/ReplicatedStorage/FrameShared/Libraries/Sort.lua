--[[ 
    Author: serverOptimist
    Description: Handles advamced sorting of tables. ]]---

local Sort = function(tableToSort, sortBy, sortDirection)
    assert(type(tableToSort) == "table", "The first argument in sortTable must be a table. Got: "..type(tableToSort))
    table.sort(tableToSort, function(index, comparingIndex)
        if sortDirection == "Descending" then 
            return index[sortBy] < comparingIndex[sortBy]
        else
            return index[sortBy] > comparingIndex[sortBy]
        end
    end)
    return tableToSort
end
--
return Sort