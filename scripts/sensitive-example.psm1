# https://www.reddit.com/r/PowerShell/comments/gdhiwa/comment/fphwgj8
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
param()

$WorkDirectory='C:\ENTERPRISE'
$TODODirectory='C:\DOCUMENTS\TODODIR'

Export-ModuleMember -Variable @(
    'WorkDirectory',
    'TODODirectory'
)