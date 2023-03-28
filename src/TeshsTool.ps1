<#
Copyright (c) 2023 Seth Earnhardt

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
"Software"), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

Add-Type -AssemblyName System.Windows.Forms

# UI Logic
function Show-PackageSelectionForm ($packages) {
    $selectedPackages = New-Object System.Collections.Generic.List[object]

    # Package Selection Form
    $packageSelectionForm = New-Object System.Windows.Forms.Form
    $packageSelectionForm.Text = "TeshsTool-Select Packages"
    $packageSelectionForm.Size = New-Object System.Drawing.Size(420, 450)
    $packageSelectionForm.StartPosition = "CenterScreen"

     # Load the icon and set it as the form's icon
    $appIconPath = "./Assets/AppIcon.ico"
    $packageSelectionForm.Icon = New-Object System.Drawing.Icon($appIconPath)

    $checkedListBox = New-Object System.Windows.Forms.CheckedListBox
    $checkedListBox.Size = New-Object System.Drawing.Size(360, 350)
    $checkedListBox.Location = New-Object System.Drawing.Point(20, 20)
    $checkedListBox.Font = New-Object System.Drawing.Font("Microsoft Sans Serif", 12) # Adjust the font size here
    foreach ($package in $packages) {
        $checkedListBox.Items.Add($package.Name, $false)
    }
    $packageSelectionForm.Controls.Add($checkedListBox)

    $selectAllButton = New-Object System.Windows.Forms.Button
    $selectAllButton.Text = "Select All"
    $selectAllButton.Location = New-Object System.Drawing.Point(20, 375)
    $selectAllButton.Size = New-Object System.Drawing.Size(75, 23)
    $selectAllButton.Add_Click({ 
        for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
            $checkedListBox.SetItemChecked($i, $true)
        }
    })
    $packageSelectionForm.Controls.Add($selectAllButton)

    $deselectAllButton = New-Object System.Windows.Forms.Button
    $deselectAllButton.Text = "Deselect All"
    $deselectAllButton.Location = New-Object System.Drawing.Point(100, 375)
    $deselectAllButton.Size = New-Object System.Drawing.Size(75, 23)
    $deselectAllButton.Add_Click({ 
        for ($i = 0; $i -lt $checkedListBox.Items.Count; $i++) {
            $checkedListBox.SetItemChecked($i, $false)
        }
    })
    $packageSelectionForm.Controls.Add($deselectAllButton)

    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Text = "Cancel"
    $cancelButton.DialogResult = "Cancel"
    $cancelButton.Location = New-Object System.Drawing.Point(225, 375)
    $cancelButton.Size = New-Object System.Drawing.Size(75, 23)
    $packageSelectionForm.Controls.Add($cancelButton)
    $packageSelectionForm.CancelButton = $cancelButton

    $installbutton = New-Object System.Windows.Forms.Button
    $installbutton.Text = "Install"
    $installbutton.DialogResult = "Ok"
    $installbutton.Location = New-Object System.Drawing.Point(305, 375)
    $installbutton.Size = New-Object System.Drawing.Size(75, 23)
    $packageSelectionForm.Controls.Add($installbutton)
    $packageSelectionForm.AcceptButton = $installbutton
    $packageSelectionForm.Controls.Add($deselectAllButton)

    if ($packageSelectionForm.ShowDialog() -eq "Ok") {
        for ($i = 0; $i -lt $packages.Count; $i++) {
            if ($checkedListBox.GetItemChecked($i)) {
                $selectedPackages.Add($packages[$i])
            }
        }
    }

    return $selectedPackages
}

function Show-ProgressForm ($totalPackages) {
    # Progress Form
    $progressForm = New-Object System.Windows.Forms.Form
    $progressForm.Text = "Installing Packages"
    $progressForm.Size = New-Object System.Drawing.Size(420, 150)
    $progressForm.StartPosition = "CenterScreen"

     # Load the icon and set it as the form's icon
    $appIconPath = "./Assets/AppIcon.ico"
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

# Main Logic
$folderPath = ".\Software\"
$packages = Get-ChildItem $folderPath -Include *.exe,*.msi,*.reg -Recurse |  Sort-Object @{Expression={if($_.Extension -eq ".reg"){"0"}else{"1"+$_.Extension}}}

$selectedPackages = Show-PackageSelectionForm -packages $packages
$totalPackages = $selectedPackages.Count
$progress = 0

if ($totalPackages -gt 0) {
    $progressForm, $progressLabel, $progressBar = Show-ProgressForm -totalPackages $totalPackages

    foreach ($package in $selectedPackages) {
        $arguments = "/qn"
        
        if($package.Extension -eq ".exe")
        {
            $arguments = "-s"
            Start-Process -FilePath $package.FullName -ArgumentList $arguments -Wait
        }
        elseif($package.Extension -eq ".msi"){
            $arguments = "/qn /i `"$($package.FullName)`""
            Start-Process -FilePath "msiexec.exe" -ArgumentList $arguments -Wait
        }
        elseif($package.Extension -eq ".reg")
        {
            Start-Process -FilePath "reg.exe" -ArgumentList "import `"$($package.FullName)`"" -Wait
        }

        $progress++
        $percentComplete = ($progress / $totalPackages) * 100
        $status = "Installing $($package.Name)..."

        Update-ProgressForm -progressForm $progressForm -progressLabel $progressLabel -progressBar $progressBar -status $status -percentComplete $percentComplete
    }

    $progressLabel.Text = "Installation complete!"
    $progressBar.Value = 100
    $progressForm.Refresh()
    Start-Sleep -Seconds 5
    $progressForm.Close()
} else {
    Write-Host "No packages selected. Exiting."
}