@echo off
setlocal

REM --- Configuration ---
set ENV_NAME=llm_eval_env
set STREAMLIT_SCRIPT=streamlit_app.py
set CONDA_INSTALLER_URL=[https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe](https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe)
set MINICONDA_PATH=%USERPROFILE%\Miniconda3

REM --- Check for Conda Installation ---
echo Checking for Conda installation...
where conda >nul 2>nul
if %errorlevel% neq 0 (
    echo Conda not found. Attempting to install Miniconda...
    echo.
    echo Please follow the Miniconda installer prompts.
    echo IMPORTANT: During installation, select "Install for me only" and
    echo "Add Miniconda3 to my PATH environment variable" (or ensure it's added manually later).
    echo.
    powershell -Command "Invoke-WebRequest -Uri '%CONDA_INSTALLER_URL%' -OutFile 'Miniconda3-latest-Windows-x86_64.exe'"
    start /wait Miniconda3-latest-Windows-x86_64.exe /S /D=%MINICONDA_PATH%
    del Miniconda3-latest-Windows-x86_64.exe
    
    REM Re-check if conda is in PATH after installation
    where conda >nul 2>nul
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: Miniconda installation failed or was not added to PATH.
        echo Please ensure Conda is installed and its 'Scripts' directory is in your system's PATH.
        echo You might need to restart your command prompt or computer.
        pause
        exit /b 1
    )
    echo Conda installed successfully.
) else (
    echo Conda found.
)

REM --- Initialize Conda (important for fresh installs or specific environments) ---
call conda init cmd.exe >nul 2>nul

REM --- Activate Base Environment (ensure conda commands are available) ---
call conda activate base >nul 2>nul

REM --- Create/Update Conda Environment ---
echo.
echo Creating/Updating Conda environment '%ENV_NAME%' from environment.yml...
conda env create -f environment.yml -n %ENV_NAME% || conda env update -f environment.yml -n %ENV_NAME%
if %errorlevel% neq 0 (
    echo ERROR: Failed to create or update Conda environment.
    echo Please check the error messages above.
    pause
    exit /b 1
)
echo Conda environment '%ENV_NAME%' is ready.

REM --- Activate the specific environment and run the Streamlit app ---
echo.
echo Activating environment and starting Streamlit app...
call conda activate %ENV_NAME%
if %errorlevel% neq 0 (
    echo ERROR: Failed to activate Conda environment '%ENV_NAME%'.
    pause
    exit /b 1
)

REM Navigate to the directory where streamlit_app.py is located (same as this batch file)
cd /d "%~dp0"

streamlit run %STREAMLIT_SCRIPT% --server.port 8501 --server.enableCORS false --server.enableXsrfProtection false

echo.
echo Application finished or closed.
pause
endlocal