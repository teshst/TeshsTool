[![Codacy Security Scan ](https://github.com/teshst/TeshsTool/actions/workflows/codacy.yml/badge.svg?branch=main)](https://github.com/teshst/TeshsTool/actions/workflows/codacy.yml) [![PSScriptAnalyzer ](https://github.com/teshst/TeshsTool/actions/workflows/powershell.yml/badge.svg?branch=main)](https://github.com/teshst/TeshsTool/actions/workflows/powershell.yml)
# TeshsTool - User Guide

TeshsTool is a PowerShell script designed to automate the installation of software packages on Windows-based machines. The script utilizes WinForms for the graphical user interface (GUI).

## Requirements

Before using TeshsTool, ensure you meet the following requirements:

- PowerShell 5.0 or later
- Administrative rights to run the program and install packages.

<details>
  <summary>Supported Extensions</summary>

  - .exe
  - .msi
  - .reg
  - .ps1
  - .vbs

</details>

## Overview

### File Locations
The required locations are created automatically and can be customized by modifying these values:

  ``` powershell
  $appIconPath = ".\Assets\AppIcon.ico"
  $softwarePath = ".\Software"
  $logPath = ".\Logs"
  ```

### Install Process
When TeshsTool is first run, it checks for folders named after the software packages you want to install. Inside these folders should be the required installation files.

  ```powershell
  # Files with names like example.uninstaller.ext will be ignored during installation.

  $directoryPath = Join-Path -Path $softwarePath -ChildPath $selectedDirectory.Name
  $packages = Get-ChildItem $directoryPath | Where-Object { $_.Extension -match "/*.(exe|msi|reg|ps1|vbs)$" -and $_.Name -notmatch '\.uninstaller\.\w+$' }
  ```

### Uninstall Process
The uninstallation process uses existing software locations and checks if the extension is .msi, in which case it can be uninstalled directly. If the extension is different, it searches for a file with the format of example.uninstaller.ext to complete the uninstallation.

  ```powershell
  # Files without .uninstaller.ext are ignored.

  $directoryPath = Join-Path -Path $softwarePath -ChildPath $selectedDirectory.Name
  $packages = Get-ChildItem $directoryPath | Where-Object { $_.Extension -match "/*.(msi)$" -or $_.Name -match '\.uninstaller\.\w+$' }
  ```

### Templates
Example templates for creating .uninstaller files to remove different types of programs can be found in the templates folder.


  ``` powershell
  # Path: Templates/sample.uninstaller.sh

  # Locations
  $logPath = ".\logs"

  # Functions
  function Save-Log($message) {
      $logFile = Join-Path -Path $logPath -ChildPath ("Log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")
      $logMessage = "$(Get-Date) : $message"
      Add-Content -Path $logFile -Value $logMessage
      Show-Message $logMessage
  }

  try {
      $Sample = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Sample" }
      if ($null -ne $Sample) {
        $Sample.Uninstall()
      }
  }
  catch {
      Save-Log $_.Exception.Message
  }

  ```

## How to use

### Terminal
1. Ensure you have the software inside the software folder and that its extension is supported.

2. Open a PowerShell terminal as an administrator.

3. Navigate to the directory where the project is cloned.

4. In the terminal, type the following command to run the program:

    >  .\TeshsTool.ps1

5. Select desired software individually or select all.

6. Click "Install" to begin installation or "Uninstall" to remove software.

### Compiled Executable
1. Ensure you have the software inside the software folder and that its extension is supported.

2. Run the teshstool.exe as an administrator.

3. Select desired software individually or select all.

4. Click "Install" to begin installation or press "Uninstall" to remove software.

## Editing & Building
You can make any necessary changes to the existing teshstool.ps1 script. Once you are satisfied with the changes, run the rebuildteshstool.bat as an administrator to compile an executable.

  > .\RebuildTeshsTool.bat


## Logs
Logs are stored in the logs folder, and a message will appear when a log is created. All logs are created and stored by date and time.

  ``` powershell
  function Save-Log($package, $message) {
      $logFile = Join-Path -Path $logPath -ChildPath ("Log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")
      $logMessage = "$(Get-Date) - $($package.FullName): $message"
      Add-Content -Path $logFile -Value $logMessage
      Show-Message $logMessage
  }
  ```

## Disclaimer
This script is provided as-is and without any warranty. The author shall not be liable for any damages or losses arising from the use of this script. Use at your own risk.

## License
This script is licensed under the MIT license. See the LICENSE file for more information.
