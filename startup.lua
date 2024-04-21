local readOnlyErrorColor = 0x4000 
local colors = {
    white = 0x1,
    orange = 0x2,
    magenta = 0x4,
    lightBlue = 0x8,
    yellow = 0x10,
    lime = 0x20,
    pink = 0x40,
    gray = 0x80,
    lightGray = 0x100,
    cyan = 0x200,
    purple = 0x400,
    blue = 0x800,
    brown = 0x1000,
    green = 0x2000,
    red = 0x4000,
    black = 0x8000
}
local readOnlyPaths = {}
local hiddenPaths = {}
local function normalizePath(path)
    path = path:gsub("%.%.", "")
    path = path:gsub("[\\/]([\\/]+)", "/")
    path = path:gsub("[\\/]$", "")
    return path
end
local function hidePath(path)
    local normalizedPath = fs.combine(path, "")
    hiddenPaths[normalizedPath] = true
end
local function unhidePath(path)
    local normalizedPath = fs.combine(path, "")
    hiddenPaths[normalizedPath] = nil
end
local old_fsList = fs.list
fs.list = function(path)
    local files = old_fsList(path)
    local filteredFiles = {}
    for _, file in ipairs(files) do
        local fullPath = fs.combine(path, file)
        local normalizedPath = fs.combine(path, "")
        if not hiddenPaths[fullPath] and not hiddenPaths[normalizedPath .. "." .. file] then
            table.insert(filteredFiles, file)
        end
    end
    return filteredFiles
end
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
    end
end
fs.hide = function(path)
    hidePath(path)
end
fs.unhide = function(path)
    unhidePath(path)
end
_G["fs"]["delete"] = function(path)
    path = normalizePath(path)
    for _, readOnlyPath in ipairs(readOnlyPaths) do
        if path:sub(1, #normalizePath(readOnlyPath)) == normalizePath(readOnlyPath) then
            term.setTextColor(readOnlyErrorColor)
            print("Cannot delete read-only file: " .. path)
            term.setTextColor(colors.white) 
            return false 
        end
    end
    return old_fsDelete(path)
end
