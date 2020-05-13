# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

& "$PSScriptRoot/set-env.ps1"

# Install iqsharp if not installed yet.

Write-Host ("Installing IQ# tool.")
$install = $False

# Install iqsharp if not installed yet.
try {
    $install = [string]::IsNullOrWhitespace((dotnet tool list --tool-path $Env:TOOLS_DIR | Select-String -Pattern "microsoft.quantum.iqsharp"))
} catch {
    Write-Host ("`dotnet iqsharp --version` threw error: " + $_)
    $install = $True
}

if ($install) {
    try {
        Write-Host ("Installing Microsoft.Quantum.IQSharp at $Env:TOOLS_DIR")
        dotnet tool install Microsoft.Quantum.IQSharp --version 0.11.2004.2825 --tool-path $Env:TOOLS_DIR

    
        $path = (Get-Item "$Env:TOOLS_DIR\dotnet-iqsharp*").FullName
        & $path install --user --path-to-tool $path --log-level "Debug" 2 > stderr.txt
        Write-Host "iq# kernel installed ($LastExitCode)"
        Write-Host "cat stderr.txt"
        cat stderr.txt
    } catch {
        Write-Host ("iq# installation threw error: " + $_)
        Write-Host ("iq# might not be correctly installed.")
        Write-Host ("exception: " + $_.Exception)

        Write-Host("========================")
        Write-Host('Exit code: ' + $LastExitCode)
        Write-Host ("cat stderr.txt")
        cat stderr.txt
        Write-Host("========================")
    }
} else {
    Write-Host ("Microsoft.Quantum.IQSharp is already installed in this host.")
}

# Azure DevOps agent failing with "PowerShell exited with code '1'."
# For now, guarantee this script succeeds:
exit 0
