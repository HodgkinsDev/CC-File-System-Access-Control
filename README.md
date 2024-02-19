# CC-File-System-Access-Control

CC-File-System-Access-Control is a Lua script designed for use with ComputerCraft, a modification for Minecraft that allows players to interact with computers and robots using Lua programming. This script provides enhanced control over file system access, including the ability to hide directories and files, mark paths as read-only, and override certain file system functions.

## Features

- **Hiding Paths**: Allows users to hide directories and files from being listed or accessed through the file system.
- **Read-only Paths**: Supports marking specific paths as read-only, preventing modifications such as writing, deleting, moving, or copying files.
- **Function Overrides**: Overrides default file system functions to enforce access control policies on specified paths.
- **Path Normalization**: Normalizes paths to ensure consistency and prevent path traversal attacks.
- **Dynamic Configuration**: Provides functions to dynamically set paths as read-only or remove read-only status.

## Usage

### Installation

To install the script:

1. Ensure you have ComputerCraft installed in your Minecraft game.
2. Run the following command in ComputerCraft:

```
pastebin get VLjBk8ZY startup.lua
```

This command downloads the script and saves it as `startup.lua`. Ensure that this command is executed at startup to override the system functions. If you already have a `startup.lua` file, you can paste the code of CC-File-System-Access-Control into your existing `startup.lua` file.

By following these installation instructions and utilizing the provided functions, you can integrate the access control features into your Lua programs in ComputerCraft.

### Available Functions

- `fs.hide(path)`: Hide the specified directory or file.
- `fs.unhide(path)`: Unhide the specified directory or file.
- `fs.setReadOnlyPath(path, readOnly)`: Mark the specified path as read-only (`true`) or writable (`false`).
- Override of standard `fs` functions such as:
  - `open`
  - `isReadOnly`
  - `delete`
  - `move`
  - `copy`
  - `write`
  - `append`
  - `makeDir`
  - `deleteDir`

These functions enable enhanced control over file system operations, including hiding paths, marking paths as read-only, and overriding default file system functions.

### Example

```lua
-- Hide a directory
fs.hide("path/to/directory")

-- Mark a path as read-only
fs.setReadOnlyPath("path/to/file", true)

-- Unhide a directory
fs.unhide("path/to/directory")

-- Mark a path as read/write
fs.setReadOnlyPath("path/to/file", false)

