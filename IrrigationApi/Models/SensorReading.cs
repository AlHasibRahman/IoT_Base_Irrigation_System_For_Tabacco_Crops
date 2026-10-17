namespace IrrigationApi.Models;

public class SensorReading
{
    public long Id { get; set; }

    public int DeviceId { get; set; }

    public double Temperature { get; set; }

    public double Humidity { get; set; }

    public double SoilMoisture { get; set; }

    public double SoilPh { get; set; }

    public bool PumpOn { get; set; }

    public double WateringDurationMinutes { get; set; }

    public DateTime RecordedAt { get; set; } = DateTime.UtcNow;

    public Device Device { get; set; } = null!;
}