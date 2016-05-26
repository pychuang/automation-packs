#Login-AzureRmAccount

#Set-PSDebug -Trace 1

function Monitor()
{
    While ($True) {
        #Start-Sleep -Seconds 10
        Write-Output "Get Runbook status..."
    
        $job = (Get-AzureRmAutomationJob -ResourceGroupName pychuang-test-automation -AutomationAccountName pychuang-test-automation2 -RunbookName TestConnection | sort LastModifiedDate -Descending)[0]
        
        Write-Output $job.JobId
        Write-Output $job.Status
        $output = Get-AzureRmAutomationJobOutput -ResourceGroupName pychuang-test-automation -AutomationAccountName pychuang-test-automation2 -Id $job.JobId
        Write-Output $output
        #$outputrecord = Get-AzureRmAutomationJobOutputRecord -ResourceGroupName pychuang-test-automation -AutomationAccountName pychuang-test-automation2 -JobId $job.JobId
        #Write-Output "RECORD: $outputrecord"

        if ($job.Status -eq "Suspended") {
            # Error or exception, stop the runbook
            Stop-AzureRmAutomationJob -ResourceGroupName pychuang-test-automation -AutomationAccountName pychuang-test-automation2 -Id $job.JobId
            break
        } elseif ($job.Status -eq "Completed") {
            break
        } elseif ($job.Status -eq "Stopped") {
            break
        }
        Write-Output "sleep 10s"
        Start-Sleep -Seconds 10
    }
}

Monitor
#Set-PSDebug -Trace 1

#$job = Start-Job -ScriptBlock $scriptblock
#Wait-Job $job