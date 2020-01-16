# local quick test before adding pesters


remove-module -name Selenium -ErrorAction SilentlyContinue
if ( (get-module -name Selenium) ) { throw 'Failed to unload module' }
import-module .\Selenium.psd1

$Driver = Start-SeChrome -DriverPath "C:\tools\selenium\79" -Maximized
$Driver.Manage().Timeouts().ImplicitWait = [TimeSpan]::FromSeconds(6)

$Driver | Enter-SeUrl -url 'https://www.google.com'
#$Driver | Find-SeElement -name q | Send-SeKeys -Keys 'Powershell-Selenium' | Send-SeKeys -Keys ([OpenQA.Selenium.Keys]::Enter)
$Driver | Find-SeElement -ClassName 'SDkEP' | Find-SeElement -Name 'q' | Send-SeKeys -Keys 'Powershell-Selenium' | Send-SeKeys -Keys ([OpenQA.Selenium.Keys]::Enter)

$Driver | Stop-SeDriver