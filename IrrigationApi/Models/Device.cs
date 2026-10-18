namespace IrrigationApi.Models;

public class Device
{
    public int Id { get; set; }

    public string Name { get; set; } = string.Empty;

    public string FieldName { get; set; } = string.Empty;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // The pump state requested by the app
    public bool DesiredPumpOn { get; set; } = false;

    // Version number for each new pump command
    public long PumpCommandVersion { get; set; } = 0;

    // Last command version acknowledged by the ESP8266
    public long PumpAcknowledgedVersion { get; set; } = 0;

    // Record the result reported by the device
    public bool? PumpLastCommandSucceeded { get; set; }
    public string? PumpLastCommandError { get; set; }

    public DateTime? PumpCommandUpdatedAt { get; set; }
    public DateTime? PumpAcknowledgedAt { get; set; }

    public ICollection<SensorReading> Readings { get; set; }
        = new List<SensorReading>();
}