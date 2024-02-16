local readOnlyPaths = {}
local old_fsOpen = _G["fs"]["open"]
local old_fsIsReadOnly = _G["fs"]["isReadOnly"]
local old_fsDelete = _G["fs"]["delete"]
local old_fsMove = _G["fs"]["move"]
local old_fsCopy = _G["fs"]["copy"]
local old_fsWrite = _G["fs"]["write"]

-- Helper function to normalize paths
local function normalizePath(path)
    return path:gsub("[\\/]$", "") -- Remove trailing slashes
end

_G["fs"]["open"] = function(path, mode)
    local isReadOnlyPath = false
    path = normalizePath(path)
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if path:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
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
    path = normalizePath(path)
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if path:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
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

_G["fs"]["delete"] = function(path)
    local isReadOnlyPath = false
    path = normalizePath(path)
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if path:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
            isReadOnlyPath = true
            break
        end
    end
    if isReadOnlyPath then
        return nil
    else
        return old_fsDelete(path)
    end
end

_G["fs"]["move"] = function(fromPath, toPath)
    local isFromReadOnly = false
    local isToReadOnly = false
    fromPath = normalizePath(fromPath)
    toPath = normalizePath(toPath)
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if fromPath:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
            isFromReadOnly = true
        end
        if toPath:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
            isToReadOnly = true
        end
    end
    if isFromReadOnly or isToReadOnly then
        return nil
    else
        return old_fsMove(fromPath, toPath)
    end
end

_G["fs"]["copy"] = function(fromPath, toPath)
    local isFromReadOnly = false
    local isToReadOnly = false
    fromPath = normalizePath(fromPath)
    toPath = normalizePath(toPath)
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if fromPath:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
            isFromReadOnly = true
        end
        if toPath:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
            isToReadOnly = true
        end
    end
    if isFromReadOnly or isToReadOnly then
        return nil
    else
        return old_fsCopy(fromPath, toPath)
    end
end

_G["fs"]["write"] = function(path, text)
    local isReadOnlyPath = false
    path = normalizePath(path)
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if path:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
            isReadOnlyPath = true
            break
        end
    end
    if isReadOnlyPath then
        return nil
    else
        return old_fsWrite(path, text)
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
