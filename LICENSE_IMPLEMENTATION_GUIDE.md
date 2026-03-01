# 📜 License Implementation Guide

This project uses an automated bash-based utility to manage license headers across the codebase. This ensures legal compliance and consistency without manual editing.

## 🛠 Prerequisites

To run the licensing tool, ensure your environment has the following available in the global bash namespace:
1.  **`license_check`**: The core orchestration function.
2.  **`findUpFile`**: The utility that locates the project root.
3.  **Standard Unix Tools**: `bash`, `sed`, `find`, and `grep`.

## 📂 Required Files

The system identifies the project root and the license content via two files that **must** exist in this directory:

| File | Description |
| :--- | :--- |
| `LICENSE` | The full legal text of the project license. |
| `license.small` | The short header (usually 1 line) to be injected into source files. |

> **Note**: Do not add comment characters (`#` or `//`) to `license.small`. The tool detects the file type and adds the correct comment syntax automatically.

## 🚀 How to Migrate or Update Licenses

If you need to change the copyright holder, the year, or the license type:

1.  **Update the Source**: Edit the text inside `license.small`.
2.  **Execute**: Run the following command from **anywhere** within the project tree:
    ```bash
    license_check
    ```
3.  **Automatic Processing**:
    * The tool finds the project root using `findUpFile`.
    * It identifies all supported files (`.sh`, `.py`, `.js`, `.ts`, `.go`, etc.).
    * It removes existing blocks matching `Copyright`, `License`, or `©`.
    * It injects the new header from `license.small`.
    * It ensures a mandatory empty line exists after the header for readability.



## 📝 Supported File Types & Logic

| Extension | Comment Style | Placement |
| :--- | :--- | :--- |
| `.js`, `.ts`, `.go` | `//` | Line 1 |
| `.sh`, `.py` | `#` | Line 1 |
| *With Shebang* | `#` or `//` | Line 2 (After `#!`) |

## 🧪 Verification

After running the tool, you can verify the changes by checking a few random files or running the test suite:
```bash
licence_check_testAll

```

## ⚠️ Important Notes

* **Idempotency**: Running the tool multiple times is safe. It will not duplicate headers.
* **Shebang Preservation**: The tool is specifically designed to keep `#!/usr/bin/env bash` as the very first line, moving the license to the second line.
* **Manual Headers**: If you have custom comments at the top of a file that contain the word "Copyright," the tool may identify them as a license block and replace them.

---

*Guide generated on 2026-03-01*
