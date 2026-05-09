param(
    [Parameter(Position = 0)]
    [string]$Message
)

$ErrorActionPreference = "Stop"

function Invoke-Git {
    param([Parameter(ValueFromRemainingArguments = $true)][string[]]$GitArgs)
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) {
        throw "git $($GitArgs -join ' ') failed with exit code $LASTEXITCODE"
    }
}

$repoRoot = Invoke-Git rev-parse --show-toplevel
Set-Location $repoRoot

$branch = Invoke-Git branch --show-current
if ([string]::IsNullOrWhiteSpace($branch)) {
    throw "Current repository is not on a branch."
}

$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "No local changes to sync."
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Message)) {
    $Message = "Update project $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
}

Invoke-Git add -A
Invoke-Git commit -m $Message
Invoke-Git pull --rebase origin $branch
Invoke-Git push origin $branch

Write-Host "Synced $branch to origin."
