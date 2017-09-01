var mongoose = require('mongoose');

module.exports = mongoose.model('ToDo', {
    id: String,
    comment: String,
    category: String,
    created: Date,
    updated: Date
});