using IrrigationApi.Models;
using Microsoft.EntityFrameworkCore;

namespace IrrigationApi.Data
{
    public class IrrigationApiDbContext : DbContext
    {
        IrrigationApiDbContext(DbContextOptions<IrrigationApiDbContext> dbContextOptions) : base(dbContextOptions)
        {

        }

        //DbSet Properties
        public DbSet<Device> Devices { get; set; }

        protected override void OnModelCreating(ModelBuilder b)
        {
            b.Entity<SensorReading>().HasIndex(x => new { x.DeviceId, x.RecordedAt });
            b.Entity<Device>().HasData(new Device
            {
                Id = 1,
                Name = "Tobacco Field 1",
                FieldName = "Plot A",
                CreatedAt = new DateTime(2026, 1, 1)
            });
        }
    }
}