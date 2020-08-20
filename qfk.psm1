#requires -Version 2 -Modules posh-git

function Write-Theme {

    param(
        [bool]
        $lastCommandFailed,
        [string]
        $with
    )

    $lastColor = $sl.Colors.PromptBackgroundColor
    
     # check the last command state and indicate if failed
    $sFailed = ""
    If ($lastCommandFailed) {
        $sFailed = " $($sl.PromptSymbols.FailedCommandSymbol)"
    }

    $prompt = ""

    $lastColor = $sl.Colors.PromptBackgroundColor
    $prompt += Write-Prompt -Object $sl.PromptSymbols.StartSymbol -ForegroundColor $sl.Colors.UserBackgroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    $prompt += Write-Prompt -Object $sFailed -ForegroundColor $sl.Colors.CommandFailedIconForegroundColor
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.UserBackgroundColor

    #check for elevated prompt
    If (Test-Administrator) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.ElevatedSymbol) " -ForegroundColor $sl.Colors.AdminIconForegroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    }

    $user = $sl.CurrentUser
    $computer = $sl.CurrentHostname
    if (Test-NotDefaultUser($user)) {
        $prompt += Write-Prompt -Object " $user@$computer " -ForegroundColor $sl.Colors.SessionInfoForegroundColor -BackgroundColor $sl.Colors.UserBackgroundColor
    }

    if (Test-VirtualEnv) {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.SessionInfoBackgroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.VirtualEnvSymbol) $(Get-VirtualEnvName) " -ForegroundColor $sl.Colors.VirtualEnvForegroundColor -BackgroundColor $sl.Colors.VirtualEnvBackgroundColor
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.VirtualEnvBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }
    else {
        $prompt += Write-Prompt -Object "$($sl.PromptSymbols.SegmentForwardSymbol) " -ForegroundColor $sl.Colors.UserBackgroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    }

    # Writes the drive portion
    $prompt += Write-Prompt -Object (Get-ShortPath -dir $pwd) -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor
    $prompt += Write-Prompt -Object ' ' -ForegroundColor $sl.Colors.PromptForegroundColor -BackgroundColor $sl.Colors.PromptBackgroundColor

    $status = Get-VCSStatus
    if ($status) {
        $themeInfo = Get-VcsInfo -status ($status)
        $lastColor = $themeInfo.BackgroundColor
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $sl.Colors.PromptBackgroundColor -BackgroundColor $lastColor
        $prompt += Write-Prompt -Object " $($themeInfo.VcInfo) " -BackgroundColor $lastColor -ForegroundColor $sl.Colors.GitForegroundColor
    }

    if ($with) {
        $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor -BackgroundColor $sl.Colors.WithBackgroundColor
        $prompt += Write-Prompt -Object " $($with.ToUpper()) " -BackgroundColor $sl.Colors.WithBackgroundColor -ForegroundColor $sl.Colors.WithForegroundColor
        $lastColor = $sl.Colors.WithBackgroundColor
    }

    # Writes the postfix to the prompt
    $prompt += Write-Prompt -Object $sl.PromptSymbols.SegmentForwardSymbol -ForegroundColor $lastColor
    $prompt += Set-Newline
    $prompt += Write-Prompt -Object $sl.PromptSymbols.NewLineSymbol -ForegroundColor $sl.Colors.UserBackgroundColor -BackgroundColor $sl.Colors.SessionInfoBackgroundColor
    $prompt += " "
    $prompt
}

$sl = $global:ThemeSettings #local settings
$sl.PromptSymbols.SegmentForwardSymbol = [char]::ConvertFromUtf32(0xE0B0)
$sl.PromptSymbols.StartSymbol = [char]::ConvertFromUtf32(0x250C)
$sl.PromptSymbols.NewLineSymbol = [char]::ConvertFromUtf32(0x2514) + $sl.PromptSymbols.SegmentForwardSymbol
$sl.Colors.PromptForegroundColor = [ConsoleColor]::White
$sl.Colors.PromptBackgroundColor = [System.ConsoleColor]::DarkCyan
$sl.Colors.PromptSymbolColor = [ConsoleColor]::White
$sl.Colors.PromptHighlightColor = [ConsoleColor]::DarkBlue
$sl.Colors.GitForegroundColor = [ConsoleColor]::Black
$sl.Colors.GitNoLocalChangesAndAheadColor = [ConsoleColor]::DarkGray
$sl.Colors.WithForegroundColor = [ConsoleColor]::White
$sl.Colors.WithBackgroundColor = [ConsoleColor]::DarkRed
$sl.Colors.VirtualEnvBackgroundColor = [System.ConsoleColor]::Red
$sl.Colors.VirtualEnvForegroundColor = [System.ConsoleColor]::White
$sl.Colors.UserBackgroundColor = [System.ConsoleColor]::DarkMagenta
