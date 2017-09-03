using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using ToDoWebApp.Models;

namespace ToDoWebApp.Controllers
{
    public class ToDoAddController : ApiController
    {
        [HttpPost]
        public ToDo Post(ToDo todo)
        {
            var cx = new ToDoDBContext();
            todo.id = Guid.NewGuid();
            todo.created = DateTime.Now;
            todo.updated = DateTime.Now;
            cx.ToDoes.Add(todo);
            cx.SaveChanges();
            return todo;
        }
    }
}
