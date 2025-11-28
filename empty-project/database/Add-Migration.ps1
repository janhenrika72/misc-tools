param(
    [Parameter(Mandatory=$true)]
    [string] $MigrationName
)

$contextFile = (Get-Item -Path *Context.cs)

& dotnet ef migrations add $MigrationName --context $contextFile.BaseName --startup-project ../SkytechControl.SubscriptionManagement
