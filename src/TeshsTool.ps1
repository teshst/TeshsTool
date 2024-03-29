#Requires -Version 3.0
#Requires -RunAsAdministrator

Add-Type -AssemblyName System.Windows.Forms

# Locations
$appIconPath = ".\Assets\AppIcon.ico"
$softwarePath = ".\Software"
$logPath = ".\Logs"

# Initialize process list
$proclist = @()

# Check if log folder exist if not create it
if (-not (Test-Path -Path $logPath)) {
    Show-Message "Log directory not found. Creating directory..."
    New-Item -Path $logPath -ItemType Directory
}

# Check if software folder exist if not create it
if (-not (Test-Path -Path $softwarePath)) {
    Show-Message "Software directory not found. Creating directory..."
    New-Item -Path $softwarePath -ItemType Directory
}

# Show message window
function Show-Message($message) {
    $messageForm = New-Object System.Windows.Forms.Form
    $messageForm.Text = "Info"
    $messageForm.Size = New-Object System.Drawing.Size(400, 150)
    $messageForm.StartPosition = "CenterScreen"

    if (Test-Path -Path $appIconPath) {
        $messageForm.Icon = New-Object System.Drawing.Icon($appIconPath)
    }

    $messageLabel = New-Object System.Windows.Forms.Label
    $messageLabel.AutoSize = $false
    $messageLabel.AutoSize = $true
    $messageLabel.Location = New-Object System.Drawing.Point(20, 20)
    $messageLabel.Text = $message
    $messageLabel.TextAlign = [System.Drawing.ContentAlignment]::TopLeft
    $messageLabel.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Left -bor [System.Windows.Forms.AnchorStyles]::Right

    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Text = "Ok"
    $okButton.Location = New-Object System.Drawing.Point(150, 80)
    $okButton.AutoSize = $true
    $okButton.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom

    $okButton.Add_Click{
        $messageForm.Dispose()
        $messageForm.Close()
    }

    $messageForm.Controls.Add($messageLabel)
    $messageForm.Controls.Add($okButton)

    $messageForm.ShowDialog()
}

# Save logs to log folder
function Save-Log($package, $message) {
    $logFile = Join-Path -Path $logPath -ChildPath ("Log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".log")
    $logMessage = "$(Get-Date) - $($package.FullName): $message"
    Add-Content -Path $logFile -Value $logMessage
    Show-Message $logMessage
}

# Kill any running processes started by this script
function Close-Process($processes) {
    foreach ($process in $processes) {
        Stop-Process -Id $process.Id -Force -ErrorAction SilentlyContinue
    }
}

# Add checked items to list
function Get-SelectedItem($packageDirectories, $selectedDirectories) {
    for ($i = 0; $i -lt $packageDirectories.Count; $i++) {
        if ($checkedListBox.GetItemChecked($i)) {
            $selectedDirectories.Add($packageDirectories[$i])
        }
    }
    return $selectedDirectories
}

# Main window for application
function Show-PackageSelectionForm($packageDirectories) {

    $selectedDirectories = New-Object System.Collections.Generic.List[System.IO.DirectoryInfo]

    # UI Elements
    $packageSelectionForm = New-Object System.Windows.Forms.Form
    $packageSelectionForm.Text = "TeshsTool"
    $packageSelectionForm.Size = New-Object System.Drawing.Size(420, 450)
    $packageSelectionForm.StartPosition = "CenterScreen"

    $checkedListBox = New-Object System.Windows.Forms.CheckedListBox
    $checkedListBox.Size = New-Object System.Drawing.Size(360, 350)
    $checkedListBox.Location = New-Object System.Drawing.Point(20, 20)
    $checkedListBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12)
    $packageSelectionForm.Controls.Add($checkedListBox)

    $selectAllButton = New-Object System.Windows.Forms.Button
    $selectAllButton.Text = "Select All"
    $selectAllButton.Location = New-Object System.Drawing.Point(20, 375)
    $selectAllButton.Size = New-Object System.Drawing.Size(75, 23)
    $packageSelectionForm.Controls.Add($selectAllButton)

    $deselectAllButton = New-Object System.Windows.Forms.Button
    $deselectAllButton.Text = "Deselect All"
    $deselectAllButton.Location = New-Object System.Drawing.Point(100, 375)
    $deselectAllButton.Size = New-Object System.Drawing.Size(75, 23)
    $packageSelectionForm.Controls.Add($deselectAllButton)

    $installButton = New-Object System.Windows.Forms.Button
    $installButton.Text = "Install"
    $installButton.Location = New-Object System.Drawing.Point(305, 375)
    $installButton.Size = New-Object System.Drawing.Size(75, 23)
    $packageSelectionForm.Controls.Add($installButton)

    $uninstallButton = New-Object System.Windows.Forms.Button
    $uninstallButton.Text = "Uninstall"
    $uninstallButton.Location = New-Object System.Drawing.Point(225, 375)
    $uninstallButton.Size = New-Object System.Drawing.Size(75, 23)
    $packageSelectionForm.Controls.Add($uninstallButton)

    if (Test-Path -Path $appIconPath) {
        $packageSelectionForm.Icon = New-Object System.Drawing.Icon($appIconPath)
    }

    foreach ($packageDirectory in $packageDirectories) {
        $checkedListBox.Items.Add($packageDirectory.Name, $false)
    }

    $selectAllButton.Add_Click{
        for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
            $checkedListBox.SetItemChecked($i, $true)
        }
    }

    $deselectAllButton.Add_Click{
        for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
            $checkedListBox.SetItemChecked($i, $false)
        }
    }

    $installButton.Add_Click{
        Get-SelectedItem $packageDirectories $selectedDirectories
        Install-Package $selectedDirectories
    }

    $uninstallButton.Add_Click{
        Get-SelectedItem $packageDirectories $selectedDirectories
        Uninstall-Package $selectedDirectories
    }

    $packageSelectionForm.Add_Closing{
        Quit
    }

    $packageSelectionForm.ShowDialog()
}

