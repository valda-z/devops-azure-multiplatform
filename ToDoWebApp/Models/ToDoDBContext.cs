using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace ToDoWebApp.Models
{
    public class ToDoDBContext : DbContext
    {
        public ToDoDBContext()
            : base("DefaultConnection")
        {
        }

        public static ToDoDBContext Create()
        {
            return new ToDoDBContext();
        }

        public System.Data.Entity.DbSet<ToDo> ToDoes { get; set; }
    }
}