
var express = require('express')
  , mongoose = require('mongoose')
  , http = require('http')
;

var app = express();

app.configure(function() {
    app.set('port', process.env.PORT || 3333)
    app.use(express.bodyParser());
    app.use(express.methodOverride());

    // for cross origin in Dev, security hole! should only for Dev purpose
    app.use(function(req, res, next) {
        res.setHeader("Access-Control-Allow-Origin", "*");
        res.setHeader("Access-Control-Allow-Headers", "Origin, X-Requested-With, Content-Type, Accept");
        return next();
    });

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

// get all
app.get("/todo", function(req, res) {
    Todo.find({}, function(err, docs) {
        if (err) {
            res.send(400);
        } else {
            res.send(docs);
        }
    });
});

// handle param
app.param("item", function(req, res, next, item) {
    Todo.find({ title: item }, function(err, docs) {
        req.todo = docs[0];
        console.log (req.todo);
        next();
    });
});

// get one item
app.get("/todo/:item", function(req, res) {
    res.send(req.todo);
});

// create
app.post('/todo', function(req, res) {
    var b = req.body;
    new Todo({
        title: b.title,
        completed: b.completed
    }).save(function(err, docs){
        if (err) {
            res.send(err);
        } else {
            res.send(docs);
        }
    });
});

// update
app.put('/todo/:item', function(req, res) {
    var b = req.body;
    console.log(req.params.item);
    Todo.update(
        // query
        {title: req.params.item},
        {title: b.title, completed: b.completed},
        function(err, docs) {
            if (err) {
                res.send(err);
            } else {
                res.status(200);
            }
        }
    );
})

// delete
app.delete('/todo/:item', function(req, res) {
    Todo.remove(
        // query
        {title: req.params.item},
        function(err, docs) {
            if (err) {
                res.send(err);
            } else {
                res.status(200);
            }
        }
    );
});


http.createServer(app).listen(app.get('port'), function() {
    console.log("Express server listening on port " + app.get('port'));
});