# Main window for progress tracking
function Show-ProgressForm() {
    $packageSelectionForm.Dispose()

    $progressForm = New-Object System.Windows.Forms.Form
    $progressForm.Text = "Installing Packages"
    $progressForm.Size = New-Object System.Drawing.Size(420, 150)
    $progressForm.StartPosition = "CenterScreen"

    if (Test-Path -Path $appIconPath) {
        $progressForm.Icon = New-Object System.Drawing.Icon($appIconPath)
    }

    $progressLabel = New-Object System.Windows.Forms.Label
    $progressLabel.Size = New-Object System.Drawing.Size(360, 20)
    $progressLabel.Location = New-Object System.Drawing.Point(20, 20)
    $progressLabel.Text = "Preparing..."

    $progressForm.Controls.Add($progressLabel)

    $progressBar = New-Object System.Windows.Forms.ProgressBar
    $progressBar.Size = New-Object System.Drawing.Size(360, 30)
    $progressBar.Location = New-Object System.Drawing.Point(20, 50)
    $progressBar.Style = "Continuous"

    $progressForm.Controls.Add($progressBar)
    $progressForm.Show()
    $progressForm.Refresh()

    return $progressForm, $progressLabel, $progressBar
}

# Update progress window
function Update-ProgressForm ($progressForm, $progressLabel, $progressBar, $status, $percentComplete) {
    $progressLabel.Text = $status
    $progressBar.Value = $percentComplete
    $progressForm.Refresh()
}

# Close progress window
function Complete-ProgressForm($Status) {
    $progressLabel.Text = $Status
    $progressForm.Refresh()

    Close-Process -processes $proclist

    $progressForm.Dispose()
    $progressForm.Close()

    $selectedDirectories.Clear()

    $selectedDirectories = Show-PackageSelectionForm $packageDirectories
}

# Close main window
function Quit() {
    Close-Process -processes $proclist

    $packageSelectionForm.Dispose()
    $packageSelectionForm.Close()
}

