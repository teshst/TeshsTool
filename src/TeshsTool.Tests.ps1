Describe "TeshsTool Tests" {
    # Test the Create-MainWindow function
    Context "Create-MainWindow" {
        It "Returns a valid window object" {
            $window = Create-MainWindow
            $window | Should -BeOfType [Windows.Window]
        }

        It "Has the correct title" {
            $window = Create-MainWindow
            $window.Title | Should -Be "TeshsTool-v1.1"
        }

        It "Has a ListBox control" {
            $window = Create-MainWindow
            $window.Content | Should -BeOfType [Windows.Controls.ListBox]
        }

        It "Has a Select All button" {
            $window = Create-MainWindow
            $window.Children | Should -Contain "Select All"
        }

        It "Has a Deselect All button" {
            $window = Create-MainWindow
            $window.Children | Should -Contain "Deselect All"
        }

        It "Has an Install button" {
            $window = Create-MainWindow
            $window.Children | Should -Contain "Install"
        }

        It "Has an Uninstall button" {
            $window = Create-MainWindow
            $window.Children | Should -Contain "Uninstall"
        }
    }

    # Test the Select-AllPackages function
    Context "Select-AllPackages" {
        It "Selects all packages in the ListBox" {
            $window = Create-MainWindow
            $listBox = $window.Content
            $listBox.Items.Add("Package 1")
            $listBox.Items.Add("Package 2")
            $listBox.Items.Add("Package 3")

            Select-AllPackages

            $listBox.Items | ForEach-Object {
                $_.IsSelected | Should -Be $true
            }
        }
    }

    # Test the Deselect-AllPackages function
    Context "Deselect-AllPackages" {
        It "Deselects all packages in the ListBox" {
            $window = Create-MainWindow
            $listBox = $window.Content
            $listBox.Items.Add("Package 1")
            $listBox.Items.Add("Package 2")
            $listBox.Items.Add("Package 3")

            Deselect-AllPackages

            $listBox.Items | ForEach-Object {
                $_.IsSelected | Should -Be $false
            }
        }
    }

    # Test the Install-Packages function
    Context "Install-Packages" {
        It "Installs selected packages" {
            $selectedPackages = @("Package 1", "Package 2", "Package 3")
            Install-Packages -selectedPackages $selectedPackages | Should -Be $true
        }
    }

    # Test the Uninstall-Packages function
    Context "Uninstall-Packages" {
        It "Uninstalls selected packages" {
            $selectedPackages = @("Package 1", "Package 2", "Package 3")
            Uninstall-Packages -selectedPackages $selectedPackages | Should -Be $true
        }
    }

    # Test the Create-ProgressWindow function
    Context "Create-ProgressWindow" {
        It "Returns a valid window object" {
            $window = Create-ProgressWindow
            $window | Should -BeOfType [Windows.Window]
        }

        It "Has the correct title" {
            $window = Create-ProgressWindow
            $window.Title | Should -Be "Installing Packages"
        }

        It "Has a Grid control" {
            $window = Create-ProgressWindow
            $window.Content | Should -BeOfType [Windows.Controls.Grid]
        }

        It "Has a Label control" {
            $window = Create-ProgressWindow
            $window.Content.Children | Should -Contain "Preparing..."
        }

        It "Has a ProgressBar control" {
            $window = Create-ProgressWindow
            $window.Content.Children | Should -Contain "ProgressBar"
        }
    }

    # Test the Update-ProgressWindow function
    Context "Update-ProgressWindow" {
        It "Updates the progress window" {
            $window = Create-ProgressWindow
            $grid = $window.Content
            $progressLabel = $grid.Children[0]
            $progressBar = $grid.Children[1]

            Update-ProgressWindow -progressWindow $window -progressLabel $progressLabel -progressBar $progressBar -status "Installing..." -percentComplete 50

            $progressLabel.Content | Should -Be "Installing..."
            $progressBar.Value | Should -Be 50
        }
    }

    # Test the Quit function
    Context "Quit" {
        It "Kills all started processes" {
            $process = Start-Process notepad -PassThru
            $proclist = @($process)

            Quit "Installation complete."

            $proclist | ForEach-Object {
                Get-Process -Id $_.Id -ErrorAction SilentlyContinue | Should -BeNullOrEmpty
            }
        }
    }
}