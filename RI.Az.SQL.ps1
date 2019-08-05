Function Get-RIAzSqlDatabaseEdition {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Small','Medium','Large')]
        $Size,
        [string]
        [ValidateSet('Prod','Cert','Dev')]
        $Environment
    )
    # some logic in here
    if($Size -eq "Small" -and $Environment -eq "Dev"){$Edition=Write-Output "Standard"}
    if($Size -ne "Medium" -and $Environment -ne "Dev"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    if($Size -eq "Medium" -and $Environment -eq "Prod"){$Edition=Write-Output "Premium"}
    elseif($Size -eq "Medium" -and $Environment -eq "Cert"){$Edition=Write-Output "Premium"}
    elseif($Size -eq "Medium" -and $Environment -eq "Dev"){$Edition=Write-Output "Standard"}
    elseif($Size -eq "Large" -and $Environment -eq "Dev"){$Edition=Write-Output "Standard"}
    $Edition
}
Function Get-RIAzSqlDatabaseDTU {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Small','Medium','Large')]
        $Size,
        [string]
        [ValidateSet('Prod','Cert','Dev')]
        $Environment,
        [string]
        [ValidateSet('auth','master','order','planning')]
        $DatabaseType
    )
    if($Size -ne "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "auth"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    if($Size -ne "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "master"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    if($Size -ne "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "planning"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    if($Size -ne "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "order"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}

    if($Size -ne "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "auth"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    if($Size -ne "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "master"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    if($Size -ne "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "planning"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    if($Size -ne "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "order"){Write-Host "The current accepted size is Medium. Please choose Medium. Other sizes are not in effect currently."}
    
    if($Size -ne "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "auth"){Write-Host "The current accepted size for Dev auth database environment is Small. Please choose Small. Other sizes are not in effect currently."}
    if($Size -ne "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "master"){Write-Host "The current accepted size for Dev master database environment is Small. Please choose Small. Other sizes are not in effect currently."}
    if($Size -ne "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "planning"){Write-Host "The current accepted size for Dev planning database environment is Small. Please choose Small. Other sizes are not in effect currently."}
    if($Size -ne "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "order"){Write-Host "The current accepted size for Dev order database environment is Small. Please choose Small. Other sizes are not in effect currently."}
    
    if($Size -eq "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "auth")
    {$DTU=Write-Output "P2"}
    elseif($Size -eq "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "master")
    {$DTU=Write-Output "P4"}
    elseif($Size -eq "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "planning")
    {$DTU=Write-Output "P6"}
    elseif($Size -eq "Medium" -and $Environment -eq "Prod" -and $DatabaseType -eq "order")
    {$DTU=Write-Output "P4"}
    elseif($Size -eq "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "auth")
    {$DTU=Write-Output "P2"}
    elseif($Size -eq "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "master")
    {$DTU=Write-Output "P4"}
    elseif($Size -eq "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "planning")
    {$DTU=Write-Output "P6"}
    elseif($Size -eq "Medium" -and $Environment -eq "Cert" -and $DatabaseType -eq "order")
    {$DTU=Write-Output "P4"}
    elseif($Size -eq "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "auth")
    {$DTU=Write-Output "S1"}
    elseif($Size -eq "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "master")
    {$DTU=Write-Output "S2"}
    elseif($Size -eq "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "planning")
    {$DTU=Write-Output "S4"}
    elseif($Size -eq "Small" -and $Environment -eq "Dev" -and $DatabaseType -eq "order")
    {$DTU=Write-Output "S2"}
    $DTU
}
Function New-RIAzSqlServer {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        
        [string]
        $ResourceGroup,
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $KeyVaultName,
        [string]
        $System,
        [string]
        [ValidateSet('Prod','Cert','Dev')]
        $Environment
        
        
    )
    $UserNameSecretName=Get-RIAzKeyvaultSqlServerRootUserNameSecretName -Location $Location -System $System -Environment $Environment
    $PasswordSecretName=Get-RIAzKeyvaultSqlServerRootPasswordSecretName -Location $Location -System $System -Environment $Environment
    $SqlServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
    Write-Output "SQL Server $SqlServerName is being Created..."| Out-Host
    $SQLServer=Get-AzSqlServer -ResourceGroupName $ResourceGroup -ServerName $SqlServerName -ErrorAction SilentlyContinue
    $Credential=Get-RIAzSQLServerCredential -KeyVaultName $KeyVaultName -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName
    If($SqlServer.ServerName -eq $SqlServerName){Write-Host "SQL Server $SqlServerName Exist. This step has been skipped. "}else{$NewSQLServer=New-AzSqlServer -ServerName $SqlServerName -ResourceGroupName $ResourceGroup -SqlAdministratorCredentials $Credential -Location $Location}
    If($NewSQLServer.ServerName -eq $SqlServerName){Write-Output "SQL Server $SqlServerName has been created." | Out-Host}
    $SQLServer=Get-AzSqlServer -ResourceGroupName $ResourceGroup -ServerName $SqlServerName
    Return $SQLServer
}
Function New-RIAzSqlAuthDatabase {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        
        [string]
        $ServerName,
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Small','Medium','Large')]
        $Size,
        [string]
        [ValidateSet('Prod','Cert','Dev')]
        $Environment,
        [string]
        $System
    )
    $Edition = Get-RIAzSqlDatabaseEdition -Size $Size -Environment $Environment
    $Dtu = Get-RIAzSqlDatabaseDtu  -Size $Size -Environment $Environment -DatabaseType "auth"
    $DBName=Get-RIAzSqlDatabaseName -System $System -FunctionName "auth" -Environment $Environment
    Write-Output "$DBName-Database is being Created..."| Out-Host
    $AuthDB=Get-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    If($AuthDB.DatabaseName -eq $DBName){Write-Host "Database $DBName Exist. This step has been skipped."}else{$NewDB=New-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -Edition $Edition -RequestedServiceObjectiveName $DTU}
    If($NewDB.DatabaseName -eq $DBName){Write-Output "Database $DBName-Database has been created." | Out-Host }
}
Function New-RIAzSqlMasterDatabase {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        
        [string]
        $ServerName,
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Small','Medium','Large')]
        $Size,
        [string]
        [ValidateSet('Prod','Cert','Dev')]
        $Environment,
        [string]
        $System
    )
    $Edition = Get-RIAzSqlDatabaseEdition -Size $Size -Environment $Environment
    $Dtu = Get-RIAzSqlDatabaseDtu  -Size $Size -Environment $Environment -DatabaseType "master"
    $DBName=Get-RIAzSqlDatabaseName -System $System -FunctionName "master" -Environment $Environment
    Write-Output "$DBName-Database is being Created..."| Out-Host
    $MasterDB=Get-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    If($MasterDB.DatabaseName -eq $DBName){Write-Host "Database $DBName Exist. This step has been skipped."}else{$NewDB=New-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -Edition $Edition -RequestedServiceObjectiveName $DTU}
    If($NewDB.DatabaseName -eq $DBName){Write-Output "Database $DBName-Database has been created." | Out-Host }
}
Function New-RIAzSqlPlanningDatabase {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        
        [string]
        $ServerName,
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Small','Medium','Large')]
        $Size,
        [string]
        [ValidateSet('Prod','Cert','Dev')]
        $Environment,
        [string]
        $System
    )
    $Edition = Get-RIAzSqlDatabaseEdition -Size $Size -Environment $Environment
    $Dtu = Get-RIAzSqlDatabaseDtu  -Size $Size -Environment $Environment -DatabaseType "planning"
    $DBName=Get-RIAzSqlDatabaseName -System $System -FunctionName "planning" -Environment $Environment
    Write-Output "$DBName-Database is being Created..."| Out-Host
    $PlanningDB=Get-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    If($PlanningDB.DatabaseName -eq $DBName){Write-Host "Database $DBName Exist. This step has been skipped."}else{$NewDB=New-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -Edition $Edition -RequestedServiceObjectiveName $DTU}
    If($NewDB.DatabaseName -eq $DBName){Write-Output "Database $DBName-Database has been created." | Out-Host } 
}
Function New-RIAzSqlOrderDatabase {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        
        [string]
        $ServerName,
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Small','Medium','Large')]
        $Size,
        [string]
        [ValidateSet('Prod','Cert','Dev')]
        $Environment,
        [string]
        $System
    )
    
    
    
    
    $Edition = Get-RIAzSqlDatabaseEdition -Size $Size -Environment $Environment
    $Dtu = Get-RIAzSqlDatabaseDtu  -Size $Size -Environment $Environment -DatabaseType "order"
    $DBName=Get-RIAzSqlDatabaseName -System $System -FunctionName "order" -Environment $Environment
    Write-Output "$DBName-Database is being Created..."| Out-Host
    $OrderDB=Get-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    If($OrderDB.DatabaseName -eq $DBName){Write-Host "Database $DBName Exist. This step has been skipped."}else{$NewDB=New-AzSqlDatabase -DatabaseName $DBName -ServerName $ServerName -ResourceGroupName $ResourceGroupName -Edition $Edition -RequestedServiceObjectiveName $DTU}
    If($NewDB.DatabaseName -eq $DBName){Write-Output "Database $DBName-Database has been created." | Out-Host } 
}