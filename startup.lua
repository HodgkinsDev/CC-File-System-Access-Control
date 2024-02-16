local readOnlyPaths = {}
local old_fsOpen = _G["fs"]["open"]
local old_fsIsReadOnly = _G["fs"]["isReadOnly"]

_G["fs"]["open"] = function(path, mode)
    local isReadOnlyPath = false
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if path:sub(1, #readOnlyPath) == readOnlyPath then
            isReadOnlyPath = true
            break
        end
    end
    if not isReadOnlyPath then
        return old_fsOpen(path, mode)
    elseif mode == 'w' or mode == 'd' then
        return nil
    else
        return old_fsOpen(path, 'r')
    end
end

_G["fs"]["isReadOnly"] = function(path)
    local isReadOnlyPath = false
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if path:sub(1, #readOnlyPath) == readOnlyPath then
            isReadOnlyPath = true
            break
        end
    end
    if not isReadOnlyPath then
        return old_fsIsReadOnly(path)
    else
        return true
    end
end

function fs.setReadOnlyPath(path, readOnly)
    if type(path) == "string" and type(readOnly) == "boolean" then
        if readOnly then
            table.insert(readOnlyPaths, path)
        else
            for i, readOnlyPath in ipairs(readOnlyPaths) do
                if readOnlyPath == path then
                    table.remove(readOnlyPaths, i)
                    break
                end
            end
        end
    else
        print("Invalid arguments for fs.setReadOnlyPath")
    end
end
