Function New-RIAzPassword{
Add-Type -AssemblyName System.Web
$Password = [System.Web.Security.Membership]::GeneratePassword(30,10)
$Password
}

Function New-RIAzSecret{

$Password = New-RIAzPassword
$Secret=ConvertTo-SecureString -String $Password -AsPlainText -Force
$Secret
}


Function New-RIAzSecretPassword{
[cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $Password
        )
$Secret=ConvertTo-SecureString -String $Password -AsPlainText -Force
$Secret
}
Function New-RIAzADGroup{
[cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $System,
        [string]
        $ResourceType,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        [ValidateSet('Owner','Contributor','Reader')]
        $RoleType,
        [string]
        $DomainName
        )

    $GroupName=Get-RIAzADGroupName -System $System -ResourceType $ResourceType -Environment $Environment -RoleType $RoleType
    Write-Output "Azure AD Group $GroupName is being Created..."| Out-Host
    $GroupCheck=Get-AzADGroup -DisplayName $GroupName -ErrorAction SilentlyContinue
    If($GroupCheck.DisplayName -eq $GroupName){Write-Host "Azure AD Group $GroupName Exist. This step has been skipped."}else{$NewGroup=New-AzADGroup -DisplayName $GroupName -MailNickname $GroupName}
    If($NewGroup.DisplayName -eq $GroupName){Write-Host "Azure AD Group $GroupName has been created."}
    $AzADGroup=Get-AzADGroup -DisplayName $GroupName
    Return $AzADGroup
}
Function New-RIAzADUser{
[cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $System,
        [string]
        $ResourceType,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        [ValidateSet('admin','user')]
        $RoleType,
        [string]
        $KeyvaultName,
        [string]
        $DomainName
        )
    
    $Password=New-RIAzPassword
    $Secret=New-RIAzSecretPassword -Password $Password
    $UserDisplayName=Get-RIAzADUserName -System $System -ResourceType $ResourceType -Environment $Environment -UserType admin
    $UserPrincipalName="$UserDisplayName@$DomainName"
    Write-Output "Azure AD User $UserDisplayName is being Created..."| Out-Host
    $UserCheck=Get-AzADUser -UserPrincipalName $UserPrincipalName -ErrorAction SilentlyContinue
    If($UserCheck.UserPrincipalName -eq $UserPrincipalName){Write-Host "Azure AD User $UserDisplayName Exist. Creating User $UserDisplayName has been skipped."}else{$NewUserName=New-AzADUser -DisplayName $UserDisplayName -UserPrincipalName $UserPrincipalName -Password $Secret -MailNickname $UserDisplayName}
    If($NewUserName.UserPrincipalName -eq $UserPrincipalName){Write-Host "Azure AD User $UserDisplayName has been created."}
    If($NewUserName.UserPrincipalName -eq $UserPrincipalName){Write-Host "KeyVault: Writing username and password to Keyvault $KeyvaultName."}
    If($NewUserName.UserPrincipalName -eq $UserPrincipalName){New-RIAzKeyVaultSecret -KeyVaultName $KeyvaultName -KeyVaultSecretName "$UserDisplayName-password" -SecretString $Password}
    If($NewUserName.UserPrincipalName -eq $UserPrincipalName){New-RIAzKeyVaultSecret -KeyVaultName $KeyvaultName -KeyVaultSecretName "$UserDisplayName-Account"  -SecretString $UserDisplayName}
    $AzADUser=Get-AzADUser -UserPrincipalName $UserPrincipalName
    Return $AzADUser
    
    

}
Function New-RIAzResourceGroup {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        $ResourceType,
        [string]
        [ValidateSet('Prd','crt','dev')]
        $Environment
    )
      
     $RGName=Get-RIAzResourceGroupName -Location $Location -System $System -ResourceType $ResourceType -Environment $Environment
     Write-Output "Resource Group $RGName is being Created..."| Out-Host
     $RG=Get-AzResourceGroup -Name $RGName -Location $Location -ErrorAction SilentlyContinue
     If($RG.ResourceGroupName -eq $RGName){Write-Host "Resource Group $RGName Exist. This step has been skipped. " }else{$NewRG = New-AzResourceGroup -Name $RGName -Location $Location}
     If($NewRG.ResourceGroupName -eq $RGName ){Write-Output "Resource Group $RGName has been created." | Out-Host}
     $RG=Get-AzResourceGroup -Name $RGName -Location $Location -ErrorAction SilentlyContinue
     Return $RG
}

