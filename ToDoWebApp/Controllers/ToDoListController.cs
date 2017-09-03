using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using ToDoWebApp.Models;

namespace ToDoWebApp.Controllers
{
    public class ToDoListController : ApiController
    {
        [HttpGet]
        public ToDo[] List()
        {
            return new ToDoDBContext().ToDoes.ToArray();
        }
    }
}
