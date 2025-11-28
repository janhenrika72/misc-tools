param(
    [Parameter(Mandatory=$true)]
    [string] $LocalDatabaseName
)

$dbPass = (Get-Item "Env:LOCAL_SQL_PASSWORD").Value # Do not hardcode passwords in scripts

if (-not $dbPass) {
    Write-Error "Environment variable LOCAL_SQL_PASSWORD is not set."
    exit 1
}

$contextFile = (Get-Item -Path *Context.cs)
if (-not $contextFile) {
    Write-Error "Context file not found."
    exit 1
}


$contextFilePath = $contextFile.FullName
$projectFilePath = (Get-Item -Path *.csproj).FullName

$connStr = "Server=localhost,1433;Database=$LocalDatabaseName;User Id=sa;Password=${dbPass};Trust Server Certificate=True"

& dotnet ef dbcontext scaffold $connStr Microsoft.EntityFrameworkCore.SqlServer --output-dir $PSScriptRoot\Entities --context-dir $PSScriptRoot --context $contextFile.BaseName --force --project $projectFilePath

$lines = [System.IO.File]::ReadAllLines($contextFilePath)

# Filter out the OnConfiguring override
$filteredLines = @()
$skip = $false
foreach ($line in $lines) {
    if ($line.Trim().StartsWith("protected override void OnConfiguring")) { $skip = $true }
    if ($skip -and $line.Trim().Equals("")) { $skip = $false }
    if (-not $skip) { $filteredLines += $line }
}

[System.IO.File]::WriteAllLines($contextFilePath, $filteredLines)
