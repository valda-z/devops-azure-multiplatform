package com.microsoft.azuresample.javawebapp.controller;

import com.microsoft.azuresample.javawebapp.model.ToDo;
import com.microsoft.azuresample.javawebapp.model.ToDoDAO;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.Date;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@RestController
public class MainController {
    static final Logger LOG = LoggerFactory.getLogger(MainController.class);

    ToDoDAO dao=new ToDoDAO();

    @RequestMapping(value = "/api/ToDoAdd", method = { RequestMethod.POST })
    public
    @ResponseBody
    ToDo insertToDo(@RequestBody ToDo item) {
        LOG.info("Create toto item.");
        // create ToDo item
        item.setId(UUID.randomUUID().toString());
        item.setCreated(new Date());
        item.setUpdated(new Date());
        ToDo ret = dao.create(item);
        return ret;
    }

    @RequestMapping(value = "/api/ToDo", method = { RequestMethod.POST })
    public
    @ResponseBody
    ToDo updateToDo(@RequestBody ToDo item) {
        LOG.info("Update todo item.");
        // update ToDo item
        item.setUpdated(new Date());
        ToDo ret = dao.update(item);
        return ret;
    }

    @RequestMapping(value = "/api/ToDoList", method = { RequestMethod.GET })
    public
    @ResponseBody
    List<ToDo> listToDo() {
        LOG.info("List todo items.");
        return dao.query();
    }
}

