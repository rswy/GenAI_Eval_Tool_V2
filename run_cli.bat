@echo off
setlocal

REM --- Configuration ---
set ENV_NAME=llm_eval_env
set CLI_SCRIPT=main.py
set CONDA_INSTALLER_URL=[https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe](https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe)
set MINICONDA_PATH=%USERPROFILE%\Miniconda3

REM --- Check for Conda Installation (same as run_app.bat) ---
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
    
    where conda >nul 2>nul
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: Miniconda installation failed or was not added to PATH.
        pause
        exit /b 1
    )
    echo Conda installed successfully.
) else (
    echo Conda found.
)

REM --- Initialize Conda ---
call conda init cmd.exe >nul 2>nul

REM --- Activate Base Environment ---
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

REM --- Provide instructions for using the CLI ---
echo.
echo Conda environment '%ENV_NAME%' is set up.
echo To run the LLM Evaluation CLI, open a new command prompt, activate the environment,
echo and then run the '%CLI_SCRIPT%' script with your desired arguments.
echo.
echo Example usage:
echo   conda activate %ENV_NAME%
echo   python %CLI_SCRIPT% --input_file data\your_data.csv --output_file results.csv --metrics "Semantic Similarity"
echo.
echo For more options, run:
echo   conda activate %ENV_NAME%
echo   python %CLI_SCRIPT% --help
echo.
pause
endlocal
