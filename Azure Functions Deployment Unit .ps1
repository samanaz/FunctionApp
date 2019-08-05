$scriptdir = Split-Path -Parent $PSCommandPath
$InfrastructureName = "RI.Az.ResourceName.ps1"
$InfrastructureDeployment="RI.Az.ResourceDep.ps1"
$DatabaseModule="RI.Az.SQL.ps1"
$DatabaseConf="RI.Az.SQLConf.ps1"
$InfrastructureConf="RI.Az.ResourceConf.ps1"

$ModuleInfrastructureName = Join-Path $scriptdir $InfrastructureName
$ModuleInfrastructureDeployment= Join-Path $scriptdir $InfrastructureDeployment
$ModuleDatabase= Join-Path $scriptdir $DatabaseModule
$ModuleInfrastructureConf= Join-Path $scriptdir $InfrastructureConf
$ModuleDatabaseConf= Join-Path $scriptdir $DatabaseConf

Import-Module $ModuleInfrastructureName
Import-Module $ModuleInfrastructureDeployment
Import-Module $ModuleDatabase
Import-Module $ModuleInfrastructureConf
Import-Module $ModuleDatabaseConf

$Location="Australia East"
$System="saman"
$Environment="dev"
$ResourceType="MGM"
$StorageSKUName= "Standard_LRS"
$SkuName="Standard_LRS"
$AccessTier="Cool"
$FunctionAppType="te"
$SourcePath="C:\Users\SamanAzadpour\OneDrive - Retail Insight Ltd\Azure Services\Azure Functions\Azure Functions Zip\Azure_Functions_Blobe_to_Queue.deps.zip"
$SubscriptionID="fe3bcd09-82ad-4d20-b7a2-4efd372e3c14"
$TenantID="76365d9c-4d0c-4c97-bd67-1031c1b279b3"
$ApplicationId="df4bb57e-6ea2-4e75-b932-38ca97cb219f"
$ClientSecret="kZ3v-W1S=_Ce5NCFD7=5uW*NcX8r*2Ws"

az
$MGMRG=New-RIAzResourceGroup -Location $Location -System $System -ResourceType $ResourceType -Environment $Environment
$MGMStorage=New-RIAzStorageAccount -ResourceGroupName $MGMRG.ResourceGroupName -Location $Location -System $System -SkuName $SkuName -Environment $Environment -AccessTier $AccessTier
$StorageKey=Get-RIAzFuncAppStorageAccountConnection -ResourceGroupName $MGMRG.ResourceGroupName -StorageAccountName $MGMStorage.StorageAccountName
$Container=New-RIAzStorageContainer -ResourceGroupName $MGMRG.ResourceGroupName -System $System -Direction "in" -StorageAccountContext $MGMStorage.Context
$Queue=New-RIAzStorageQueue -ResourceGroupName $MGMRG.ResourceGroupName -System $System -StorageAccountContext $MGMStorage.Context
$WebRG=New-RIAzResourceGroup -Location $Location -System $System -ResourceType Web -Environment $Environment
$Func=New-RIAzFunctionApp -ResourceGroupName $WebRG.ResourceGroupName -Location $Location -System $System -FunctionAppType $FunctionAppType -Environment $Environment
New-RIAzFunctionAppVariable -ResourceGroupName $WebRG.ResourceGroupName -FunctionAppName $Func.name -Key "StorageAccount" -value "$StorageKey" | Out-Null
New-RIAzFunctionAppVariable -ResourceGroupName $WebRG.ResourceGroupName -FunctionAppName $Func.name -Key "queueName" -value $Queue.Name | Out-Null
New-RIAzFunctionAppVariable -ResourceGroupName $WebRG.ResourceGroupName -FunctionAppName $Func.name -Key "ContainerToMonitor" -value $Container.Name | Out-Null
#New-RIAzFunctionAppDeployment -ResourceGroupName $WebRG.ResourceGroupName -FunctionAppName $Func.name -SourcePath $SourcePath