Function New-RIAzKeyVaultUserPrincipalAccessPolicy {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        $KeyvaultName,
        [string]
        $DomainName
        
        
    )
    $ResourceType="keyvault"
    $ADGroup=New-RIAzADGroup -System $System -ResourceType $ResourceType -Environment $Environment -RoleType Owner
    $ADGroupDisplayName=$ADGroup.DisplayName
    $ADUser=New-RIAzADUser -System $System -ResourceType $ResourceType -Environment $Environment -RoleType admin -KeyvaultName $KeyvaultName -DomainName $DomainName
    $ADUserDiplayName=$ADUser.DisplayName
    $MemberCheck=Get-AzADGroupMember -GroupObjectId $ADGroup.Id | Select-Object DisplayName | Where-Object {$_.DisplayName -eq "$ADUserDiplayName"} | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
    If($MemberCheck -eq $ADUserDiplayName){Write-Host "The User is a member of AD Group $ADGroupDisplayName. This step has been skipped." }else{$NewMember=Add-AzADGroupMember -MemberUserPrincipalName $ADUser.UserPrincipalName -TargetGroupObjectId $ADGroup.Id}
    $MemberCheckAdd=Get-AzADGroupMember -GroupObjectId $ADGroup.Id | Select-Object DisplayName | Where-Object {$_.DisplayName -eq "$ADUserDiplayName"} | Select-Object -ExpandProperty DisplayName -ErrorAction SilentlyContinue
    If($MemberCheckAdd -eq $ADUserDiplayName){Write-Host "The User member of AD Group $ADGroupDisplayName has been added to the AD Group $ADGroupDisplayName." }
    $KeyVault=Get-AzKeyVault -VaultName $KeyvaultName -ErrorAction SilentlyContinue
    If($KeyVault.VaultName -eq $KeyvaultName){Set-AzKeyVaultAccessPolicy -VaultName $KeyvaultName -ObjectId $ADGroup.Id -PermissionsToSecrets set,get,list}else{Write-Host "Key Vault $KeyvaultName does not Exist. Setting access policy to $KeyvaultName has been skipped." -ForegroundColor Red}
    
}
Function New-RIAzKeyVaultServicePrincipalAccessPolicy {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        $KeyvaultName,
        [string]
        $ServicePrincipalObjectId,
        [string]
        $DomainName
        
        
    )
    $ResourceType="keyvault"
    $ADGroup=New-RIAzADGroup -System $System -ResourceType $ResourceType -Environment $Environment -RoleType Owner
    $ADGroupDisplayName=$ADGroup.DisplayName
    Add-AzADGroupMember -MemberObjectId $ServicePrincipalObjectId -TargetGroupObjectId $ADGroup.Id
    
}
Function New-RIAzKeyVault {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        $ResourceGroupName,
        [string]
        $SKU
        
    )
    
    
    
    $KVName= Get-RIAzKeyVaultName -Location $Location -System $System -Environment $Environment
    Write-Output "Key Vault $KVName is being Created..."| Out-Host
    $KeyVault=Get-AzKeyVault -VaultName $KVName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue
    If($KeyVault.VaultName -eq $KVName){Write-Host "Key Vault $KVName Exist. This step has been skipped. "}else{$NewKV=New-AzKeyVault -Name $KVName -ResourceGroupName $ResourceGroupName -Location $Location -Sku $SKU -EnabledForDeployment}
    If($NewKV.VaultName -eq $KVName){Write-Output "Key Vault $KVName has been created."| Out-Host}
    $KeyVault=Get-AzKeyVault -VaultName $KVName -ResourceGroupName $ResourceGroupName
    Return $KeyVault
}
Function Set-RIAzKeyVaultSecret(){
param(
        [Parameter(Mandatory)]
        [string]
        $KeyVaultName,
        [string]
        $KeyVaultSecretName,
        [string]
        $SecretString
        
        )
        $Keyvaultcheck=Get-AzKeyVault -VaultName $KeyVaultName -ErrorAction SilentlyContinue
        if($Keyvaultcheck){Write-Host "Key Vault $KeyVaultName Exist."}else{Write-Host "Key Vault $KeyVaultName does not Exist. Please create keyvault $KeyVaultName."}
        if($Keyvaultcheck){Write-Output "KeyVault: Checking $KeyVaultSecretName Secure Secret..."| Out-Host}else{break}
        $SecureSecret=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecretName -ErrorAction SilentlyContinue
        if($SecureSecret){Write-Host "Keyvault: Key $SecureSecretName exist. Creating secure secret $KeyVaultSecretName has been skipped."}else{$NewSecret = ConvertTo-SecureString -String $SecretString -AsPlainText -Force}
        if($NewSecret){Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecretName -SecretValue $NewSecret -ContentType Secret}
        if($NewSecret){Write-Host "Keyvault: Key $SecureSecretName has been created."}
}

