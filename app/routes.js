var ToDo = require('./models/todo');

module.exports = function(app) {
    /* API */

    // get all 
    app.get('/api/ToDoList', function(req, res) {

        // mongoose get all todoes
        ToDo.find(function(err, todoes) {

            // send an error
            if (err)
                res.send(err)

            res.json(todoes); // return all 
        });
    });

    // get todo form data and dave it
    app.post('/api/ToDoAdd', function(req, res) {

        // insert new todo			
        ToDo.create({
            id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                var r = Math.random() * 16 | 0,
                    v = c == 'x' ? r : r & 0x3 | 0x8;
                return v.toString(16);
            }),
            comment: req.body.comment,
            category: req.body.category,
            created: new Date(),
            updated: new Date()
        }, function(err, todo) {
            if (err)
                res.send(err);

            res.send(todo);
        });

    });

    // update
    app.post('/api/ToDo', function(req, res) {
        var id = req.body._id;
        console.log("Saving todo: " + id);

        ToDo.findById(id, function(err, todo) {
            if (err)
                res.send(err);

            // fields that can be updated:
            todo.comment = req.body.comment;
            todo.category = req.body.category;
            todo.updated = new Date();

            todo.save(function(err) {
                if (err)
                    res.send(err);

                res.send(todo);
            });
        });
    });

    app.get('*', function(req, res) {
        // load index.html otherwise
        res.sendfile('./www/index.html');
    });
};