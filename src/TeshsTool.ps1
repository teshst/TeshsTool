Add-Type -AssemblyName System.Windows.Forms

# Locations
$appIconPath = ".\Assets\AppIcon.ico"
$softwarePath = ".\Software"
$uninstallPath = ".\Uninstallers"

# UI Elements
$packageSelectionForm = New-Object System.Windows.Forms.Form
$packageSelectionForm.Text = "TeshsTool-v1.1"
$packageSelectionForm.Size = New-Object System.Drawing.Size(420, 475)
$packageSelectionForm.StartPosition = "CenterScreen"

$checkedListBox = New-Object System.Windows.Forms.CheckedListBox
$checkedListBox.Size = New-Object System.Drawing.Size(360, 350)
$checkedListBox.Location = New-Object System.Drawing.Point(20, 20)
$checkedListBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12) # Adjust the font size here

$selectAllButton = New-Object System.Windows.Forms.Button
$selectAllButton.Text = "Select All"
$selectAllButton.Location = New-Object System.Drawing.Point(20, 375)
$selectAllButton.Size = New-Object System.Drawing.Size(75, 23)

$deselectAllButton = New-Object System.Windows.Forms.Button
$deselectAllButton.Text = "Deselect All"
$deselectAllButton.Location = New-Object System.Drawing.Point(100, 375)
$deselectAllButton.Size = New-Object System.Drawing.Size(75, 23)

$cancelButton = New-Object System.Windows.Forms.Button
$cancelButton.Text = "Cancel"
$cancelButton.DialogResult = "Cancel"
$cancelButton.Location = New-Object System.Drawing.Point(225, 375)
$cancelButton.Size = New-Object System.Drawing.Size(75, 23)

$installButton = New-Object System.Windows.Forms.Button
$installButton.Text = "Install"
$installButton.Location = New-Object System.Drawing.Point(305, 375)
$installButton.Size = New-Object System.Drawing.Size(75, 23)

$uninstallButton = New-Object System.Windows.Forms.Button
$uninstallButton.Text = "Uninstall"
$uninstallButton.Location = New-Object System.Drawing.Point(305, 400)
$uninstallButton.Size = New-Object System.Drawing.Size(75, 23)

function CheckedItems() {
  $selectedDirectories = New-Object System.Collections.Generic.List[System.IO.DirectoryInfo]

  for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
    if ($checkedListBox.GetItemChecked($i)) {
      $selectedDirectory = $packageDirectories | Where-Object { $_.Name -eq $checkedListBox.Items[$i] }
      if ($selectedDirectory) {
        $selectedDirectories.Add($selectedDirectory)
      }             
    }
  }
  return $selectedDirectories
}
# Main window for application
function Show-PackageSelectionForm ($packageDirectories) {

  # Load the icon and set it as the form's icon
  $packageSelectionForm.Icon = New-Object System.Drawing.Icon($appIconPath)

  # Add buttons to selection form
  $packageSelectionForm.Controls.Add($checkedListBox)

  $packageSelectionForm.Controls.Add($selectAllButton)
  $packageSelectionForm.Controls.Add($deselectAllButton)

  $packageSelectionForm.Controls.Add($cancelButton)
  $packageSelectionForm.CancelButton = $cancelButton

  $packageSelectionForm.Controls.Add($installButton)
  $packageSelectionForm.Controls.Add($uninstallButton)

  # Add Packages to selection form list
  foreach ($packageDirectory in $packageDirectories) {
    $checkedListBox.Items.Add($packageDirectory.Name, $false)
  }
    
  # Select and Deselect all packages in list
  $selectAllButton.Add_Click{ 
    for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
      $checkedListBox.SetItemChecked($i, $true)
    }
  }

  $deselectAllButton.Add_Click({ 
      for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
        $checkedListBox.SetItemChecked($i, $false)
      }
    })

  $installButton.Add_Click({ 
      $selectedDirectories = CheckedItems
      Install -totalPackageDirectories $totalPackageDirectories -selectedDirectories $selectedDirectories 
    })
    
  $uninstallButton.Add_Click({ 
      $selectedDirectories = CheckedItems
      Uninstall -totalPackageDirectories $totalPackageDirectories -selectedDirectories $selectedDirectories 
    })

  if ($packageSelectionForm.ShowDialog() -eq "Ok") {

  }

  return $selectedDirectories
}

