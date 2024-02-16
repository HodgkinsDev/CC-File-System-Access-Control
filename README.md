# File System Access Control

This Lua script provides functionality to control read and write access to specific paths in the file system.

## Installation

Install CC-File System Access Control

**Step 1**

    pastebin get VLjBk8ZY startup.lua
**Step 2**

Run the installer
&#x200B;

## How to Use

1. **Initialization**: This needs to run as a startup file so it overwrites system functions.

2. **Setting Read-Only Paths**: Use the `fs.setReadOnlyPath(path, readOnly)` function to set paths as read-only or not. Pass the path as a string and `true` for `readOnly` if you want to make it read-only, and `false` to make it writable.

3. **File System Operations**: All file system operations such as opening files, writing to files, moving files, copying files, and deleting files are intercepted by the script. If the path matches a read-only path, write and delete operations are blocked, and read operations are redirected to read-only mode.

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

### Additional Functions

The script also intercepts the following file system operations to ensure read-only paths are respected:

- `fs.delete(path)`: Prevents deletion of files and directories within read-only paths.
- `fs.move(fromPath, toPath)`: Prevents moving files and directories into or out of read-only paths.
- `fs.copy(fromPath, toPath)`: Prevents copying files and directories into or out of read-only paths.

## Example

```lua
-- Set "/test/" path as read-only
fs.setReadOnlyPath("/test/", true)

-- Set "/test/" path as read/write
fs.setReadOnlyPath("/test/", false)
