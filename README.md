

# TeshsTool - How to use

This script is designed to automate the installation of software packages that have extensions such as .exe, .msi, and .reg on Windows-based machines. The script is written in PowerShell and is compatible with Windows operating systems.

## Requirements

Before using this script, please make sure you have the following:

- PowerShell 5.0 or later
- Software packages with the extensions .exe, .msi, or .reg that need to be installed
- Proper permissions to run as admin.

## How to use
1. Ensure the Software folder exists and that software has be placed in it.

2. Open a PowerShell terminal.

3. Navigate to the directory where the script is saved.

4. In the terminal, type the following command to run the script or start the teshstool.exe:

```powershell
.\teshstool.ps1
```
5. Select desired software or select all.

6. Click installt to begin installation.

## Troubleshooting
 - If you encounter any errors during the installation process, please check that you have the necessary permissions to install the software packages.

  - If the script is unable to find the software packages, please ensure that you have entered the correct folder path.

  - If software fails to install or there are any errors relating to the arguments passed. Then the software doesnt support the type of arguments passed to run them silently. Edits will have to be made to the script in order for it the correct arguments to be passed.

## Editing
In order for the teshstool.exe to update to reflect any changes made you will have to run the rebuildteshstool.bat in order to recompile it.

## Disclaimer

This script is provided as-is and without any warranty. The author shall not be liable for any damages or losses arising from the use of this script. Use at your own risk.

## License

This script is licensed under the MIT license. See the LICENSE file for more information.