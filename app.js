
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


// get


// add


// update


// delete




http.createServer(app).listen(app.get('port'), function() {
    console.log("Express server listening on port " + app.get('port'));
});