
public class MigrationHandler(IServiceProvider serviceProvider) : IMigrationHandler
{
    private readonly IServiceProvider _serviceProvider = serviceProvider;

    public void UpdateIfNeeded()
    {
        using (var scope = _serviceProvider.CreateScope())
        {
            var db = scope.ServiceProvider.GetRequiredService<SubscriptionManagementDbContext>();

            var pendingMigrations = db.Database.GetPendingMigrations(); // If this yields an empty list, make sure that DbContext OnConfiguring method is not overridden with wrong database

            if (pendingMigrations.Any())
            {
                Console.WriteLine("The following migrations will be applied:");
                foreach (var migrationName in pendingMigrations)
                {
                    Console.WriteLine(migrationName);
                }
                db.Database.Migrate();
            }
            else
            {
                Console.WriteLine("Database is up to date");
            }

        }
    }
}