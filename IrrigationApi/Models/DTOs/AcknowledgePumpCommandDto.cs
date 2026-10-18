using System.ComponentModel.DataAnnotations;

namespace IrrigationApi.DTOs;

public class AcknowledgePumpCommandDto
{
    [Range(0, long.MaxValue)]
    public long CommandVersion { get; set; }

    [Required]
    public bool? Applied { get; set; }

    [MaxLength(300)]
    public string? ErrorMessage { get; set; }
}