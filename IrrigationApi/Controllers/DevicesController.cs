using IrrigationApi.Data;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace IrrigationApi.Controllers;

[ApiController]
[Route("api/devices")]
public class DevicesController : ControllerBase
{
    private readonly IrrigationDbContext _db;

    public DevicesController(IrrigationDbContext db)
    {
        _db = db;
    }

    // GET /api/devices
    [HttpGet]
    public async Task<IActionResult> GetDevices()
    {
        var devices = await _db.Devices
            .AsNoTracking()
            .Select(d => new
            {
                d.Id,
                d.Name,
                d.FieldName,
                d.CreatedAt
            })
            .ToListAsync();

        return Ok(devices);
    }

    // GET /api/devices/1
    [HttpGet("{id:int}")]
    public async Task<IActionResult> GetDevice(int id)
    {
        var device = await _db.Devices
            .AsNoTracking()
            .Where(d => d.Id == id)
            .Select(d => new
            {
                d.Id,
                d.Name,
                d.FieldName,
                d.CreatedAt
            })
            .FirstOrDefaultAsync();

        if (device is null)
        {
            return NotFound(new { message = "Device not found." });
        }

        return Ok(device);
    }

    // GET /api/devices/1/pump-status
    [HttpGet("{id:int}/pump-status")]
    public async Task<IActionResult> GetPumpStatus(int id)
    {
        var deviceExists = await _db.Devices
            .AnyAsync(d => d.Id == id);

        if (!deviceExists)
        {
            return NotFound(new { message = "Device not found." });
        }

        var reading = await _db.SensorReadings
            .AsNoTracking()
            .Where(r => r.DeviceId == id)
            .OrderByDescending(r => r.RecordedAt)
            .ThenByDescending(r => r.Id)
            .Select(r => new
            {
                r.PumpOn,
                r.RecordedAt
            })
            .FirstOrDefaultAsync();

        if (reading is null)
        {
            return NotFound(new
            {
                message = "No pump status is available yet."
            });
        }

        return Ok(new
        {
            deviceId = id,
            reading.PumpOn,
            reading.RecordedAt
        });
    }
}