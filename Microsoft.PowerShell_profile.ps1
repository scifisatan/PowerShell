$LSCustomFormatURL = "https://raw.githubusercontent.com/scifisatan/PowerShell/main/CustomLSFormat.format.ps1xml"
$ModulePath = $env:PSModulePath.Split(';')[0]
function cleanerls{
    Get-ChildItem | Format-Wide -Column 1
}

function fixFormatXML {
    Invoke-RestMethod $LSCustomFormatUrl >  $ModulePath\Terminal-Icons\0.5.0\Terminal-Icons.format.ps1xml
}

function installPoShFuck {
    $tmp = (Join-Path $env:temp "poshfuck.zip")
    $dst = (Join-Path $ModulePath PoShFuck)

    Invoke-WebRequest 'https://github.com/mattparkes/PoShFuck/archive/master.zip' -OutFile $tmp
    
    Move-Item "$dst\PoShFuck-master\*" "$dst" -Force
    Remove-Item "$dst\PoShFuck-master" -Recurse -Force
    Remove-Item $tmp -Force

}

function checkModule {
    param (
        [string]$ModuleName
    )

    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName is not installed"
        if ($ModuleName -eq "PoShFuck"){
            installPoShFuck
        }

        Install-Module -Name $ModuleName -Force -SkipPublisherCheck
    }
}

$modules = @(
    "Terminal-Icons",
    "z",
    "PoShFuck"
)

foreach ($module in $modules) {
    checkModule $module
    Import-Module $module
}

#custom format for terminal-icons in format-wide

$ENV:STARSHIP_CONFIG = "C:\Users\Abi\terminalConfig.toml"
Invoke-Expression (&starship init powershell)

New-Alias -Name ls -Value cleanerls -Force
New-Alias -Name fixls -Value fixFormatXML