Function Get-RIAzKeyvaultSecureSecret{
[cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    $SecureSecretName
    )
    Write-Output "KeyVault: Reading Secure Secret..."| Out-Host
    $SecureSecret=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecureSecretName -ErrorAction SilentlyContinue
    if($SecureSecret){Write-Host "Keyvault: Key $SecureSecretName exist and it is ready to use."}else{Write-Host "Keyvault: Key $SecureSecretName does not exist." -ForegroundColor Red}
    if($SecureSecret){$SecureSecret= Write-Output $SecureSecret.SecretValueText}
    if($SecureSecret){$SecureSecret= ConvertTo-SecureString -String $SecureSecret -AsPlainText -Force}
    Return $SecureSecret
}

Function Get-RIAzKeyvaultSecret{
[cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    $SecretName
    )
    Write-Output "KeyVault: Reading Secret..."| Out-Host
    $Secret=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -ErrorAction SilentlyContinue
    if($Secret){Write-Host "Keyvault: Key $SecretName exist and it is ready to use."}else{Write-Host "Keyvault: Key $SecretName does not exist." -ForegroundColor Red}
    if($Secret){$Secret = Write-Output $Secret.SecretValueText}
    Return $Secret
}

 Function New-RIAzSQLServerCredential{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    [ValidateSet('Australia East','Australia Southeast','West Europe')]
    $Location,
    [string]
    $System,
    [string]
    [ValidateSet('prd','crt','dev')]
    $Environment,
    [string]
    $KeyVaultName
    
    )
    $UserName=Get-RIAzADUserName -System $System -ResourceType "sql" -Environment $Environment -UserType admin
    $UsernameKeyvaultSecretName=Get-RIAzKeyvaultSqlServerRootUserNameSecretName -Location $Location -System $System -Environment $Environment
    $PasswordKeyvaultSecretName=Get-RIAzKeyvaultSqlServerRootPasswordSecretName -Location $Location -System $System -Environment $Environment
    Write-Output "KeyVault: SQL Server Root Account Check and Write..."| Out-Host
    $SQLServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
    $Secret=ConvertTo-SecureString -String $UserName -AsPlainText -Force
    $RootSQLAccount=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $UsernameKeyvaultSecretName
    If($RootSQLAccount.Name -eq $UsernameKeyvaultSecretName){Write-Host "Keyvault: $UsernameKeyvaultSecretName Exist. Writting $UsernameKeyvaultSecretName to Keyvault has been skipped."} else {$NewSecretUserName=Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $UsernameKeyvaultSecretName -SecretValue $Secret -ContentType Azure_SQL_Server_Root_Account -WarningAction SilentlyContinue}
    If($NewSecretUserName.Name -eq $UsernameKeyvaultSecretName){Write-Host "Key Vault: The SQL Username $UsernameKeyvaultSecretName has been created."}
    Write-Output "KeyVault: SQL Server Root Password Check and Write..."| Out-Host
    $RootSQLPassword=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $PasswordKeyvaultSecretName
    $Secret=New-RIAzSecret
    If($RootSQLPassword.Name -eq $PasswordKeyvaultSecretName){Write-Host "Keyvault: $PasswordKeyvaultSecretName Exist. Writing $PasswordKeyvaultSecretName to Keyvault has been skipped."} else {$NewSecretUserPassword=Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $PasswordKeyvaultSecretName -SecretValue $Secret -ContentType Azure_SQL_Server_Root_Password -WarningAction SilentlyContinue}
    If($NewSecretUserPassword.Name -eq $PasswordKeyvaultSecretName){Write-Host "Key Vault: The SQL Username $PasswordKeyvaultSecretName has been created."}
 }
 
 Function New-RIAzKeyvaultSQLServerMasterCredential{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    [ValidateSet('Australia East','Australia Southeast','West Europe')]
    $Location,
    [string]
    $System,
    [string]
    [ValidateSet('prd','crt','dev')]
    $Environment,
    [string]
    $KeyVaultName
    
    )
    $UserName=Get-RIAzADUserName -System $System -ResourceType "sqlmaster" -Environment $Environment -UserType admin
    $UsernameKeyvaultSecretName=Get-RIAzKeyvaultSqlServerMasterUserNameSecretName -Location $Location -System $System -Environment $Environment
    $PasswordKeyvaultSecretName=Get-RIAzKeyvaultSqlServerMasterPasswordSecretName -Location $Location -System $System -Environment $Environment
    Write-Output "KeyVault: SQL Server Internal Database Root Account Check and Write..."| Out-Host
    $SQLServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
    $Secret=ConvertTo-SecureString -String $UserName -AsPlainText -Force
    $RootSQLAccount=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $UsernameKeyvaultSecretName
    If($RootSQLAccount.Name -eq $UsernameKeyvaultSecretName){Write-Host "Keyvault: $UsernameKeyvaultSecretName Exist. Writting $UsernameKeyvaultSecretName to Keyvault has been skipped."} else {$NewSecretUserName=Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $UsernameKeyvaultSecretName -SecretValue $Secret -ContentType Azure_SQL_Server_Internal-Database_Root_Account -WarningAction SilentlyContinue}
    If($NewSecretUserName.Name -eq $UsernameKeyvaultSecretName){Write-Host "Key Vault: The SQL Username $UsernameKeyvaultSecretName has been created."}
    Write-Output "KeyVault: SQL Server Internal Database Root Password Check and Write..."| Out-Host
    $RootSQLPassword=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $PasswordKeyvaultSecretName
    $Secret=New-RIAzSecret
    If($RootSQLPassword.Name -eq $PasswordKeyvaultSecretName){Write-Host "Keyvault: $PasswordKeyvaultSecretName Exist. Writing $PasswordKeyvaultSecretName to Keyvault has been skipped."} else {$NewSecretUserPassword=Set-AzKeyVaultSecret -VaultName $KeyVaultName -Name $PasswordKeyvaultSecretName -SecretValue $Secret -ContentType Azure_SQL_Server-Internal-Database_Root_Password -WarningAction SilentlyContinue}
    If($NewSecretUserPassword.Name -eq $PasswordKeyvaultSecretName){Write-Host "Key Vault: The SQL Username $PasswordKeyvaultSecretName has been created."}
 }
 
 Function Get-RIAzSQLServerCredential{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName
    )
    
    Write-Output "KeyVault: SQL Server Root Password Reading..."| Out-Host
    $SQL_Admin_Account =Get-RIAzKeyvaultSecret -KeyVaultName $KeyVaultName -SecretName $UserNameSecretName -ErrorAction SilentlyContinue
    $SQL_Admin_Password=Get-RIAzKeyvaultSecureSecret -KeyVaultName $KeyVaultName -SecureSecretName $PasswordSecretName -ErrorAction SilentlyContinue
    if($SQL_Admin_Account -and $SQL_Admin_Password){$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList ($SQL_Admin_Account, $SQL_Admin_Password)} else {Write-Host "Keyvault: $UserNameSecretName or $PasswordSecretName does not exist." -ForegroundColor Red}
    if($Credential){Write-Output "KeyVault: SQL Server Credential is ready to use for creating or connecting to Azure SQL Server."| Out-Host}
    Return $Credential
 }
 <#
 Function Get-RIAzSQLServerConnection{
 [cmdletbinding()]
    param ([parameter(Mandatory)]
    [string]
    $KeyVaultName,
    [string]
    $UserNameSecretName,
    [string]
    $PasswordSecretName
    )
    Write-Output "KeyVault: SQL Server Root Account Reading..."| Out-Host
    $SQL_Admin_Account=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $UserNameSecretName
    $SQL_Admin_Account = Write-Output $SQL_Admin_Account.SecretValueText
    Write-Output "KeyVault: SQL Server Root Password Reading..."| Out-Host
    $SQL_Admin_Password=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $PasswordSecretName
    $SQL_Admin_Password = Write-Output $SQL_Admin_Password.SecretValueText
    $SQL_Admin_Password= ConvertTo-SecureString -String $SQL_Admin_Password -AsPlainText -Force
    $Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $SQL_Admin_Account, $SQL_Admin_Password
    Write-Output "KeyVault: SQL Server Credential is ready to use for creating Azure SQL Server."| Out-Host
    Return $Credential
 }#>

 Function New-RIAzStorageAccount {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('Standard_LRS','Standard_ZRS','Standard_GRS', 'Standard_RAGRS', 'Premium_LRS')]
        $SkuName,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        [ValidateSet('Cool','Hot')]
        $AccessTier
    )
    

     
     $StorageAccountName=Get-RIAzStorageAccountName -Location $Location -System $System -Environment $Environment
     Write-Output "Storage Account $StorageAccountName is being Created..."| Out-Host
     $Storage=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
     If($Storage.StorageAccountName -eq $StorageAccountName){Write-Host "Storage Account $StorageAccountName Exist. This step has been skipped. "}else{$NewSA=New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -SkuName $SkuName -Kind StorageV2 -AccessTier $AccessTier}
     If($NewSA.StorageAccountName -eq $StorageAccountName){Write-Output "Storage Account $StorageAccountName has been created."| Out-Host}
     $SA=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
     Return $SA

}
Function Get-RIAzFuncAppStorageAccountConnection {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $StorageAccountName
        )
    $Storage=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
    If($Storage.StorageAccountName -eq $StorageAccountName){$StorageKey=Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName}else{Write-Host "Storage Account $StorageAccount does not exist."}
    If($Storage.StorageAccountName -eq $StorageAccountName){$StorageKey= ($StorageKey | Where-Object {$_.KeyName -eq "Key1"}).Value}
    If($Storage.StorageAccountName -eq $StorageAccountName){$FuncKey="DefaultEndpointsProtocol=https;AccountName=$StorageAccountName;AccountKey=$StorageKey"}
    Return $FuncKey
    }

