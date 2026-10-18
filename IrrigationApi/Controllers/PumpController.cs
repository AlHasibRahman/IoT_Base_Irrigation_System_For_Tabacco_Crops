using IrrigationApi.Data;
using IrrigationApi.DTOs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace IrrigationApi.Controllers;

[ApiController]
[Route("api/devices/{deviceId:int}/pump")]
public class PumpController : ControllerBase
{
    private readonly IrrigationDbContext _db;

    public PumpController(IrrigationDbContext db)
    {
        _db = db;
    }

    // PUT /api/devices/1/pump
    // App requests ON or OFF.
    [HttpPut]
    public async Task<IActionResult> SetPump(
        int deviceId,
        [FromBody] SetPumpCommandDto dto)
    {
        var device = await _db.Devices
            .FirstOrDefaultAsync(d => d.Id == deviceId);

        if (device is null)
        {
            return NotFound(new
            {
                message = "Device not found."
            });
        }

        device.DesiredPumpOn = dto.PumpOn!.Value;
        device.PumpCommandVersion++;
        device.PumpCommandUpdatedAt = DateTime.UtcNow;
        device.PumpLastCommandSucceeded = null;
        device.PumpLastCommandError = null;

        await _db.SaveChangesAsync();

        return Accepted(new
        {
            deviceId,
            pumpOn = device.DesiredPumpOn,
            commandVersion = device.PumpCommandVersion,
            pending = true,
            message = "Command queued. Waiting for device acknowledgement."
        });
    }

    // GET /api/devices/1/pump/command
    // ESP8266 polls this endpoint.
    [HttpGet("command")]
    public async Task<IActionResult> GetPumpCommand(int deviceId)
    {
        var device = await _db.Devices
            .AsNoTracking()
            .Where(d => d.Id == deviceId)
            .Select(d => new
            {
                d.Id,
                d.DesiredPumpOn,
                d.PumpCommandVersion,
                d.PumpAcknowledgedVersion
            })
            .FirstOrDefaultAsync();

        if (device is null)
        {
            return NotFound(new
            {
                message = "Device not found."
            });
        }

        return Ok(new
        {
            deviceId = device.Id,
            pumpOn = device.DesiredPumpOn,
            commandVersion = device.PumpCommandVersion,
            pending = device.PumpCommandVersion >
                      device.PumpAcknowledgedVersion
        });
    }

    // POST /api/devices/1/pump/command/ack
    // ESP8266 reports whether it applied the command.
    [HttpPost("command/ack")]
    public async Task<IActionResult> AcknowledgeCommand(
        int deviceId,
        [FromBody] AcknowledgePumpCommandDto dto)
    {
        var device = await _db.Devices
            .FirstOrDefaultAsync(d => d.Id == deviceId);

        if (device is null)
        {
            return NotFound(new
            {
                message = "Device not found."
            });
        }

        // Ignore acknowledgements for stale commands.
        if (dto.CommandVersion != device.PumpCommandVersion)
        {
            return Conflict(new
            {
                message = "This command is no longer current."
            });
        }

        device.PumpAcknowledgedVersion = dto.CommandVersion;
        device.PumpAcknowledgedAt = DateTime.UtcNow;
        device.PumpLastCommandSucceeded = dto.Applied!.Value;
        device.PumpLastCommandError = dto.Applied.Value
            ? null
            : dto.ErrorMessage ?? "Device failed to apply the command.";

        await _db.SaveChangesAsync();

        return Ok(new
        {
            deviceId,
            commandVersion = dto.CommandVersion,
            applied = dto.Applied.Value,
            pending = false,
            message = dto.Applied.Value
                ? "Command acknowledged."
                : "Device reported a command failure."
        });
    }
}