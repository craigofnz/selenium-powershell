function Select-SeWindow
{
    <#
    .SYNOPSIS
    Selects a window given a specified title search scheme

    .DESCRIPTION
    Selects a window given a specified title search scheme

    Iterates through $Driver's window handles until it can find a window where the string fragment described in $Title can be matched by the
    search scheme descibed in $FindBy.

    .OUTPUTS
    Success: [string] Representing the WindowHandle Identifier
    Failure: [Exception]

    .EXAMPLE
    $Driver | Select-SeWindow -Title " | Microsoft Teams" -EndsWith -WaitHtml
    
    .EXAMPLE
    Select-SeWindow -Driver $TeamsApp -Title "Microsoft Teams Notification" -Equals -Verbose

    .NOTES
    If this proves useful, we should PR it to the selenium-powershell project.
    #>

    [CmdLetBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [OpenQA.Selenium.IWebDriver]
        $Driver,

        [Parameter(Mandatory=$true)]
        [ValidateNotNull()]
        [string]
        $Title,

        [Parameter(ParameterSetName = 'Contains')]
        [switch]
        $Contains,

        [Parameter(ParameterSetName = 'EndsWith')]
        [switch]
        $EndsWith,

        [Parameter(ParameterSetName = 'Equals')]
        [switch]
        $Equals,

        [Parameter(ParameterSetName = 'Matches')]
        [switch]
        $Matches,

        [Parameter(ParameterSetName = 'StartsWith')]
        [switch]
        $StartsWith,

        [Parameter()]
        [switch]
        $WaitHtml
    )
    
    function test_titlematch
    {
        param($DriverTitle,$FindBy,$Title)

        switch($FindBy)
        {
            'Equals'       {  $DriverTitle -eq $Title         } 
            'EndsWith'     {  $DriverTitle.EndsWith($Title)   }
            'StartsWith'   {  $DriverTitle.StartsWith($Title) }
            'Contains'     {  $DriverTitle.Contains($Title)   }
            'Matches'      {  $DriverTitle -match $Title      }
        } 
    }

    $startWindowHandle = $Driver.CurrentWindowHandle
    Write-Verbose "$($MyInvocation.MyCommand): StartWindowHandle = $startWindowHandle : '$($Driver.Title)'"

    foreach (  $handle in (Get-SeWindow -Driver $Driver)  )
    {
        Write-Verbose "$($MyInvocation.MyCommand): WindowHandle = $handle"

        if (  ($Driver.Title) -and (test_titlematch -DriverTitle $Driver.Title -Title $Title -FindBy $PSCmdlet.ParameterSetName)  )
        {
            break
        }

        Write-Verbose "$($MyInvocation.MyCommand): Window '$($Driver.Title)' did not match '$Title' using $($PSCmdlet.ParameterSetName)" -ErrorAction SilentlyContinue
        if ($handle -ne $Driver.CurrentWindowHandle)
        {
            Switch-SeWindow -Driver $Driver -Window $handle
        }
        else
        {
            Write-Verbose "$($MyInvocation.MyCommand): Skipped switching to Window '$handle' from Window '$($Driver.CurrentWindowHandle)'"
        }

        if ($WaitHtml)
        {
            Find-SeElement -Driver $Driver -TagName 'html' -Wait | Out-Null 
        }
    }

    if (-not  (test_titlematch -DriverTitle $Driver.Title -Title $Title -FindBy $PSCmdlet.ParameterSetName)  )
    {
        Write-Warning "$($MyInvocation.MyCommand): Switching back to WindowHandle $startWindowHandle"
        Switch-SeWindow -Driver $Driver -Window $startWindowHandle
        throw "$($MyInvocation.MyCommand): Failed to locate window.`nCould not match '$Title' using $($PSCmdlet.ParameterSetName)"
    }
    else 
    {
        Write-Verbose "$($MyInvocation.MyCommand): Found window '$($Driver.Title)' matching '$Title' using $($PSCmdlet.ParameterSetName)"
        $Driver.CurrentWindowHandle
    }
}