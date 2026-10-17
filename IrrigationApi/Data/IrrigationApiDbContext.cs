using IrrigationApi.Models;
using Microsoft.EntityFrameworkCore;

namespace IrrigationApi.Data;

public class IrrigationDbContext : DbContext
{
    public IrrigationDbContext(
        DbContextOptions<IrrigationDbContext> options)
        : base(options)
    {
    }

    public DbSet<Device> Devices => Set<Device>();

    public DbSet<SensorReading> SensorReadings =>
        Set<SensorReading>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        modelBuilder.Entity<Device>(entity =>
        {
            entity.HasKey(d => d.Id);

            entity.Property(d => d.Name)
                .HasMaxLength(100)
                .IsRequired();

            entity.Property(d => d.FieldName)
                .HasMaxLength(150)
                .IsRequired();
        });

        modelBuilder.Entity<SensorReading>(entity =>
        {
            entity.HasKey(r => r.Id);

            entity.Property(r => r.Temperature).HasColumnType("float");
            entity.Property(r => r.Humidity).HasColumnType("float");
            entity.Property(r => r.SoilMoisture).HasColumnType("float");
            entity.Property(r => r.SoilPh).HasColumnType("float");

            entity.HasOne(r => r.Device)
                .WithMany(d => d.Readings)
                .HasForeignKey(r => r.DeviceId)
                .OnDelete(DeleteBehavior.Restrict);

            entity.HasIndex(r => new { r.DeviceId, r.RecordedAt });
        });
    }
}