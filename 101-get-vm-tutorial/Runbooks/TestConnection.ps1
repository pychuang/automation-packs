workflow TestConnection
{
	$Conn = Get-AutomationConnection -Name AzureRunAsConnection
    Write-Output $Conn
	Add-AzureRMAccount -ServicePrincipal -Tenant $Conn.TenantID `
    -ApplicationId $Conn.ApplicationID -CertificateThumbprint $Conn.CertificateThumbprint
    Write-Output "TestConnection Finished"
}