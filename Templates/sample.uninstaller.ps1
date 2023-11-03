# Path: Templates/sample.uninstaller.ps1

# Locations
$logPath = ".\logs"

# Program to uninstall
$program = "Sample"

# Check if log folder exist if not create it
if (-not (Test-Path -Path $logPath)) {
    Write-Verbose "Log directory not found. Creating directory..."
    New-Item -Path $logPath -ItemType Directory
}

# Functions
function Save-Log($message) {
    $logFile = Join-Path -Path $logPath -ChildPath ("Log_" + (Get-Date -Format "yyyyMMdd_HHmmss") + ".txt")
    $logMessage = "$(Get-Date) : $message"
    Add-Content -Path $logFile -Value $logMessage
    Write-Verbose $logMessage
}

function Remove-Program {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param([string] $program)

    if($PSCmdlet.ShouldProcess($program, 'Uninstall')) {
        Get-CimInstance -Class Win32_Product | Where-Object { $_.Name -eq $program } | Invoke-CimMethod -MethodName "Uninstall"
        Write-Verbose "Removing $program"
    }
}

try {
    Remove-Program -program $program -Verbose -ErrorAction SilentlyContinue
}
catch {
    Save-Log $_.Exception.Message
}