Function New-RIAzStorageContainer {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $System,
        [string]
        $Direction,
        $StorageAccountContext
        )
    
    $ContainerName=Get-RIAzStorageBlobContainerName -System $System -Direction $Direction
    $StorageContainer=Get-AzStorageContainer -Name $ContainerName -Context $StorageAccountContext -ErrorAction SilentlyContinue
    If($StorageContainer.Name -eq $ContainerName){Write-Host "Storage Blob Container $ContainerName Exist. This step has been skipped."}else{$NewContainer=New-AzStorageContainer -Name $ContainerName -Context $StorageAccountContext}
    If($NewContainer.Name -eq $ContainerName){Write-Output "Storage Blob Container $ContainerName has been created."}
    $Container=Get-AzStorageContainer -Name $ContainerName -Context $StorageAccountContext -ErrorAction SilentlyContinue
    Return $Container

    }

Function New-RIAzStorageQueue {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $System,
        $StorageAccountContext
        )
    
    $QueueName=Get-RIAzStorageQueueName -System $System
    $StorageQueue=Get-AzStorageQueue -Name $QueueName -Context $StorageAccountContext -ErrorAction SilentlyContinue
    If($StorageQueue.Name -eq $QueueName){Write-Host "Storage Queue $QueueName Exist. This step has been skipped."}else{$NewQueue=New-AzStorageQueue -Name $QueueName -Context $StorageAccountContext}
    If($NewQueue.Name -eq $QueueName){Write-Output "Storage Queue $QueueName has been created."}
    $Queue=Get-AzStorageQueue -Name $QueueName -Context $StorageAccountContext -ErrorAction SilentlyContinue
    Return $Queue

    }
