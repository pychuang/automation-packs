Configuration webrolefull {

    $features = @(
        @{Name = "SMTP-Server"; Ensure = "Present"},
        @{Name = "Web-WMI"; Ensure = "Present"}
       )

    node full {

        function Install-Prerequisites ()
        {
            Add-WindowsFeature SMTP-Server
            Add-WindowsFeature Web-WMI

            #Add-PSSnapin WebAdministration
        }

        # https://blogs.technet.microsoft.com/bspieth/2013/02/18/configure-the-iis-6-smtp-server-with-wmi-and-powershell/
        function Configure-SMTPService ()
        {
            Write-Host -Foregroundcolor White " -> Changing the start-up type of SMTP service to 'Automatic'..."
            Set-Service "SMTPSVC" -StartupType Automatic -ErrorAction SilentlyContinue
            if ($?)
            {
                Write-Host -Foregroundcolor Green " [OK] Successfully changed startup type."
            }
            else
            {
                Write-Host -Foregroundcolor Red " [Error] Unable to change startup type."
                throw
            }

            Write-Host -Foregroundcolor White " -> Starting SMTP service..."
            Start-Service "SMTPSVC" -ErrorAction SilentlyContinue
            if ($?)
            {
                Write-Host -Foregroundcolor Green " [OK] Service successfully started."
            }
            else
            {
                Write-Host -Foregroundcolor Red " [Error] Unable to start service."
                throw
            }

            Write-Host -Foregroundcolor White " -> Configuring virtual SMTP server..."
            try
            {
                # For IISSmtpServerSetting, refer https://msdn.microsoft.com/en-us/library/ms526057(v=vs.90).aspx
                $virtualSMTPServer = Get-WmiObject IISSmtpServerSetting -namespace "root\MicrosoftIISv2" | Where-Object { $_.name -like "SmtpSVC/1" }

                # The "Only the list below" or "All except the list below" choice is controlled by $virtualSMTPServer.RelayIpList,
                # but its format is not straightforward.  We use a simpler setting here.

                # Anonymous access
                #$virtualSMTPServer.AuthAnonymous = $true

                # Integrated Windows Authentication
                $virtualSMTPServer.AuthNTLM = $true

                # Allow all computers which successfully authenticate to relay, regardless of the list above
                $virtualSMTPServer.RelayForAuth = -1

                $virtualSMTPServer.Put() | Out-Null
                Write-Host -Foregroundcolor Green " [OK] Successfully configured virtual SMTP server."
            }
            catch
            {
                Write-Host -Foregroundcolor Red " [Error] Unable to configure virtual SMTP server."
                throw
            }
        }

        foreach ($feature in $features){
            WindowsFeature ($feature.Name) {
                Name = $feature.Name
                Ensure = $feature.Ensure
            }
        }

        Set-ExecutionPolicy RemoteSigned
        Configure-SMTPService
    }
}