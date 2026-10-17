using IrrigationApi.Data;
using IrrigationApi.DTOs;
using IrrigationApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace IrrigationApi.Controllers;

[ApiController]
[Route("api")]
public class ReadingsController : ControllerBase
{
    private readonly IrrigationDbContext _db;

    public ReadingsController(IrrigationDbContext db)
    {
        _db = db;
    }

    // POST /api/readings
    // ESP8266 uploads a new sensor reading.
    [HttpPost("readings")]
    public async Task<IActionResult> CreateReading(
        [FromBody] CreateSensorReadingDto dto)
    {
        var deviceExists = await _db.Devices
            .AnyAsync(d => d.Id == dto.DeviceId);

        if (!deviceExists)
        {
            return NotFound(new
            {
                message = "Device not found."
            });
        }

        var reading = new SensorReading
        {
            DeviceId = dto.DeviceId,
            Temperature = dto.Temperature,
            Humidity = dto.Humidity,
            SoilMoisture = dto.SoilMoisture,
            SoilPh = dto.SoilPh,
            PumpOn = dto.PumpOn,
            WateringDurationMinutes =
                dto.WateringDurationMinutes,
            RecordedAt = DateTime.UtcNow
        };

        _db.SensorReadings.Add(reading);
        await _db.SaveChangesAsync();

        return Created(
            $"/api/devices/{reading.DeviceId}/readings/{reading.Id}",
            new
            {
                reading.Id,
                reading.DeviceId,
                reading.Temperature,
                reading.Humidity,
                reading.SoilMoisture,
                reading.SoilPh,
                reading.PumpOn,
                reading.WateringDurationMinutes,
                reading.RecordedAt
            });
    }

    // GET /api/devices/1/latest-reading
    [HttpGet("devices/{deviceId:int}/latest-reading")]
    public async Task<IActionResult> GetLatestReading(int deviceId)
    {
        var deviceExists = await _db.Devices
            .AnyAsync(d => d.Id == deviceId);

        if (!deviceExists)
        {
            return NotFound(new { message = "Device not found." });
        }

        var reading = await _db.SensorReadings
            .AsNoTracking()
            .Where(r => r.DeviceId == deviceId)
            .OrderByDescending(r => r.RecordedAt)
            .ThenByDescending(r => r.Id)
            .Select(r => new
            {
                r.Id,
                r.DeviceId,
                r.Temperature,
                r.Humidity,
                r.SoilMoisture,
                r.SoilPh,
                r.PumpOn,
                r.WateringDurationMinutes,
                r.RecordedAt
            })
            .FirstOrDefaultAsync();

        if (reading is null)
        {
            return NotFound(new
            {
                message = "No readings available for this device."
            });
        }

        return Ok(reading);
    }

    // GET /api/devices/1/readings?limit=50
    [HttpGet("devices/{deviceId:int}/readings")]
    public async Task<IActionResult> GetHistory(
        int deviceId,
        [FromQuery] int limit = 50)
    {
        if (limit < 1 || limit > 500)
        {
            return BadRequest(new
            {
                message = "Limit must be between 1 and 500."
            });
        }

        var deviceExists = await _db.Devices
            .AnyAsync(d => d.Id == deviceId);

        if (!deviceExists)
        {
            return NotFound(new { message = "Device not found." });
        }

        var readings = await _db.SensorReadings
            .AsNoTracking()
            .Where(r => r.DeviceId == deviceId)
            .OrderByDescending(r => r.RecordedAt)
            .ThenByDescending(r => r.Id)
            .Take(limit)
            .Select(r => new
            {
                r.Id,
                r.DeviceId,
                r.Temperature,
                r.Humidity,
                r.SoilMoisture,
                r.SoilPh,
                r.PumpOn,
                r.WateringDurationMinutes,
                r.RecordedAt
            })
            .ToListAsync();

        return Ok(readings);
    }
}