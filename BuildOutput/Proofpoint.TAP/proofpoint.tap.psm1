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
<#
.SYNOPSIS
    Call Tap clickers SIEM api to return clickers objects for single or multiple days up to 0-6 days in the past
.Notes 
    0 days in the past is today
.EXAMPLE 
    $obj = get-tapClickersbyLookbackDays -raw -permitted -blocked -verbose -URi $URi -verbose -Credential $Credential 
    Get blocked and permitted clicks for today (utc now - utc today 12:00:00). Verbose stream shows datetime utc for each 1hour interval queried
.EXAMPLE 
    $obj = get-tapClickersbyLookbackDays -LookbackDays 6 -LookbackDaysStart 0 -Raw -URi $URi -Credential $Credential 
    Get blocked and permitted clicks for interval from today (utc now) through 6 days in the past. 
 .EXAMPLE    
    $JSON = get-tapClickersbyLookbackDays -Credential $Credential -LookbackDays 1 -LookbackDaysStart 5 -URi $URi
    Get blocked and permitted clicks for 2 days (0..1) for starting 5 days in the past and ending 6 days in the past in JSON format
 .EXAMPLE    
    $yesterday = get-tapClickersbyLookbackDays -Credential $Credential -Raw -LookbackDays 0 -LookbackDaysStart 1 -URi $URi
    Get blocked clicks for yesterday
 .EXAMPLE    
    $todayAndYesterday = get-tapClickersbyLookbackDays -Credential $Credential -Raw -LookbackDays 1 -URi $URi
    Get permitted clicks for today (utc now) and yesterday
#>

function Get-TapClickersbyLookbackDays {
    [CmdletBinding()]
    param (
        [string]$URi,
        [System.Management.Automation.PSCredential]$Credential,
        [ValidateRange(0, 6)] 
        [int]$LookbackDays = 0,
        [ValidateRange(0, 6)] 
        [int]$LookbackDaysStart = 0,
        [switch]$blocked,
        [switch]$permitted,
        [switch]$Raw
    )
    begin {
        
        # Lookback days is how many days in the past you want to retrieve results for. 

        $now = [datetime]::UtcNow
        $now = $now.AddSeconds( - ($now.second - 60)) # round up to the nearest minute
        $now = $now.addminutes( - ($now.minute - 60)) # round up to the nearest hour
    }
    process {
        Try {

            $LookbackDays = if (($LookbackDaysStart + $LookbackDays) -ge 6 ) { 6 }Else { ($LookbackDaysStart + $LookbackDays) } # LookbackDays must be greater than ldStart but less than 6
            
            foreach ($day in ($LookbackDaysStart..$LookbackDays)) {
                $startDate = ($now.date).AddDays( - $day) # Today at 00:00:00
            
                foreach ($hr in (1..24)) {
                    $splat = @{
                        DateTime   = $startdate.Addhours($hr)
                        URi        = $URi
                        Credential = $Credential
                        Raw        = $Raw.IsPresent
                    }
                
                    if ($day -eq 0 -and $hr -gt ([datetime]::UtcNow).hour ) { break } #don't run queries for hours that have not happened yet today

                    # if neither switch is specified run both, otherwise run only the specified switches 
                    if ($blocked.ispresent) {

                        (Get-TAPclickers1hour @splat -blocked).where{ -not ([string]::IsNullOrEmpty($_.clicksblocked.clicktime)) }
                    
                    } 

                    if ($permitted.ispresent) {

                        (Get-TAPclickers1hour @splat -permitted).where{ -not ([string]::IsNullOrEmpty($_.clickspermitted.clicktime)) }
                    
                    }

                    if (-not $blocked.ispresent -and -not $permitted.ispresent) {
                    
                        Get-TAPclickers1hour @splat | Where-Object { ($_ | Select-Object clicks* -ExpandProperty clicks* -ErrorAction SilentlyContinue).clicktime }   
                    
                    } 

                }
            }
        } Catch {

            $PSCmdlet.ThrowTerminatingError($PSItem) 
        }
    
    }
    end {}

}
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

