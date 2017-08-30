module.exports = function(context, req) {
    context.log('JavaScript HTTP trigger function processed a request.');

    if (req.body) {
        context.log('document: ' + context.bindings.cosmoDocument);
        context.log('document.id: ' + context.bindings.cosmoDocument.id);
        context.log('document.comment: ' + context.bindings.cosmoDocument.comment);

        context.bindings.cosmoDocumentOut = context.bindings.cosmoDocument;
        context.bindings.cosmoDocumentOut.updated = new Date();
        context.bindings.cosmoDocumentOut.category = req.body.category;
        context.bindings.cosmoDocumentOut.comment = req.body.comment;

        context.res = {
            // status: 200, /* Defaults to 200 */
            body: "Todo item with id updated: " + context.bindings.cosmoDocumentOut.id
        };
    } else {
        context.res = {
            status: 400,
            body: "Insufficient parameters!"
        };
    }
    context.done();
};