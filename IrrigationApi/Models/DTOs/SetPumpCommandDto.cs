using System.ComponentModel.DataAnnotations;

namespace IrrigationApi.DTOs;

public class SetPumpCommandDto
{
    [Required]
    public bool? PumpOn { get; set; }
}