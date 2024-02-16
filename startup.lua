local readOnlyPaths = {}
local hiddenPaths = {}

-- Helper function to normalize paths
local function normalizePath(path)
    -- Replace any occurrences of ".." with an empty string
    path = path:gsub("%.%.", "")
    -- Remove any occurrences of consecutive slashes
    path = path:gsub("[\\/]([\\/]+)", "/")
    -- Remove trailing slashes
    path = path:gsub("[\\/]$", "")
    return path
end

-- Function to hide a directory or file
local function hidePath(path)
    local normalizedPath = fs.combine(path, "")  -- Ensure path has a trailing slash
    hiddenPaths[normalizedPath] = true
    print("Path hidden:", normalizedPath)
end

-- Function to unhide a directory or file
local function unhidePath(path)
    local normalizedPath = fs.combine(path, "")  -- Ensure path has a trailing slash
    hiddenPaths[normalizedPath] = nil
    print("Path unhidden:", normalizedPath)
end

-- Override fs.list function to exclude hidden directories and files
local old_fsList = fs.list
fs.list = function(path)
    local files = old_fsList(path)
    local filteredFiles = {}
    for _, file in ipairs(files) do
        local fullPath = fs.combine(path, file)
        local normalizedPath = fs.combine(path, "")  -- Ensure path has a trailing slash
        if not hiddenPaths[fullPath] and not hiddenPaths[normalizedPath .. "." .. file] then
            table.insert(filteredFiles, file)
        end
    end
    return filteredFiles
end

-- Override fs functions related to file operations to support read-only paths
local old_fsOpen = _G["fs"]["open"]
local old_fsIsReadOnly = _G["fs"]["isReadOnly"]
local old_fsDelete = _G["fs"]["delete"]
local old_fsMove = _G["fs"]["move"]
local old_fsCopy = _G["fs"]["copy"]
local old_fsWrite = _G["fs"]["write"]
local old_fsAppend = _G["fs"]["append"]
local old_fsMakeDir = _G["fs"]["makeDir"]
local old_fsDeleteDir = _G["fs"]["deleteDir"]

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

_G["fs"]["append"] = function(path, text)
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
        return old_fsAppend(path, text)
    end
end

_G["fs"]["makeDir"] = function(path)
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
        return old_fsMakeDir(path)
    end
end

_G["fs"]["deleteDir"] = function(path)
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
        return old_fsDeleteDir(path)
    end
end

-- Function to set a path as read-only or not
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

-- Add commands to fs namespace to hide and unhide directories and files
fs.hide = function(path)
    hidePath(path)
end

fs.unhide = function(path)
    unhidePath(path)
end