function Show-ProgressForm () {
  # Progress Form
  $progressForm = New-Object System.Windows.Forms.Form
  $progressForm.Text = "Installing Packages"
  $progressForm.Size = New-Object System.Drawing.Size(420, 150)
  $progressForm.StartPosition = "CenterScreen"

  # Load the icon and set it as the form's icon
  $progressForm.Icon = New-Object System.Drawing.Icon($appIconPath)

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

function Update-ProgressForm ($progressForm, $progressLabel, $progressBar, $status, $percentComplete) {
  $progressLabel.Text = $status
  $progressBar.Value = [int]$percentComplete

  $progressForm.Refresh()
}

function Quit($Status) {

  $progressLabel.Text = $Status
  $progressBar.Value = 100
  $progressForm.Refresh()

  # Kill all started process
  foreach ($proc in $proclist) {
    Stop-Process -Id $proc.Id -Force -ErrorAction continue -Verbose
  }

  Start-Sleep -Seconds 3
  $progressForm.Close()
  $progressForm.Dispose()

  $packageSelectionForm.Close()
  $packageSelectionForm.Dispose()
}

function Install($totalPackageDirectories, $selectedDirectories) {
  $progress = 0

  if ($totalPackageDirectories -gt 0) {

    $progressForm, $progressLabel, $progressBar = Show-ProgressForm

    foreach ($selectedDirectory in $selectedDirectories) {

      $directoryPath = Join-Path -Path $softwarePath -ChildPath $selectedDirectory.Name
      $packages = Get-ChildItem $directoryPath | Where-Object { $_.Extension -match "/*.(exe|msi|reg|ps1|vbs)$" }

      foreach ($package in $packages) {

        # Update Progress Bar
        $status = "Installing $($package.Name)..."
        $percentComplete = ($progress / $totalPackageDirectories) * 100
              
        #Update Progress Bar
        $progress++
        
        Update-ProgressForm -progressForm $progressForm -progressLabel $progressLabel -progressBar $progressBar -status $status -percentComplete $percentComplete 

        $extension = $package.Extension

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
      Quit -Status "Installation Complete"
    }  
  }
  else {
    Write-Verbose "No packages selected."
  }
}

function Uninstall($totalPackageDirectories, $selectedDirectories) {
  $progress = 0

  if ($totalPackageDirectories -gt 0) {
    
    $progressForm, $progressLabel, $progressBar = Show-ProgressForm

    foreach ($selectedDirectory in $selectedDirectories) {

      $directoryPath = Join-Path -Path $uninstallPath -ChildPath $selectedDirectory.Name
      $packages = Get-ChildItem $directoryPath | Where-Object { $_.Extension -match "/*.(exe|msi|ps1|vbs)$" }

      foreach ($package in $packages) {

        # Update Progress Bar
        $status = "Uninstalling $($package.Name)..."
        $percentComplete = ($progress / $totalPackageDirectories) * 100
              
        #Update Progress Bar
        $progress++
        
        Update-ProgressForm -progressForm $progressForm -progressLabel $progressLabel -progressBar $progressBar -status $status -percentComplete $percentComplete 

        $extension = $package.Extension

        switch ($extension) {
          ".exe" {
            $arguments = " /S /v /qn"
            $proclist += Start-Process -FilePath $package.FullName -ArgumentList $arguments -Wait -NoNewWindow
          }
          ".msi" {
            $arguments = "/I `"$($package.FullName)`" /quiet"
            $proclist += Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait -NoNewWindow
          }
          ".ps1" {
            $arguments = "`"'$($package.FullName)'`""
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
    }
    Quit -Status "Uninstall Complete"
  }
  else {
    Write-Host "No packages selected."
  }
}

# Kill process on error
trap {

  Write-Host "Killed processes."
  # Kill all started process
  foreach ($proc in $proclist) {
    Stop-Process -Id $proc.Id -Force -ErrorAction continue -Verbose
  }
}

# Main Logic
$packageDirectories = Get-ChildItem $softwarePath -Directory
$totalPackageDirectories = $selectedDirectories.Count

$selectedDirectories = Show-PackageSelectionForm -packageDirectories $packageDirectories
