<<<<<<< HEAD
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
=======
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
>>>>>>> c5a6cdd067f877cc0b8365c91a6159ba2844e96a
