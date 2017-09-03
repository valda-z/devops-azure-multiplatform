using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using ToDoWebApp.Models;

namespace ToDoWebApp.Controllers
{
    public class ToDoController : ApiController
    {
        [HttpPost]
        public ToDo Post(ToDo todo)
        {
            var cx = new ToDoDBContext();
            var curr = cx.ToDoes.Single(e => e.id == todo.id);
            curr.updated = DateTime.Now;
            curr.category = todo.category;
            curr.comment = todo.comment;
            cx.SaveChanges();
            return todo;
        }
    }
}
