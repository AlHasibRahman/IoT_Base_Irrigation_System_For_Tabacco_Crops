using System.ComponentModel.DataAnnotations;

public class CreateDeviceRequest
{
    [Required]
    public string Name { get; set; } = string.Empty;

    [Required]
    public string FieldName { get; set; } = string.Empty;
}