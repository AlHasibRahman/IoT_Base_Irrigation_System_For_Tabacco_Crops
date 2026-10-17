using System.ComponentModel.DataAnnotations;

namespace IrrigationApi.DTOs;

public class CreateSensorReadingDto
{
    [Range(1, int.MaxValue)]
    public int DeviceId { get; set; }

    [Range(-20, 80)]
    public double Temperature { get; set; }

    [Range(0, 100)]
    public double Humidity { get; set; }

    [Range(0, 100)]
    public double SoilMoisture { get; set; }

    [Range(0, 14)]
    public double SoilPh { get; set; }

    public bool PumpOn { get; set; }

    [Range(0, 1440)]
    public double WateringDurationMinutes { get; set; }
}