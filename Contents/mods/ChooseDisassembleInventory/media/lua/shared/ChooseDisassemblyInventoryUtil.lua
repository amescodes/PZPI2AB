function ChooseDisassemblyInventoryPrint(txt, debugOnly)
    if debugOnly == nil then
        debugOnly = false
    end
    if not debugOnly or ChooseDisassemblyInventory.Verbose then
        print(txt)
    end
end

function ChooseDisassemblyInventory_PrintQueue(playerObj)
    local queue = ISTimedActionQueue.getTimedActionQueue(playerObj).queue;
    if queue then
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory: queue...", true)
        for i, action in ipairs(queue) do
            local jobType = action.jobType
            if not jobType then
                jobType = "???"
                local item = action.item:getFullType()
                ChooseDisassemblyInventoryPrint("unknown job...item: "..item, true)
            end
            ChooseDisassemblyInventoryPrint(tostring(i).. ") action: "..jobType, true)
        end
        ChooseDisassemblyInventoryPrint("ChooseDisassemblyInventory: queue END ", true)
    end
end

function ChooseDisassemblyInventory_PrintArray(array)
    if array then
        for i = 0, array:size() - 1 do 
            local s = array:get(i)
            ChooseDisassemblyInventoryPrint(tostring(s), true)
        end
    end
end

-- http://lua-users.org/wiki/BinaryInsert
local fcomp_default = function( a,b ) return a < b end
function BinaryInsert(t, value, fcomp)
    -- Initialise compare function
    local fcomp = fcomp or fcomp_default
    --  Initialise numbers
    local iStart,iEnd,iMid,iState = 1,#t,1,0
    -- Get insert position
    while iStart <= iEnd do
        -- calculate middle
        iMid = math.floor( (iStart+iEnd)/2 )
        -- compare
        if fcomp( value,t[iMid] ) then
        iEnd,iState = iMid - 1,0
        else
        iStart,iState = iMid + 1,1
        end
    end
    table.insert( t,(iMid+iState),value )
    return (iMid+iState)
end

function ShallowClone(array)
    local result = ArrayList.new()
    for i = 0, array:size() - 1 do
        result:add(array:get(i))
    end
    return result
end
-- -- http://lua-users.org/wiki/BinarySearch
-- local default_fcompval = function( value ) return value end
-- local fcompf = function( a,b ) return a < b end
-- local fcompr = function( a,b ) return a > b end
-- function BinarySearch( tbl,value,fcompval,reversed )
--     -- Initialise functions
--     local fcompval = fcompval or default_fcompval
--     local fcomp = reversed and fcompr or fcompf
--     --  Initialise numbers
--     local iStart,iEnd,iMid = 0,tbl:size(),0
--     -- Binary Search
--     while iStart <= iEnd do
--         -- calculate middle
--         iMid = math.floor( (iStart+iEnd)/2 )
--         -- get compare value
--         local value2 = fcompval( tbl:get(iMid] )
--         -- get all values that match
--         if value == value2 then
--         local tfound,num = { iMid,iMid },iMid - 1
--         while value == fcompval( tbl[num] ) do -- ERROR: this may cause fail in fcompval if num is out of range and tbl[num] is nil
--             tfound[1],num = num,num - 1
--         end
--         num = iMid + 1
--         while value == fcompval( tbl[num] ) do -- ERROR: this may cause fail in fcompval if num is out of range and tbl[num] is nil
--             tfound[2],num = num,num + 1
--         end
--         return tfound
--         -- keep searching
--         elseif fcomp( value,value2 ) then
--         iEnd = iMid - 1
--         else
--         iStart = iMid + 1
--         end
--     end
-- end