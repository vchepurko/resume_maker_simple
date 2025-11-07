# Running the Resume PDF Tool (macOS / Linux)

This project ships with a macOS/Linux installer: `setup.command`.  
It creates a local virtual environment (`.venv/`), installs required libraries, and a global-ish launcher: `resume-build`.

---

## 1) macOS

### A) First run (double-click)
1. Put `setup.command` in the project root (same folder as your `resume.py`).
2. In Finder, right-click `setup.command` → Open.  
   - If Gatekeeper warns about an “unidentified developer”, use **System Settings → Privacy & Security → Allow Anyway**, then right-click → **Open** again.

   - 1 — Enable the “New Terminal at Folder” option. If “New Terminal at Folder” is not available:
     1. Open System Settings → Keyboard → Keyboard Shortcuts → Services.
     2. Scroll to the Files and Folders section.
     3. Enable New Terminal at Folder (and optionally “New Terminal Tab at Folder”).
   - 2 — Open terminal
     1. Locate your setup.command file in Finder (for example, in Downloads or your project folder).
     2. Right-click the folder background (not the file itself).
     3. Choose: Services → New Terminal at Folder (If you don’t see this option, see note below.)
     4. A Terminal window will open in that exact directory.
     5. Add to reminal text and enter, after that you can open setup.command by double click.
          ```bash
          chmod +x setup.command
          ```
4. The script will:
   - Check for Python 3 (you can install it with Homebrew: `brew install python`).
   - Create `.venv/`.
   - Install libraries: `reportlab`, `pypdf2`, `pdfminer.six`, `pdfplumber`, `Pillow`, `PyYAML`, `click`.
   - Create a launcher at `~/.local/bin/resume-build`.

### B) Add to PATH (if needed)
If `resume-build` is not found after installation:
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### C) Usage examples
```bash
# Show CLI help (if your script supports Click/argparse help)
resume-build --help

# Build a PDF using a YAML template
resume-build --config template.yaml --out "Vitaliy-CV.pdf"

# Use a different input/output
resume-build --config configs/senior.yaml --out dist/cv-senior.pdf
```

> If your entrypoint is not `resume.py`, edit `LAUNCH_TARGET` inside `setup.command` and run it again.

---

## 2) Linux (Ubuntu/Debian and others)

### A) Run the installer
```bash
chmod +x setup.command
./setup.command
```

If Python 3 is missing and your distro supports `apt`, the script will try:
```bash
sudo apt-get update -y
sudo apt-get install -y python3 python3-venv python3-pip
```
On other distributions (Fedora, Arch, etc.), install Python 3 manually with your package manager, then re-run `./setup.command`.

### B) Ensure PATH contains the launcher directory
```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

### C) Usage examples
```bash
resume-build --help
resume-build --config template.yaml --out cv.pdf
resume-build --config profile.yaml --photo assets/headshot.jpg --out out/cv.pdf
```

---

## 3) Troubleshooting

- **Command not found: `resume-build`**
  - Add `~/.local/bin` to your PATH (see sections above), or run the script directly:
    ```bash
    ./.venv/bin/python resume.py --config template.yaml --out cv.pdf
    ```

- **Permission denied when double-clicking `setup.command` (macOS)**
  - Run:
    ```bash
    chmod +x setup.command
    xattr -d com.apple.quarantine setup.command 2>/dev/null || true
    ```
  - Then right-click → Open.

- **Homebrew is not installed (macOS)**
  - Install it:
    ```bash
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew install python
    ```

- **Different entrypoint**
  - If your main script is not `resume.py`, edit `LAUNCH_TARGET` near the top of `setup.command` and re-run it.

- **Reinstall dependencies**
  - Remove the virtual environment and re-run the installer:
    ```bash
    rm -rf .venv
    ./setup.command
    ```

---

## 4) What gets installed

- Local virtual environment: `.venv/`
- Python packages: `reportlab`, `pypdf2`, `pdfminer.six`, `pdfplumber`, `Pillow`, `PyYAML`, `click`
- Launcher: `~/.local/bin/resume-build`

You can always bypass the launcher and run directly:
```bash
. .venv/bin/activate
python resume.py --config template.yaml --out cv.pdf
```