Function New-RIAzFunctionAppStorageAccount {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('Standard_LRS','Standard_ZRS','Standard_GRS', 'Standard_RAGRS', 'Premium_LRS')]
        $SkuName,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        [ValidateSet('Cool','Hot')]
        $AccessTier,
        [string]
        $FunctionAppType
    )
    

     $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
     
     $StorageAccountName=Get-RIAzFunctionAppStorageAccountName -Location $Location -System $System -Environment $Environment -FunctionAppType $FunctionAppType
     Write-Output "Storage Account $StorageAccountName is being Created..."| Out-Host
     $Storage=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
     If($Storage.StorageAccountName -eq $StorageAccountName){Write-Host "Storage Account $StorageAccountName Exist. This step has been skipped. "}else{$NewSA=New-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName -Location $Location -SkuName $SkuName -Kind StorageV2 -AccessTier $AccessTier}
     If($NewSA.StorageAccountName -eq $StorageAccountName){Write-Output "Storage Account $StorageAccountName has been created."| Out-Host}
     $SA=Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue
     Return $SA
}
Function New-RIAzAutomationAccount {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment
        
    )
    

     
     $AutomationAccountName=Get-RIAzAutomationAccountName -Location $Location -System $System -Environment $Environment
     Write-Output "Automation Account $AutomationAccountName is being Created..."| Out-Host
     $AutomationAccount= Get-AzAutomationAccount -ResourceGroupName $ResourceGroupName -Name $AutomationAccountName -ErrorAction SilentlyContinue
     If($AutomationAccount.AutomationAccountName -eq $AutomationAccountName){Write-Host "Automation Account $AutomationAccountName Exist. This step has been skipped. "}else{$NewAutomationAccount=New-AzAutomationAccount -Name $AutomationAccountName -ResourceGroupName $ResourceGroupName -Location $Location}
     If($NewAutomationAccount.AutomationAccountName -eq $AutomationAccountName){Write-Output "Automation Account $AutomationAccountName has been created."| Out-Host}

}
Function New-RIAzServiceBusNamespace {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment
        
    )
     #Sku Function should be created
     $ServiceBusNamespaceName=Get-RIAzServiceBusNamespaceName -Location $Location -System $System -Environment $Environment
     Write-Output "Service Bus Name Space $ServiceBusNamespaceName is being Created..."| Out-Host
     $ServiceBusNameSpace=Get-AzServiceBusNamespace -ResourceGroupName $ResourceGroupName -Name $ServiceBusNamespaceName -ErrorAction SilentlyContinue
     If($ServiceBusNameSpace.Name -eq $ServiceBusNamespaceName){Write-Host "Service Bus Name Space $ServiceBusNamespaceName Exist. This step has been skipped. "}else{$NewSBNS=New-AzServiceBusNamespace -Name $ServiceBusNamespaceName -ResourceGroupName $ResourceGroupName -Location $Location }
     If($NewSBNS.Name -eq $ServiceBusNamespaceName){Write-Output "Service Bus Name Space $ServiceBusNamespaceName has been created."| Out-Host}

}
Function New-RIAzAppServicePlan {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        $Tier,
        [string]
        $WorkerSize,
        [bool]
        $PerSiteScaling
        
    )
     #Tier Function should be created
     #WorkerSize Function should be created
     
     $AppServicePlanName=Get-RIAzServiceBusNamespaceName -Location $Location -System $System -Environment $Environment
     Write-Output "App Service Plan $AppServicePlanName is being Created..."| Out-Host
     $AppServicePlan=Get-AzAppServicePlan -ResourceGroupName $ResourceGroupName -Name $AppServicePlanName -ErrorAction SilentlyContinue
     If ($AppServicePlan.Name -eq $AppServicePlanName){Write-Host "App Service Plan $AppServicePlanName Exist. This step has been skipped. "}else{$NewAppServicePlan=New-AzAppServicePlan -Name $AppServicePlanName -ResourceGroupName $ResourceGroupName -Location $Location -Tier $Tier -WorkerSize $WorkerSize -PerSiteScaling $PerSiteScaling}
     If ($NewAppServicePlan.Name -eq $AppServicePlanName){Write-Output "App Service Plan $AppServicePlanName has been created."| Out-Host}

}

