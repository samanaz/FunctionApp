Function New-RIAzSQLQuerry{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    $SQLServerInstance,
    [string]
    $DatabaseName,
    [string]
    $Querry,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName
    
    
    )
    $Domain=".database.windows.net"
    $SQLServerInstanceFullName="$SQLServerInstance$Domain"
    $Creds=Get-RIAzSQLServerCredential -KeyVaultName $KeyvaultName -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName
    if($Creds){$Result=Invoke-Sqlcmd -Query $Querry -ServerInstance $SQLServerInstanceFullName -Database $DatabaseName -Credential $creds}
    Return $Result

}
Function Get-RIAzSQLMasterUsername{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    [string]
    $SQLServerInstance,
    #[ValidateSet('master','auth','planning','order')]
    #$DatabaseName,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName,
    [string]
    $InternalSQLDatabaseUsername
    
    )
    
    
    $Querry="SELECT [Name] FROM [master].[sys].[sql_logins] WHERE [name] = '$InternalSQLDatabaseUsername'"
    $Result=New-RIAzSQLQuerry -KeyVaultName $KeyVaultName -SQLServerInstance $SQLServerInstance -DatabaseName "master" -Querry $Querry -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName
    if($Result.Name -eq $InternalSQLDatabaseUsername){Write-Host "SQL Server: SQL Internal User $InternalSQLDatabaseUsername exist."}else{Write-Host "SQL Server: User $InternalSQLDatabaseUsername does not exist. It is possible to create user $InternalSQLDatabaseUsername."}
    Return $Result.Name
    
}
Function New-RIAzSQLMasterUsername{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    [string]
    $SQLServerInstance,
    #[ValidateSet('master','auth','planning','order')]
    #$DatabaseName,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName,
    [string]
    $InternalSQLDatabaseUsername,
    [string]
    $InternalSQLDatabasePassword
    
    )
    
    $InternalDatabaseUsernameCheck=Get-RIAzSQLMasterUsername -KeyVaultName $KeyvaultName -SQLServerInstance $SQLServerInstance -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName -InternalSQLDatabaseUsername $InternalSQLDatabaseUsername 
    if($InternalDatabaseUsernameCheck -eq $null){$Querry="CREATE LOGIN [$InternalSQLDatabaseUsername] WITH PASSWORD = '$InternalSQLDatabasePassword'"}
    if($InternalDatabaseUsernameCheck -eq $null){$AddSQLUser=New-RIAzSQLQuerry -KeyVaultName $KeyvaultName -SQLServerInstance $SQLServerInstance -DatabaseName "master" -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName -Querry $Querry}
    if($InternalDatabaseUsernameCheck -eq $null -and $AddSQLUser -eq $null){Write-Host "SQL Server: User $InternalSQLDatabaseUsername has been successfully created."}
    Return $InternalSQLDatabaseUsername
}
Function Get-RIAzSQLInternalDatabaseUsername{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    [string]
    $SQLServerInstance,
    #[ValidateSet('master','auth','planning','order')]
    $DatabaseName,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName,
    [string]
    $InternalSQLDatabaseUsername
    
    )
    
    $FullDatabaseName=Get-RIAzSqlDatabaseName -System $System -FunctionName $DatabaseName -Environment $Environment
    $Querry="SELECT [Name] FROM [$FullDatabaseName].[sys].[database_principals] WHERE [name] = '$InternalSQLDatabaseUsername'"
    $Result=New-RIAzSQLQuerry -KeyVaultName $KeyVaultName -SQLServerInstance $SQLServerInstance -DatabaseName $FullDatabaseName -Querry $Querry -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName
    if($Result.Name -eq $InternalSQLDatabaseUsername){Write-Host "SQL Server: SQL Internal User $InternalSQLDatabaseUsername exist."}else{Write-Host "SQL Server: User $InternalSQLDatabaseUsername does not exist. It is possible to create user $InternalSQLDatabaseUsername."}
    Return $Result.Name
    
}
Function New-RIAzSQLInternalDatabaseUsername{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    [string]
    $SQLServerInstance,
    #[ValidateSet('master','auth','planning','order')]
    $DatabaseName,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName,
    [string]
    $InternalSQLDatabaseUsername,
    [string]
    $InternalSQLDatabasePassword
    
    )
    $FullDatabaseName=Get-RIAzSqlDatabaseName -System $System -FunctionName $DatabaseName -Environment $Environment
    $InternalDatabaseUsernameCheck=Get-RIAzSQLInternalDatabaseUsername -KeyVaultName $KeyvaultName -SQLServerInstance $SQLServerInstance -DatabaseName $DatabaseName -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName -InternalSQLDatabaseUsername $InternalSQLDatabaseUsername
    if($InternalDatabaseUsernameCheck -eq $null){$Querry="CREATE USER [$InternalSQLDatabaseUsername] FOR LOGIN [$InternalSQLDatabaseUsername] WITH DEFAULT_SCHEMA = dbo;"}
    if($InternalDatabaseUsernameCheck -eq $null){$AddSQLUser=New-RIAzSQLQuerry -KeyVaultName $KeyvaultName -SQLServerInstance $SQLServerInstance -DatabaseName $FullDatabaseName -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName -Querry $Querry}
    if($InternalDatabaseUsernameCheck -eq $null -and $AddSQLUser -eq $null){Write-Host "SQL Server: User $InternalSQLDatabaseUsername has been successfully created."}
    Return $InternalSQLDatabaseUsername
}
Function Set-RIAzSQLInternalDatabasePermission{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $Location,
    [string]
    $System,
    [string]
    $Environment,
    [string]
    $KeyVaultName,
    [string]
    $SQLServerInstance,
    [string]
    $DatabaseName,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName
    )
    $FullDatabaseName=Get-RIAzSqlDatabaseName -System $System -FunctionName $DatabaseName -Environment $Environment
    Write-Host "SQL Server: Connecting to $SQLServerInstance"
    $Querry="ALTER ROLE db_owner ADD MEMBER [$InternalSQLDatabaseUsername];"
    New-RIAzSQLQuerry -KeyVaultName $KeyVaultName -SQLServerInstance $SQLServerInstance -DatabaseName $FullDatabaseName -Querry $Querry -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName 
    Write-Host "SQL Server: User permission for database $FullDatabaseName has been set to db_owner"
    
}
Function Set-RIAzSQLFirewallRule{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $Location,
    [string]
    $System,
    [string]
    $Environment,
    [string]
    $ResourceGroupName,
    [string]
    $SQLServerInstance
    
    
    )
    $PublicIpAddress=(Invoke-WebRequest -uri "http://ifconfig.me/ip").Content
    $SQLServerFirewallRuleName=Get-RIAzSqlServerFirewallRuleName -Location $Location -System $System -Environment $Environment
    $FirewallRuleCheck=Get-AzSqlServerFirewallRule -FirewallRuleName $SQLServerFirewallRuleName -ServerName $SQLServerInstance -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if($FirewallRuleCheck.FirewallRuleName -eq $SQLServerFirewallRuleName){Write-Host "SQL Server: Firewall Rule $SQLServerFirewallRuleName exist. Creating Firewall Rule $SQLServerFirewallRuleName has been skipped."}else{$NewServerFirewallRule=New-AzSqlServerFirewallRule -ServerName $SQLServerInstance -ResourceGroupName $ResourceGroupName -FirewallRuleName $SQLServerFirewallRuleName -StartIpAddress $PublicIpAddress -EndIpAddress $PublicIpAddress}
    if($NewServerFirewallRule){Write-Host "SQL Server: Firewall Rule $SQLServerFirewallRuleName has been created."}
    }
