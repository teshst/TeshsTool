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

$folderPath = ".\Software\"
$packages = Get-ChildItem $folderPath -Include *.exe,*.msi,*.reg -Recurse |  Sort-Object @{Expression={if($_.Extension -eq ".reg"){"0"}else{"1"+$_.Extension}}}
$totalPackages = $packages.Count
$progress = 0

Write-Progress -Activity "Installing packages" -Status "Preparing..." -PercentComplete 0


foreach ($package in $packages)
{
    $arguments = ""
    $filePath = ""
    
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
    Write-Progress -Activity "Installing packages" -Status $status -PercentComplete $percentComplete
}

Write-Progress -Activity "Installing packages" -Status "Installation complete!" -Completed
Start-Sleep -Seconds 20
