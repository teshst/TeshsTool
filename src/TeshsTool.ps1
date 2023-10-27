Add-Type -AssemblyName PresentationFramework

# Locations
$softwarePath = ".\Software"
$uninstallPath = ".\Uninstallers"

# Function to create the main window
function Create-MainWindow {
    $mainWindow = New-Object Windows.Window
    $mainWindow.Title = "TeshsTool-v1.1"
    $mainWindow.Width = 420
    $mainWindow.Height = 475
    $mainWindow.WindowStartupLocation = [Windows.WindowStartupLocation]::CenterScreen

    # Create a ListBox to display the available packages
    $packageListBox = New-Object Windows.Controls.ListBox
    $packageListBox.Name = "packageListBox"
    $packageListBox.Width = 360
    $packageListBox.Height = 350
    $packageListBox.Margin = "20,20,0,0"
    $mainWindow.Content = $packageListBox

    # Create buttons
    $selectAllButton = New-Object Windows.Controls.Button
    $selectAllButton.Content = "Select All"
    $selectAllButton.Add_Click({ Select-AllPackages })
    $selectAllButton.HorizontalAlignment = [Windows.HorizontalAlignment]::Left
    $selectAllButton.VerticalAlignment = [Windows.VerticalAlignment]::Top
    $selectAllButton.Width = 75
    $selectAllButton.Height = 23
    $selectAllButton.Margin = "20,375,0,0"

    $deselectAllButton = New-Object Windows.Controls.Button
    $deselectAllButton.Content = "Deselect All"
    $deselectAllButton.Add_Click({ Deselect-AllPackages })
    $deselectAllButton.HorizontalAlignment = [Windows.HorizontalAlignment]::Left
    $deselectAllButton.VerticalAlignment = [Windows.VerticalAlignment]::Top
    $deselectAllButton.Width = 75
    $deselectAllButton.Height = 23
    $deselectAllButton.Margin = "100,375,0,0"

    $installButton = New-Object Windows.Controls.Button
    $installButton.Content = "Install"
    $installButton.Add_Click({ Install-Packages })
    $installButton.HorizontalAlignment = [Windows.HorizontalAlignment]::Left
    $installButton.VerticalAlignment = [Windows.VerticalAlignment]::Top
    $installButton.Width = 75
    $installButton.Height = 23
    $installButton.Margin = "305,375,0,0"

    $uninstallButton = New-Object Windows.Controls.Button
    $uninstallButton.Content = "Uninstall"
    $uninstallButton.Add_Click({ Uninstall-Packages })
    $uninstallButton.HorizontalAlignment = [Windows.HorizontalAlignment]::Left
    $uninstallButton.VerticalAlignment = [Windows.VerticalAlignment]::Top
    $uninstallButton.Width = 75
    $uninstallButton.Height = 23
    $uninstallButton.Margin = "305,400,0,0"

    # Add buttons to the main window
    $mainWindow.Content = $packageListBox
    $mainWindow.Children.Add($selectAllButton)
    $mainWindow.Children.Add($deselectAllButton)
    $mainWindow.Children.Add($installButton)
    $mainWindow.Children.Add($uninstallButton)

    return $mainWindow
}

# Function to select all packages
function Select-AllPackages {
    $packageListBox.Items | ForEach-Object {
        $_.IsSelected = $true
    }
}

# Function to deselect all packages
function Deselect-AllPackages {
    $packageListBox.Items | ForEach-Object {
        $_.IsSelected = $false
    }
}

# Function to install selected packages
function Install-Packages {
    $selectedPackages = $packageListBox.SelectedItems
    Install -selectedPackages $selectedPackages
}

# Function to uninstall selected packages
function Uninstall-Packages {
    $selectedPackages = $packageListBox.SelectedItems
    Uninstall -selectedPackages $selectedPackages
}

# Function to create the progress window
function Create-ProgressWindow {
    $progressWindow = New-Object Windows.Window
    $progressWindow.Title = "Installing Packages"
    $progressWindow.Width = 420
    $progressWindow.Height = 150
    $progressWindow.WindowStartupLocation = [Windows.WindowStartupLocation]::CenterScreen

    # Create a Grid to hold UI elements
    $grid = New-Object Windows.Controls.Grid

    $progressLabel = New-Object Windows.Controls.Label
    $progressLabel.Content = "Preparing..."
    $progressLabel.HorizontalAlignment = [Windows.HorizontalAlignment]::Left
    $progressLabel.VerticalAlignment = [Windows.VerticalAlignment]::Top
    $progressLabel.Margin = "20,20,0,0"
    $grid.Children.Add($progressLabel)

    $progressBar = New-Object Windows.Controls.ProgressBar
    $progressBar.Name = "progressBar"
    $progressBar.HorizontalAlignment = [Windows.HorizontalAlignment]::Left
    $progressBar.VerticalAlignment = [Windows.VerticalAlignment]::Top
    $progressBar.Width = 360
    $progressBar.Height = 30
    $progressBar.Margin = "20,50,0,0"
    $progressBar.Style = [Windows.Controls.ProgressBarStyle]::Continuous
    $grid.Children.Add($progressBar)

    $progressWindow.Content = $grid

    return $progressWindow
}

