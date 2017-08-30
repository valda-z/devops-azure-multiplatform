module.exports = function(context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    if (req.body) {
        context.bindings.cosmoDocument = {
            id: 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
                var r = Math.random() * 16 | 0,
                    v = c == 'x' ? r : r & 0x3 | 0x8;
                return v.toString(16);
            }),
            created: new Date(),
            updated: new Date(),
            category: req.body.category,
            comment: req.body.comment
        }

        context.res = {
            // status: 200, /* Defaults to 200 */
            body: "Todo item created with id: " + context.bindings.cosmoDocument.id
        };
    } else {
        context.res = {
            status: 400,
            body: "Insufficient parameters!"
        };
    }
    context.done();
};