Function New-RIAzApiManagement {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        $Organization,
        [string]
        $AdminEmail,
        [string]
        $Sku
        
    )
     #SKU Function should be created
     #Other information Function should be created
     
     $APIManagmentName=Get-RIAzApiManagementName -Location $Location -System $System -Environment $Environment
     Write-Output "API Management $APIManagmentName is being Created..."| Out-Host
     $APIManagement=Get-AzApiManagement -ResourceGroupName $ResourceGroupName -Name $APIManagmentName -ErrorAction SilentlyContinue
     $Job={New-AzApiManagement -Name $($args[0]) -ResourceGroupName $($args[1]) -Location $($args[2]) -Organization $($args[3]) -AdminEmail $($args[4]) -Sku $($args[5])}
     If($APIManagement.ProvisioningState -eq "Activating"){Write-Host "API Management $APIManagmentName Exist. It is being activated which takes up to 20 minutes please wait..."}
     elseIf($APIManagement.Name -eq $APIManagmentName){Write-Host "API Management $APIManagmentName Exist. This step has been skipped. "}
     else{$NewAPIManagement=Start-Job -ScriptBlock $Job -Name "NewAPIManagement" -ArgumentList $APIManagmentName,$ResourceGroupName,$Location,$Organization,$AdminEmail,$Sku}
     If($NewAPIManagement.State -eq "Running"){Write-Output "API Management $APIManagmentName has been created. It takes up to 20 minutes to activate please waite..."| Out-Host}

}

