# File System Access Control

This Lua script provides functionality to control read and write access to specific paths in the file system.

## How to Use

1. **Initialization**: This needs to run as a startup file so it overwrites system functions

2. **Setting Read-Only Paths**: Use the `fs.setReadOnlyPath(path, readOnly)` function to set paths as read-only or not. Pass the path as a string and `true` for `readOnly` if you want to make it read-only, and `false` to make it writable.

3. **File System Operations**: All file system operations such as opening files are intercepted by the script. If the path matches a read-only path, write operations are blocked, and read operations are redirected to read-only mode.

## Functions

### `fs.setReadOnlyPath(path, readOnly)`

Sets the read-only status of a given path.

- `path`: (string) The path to set as read-only or writable.
- `readOnly`: (boolean) Set to `true` to make the path read-only, `false` to make it writable.

### `fs.open(path, mode)`

Overrides the default `fs.open` function to control file opening behavior based on read-only paths.

- `path`: (string) The path of the file to open.
- `mode`: (string) The mode in which to open the file (`r` for read, `w` for write, etc.).

### `fs.isReadOnly(path)`

Overrides the default `fs.isReadOnly` function to check whether a path is read-only.

- `path`: (string) The path to check for read-only status.

## Example

```lua
-- Set "/system/" path as read-only
fs.setReadOnlyPath("/system/", true)

-- Try to open a file in read-only mode
local file = fs.open("/system/file.txt", "r")
if file then
    print("File opened successfully.")
else
    print("Error: File could not be opened.")
end

-- Try to open a file in write mode
local file = fs.open("/system/file.txt", "w")
if file then
    print("File opened successfully.")
else
    print("Error: File could not be opened.")
end
