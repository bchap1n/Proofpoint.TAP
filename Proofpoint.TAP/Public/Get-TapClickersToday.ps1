function Get-TapClickersToday {
    [CmdletBinding()]
    param (
        [string]$URi,
        [System.Management.Automation.PSCredential]$Credential, 
        [switch]$blocked,
        [switch]$permitted,
        [switch]$Raw
    )
    Try {

        # get the results for today so far by rounding up current hour 
        
        $startDate = (Get-Date -AsUTC).date # Today at 00:00:00 in Utc
        $now = [datetime]::utcNow
        $now = $now.AddSeconds( - ($now.second - 60)) # round up to the nearest minute
        $now = $now.addminutes( - ($now.minute - 60)) # round up to the nearest hour
        
        foreach ($hr in (1..$($now.hour))) {

            $splat = @{
                DateTime   = $startdate.Addhours($hr)
                URi        = $URi
                Credential = $Credential
                Raw        = $Raw.IsPresent
            }
            
            # if neither switch is specified run both, otherwise run only the specified switches 
            if ($blocked.ispresent -or ($blocked.ispresent -and $permitted.ispresent) -or (-not $blocked.ispresent -and -not $permitted.ispresent)) {

                (Get-TAPclickers1hour @splat -blocked).where{ -not ([string]::IsNullOrEmpty($_.clicksblocked.clicktime)) }
            } 

            if ($permitted.ispresent -or ($blocked.ispresent -and $permitted.ispresent) -or (-not $blocked.ispresent -and -not $permitted.ispresent)) {

                (Get-TAPclickers1hour @splat -permitted).where{ -not ([string]::IsNullOrEmpty($_.clickspermitted.clicktime)) }
            } 

        }
    
    } Catch {

        $PSCmdlet.ThrowTerminatingError($PSItem) 
    }
    
}