Function New-RIAzManagmentGroup {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        [ValidateSet('Standard_LRS','Standard_ZRS','Standard_GRS', 'Standard_RAGRS', 'Premium_LRS')]
        $StorageSKUName,
        [string]
        $APIManagementOrganization,
        [string]
        $APIManagementAdminEmail,
        [string]
        $APIManagementSKU,
        [string]
        $DomainName
                
    )
    
    
     $RG_MGM=New-RIAzResourceGroup -Location $Location -System $System -ResourceType "mgmt" -Environment $Environment
     $KeyVault=New-RIAzKeyVault -Location $Location -System $System -Environment $Environment -ResourceGroupName $RG_MGM.ResourceGroupName -SKU "Standard" #-UserPrincipalName $UserPrincipalName
     New-RIAzKeyVaultUserPrincipalAccessPolicy -System $System -Environment $Environment -KeyvaultName $KeyVault.VaultName -DomainName $DomainName
     $Storage_Account=New-RIAzStorageAccount -ResourceGroupName $RG_MGM.ResourceGroupName -Location $Location -System $System -SkuName $StorageSKUName -Environment $Environment -AccessTier Hot
     $AutomationAccount=New-RIAzAutomationAccount -ResourceGroupName $RG_MGM.ResourceGroupName -Location $Location -System $System -Environment $Environment
     $ServiceBusNamespace = New-RIAzServiceBusNamespace -ResourceGroupName $RG_MGM.ResourceGroupName -Location $Location -System $System -Environment $Environment
     #$APIManagement=New-RIAzApiManagement -ResourceGroupName $RG_MGM.ResourceGroupName -Location $Location -System $System -Environment $Environment -Organization $APIManagementOrganization -AdminEmail $APIManagementAdminEmail -Sku $APIManagementSKU
     
}

Function New-RIAzDatabaseGroup {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        [ValidateSet('Small','Medium','Large')]
        $DatabaseSize

        
                
    )
    
     
     
     $RG_DB=New-RIAzResourceGroup -Location $Location -System $System -ResourceType "db" -Environment $Environment
     $RG_MGM=Get-RIAzResourceGroupName -Location $Location -System $System -ResourceType "mgmt" -Environment $Environment
     $KeyvaultName= Get-RIAzKeyVaultName -Location $Location -System $System -Environment $Environment
     $KeyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $RG_MGM
     New-RIAzSQLServerCredential -Location $Location -System $System -Environment $Environment -KeyVaultName $KeyVault.VaultName
     $SQL_Server=New-RIAzSqlServer -ResourceGroup $RG_DB.ResourceGroupName -Location $Location -KeyVaultName $KeyVault.VaultName -System $System -Environment $Environment
     $SQL_DB_Auth= New-RIAzSqlAuthDatabase -ServerName $SQL_Server.ServerName -ResourceGroupName $RG_DB.ResourceGroupName -Size $DatabaseSize -Environment $Environment -System $System
     $SQL_DB_Master=New-RIAzSqlMasterDatabase -ServerName $SQL_Server.ServerName -ResourceGroupName $RG_DB.ResourceGroupName -Size $DatabaseSize -Environment $Environment -System $System
     $SQL_DB_Planning= New-RIAzSqlPlanningDatabase -ServerName $SQL_Server.ServerName -ResourceGroupName $RG_DB.ResourceGroupName -Size $DatabaseSize -Environment $Environment -System $System
     $SQL_DB_Order= New-RIAzSqlOrderDatabase -ServerName $SQL_Server.ServerName -ResourceGroupName $RG_DB.ResourceGroupName -Size $DatabaseSize -Environment $Environment -System $System
     
}
Function New-RIAzWebGroup {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        $Tier,
        [string]
        $WorkerSize
        
                
    )
    
     
     $RG_Web=New-RIAzResourceGroup -Location $Location -System $System -ResourceType "web" -Environment $Environment
     $AppServicePlan=New-RIAzAppServicePlan -ResourceGroupName $RG_Web.ResourceGroupName -Location $Location -System $System -Environment $Environment -Tier $Tier -WorkerSize $WorkerSize -PerSiteScaling $true
     
}
Function New-RIAzETLGroup {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment
                
    )
    
     
     $RG=New-RIAzResourceGroup -Location $Location -System $System -ResourceType "etl" -Environment $Environment
     
}

