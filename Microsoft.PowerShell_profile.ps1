$LSCustomFormatURL = "https://raw.githubusercontent.com/scifisatan/PowerShell/main/CustomLSFormat.format.ps1xml"
$ModulePath = $env:PSModulePath.Split(';')[0]
function cleanerls{
    Get-ChildItem | Format-Wide 
}

function fixFormatXML {
    curl $LSCustomFormatUrl >  $ModulePath\Terminal-Icons\0.11.0\Terminal-Icons.format.ps1xml
}

function installPoShFuck {
    $pfk = (Join-Path $env:temp "poshfuck.zip")
    $dst = (Join-Path $env:PSModulePath.Split(';')[0] PoShFuck)

    mkdir $dst -ea SilentlyContinue
   
    [Net.ServicePointManager]::SecurityProtocol = "tls12"
    Invoke-WebRequest 'https://github.com/mattparkes/PoShFuck/archive/master.zip' -OutFile $pfk

    $shell = New-Object -ComObject Shell.Application; $shell.Namespace($dst).copyhere(($shell.NameSpace($pfk)).items(),20)

    Move-Item "$dst\PoShFuck-master\*" "$dst" -Force
    Remove-Item "$dst\PoShFuck-master" -Recurse -Force
    Remove-Item $pfk -Force

}

function checkModule {
    param (
        [string]$ModuleName
    )

    ##checking if it's installed or not
    if (!(Get-Module -ListAvailable -Name $ModuleName)) {
        Write-Host "Module $ModuleName is not installed"

        if ($ModuleName -eq "PoShFuck"){
            installPoShFuck
        }

        Install-Module -Name $ModuleName 
    }
}

# ------------------------ Main ------------------------
$modules = @(
    "Terminal-Icons",
    "z",
    "PoShFuck"
)

foreach ($module in $modules) {
    try {
        Import-Module $module 
    }
    catch {
        checkModule $module
    }
   
}


try {
    $ENV:STARSHIP_CONFIG = "$ModulePath\..\terminalConfig.toml"
    Invoke-Expression (&starship init powershell)
}
catch {
    starship preset nerd-font-symbols -o $ModulePath\..\terminalConfig.toml
}


Set-Alias -Name ls -Value cleanerls -Option AllScope
New-Alias -Name fixls -Value fixFormatXML
Set-Alias -Name pn -Value pnpm
