
var express = require('express')
  , mongoose = require('mongoose')
  , http = require('http')
;

var app = express();

app.configure(function() {
    app.set('port', process.env.PORT || 3000)
    app.use(express.bodyParser());
    app.use(express.methodOverride());
    app.use(app.router);
    app.use(express.static(__dirname + "/dist"));
});


mongoose.connect("mongodb://localhost/todo");

var Schema = mongoose.Schema;

var todoSchema = new Schema({
    title: String,
    completed: Boolean
});

var Todo = mongoose.model('Todo', todoSchema);

// get
app.get("/todo", function(req, res) {
    Todo.find({}, function(err, docs) {
        res.send(docs);
    });
});

// create
app.post('/todo', function(req, res) {
    var b = req.body;
    new Todo({
        title: b.title,
        completed: b.completed
    }).save(function(err, docs){
        if (err)
            res.json(err);
    });
});

// handle param
app.param('item', function(req, res, next, name) {
    Todo.find({ title: item }, function(err, docs) {
        req.todo = doc[0];
        next();
    });
});

app.get('/todo/:item', function(req, res) {
    res.send(req.todo);
});

// update
app.put('/todo/:item', function(req, res) {
    var b = req.body;
    Todo.update(
        // query
        {title: req.param.title},
        {title: b.title, completed: b.completed},
        function(err) {

        }
    );
})

// delete
app.delete('/todo/:item', function(req, res) {
    Todo.remove(
        // query
        {title: req.params.title},
        function(err) {

        }
    )
});



http.createServer(app).listen(app.get('port'), function() {
    console.log("Express server listening on port " + app.get('port'));
});