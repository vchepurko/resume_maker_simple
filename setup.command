#!/usr/bin/env bash
# setup.command
# Purpose:
#   - Ensure Python 3 is available
#   - Create local virtual environment: .venv/
#   - Install PDF + config libraries
#   - Create a launcher: ~/.local/bin/resume-build (runs resume.py in this project)
# Notes:
#   - Run from the project root. This script cd's into its own directory automatically.
#   - If your entrypoint is not resume.py, change LAUNCH_TARGET below.

set -euo pipefail

# Always operate from the script's directory (the project root)
cd "$(dirname "$0")"

PROJECT_ROOT="$(pwd)"
VENV_DIR="${PROJECT_ROOT}/.venv"
INSTALL_BIN="${HOME}/.local/bin"
LAUNCHER="${INSTALL_BIN}/resume-build"
LAUNCH_TARGET="${PROJECT_ROOT}/resume.py"

echo "[1/6] Checking Python 3..."
if ! command -v python3 >/dev/null 2>&1; then
  OS="$(uname -s || true)"
  if [[ "$OS" == "Darwin" ]]; then
    echo "Python 3 not found. On macOS, install with Homebrew:"
    echo "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    echo "  brew install python"
    exit 1
  else
    if command -v apt-get >/dev/null 2>&1; then
      echo "Python 3 not found. Installing via apt..."
      sudo apt-get update -y
      sudo apt-get install -y python3 python3-venv python3-pip
    else
      echo "Python 3 not found and no automatic installer is available for this system."
      echo "Please install Python 3 manually and re-run."
      exit 1
    fi
  fi
fi

echo "[2/6] Creating virtual environment: ${VENV_DIR}"
if [[ ! -d "${VENV_DIR}" ]]; then
  python3 -m venv "${VENV_DIR}"
fi

echo "[3/6] Upgrading pip/setuptools/wheel"
source "${VENV_DIR}/bin/activate"
python -m pip install --upgrade pip setuptools wheel

echo "[4/6] Installing libraries"
# PDF + config stack
python -m pip install \
  reportlab \
  pypdf2 \
  pdfminer.six \
  pdfplumber \
  pillow \
  PyYAML \
  click

deactivate

echo "[5/6] Creating launcher: ${LAUNCHER}"
mkdir -p "${INSTALL_BIN}"
cat > "${LAUNCHER}" <<'EOF'
#!/usr/bin/env bash
# resume-build: run resume.py from the project where setup.command was executed

set -euo pipefail

PROJECT_ROOT="__PROJECT_ROOT__"
VENV="${PROJECT_ROOT}/.venv"
PY="${VENV}/bin/python"
TARGET="__LAUNCH_TARGET__"

if [[ ! -x "${PY}" ]]; then
  echo "Virtualenv not found at ${VENV}. Re-run setup.command." >&2
  exit 1
fi

exec "${PY}" "${TARGET}" "$@"
EOF

# Replace placeholders with absolute paths
ESCAPED_ROOT=$(printf '%s' "$PROJECT_ROOT" | sed 's/[\/&]/\\&/g')
ESCAPED_TARGET=$(printf '%s' "$LAUNCH_TARGET" | sed 's/[\/&]/\\&/g')
sed -i.bak "s/__PROJECT_ROOT__/${ESCAPED_ROOT}/g; s/__LAUNCH_TARGET__/${ESCAPED_TARGET}/g" "${LAUNCHER}" && rm -f "${LAUNCHER}.bak"
chmod +x "${LAUNCHER}"

echo "[6/6] Ensuring ${INSTALL_BIN} is in PATH"
case ":$PATH:" in
  *":${INSTALL_BIN}:"*) echo "PATH already contains ${INSTALL_BIN}";;
  *)
    # Pick an RC file to append to (zsh on macOS by default)
    if [[ -n "${ZSH_VERSION-}" || "$SHELL" == *"zsh" ]]; then
      SHELL_RC="${HOME}/.zshrc"
    elif [[ -n "${BASH_VERSION-}" || "$SHELL" == *"bash" ]]; then
      SHELL_RC="${HOME}/.bashrc"
    else
      SHELL_RC="${HOME}/.profile"
    fi
    echo "export PATH=\"${INSTALL_BIN}:\$PATH\"" >> "${SHELL_RC}"
    echo "Added ${INSTALL_BIN} to PATH in ${SHELL_RC}. Open a new terminal or run: source ${SHELL_RC}"
    ;;
esac

echo
echo "Done."
echo "Examples:"
echo "  resume-build --help"
echo "  resume-build --config template.yaml --out cv.pdf"
echo
echo "If your main script is not resume.py, edit LAUNCH_TARGET inside setup.command before running."