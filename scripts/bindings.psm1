Set-PSReadLineKeyHandler -Chord 'Ctrl+p' -ScriptBlock {
    [Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
    [Microsoft.PowerShell.PSConsoleReadLine]::Insert('python.exe')
    [Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
}
