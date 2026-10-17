namespace IrrigationApi.Models
{
    public class Device
    {
        public int Id { get; set; }
        public string Name { get; set; } = "";
        public string FieldName { get; set; } = "";
        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    }
}