# Function to update the progress window
function Update-ProgressWindow {
    param (
        $progressWindow,
        $progressLabel,
        $progressBar,
        $status,
        $percentComplete
    )

    $progressLabel.Content = $status
    $progressBar.Value = [int]$percentComplete
    $progressWindow.UpdateLayout()
}

# Function to handle quitting and process termination
function Quit($status) {
    $progressLabel.Content = $status
    $progressBar.Value = 100
    $progressWindow.UpdateLayout()

    # Kill all started processes
    $proclist | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }

    Start-Sleep -Seconds 3
    $progressWindow.Close()
    $packageSelectionForm.Close()
}

# Function to install packages
function Install($selectedPackages) {
    $totalPackageCount = $selectedPackages.Count
    $progress = 0
    $progressWindow, $progressLabel, $progressBar = Create-ProgressWindow

    foreach ($package in $selectedPackages) {
        $status = "Installing $($package.Name)..."
        $percentComplete = ($progress / $totalPackageCount) * 100

        $progress++
        Update-ProgressWindow -progressWindow $progressWindow -progressLabel $progressLabel -progressBar $progressBar -status $status -percentComplete $percentComplete

        $extension = [System.IO.Path]::GetExtension($package.Name)

        switch ($extension) {
            ".exe" {
                $arguments = "/S /v /qn"
                $proclist += Start-Process -FilePath $package.FullName -ArgumentList $arguments -Wait -NoNewWindow
            }
            ".msi" {
                $arguments = "/I `"$($package.FullName)`" /quiet"
                $proclist += Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
            }
            ".reg" {
                $arguments = "/s `"$($package.FullName)`""
                $proclist += Start-Process -FilePath "regedit.exe" -ArgumentList $arguments -Wait -NoNewWindow
            }
            ".ps1" {
                $arguments = "`"$($package.FullName)`" -DeployMode 'Silent'"
                $proclist += Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Wait -NoNewWindow
            }
            ".vbs" {
                $arguments = "`"$($package.FullName)`""
                $proclist += Start-Process -FilePath "cscript.exe" -ArgumentList $arguments -Wait -NoNewWindow
            }
            default {
                Write-Verbose "No package install package found."
            }
        }
    }

    Quit -status "Installation Complete"
}

# Function to uninstall packages
function Uninstall($selectedPackages) {
    $totalPackageCount = $selectedPackages.Count
    $progress = 0
    $progressWindow, $progressLabel, $progressBar = Create-ProgressWindow

    foreach ($package in $selectedPackages) {
        $status = "Uninstalling $($package.Name)..."
        $percentComplete = ($progress / $totalPackageCount) * 100

        $progress++
        Update-ProgressWindow -progressWindow $progressWindow -progressLabel $progressLabel -progressBar $progressBar -status $status -percentComplete $percentComplete

        $extension = [System.IO.Path]::GetExtension($package.Name)
        $uninstallerFolder = Join-Path -Path $uninstallPath -ChildPath $package.Name  # Specify the path to the uninstaller folder

        switch ($extension) {
            ".exe" {
                $arguments = "/S /v /qn"
                $proclist += Start-Process -FilePath "$uninstallerFolder\$($package.Name)" -ArgumentList $arguments -Wait -NoNewWindow
            }
            ".msi" {
                $arguments = "/X `"$uninstallerFolder\$($package.Name)`" /quiet"
                $proclist += Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
            }
            ".ps1" {
                $arguments = "`"$($package.FullName)`""
                $proclist += Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Wait -NoNewWindow
            }
            ".vbs" {
                $arguments = "`"$($package.FullName)`""
                $proclist += Start-Process -FilePath "cscript.exe" -ArgumentList $arguments -Wait -NoNewWindow
            }
            default {
                Write-Verbose "No uninstall package found"
            }
        }
    }

    Quit -status "Uninstall Complete"
}

# Kill process on error
trap {
    Write-Host "Killed processes."
    $proclist | ForEach-Object {
        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
    }
}

# Main Logic
$packageDirectories = Get-ChildItem $softwarePath -File

# Populate the ListBox with available packages
$packageDirectories | ForEach-Object {
    $packageListBox.Items.Add($_.Name)
}

$mainWindow = Create-MainWindow

$selectedPackages = $mainWindow.ShowDialog()