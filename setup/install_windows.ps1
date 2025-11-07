# Installer for PDF toolchain (Windows / PowerShell)
# - Checks/installs Python 3 via winget if possible
# - Creates .venv\ virtualenv in the project
# - Installs PDF libraries
# - Creates a local launcher: resume-build.cmd (in the project root)

$ErrorActionPreference = "Stop"

function Have-Cmd($name) {
  $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

Write-Host "[1/6] Checking Python 3..."
$pyCmd = $null
if (Have-Cmd "py") {
  $pyCmd = "py -3"
} elseif (Have-Cmd "python") {
  $pyCmd = "python"
}

if (-not $pyCmd) {
  if (Have-Cmd "winget") {
    Write-Host "Python 3 not found. Installing via winget..."
    winget install -e --id Python.Python.3 --accept-source-agreements --accept-package-agreements
    if (Have-Cmd "py") { $pyCmd = "py -3" }
    elseif (Have-Cmd "python") { $pyCmd = "python" }
    else {
      Write-Error "Python still not available after winget install. Restart PowerShell and re-run."
    }
  } else {
    Write-Error "Python 3 not found and winget is unavailable. Install Python 3 manually and re-run."
  }
}

Write-Host "[2/6] Creating virtual environment: .venv"
$venvPath = Join-Path (Get-Location) ".venv"
if (-not (Test-Path $venvPath)) {
  & $pyCmd -m venv .venv
}

$pyExe = Join-Path $venvPath "Scripts\python.exe"
if (-not (Test-Path $pyExe)) {
  Write-Error "Virtualenv python not found at $pyExe"
}

Write-Host "[3/6] Upgrading pip"
& $pyExe -m pip install --upgrade pip wheel setuptools

Write-Host "[4/6] Installing PDF libraries"
& $pyExe -m pip install `
  reportlab `
  pypdf2 `
  pdfminer.six `
  pdfplumber `
  pillow `
  PyYAML `
  click

Write-Host "[5/6] Creating launcher: resume-build.cmd"
$launcher = @"
@echo off
setlocal
set PROJECT_ROOT=%~dp0
set PY=%PROJECT_ROOT%\.venv\Scripts\python.exe
if not exist "%PY%" (
  echo Virtualenv not found at %PROJECT_ROOT%\.venv
  echo Re-run install_windows.ps1
  exit /b 1
)
rem Forward all arguments to resume.py in this project
"%PY%" "%PROJECT_ROOT%\resume.py" %*
endlocal
"@
Set-Content -Path ".\resume-build.cmd" -Value $launcher -Encoding ASCII

Write-Host "[6/6] Done."
Write-Host "Usage example:"
Write-Host "  .\resume-build.cmd --help"