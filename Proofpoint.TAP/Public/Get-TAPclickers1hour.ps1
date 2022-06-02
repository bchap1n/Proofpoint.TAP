<#
.SYNOPSIS
    Call Tap clickers SIEM api to return clickers objects for single hour

.EXAMPLE 
    $blocked = get-tapClickers1hour -DateTime ([datetime]::today).addhours(1) -blocked -raw -Uri $uri -Credential $credential
    Get blocked clicks for 12:00:00 - 01:00:00 today local time / results will be relative utc time
.EXAMPLE 
    $json = get-tapClickers1hour -DateTime ([datetime]::today).addhours(1) -blocked -Uri $uri -Credential $credential -verbose
    Get blocked and permitted clicks for 12:00:00 - 01:00:00 today local time. Verbose stream shows datetime utc for each 1hour interval queried

#>
function Get-TAPclickers1hour {
    [CmdletBinding()]
    param (
        [string]$URi,
        [System.Management.Automation.PSCredential]$Credential,
        [System.DateTime]$DateTime = [datetime]::UtcNow,   
        [switch]$blocked,
        [switch]$permitted,
        [switch]$Raw
    )
    
    begin {

    }
    process {
        
        try {

            # If using default (utcNow), then .toUniversalTime will have no change
            $UTCstring = $DateTime.ToUniversalTime().ToString('yyyy-MM-ddTHH:mm:ssZ') 
            Write-Verbose $UTCstring

            $param = @{
                Authentication = 'Basic'
                Credential     = $Credential
            }
    
            # if neither switch is specified run both, otherwise run only the specified switches
            $result = @(
                if ($blocked.ispresent -or ($blocked.ispresent -and $permitted.ispresent) -or (-not $blocked.ispresent -and -not $permitted.ispresent)) {
                    $URiBlocked = '{0}/siem/clicks/{1}?format=json&interval=PT60M/{2}' -f $URi, 'blocked', $UTCstring 
                    Invoke-RestMethod @param -Uri $URiBlocked
                } 
                
                if ($permitted.ispresent -or ($blocked.ispresent -and $permitted.ispresent) -or (-not $blocked.ispresent -and -not $permitted.ispresent)) {
                    $URiPermitted = '{0}/siem/clicks/{1}?format=json&interval=PT60M/{2}' -f $URi, 'permitted', $UTCstring
                    Invoke-RestMethod @param -Uri $URiPermitted
                } 
            ) 

            if ($Raw) {
                $result
            } else {
                ConvertTo-Json -InputObject $result -Depth 99 -EnumsAsStrings -AsArray
            }

        } catch {
            
            $PSCmdlet.ThrowTerminatingError($PSItem) 

        }          
    }

    end {}  
}