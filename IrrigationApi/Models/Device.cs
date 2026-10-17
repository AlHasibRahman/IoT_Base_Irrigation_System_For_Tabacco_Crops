namespace IrrigationApi.Models;

public class Device
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string FieldName { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    public ICollection<SensorReading> Readings { get; set; }
        = new List<SensorReading>();
}