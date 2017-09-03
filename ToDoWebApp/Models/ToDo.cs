using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Web;

namespace ToDoWebApp.Models
{
    [Table("ToDo")]
    public class ToDo
    {
        [Key]
        [DatabaseGeneratedAttribute(DatabaseGeneratedOption.Identity)]
        public int itemId { get; set; }

        public Guid id { get; set; }

        [StringLength(50)]
        public string category { get; set; }

        [StringLength(500)]
        public string comment { get; set; }

        public DateTime created { get; set; }
        public DateTime updated { get; set; }
    }
}