Function Remove-RIAzSQLFirewallRule{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $Location,
    [string]
    $System,
    [string]
    $Environment,
    [string]
    $ResourceGroupName,
    [string]
    $SQLServerInstance
    
    
    )
    
    $SQLServerFirewallRuleName=Get-RIAzSqlServerFirewallRuleName -Location $Location -System $System -Environment $Environment
    $FirewallRuleCheck=Get-AzSqlServerFirewallRule -FirewallRuleName $SQLServerFirewallRuleName -ServerName $SQLServerInstance -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    if($FirewallRuleCheck.FirewallRuleName -eq $SQLServerFirewallRuleName){$NewRemoveFirewallRule=Remove-AzSqlServerFirewallRule -ServerName $SQLServerInstance -ResourceGroupName $ResourceGroupName -FirewallRuleName $SQLServerFirewallRuleName -Force}else{Write-Host "SQL Server: Firewall Rule $SQLServerFirewallRuleName does not exist. Removing Firewall Rule $SQLServerFirewallRuleName has been skipped."}
    if($NewRemoveFirewallRule){Write-Host "SQL Server: Firewall Rule $SQLServerFirewallRuleName has been removed."}
    }
Function Set-RIAzSQLDatabaseGroup{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $Location,
    [string]
    $System,
    [string]
    $Environment,
    [string]
    [ValidateSet('master','auth','planning','order')]
    $DatabaseName
    
    )
    $KeyVaultName=Get-RIAzKeyVaultName -Location $Location -System $System -Environment $Environment
    New-RIAzKeyvaultSQLServerMasterCredential -Location $Location -System $System -Environment $Environment -KeyVaultName $KeyVaultName
    $RG=Get-RIAzResourceGroupName -Location $Location -System $System -ResourceType "DB" -Environment $Environment
    
    $SQLServerInstance=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
    $UserNameSecretName=Get-RIAzKeyvaultSqlServerRootUserNameSecretName -Location $Location -System $System -Environment $Environment
    $PasswordSecretName=Get-RIAzKeyvaultSqlServerRootPasswordSecretName -Location $Location -System $System -Environment $Environment
    $InternalSQLDatabaseKeyvaultSecretUsername=Get-RIAzKeyvaultSqlServerMasterUserNameSecretName -Location $Location -System $System -Environment $Environment
    $InternalSQLDatabaseUsername=Get-RIAzKeyvaultSecret -KeyVaultName $KeyVaultName -SecretName $InternalSQLDatabaseKeyvaultSecretUsername
    $InternalSQLDatabaseKeyvaultSecretPassword=Get-RIAzKeyvaultSqlServerMasterPasswordSecretName -Location $Location -System $System -Environment $Environment
    $InternalSQLDatabasePassword=Get-RIAzKeyvaultSecret -KeyVaultName $KeyVaultName -SecretName $InternalSQLDatabaseKeyvaultSecretPassword
    Set-RIAzSQLFirewallRule -Location $Location -System $System -Environment $Environment -ResourceGroupName $RG -SQLServerInstance $SQLServerInstance
    if($DatabaseName -eq "master"){New-RIAzSQLMasterUsername -KeyVaultName $KeyvaultName -SQLServerInstance $SQLServerInstance -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName -InternalSQLDatabaseUsername $InternalSQLDatabaseUsername -InternalSQLDatabasePassword $InternalSQLDatabasePassword}
    New-RIAzSQLInternalDatabaseUsername -KeyVaultName $KeyvaultName -SQLServerInstance $SQLServerInstance -DatabaseName $DatabaseName -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName -InternalSQLDatabaseUsername $InternalSQLDatabaseUsername -InternalSQLDatabasePassword $InternalSQLDatabasePassword
    Set-RIAzSQLInternalDatabasePermission -Location $Location -System $System -Environment $Environment -KeyVaultName $KeyvaultName -SQLServerInstance $SQLServerInstance -DatabaseName $DatabaseName -UserNameSecretName $UserNameSecretName -PasswordSecretName $PasswordSecretName
    Remove-RIAzSQLFirewallRule -Location $Location -System $System -Environment $Environment -ResourceGroupName $RG -SQLServerInstance $SQLServerInstance
}