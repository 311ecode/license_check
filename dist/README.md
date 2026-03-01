# License Check Tool

A bash script to automatically add or update license headers across your project while preserving original source code.

## Usage

```bash
license_check

```

No parameters are required. The script will:

1. **Validate**: Ensure it's running from a Git project root.
2. **Verify**: Check for `LICENSE` and `license.small` files.
3. **Process**: Scan and update headers for all supported file types.

For help, use:

```bash
license_check.sh -h
# or
license_check.sh --help

```

## Supported File Types

The tool uses specific comment styles based on file type:

* **Double Slash (`//`)**: `.js`, `.ts`, `.jsx`, `.tsx`, `.go`
* **Hash (`#`)**: `.sh`, `.bash`, `.py`
* **Shebang Detection**: Any file starting with `#!` (e.g., scripts without extensions) will have the license placed on the second line.

## Requirements

* **Environment**: Bash environment with `sed`, `find`, and `grep`.
* **Project Root**: Must contain a `.git` directory.
* **Mandatory Files**:
* `LICENSE`: The full legal text.
* `license.small`: A single-line or short version used for the file headers.



## How It Works

### 1. Cleaning & Idempotency

Before adding a new header, the tool runs a removal pass. It detects existing headers using keywords like `Copyright`, `License`, `Proprietary`, and the `©` symbol. This ensures that re-running the tool never results in duplicate headers.

### 2. Header Placement

* **Standard Files**: The header is inserted at line 1.
* **Shebang Files**: The header is inserted at line 2, immediately following the interpreter directive.

### 3. Formatting

The tool enforces a **mandatory empty line** after every license header. This separates the legal metadata from the functional code, improving readability and making future parsing more reliable.

## Testing

The project includes a comprehensive test suite via `licence_check_testAll.sh`, covering:

* Multi-file processing
* Overwriting existing headers
* Repeated execution stability
* Preservation of shebangs and original content
