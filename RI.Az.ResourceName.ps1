#Infrastructure Naming
Function Get-RIAzADUserName{
[cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $System,
        [string]
        $ResourceType,
        [string]
        $Environment,
        [string]
        [ValidateSet('admin','user')]
        $UserType
        )

        "$System$Environment$ResourceType$UserType"
}
Function Get-RIAzADGroupName{
[cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $System,
        [string]
        $ResourceType,
        [string]
        $Environment,
        [string]
        [ValidateSet('Owner','Contributor','Reader')]
        $RoleType
        )

        "$System-$Environment-$ResourceType-$RoleType"
}
Function Get-RIAzRegionAbbreviation{
[cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location
                
        )
      
           If($Location -eq "Australia East"){$RegionAbbreviation="aea"}
           elseif($Location -eq "Australia Southeast"){$RegionAbbreviation="ase"}
           $RegionAbbreviation 
}
Function Get-RIAzResourceGroupName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $ResourceType,
        [string]
        $Environment
        
        )
        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        "$RegionAbbreviation-$System-$ResourceType-$Environment-RG".ToUpper()
}
<#Function Get-RIAzStorageAccountName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $RegionAbbreviation,
        [string]
        $System,
        [string]
        $Environment
        
        
        
        
        )
        $StorageType="disk"
        "$RegionAbbreviation$System$Environment$StorageType"
}#>
Function Get-RIAzStorageBlobContainerName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $System,
        [string]
        $Direction
        
        
        
        
        )
        $StorageType="-blob-container"
        $Direction="-$Direction"
        "$System$Direction$StorageType"
}
Function Get-RIAzStorageQueueName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $System
        
        
        
        
        
        )
        $StorageType="-queue"
        
        "$System$StorageType"
}
Function Get-RIAzKeyVaultName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )
        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        "$RegionAbbreviation-$System-$Environment-keyvault"
}
Function Get-RIAzStorageAccountName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
        )
        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        $StorageType="disk"
        "$RegionAbbreviation$System$Environment$StorageType"
}
Function Get-RIAzAutomationAccountName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )
        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        "$RegionAbbreviation-$System-$Environment-automation"
}
Function Get-RIAzServiceBusNamespaceName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )
        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        $sb="sb"
        "$RegionAbbreviation$System$Environment$sb"
}
Function Get-RIAzAppServicePlanName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )
        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        "$RegionAbbreviation-$System-$Environment-asp" 
}
Function Get-RIAzApiManagementName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )
        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        "$RegionAbbreviation-$System-api-$Environment" 
}
Function Get-RIAzSqlServerName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )

        $RegionAbbreviation=Get-RIAzRegionAbbreviation -Location $Location
        "$RegionAbbreviation-$System-$Environment-sqlserver" 
}
Function Get-RIAzSqlDatabaseName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $System,
        [string]
        $FunctionName,
        [string]
        $Environment
     
        
        
        
        )

        "$System-$FunctionName-$Environment" 
}
Function Get-RIAzSqlServerFirewallRuleName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )
        
        $SQLServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment

        "$SQLServerName-Deployment-Firewall-Rule" 
}
Function Get-RIAzKeyvaultSqlServerRootUserNameSecretName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )

        $SQLServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
        $RootAccount="-Root-SQL-Account"
        $SqlServerRootUserName="$SQLServerName$RootAccount"
        Return $SqlServerRootUserName
}
Function Get-RIAzKeyvaultSqlServerRootPasswordSecretName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )

        $SQLServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
        $RootPassword="-Root-SQL-Password"
        $SqlServerRootPassword="$SQLServerName$RootPassword"
        Return $SqlServerRootPassword
}
Function Get-RIAzKeyvaultSqlServerMasterUserNameSecretName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )

        $SQLServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
        $RootAccount="-Master-SQL-Account"
        $SqlServerRootUserName="$SQLServerName$RootAccount"
        Return $SqlServerRootUserName
}
Function Get-RIAzKeyvaultSqlServerMasterPasswordSecretName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment
     
        
        
        
        )

        $SQLServerName=Get-RIAzSqlServerName -Location $Location -System $System -Environment $Environment
        $RootPassword="-Master-SQL-Password"
        $SqlServerRootPassword="$SQLServerName$RootPassword"
        Return $SqlServerRootPassword
}
Function Get-RIAzFunctionAppName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $FunctionAppType,
        [string]
        $Environment
        )
        $RegionAbrivation=Get-RIAzRegionAbbreviation -Location $Location
        "$RegionAbrivation-$System-$FunctionAppType-$Environment-func"
}
Function Get-RIAzFunctionAppStorageAccountName {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $Location,
        [string]
        $System,
        [string]
        $Environment,
        [string]
        $FunctionAppType
        )
        $RegionAbbrivation=Get-RIAzRegionAbbreviation -Location $Location
        $StorageAccount=Get-RIAzStorageAccountName -Location $Location -System $System -Environment $Environment
        $FunctionApp="fa"
        $FunctionAppStorageAccountName="$StorageAccount$FunctionAppType$FunctionApp"
        Return $FunctionAppStorageAccountName
}
Function Get-RIAzFunctionLocation {
   [cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        [ValidateSet('Australia East','Australia Southeast','West Europe')]
        $Location
                
        )
      
           If($Location -eq "Australia East"){$FALocation="AustraliaEast"}
           elseif($Location -eq "Australia Southeast"){$FALocation="AustraliaSoutheast"}
           $FALocation
        
}