Function New-RIAzAllResource{
[cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location,
        [string]
        $System,
        [string]
        [ValidateSet('prd','crt','dev')]
        $Environment,
        [string]
        $StorageSKUName,
        [string]
        $WebTier,
        [string]
        $WebWorkerSize,
        [string]
        $DatabaseSize,
        [string]
        $APIManagementOrganization,
        [string]
        $APIManagementAdminEmail,
        [string]
        $APIManagementSKU
        #[string]
        #$UserPrincipalName
        )
        
        New-RIAzManagmentGroup -Location $Location -System $System -Environment $Environment -StorageSKUName $StorageSKUName -APIManagementOrganization $APIManagementOrganization -APIManagementAdminEmail $APIManagementAdminEmail -APIManagementSKU $APIManagementSKU #S-ServicePrincipalName $UserPrincipalName
        New-RIAzWebGroup -Location $Location -System $System -Environment $Environment -Tier $WebTier -WorkerSize $WebWorkerSize
        New-RIAzETLGroup -Location $Location -System $System -Environment $Environment
        New-RIAzDatabaseGroup -Location $Location -System $System -Environment $Environment -UserName $SQLUserName -DatabaseSize $DatabaseSize

}
Function New-RIAzFunctionApp {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $Location,
        [string]
        $System,
        [string]
        $FunctionAppType,
        [string]
        $Environment
        
        )
     
    $FuncAppName=Get-RIAzFunctionAppName -Location $Location -System $System -FunctionAppType $FunctionAppType -Environment $Environment
    $FuncAppStorage=New-RIAzFunctionAppStorageAccount -ResourceGroupName $ResourceGroupName -Location $Location -System $System -SkuName Standard_LRS -Environment $Environment -AccessTier Cool -FunctionAppType $FunctionAppType
    $FStorageName=$FuncAppStorage.StorageAccountName
    $FuncCheck=Get-RIAzFunctionApp -ResourceGroupName $ResourceGroupName -FunctionAppName $FuncAppName -ErrorAction SilentlyContinue
    If($FuncCheck.Name -eq $FuncAppName){Write-Host "Azure Function App $FuncAppName Exist. This step has been skipped."}else{$NewFuncApp=az functionapp create --storage-account $FStorageName -n $FuncAppName  -g $ResourceGroupName --os-type "Windows" -c "australiaeast" }
    $NewFuncAppNormal=$NewFuncApp | Out-String | ConvertFrom-Json
    If($NewFuncAppNormal.Name -eq $FuncAppName){Write-Output "Azure Function App $FuncAppName has been successfully created."}
    $FuncCheck=Get-RIAzFunctionApp -ResourceGroupName $ResourceGroupName -FunctionAppName $FuncAppName -ErrorAction SilentlyContinue
    Return $FuncCheck
    }
Function Get-RIAzFunctionApp {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $FunctionAppName
        
        )
        $FunctionApp=az functionapp show -g $ResourceGroupName -n $FunctionAppName
        $FuncNormal=$FunctionApp | Out-String | ConvertFrom-Json
        Return $FuncNormal
    }
Function New-RIAzFunctionAppDeployment {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $FunctionAppName,
        [string]
        $SourcePath
        
        )
        $FuncCheck=Get-RIAzFunctionApp -ResourceGroupName $ResourceGroupName -FunctionAppName $FunctionAppName -ErrorAction SilentlyContinue
        If($FuncCheck.Name -eq $FunctionAppName){az functionapp deployment source config-zip --name $FunctionAppName  --resource-group $ResourceGroupName --src $SourcePath}else{Write-Host "Azure Function App $FuncAppName Does Not Exist. This step has been skipped."}
               
    }
Function New-RIAzFunctionAppVariable {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $FunctionAppName,
        [string]
        $Key,
        [string]
        $value
        
        )
        $FuncCheck=Get-RIAzFunctionApp -ResourceGroupName $ResourceGroupName -FunctionAppName $FunctionAppName -ErrorAction SilentlyContinue
        If($FuncCheck.Name -eq $FunctionAppName){az functionapp config appsettings set --name $FunctionAppName --resource-group $ResourceGroupName --settings $Key=$value}else{Write-Host "Azure Function App $FuncAppName Does Not Exist. This step has been skipped."}
               
    }
Function Get-RIAzBearerToken {
    [cmdletbinding()]
    param ([parameter(Mandatory)]
        [string]
        $TenantId,
        [string]
        $ClientId,
        [string]
        $ClientSecret
        
        
        )
        
    $UrlNormal = "https://login.microsoftonline.com/$TenantId/oauth2/token"    
    $Body = @{
    grant_type="client_credentials"
    client_id=$ClientId
    client_secret=$ClientSecret
    resource="https://management.azure.com/"
             }
    $headers = @{
    'Content-Type'= 'application/x-www-form-urlencoded'
                }
     $BearerToken=Invoke-RestMethod -Method 'Post' -Uri $UrlNormal -Body $body -TimeoutSec "60"
     Return $BearerToken
    }