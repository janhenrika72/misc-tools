

## Create projects

```cmd
dotnet new webapi -n xxxxxxxxx 
dotnet new classlib –n xxxxxxxxx.Database 
dotnet new xunit - xxxxxxxx.Tests
```

## Database creation, scaffolding and initial migration


```xml
<ItemGroup> 
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="9.0.10"> 
        <PrivateAssets>all</PrivateAssets> 
        <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive<IncludeAssets> 
    </PackageReference> 
    <PackageReference Include="Microsoft.EntityFrameworkCore.SqlServer" Version="9.0.10" /> 
    <PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="9.0.10"> 
        <PrivateAssets>all</PrivateAssets> 
        <IncludeAssets>runtime; build; native; contentfiles; analyzers; buildtransitive</IncludeAssets> 
    </PackageReference> 
</ItemGroup> 
```
## Web API project

### Program.cs
* Add and configure db context
* Add static class with extension method for registering all services
* Add static class with extension method for registering all endpoints
* Add swagger and API key auth
* Add settings to appsettings.json

### Dependency injection
```cs
public static class ConfigureEndpoints
{
    public static void MapEndpoints(this WebApplication app)
    {
        var root = app.MapGroup("v1");
        root.AddEndpointFilter<ApiKeyEndpointFilter>();

        // --------------------------------

        var group = root.MapGroup("employees").WithTags("Employees");

        group.MapGet("", async ([FromServices] EmployeeGetOperation handler, [FromQuery] string searchText) => { return await handler.Execute(request); })
            .WithName("Get Employees");
    }
}
```


### Add Swagger with API key auth
```cs
services.AddSwaggerGen(
    c =>
    {
        c.SwaggerDoc("v1", new OpenApiInfo { Title = "Skytech Control Subscription Management API", Version = "v1" });
        c.RegisterSwaggerAuth();
    });

public static class SwaggerAuthentication
{
    private const string SchemeName = "ApiKey";
    public static void RegisterSwaggerAuth(this SwaggerGenOptions c)
    {

        c.AddSecurityDefinition(SchemeName, new OpenApiSecurityScheme
        {
            Description = "API key",
            Type = SecuritySchemeType.ApiKey,
            In = ParameterLocation.Header,
            Name = AuthConstants.ApiKeyHeaderName,
            Scheme = SchemeName
        });

        var scheme = new OpenApiSecurityScheme
        {
            Reference = new OpenApiReference
            {
                Type = ReferenceType.SecurityScheme,
                Id = SchemeName
            }
        };

        var requirement = new OpenApiSecurityRequirement
        {
            { scheme, new List<string>() }
        };

        c.AddSecurityRequirement(requirement);
    }
}

### Database migration at startup
// Migrate db

bool migrateAndExit = args.Contains("-migrate");
if (migrateAndExit || builder.Configuration.GetValue("MigrateOnStartup", false))
{
    var migrationHandler = app.Services.GetRequiredService<IMigrationHandler>();
    migrationHandler.UpdateIfNeeded();
    if (migrateAndExit)
    {
        return;
    }
}

```



### ApiKey authentication
```cs
public class ApiKeyEndpointFilter(IConfiguration configuration) : IEndpointFilter
{
    readonly IConfiguration _configuration = configuration ?? throw new ArgumentNullException(nameof(configuration));

    public async ValueTask<object?> InvokeAsync(EndpointFilterInvocationContext context, EndpointFilterDelegate next)
    {
        var extractedApiKey = context.HttpContext.Request.Headers[AuthConstants.ApiKeyHeaderName];
        if (string.IsNullOrWhiteSpace(extractedApiKey))
        {
            return Results.Unauthorized();
        }

        var validApiKey = _configuration.GetSection("Authentication").GetValue<string>("ApiKey") ?? "";

        if (!validApiKey.Equals(extractedApiKey))
        {
            return Results.Unauthorized();
        }

        return await next(context);
    }
}
```

## Test projects
```xml
  <ItemGroup>
	  <PackageReference Include="coverlet.collector" Version="6.0.0" />
	  <PackageReference Include="Microsoft.NET.Test.Sdk" Version="17.8.0" />
	  <PackageReference Include="xunit" Version="2.5.3" />
	  <PackageReference Include="Moq" Version="4.20.72" />
	  <PackageReference Include="Xunit.DependencyInjection" Version="9.7.1" />
	  <PackageReference Include="xunit.runner.visualstudio" Version="2.5.3" />
  </ItemGroup>
```

Startup.cs
```cs
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;

namespace xxxxxxxxxxx.Tests;
public class Startup
{
	public void ConfigureServices (IServiceCollection services)
	{
		var myConfiguration = new Dictionary<string, string?>
		{
			{"ConnectionStrings:ControlDb", "Server=localhost; Port=3306; Database=control; Uid=root; Pwd=password; SslMode=Preferred;"},
			//{"section:setting", ""},
		};

		var configuration = new ConfigurationBuilder()
			.AddInMemoryCollection(myConfiguration)
			.Build();

		services.AddSingleton<IConfiguration>(configuration);

		services.AddTeliaServices();

		services.AddMemoryCache();
		services.AddHttpClient();

    }
}

```

## Run Latest MSSQL in Docker

```cmd
docker run --name mssql-server -e "ACCEPT_EULA=Y" -e "SA_PASSWORD=%LOCAL_SQL_PASSWORD%" -p 1433:1433 mcr.microsoft.com/mssql/server:latest
```
Set the environment variable `LOCAL_SQL_PASSWORD` on your host computer before running the command:

```cmd
set LOCAL_SQL_PASSWORD=YourStrong!Passw0rd
```

Replace `YourStrong!Passw0rd` with a secure password of your choice.