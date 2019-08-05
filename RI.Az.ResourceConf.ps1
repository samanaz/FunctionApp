Function New-RIAzKeyVaultSecret(){
[cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $KeyVaultName,
        [string]
        $KeyVaultSecretName,
        [string]
        $SecretString
        
        )
        $KeyVault=Get-AzKeyVault -VaultName $KeyvaultName -ErrorAction SilentlyContinue
        If($KeyVault.VaultName -eq $KeyvaultName){Write-Host "The Keyvault $KeyVaultName exist. Saving the secret..."}else{Write-Host "Key Vault $KeyvaultName does not Exist. Please create the keyvault first. Secret did not save." -ForegroundColor Red}
        $KeyVaultCheck=Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $KeyVaultSecretName -ErrorAction SilentlyContinue
        If($KeyVaultCheck.Name -eq $KeyVaultSecretName){Write-Host "KeyVault: secret $KeyVaultSecretName Exist. Saving secret $KeyVaultSecretName to KeyVault has been skipped."}else{$NewSecret=Set-RIAzKeyVaultSecret -KeyVaultName $KeyVaultName -KeyVaultSecretName $KeyVaultSecretName -SecretString $SecretString -ErrorAction SilentlyContinue}
        If($NewSecret.Name -eq $KeyVaultSecretName){Write-Output "KeyVault: The Secret $KeyVaultSecretName has been created."| Out-Host}
}
Function New-RIAzRunbook(){
[cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $AutomationAccountName,
        [string]
        $RunbookPath,
        [string]
        [ValidateSet('Graph','GraphicalPowerShell','GraphicalPowerShellWorkflow','PowerShell', 'PowerShellWorkflow', 'Python2')]
        $RunbookType,
        [string]
        $RunbookName
        
        )

        Write-Output "Runbook $RunbookName is being Created..."| Out-Host
        $RunbookCheck=Get-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $RunbookName -ErrorAction SilentlyContinue
        If($RunbookCheck.Name -eq $RunbookName){Write-Host "Runbook $RunbookName Exist. Importing Runbook $RunbookName has been skipped. "}else{$NewRunbook=Import-AzAutomationRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Path $Runbookpath -Type $RunbookType -Published -Name $RunbookName}
        If($NewRunbook.Name -eq $RunbookName){Write-Output "Runbook $RunbookName has been created."| Out-Host}
               
 }
Function New-RIAzWebhook(){
[cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $AutomationAccountName,
        [string]
        $RunbookName,
        [string]
        $KeyVaultName,
        [string]
        $WebhookExpiryTime 
        )
        $WebHookName="$RunbookName-Webhook"
        Write-Output "Automation Webhook $WebHookName is being Created..."| Out-Host
        $WebhookCheck=Get-AzAutomationWebhook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $WebHookName -ErrorAction SilentlyContinue
        If($WebhookCheck.Name -eq $WebHookName){Write-Host "Automation Webhook $WebHookName Exist. Creating Webhook for Runbook $RunbookName has been skipped. "}else{$NewWebhook=New-AzAutomationWebhook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -Name $WebHookName -RunbookName $RunbookName -IsEnabled 0 -ExpiryTime $WebhookExpiryTime -Force}
        If($NewWebhook.Name -eq $WebHookName){Write-Output "Automation Webhook $WebHookName has been created."| Out-Host}
        If($NewWebhook.Name -eq $WebHookName){Write-Output "KeyVault: Saving $WebHookName to KeyVault $KeyVaultName."| Out-Host}
        If($NewWebhook.Name -eq $WebHookName){New-RIAzKeyVaultSecret -KeyVaultName $KeyVaultName -KeyVaultSecretName "$RunbookName-Webhook-Secret" -SecretString $NewWebhook.WebhookURI}
        If($NewWebhook.Name -eq $WebHookName){Write-Output "KeyVault: Saving $WebHookName to KeyVault $KeyVaultName has been successfull."| Out-Host}
        
 }
Function New-RIAzRunbookWithWebhook(){
[cmdletbinding()]
   param(
        [Parameter(Mandatory)]
        [string]
        $ResourceGroupName,
        [string]
        $AutomationAccountName,
        [string]
        $RunbookPath,
        [string]
        [ValidateSet('Graph','GraphicalPowerShell','GraphicalPowerShellWorkflow','PowerShell', 'PowerShellWorkflow', 'Python2')]
        $RunbookType,
        [string]
        $RunbookName,
        [string]
        $KeyVaultName,
        [string]
        $WebhookExpiryTime 
        )
        New-RIAzRunbook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -RunbookPath $Runbookpath -RunbookType $RunbookType -RunbookName $RunbookName
        New-RIAzWebhook -ResourceGroupName $ResourceGroupName -AutomationAccountName $AutomationAccountName -RunbookName $RunbookName -KeyVaultName $KeyVaultName -WebhookExpiryTime $WebhookExpiryTime
 }