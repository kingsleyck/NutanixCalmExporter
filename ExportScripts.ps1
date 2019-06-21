<#
    This script will extract scripts from Calm Blueprints and output
    to the /Scripts folder using the naming convention:
    
    <SubstrateName>_<ActionName>_<TaskOrder>_<TaskName>
    <ServiceName>_<ActionName>_<TaskOrder>_<TaskName>

    Tested on:

    PS Core 6.1
    Nutanix Calm 2.6, 2.7
    
    Author: Chris Kingsley
#>

Remove-Item ./Scripts/ -Recurse -Force -ErrorAction SilentlyContinue

$Blueprints = Get-ChildItem $pwd *.json

foreach ($Blueprint in $Blueprints)
{
    $Json = Get-Content $Blueprint.FullName | ConvertFrom-Json

    $OutputPath = "$(Split-Path $Blueprint -Parent)/Scripts/$((Split-Path $Blueprint -Leaf).Replace('.json',''))"

    if (-not (Test-Path $OutputPath))
    {
        $null = New-Item -Path $OutputPath -ItemType Directory
    }
    
    $Substrates = $Json.spec.resources.substrate_definition_list

    foreach ($Substrate in $Substrates)
    {
        $SubstrateName = $Substrate.name
        
        $Actions = $Substrate.action_list

        foreach ($Action in $Actions)
        {
            $Tasks = $Action.runbook.task_definition_list
    
            $Count = 0
            foreach ($Task in $Tasks)
            {
                $TaskName = $Task.name
 
                if ($Task.type -eq "EXEC" -or $Task.type -eq "SET_VARIABLE")
                {
                    $ScriptType = ".py"

                    $OutputFile = "$($SubstrateName)_$($Action.name)_$($Count)_$($TaskName)$ScriptType"

                    Write-Output "Generating file: $OutputFile."
                    $Task.attrs.script | Out-File -FilePath $OutputPath\$OutputFile -Force
                }
                
                $Count++
            }
        }
    }

    $Services = $Json.spec.resources.service_definition_list

    foreach ($Service in $Services)
    {
        $ServiceName = $Service.name
        $Actions = $Service.action_list
    
        foreach ($Action in $Actions)
        {
            $Tasks = $Action.runbook.task_definition_list
            
            $count = 1
            foreach ($Task in $Tasks)
            {
                $TaskName = $Task.name

                if ($Task.type -eq "EXEC" -or $Task.type -eq "SET_VARIABLE")
                {
                    switch ($Task.attrs.script_type)
                    {
                        "static" { $ScriptType = ".py" }
                        "npsscript" { $ScriptType = ".ps1" }
                        "sh" { $ScriptType = ".sh" }
                        Default { $ScriptType = ".txt" }
                    }

                    $OutputFile = "$($ServiceName)_$($Action.name)_$($Count)_$($TaskName)$ScriptType"

                    Write-Output "Generating file: $OutputFile."
                    $Task.attrs.script | Out-File -FilePath $OutputPath\$OutputFile -Force
                }
                
                $Count++
            }
        }
    }
}