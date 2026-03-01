# License Check Tool

A bash script to automatically add license headers to source code files in a project.

## Usage

```bash
license_check

```

**Note:** You can run this command from any subdirectory within your project. The tool will automatically "climb" the directory tree to find your `license.small` and `LICENSE` files.

## Features

* **Smart Root Discovery**: Uses `findUp` logic to locate the project root automatically.
* **Idempotent**: Safe to run multiple times; it replaces old headers rather than stacking them.
* **Shebang Support**: Correctly places licenses after `#!` lines in scripts.
* **Formatting**: Ensures a mandatory empty line separates the license from the code.

## Requirements

* `license.small`: The header text (e.g., Copyright notice).
* `LICENSE`: The full license text.
* Files must be within a directory structure containing these two files.

## Supported File Types

* `.sh`, `.bash`, `.py` (Hash comments)
* `.js`, `.ts`, `.jsx`, `.tsx`, `.go` (Double-slash comments)
* Files with bash shebangs (regardless of extension)