# Install packages
function Install($selectedDirectories) {
    if ($selectedDirectories.Count -gt 0) {
        $progressForm, $progressLabel, $progressBar = Show-ProgressForm
        foreach ($selectedDirectory in $selectedDirectories) {
            $directoryPath = Join-Path -Path $softwarePath -ChildPath $selectedDirectory.Name
            $packages = Get-ChildItem $directoryPath | Where-Object { $_.Extension -match "/*.(exe|msi|reg|ps1|vbs)$" -and $_.Name -notmatch '\.uninstaller\.\w+$' }

            $currentPackage = 0
            $progress = 0
            foreach ($package in $packages) {
                $currentPackage++
                $progress++

                $status = "Installing $($selectedDirectory.Name) ($($currentPackage)/$($packages.count))..."
                $percentComplete = ($progress / $packages.Count) * 100
                Update-ProgressForm -progressForm $progressForm -progressLabel $progressLabel -progressBar $progressBar -status $status -percentComplete $percentComplete

                $extension = $package.Extension
                switch ($extension) {
                    ".exe" {
                        $arguments = "/S /v /qn"
                        try {
                            $proclist += Start-Process -FilePath "`"$($package.FullName)`"" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                    ".msi" {
                        $arguments = "/i `"$($package.FullName)`" /quiet /norestart"
                        try {
                            $proclist += Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                    ".reg" {
                        $arguments = "/s `"$($package.FullName)`""
                        try {
                            $proclist += Start-Process -FilePath "regedit.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                    ".ps1" {
                        $arguments = "& `"'$($package.FullName)'`""
                        try {
                            $proclist += Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                    ".vbs" {
                        $arguments = "`"$($package.FullName)`""
                        try {
                            $proclist += Start-Process -FilePath "wscript.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                }
            }
        }
        Complete-ProgressForm -Status "Installation Complete"
    }
    else {
        Show-Message "No packages selected."
    }
}

# Uninstall packages
function Uninstall($selectedDirectories) {
    if ($selectedDirectories.Count -gt 0) {
        $progressForm, $progressLabel, $progressBar = Show-ProgressForm
        foreach ($selectedDirectory in $selectedDirectories) {
            $directoryPath = Join-Path -Path $softwarePath -ChildPath $selectedDirectory.Name
            $packages = Get-ChildItem $directoryPath | Where-Object { $_.Extension -match "/*.(msi)$" -or $_.Name -match '\.uninstaller\.\w+$' }

            $currentPackage = 0
            $progress = 0
            foreach ($package in $packages) {
                $currentPackage++
                $progress++

                $status = "Uninstalling $($selectedDirectory.Name) ($($currentPackage)/$($packages.count))..."
                $percentComplete = ($progress / $packages.Count) * 100
                Update-ProgressForm -progressForm $progressForm -progressLabel $progressLabel -progressBar $progressBar -status $status -percentComplete $percentComplete

                $extension = $package.Extension
                switch ($extension) {
                    ".msi" {
                        $arguments = "/x `"$($package.FullName)`" /quiet /norestart"
                        try {
                            $proclist += Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                    ".ps1" {
                        $arguments = "& `"'$($package.FullName)'`""
                        try {
                            $proclist += Start-Process -FilePath "powershell.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                    ".vbs" {
                        $arguments = "`"$($package.FullName)`""
                        try {
                            $proclist += Start-Process -FilePath "wscript.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                    ".reg" {
                        $arguments = "/s `"$($package.FullName)`""
                        try {
                            $proclist += Start-Process -FilePath "regedit.exe" -ArgumentList $arguments -Wait -NoNewWindow
                        }
                        catch {
                            Show-Message -message $_.Exception.Message
                            Save-Log $package $_.Exception.Message
                        }
                    }
                }
            }
        }
        Complete-ProgressForm -Status "Uninstall Complete"
    }
    else {
        Show-Message "No packages selected."
    }
}

# Install packages function connected to UI
function Install-Package($selectedDirectories) {
    Install $selectedDirectories
}

# Uninstall packages function connected to UI
function Uninstall-Package($selectedDirectories) {
    Uninstall $selectedDirectories
}

# Get all directories in software folder
$packageDirectories = Get-ChildItem $softwarePath -Directory

# Show main window
$selectedDirectories = Show-PackageSelectionForm $packageDirectories
