
// These two lines are required to initialize Express in Cloud Code.
var express = require('express');
var app = express();

// Global app configuration section
// Set the template engine
app.use(express.bodyParser());    // Middleware for reading request body

// This is an example of hooking up a request handler with a specific request
// path and HTTP verb using the Express routing API.
app.get('/sync', function(req, res) {
	var i = 1;
	  var x = 0;
	  while (i < 10)
	  {
	    x++;
	  }
	var paymentQuery = new Parse.Query('Payment');
  	paymentQuery.include('user');
  	paymentQuery.limit(1000);
  	paymentQuery.find({success:function(payments){
  		res.send('Success');
	  },error:function(error){ res.send(error); }});
  //res.render('hello', { message: 'Congrats, you just set up your app!' });
	});

// // Example reading from the request query string of an HTTP get request.
// app.get('/test', function(req, res) {
//   // GET http://example.parseapp.com/test?message=hello
//   res.send(req.query.message);
// });

// // Example reading from the request body of an HTTP post request.
// app.post('/test', function(req, res) {
//   // POST http://example.parseapp.com/test (with request body "message=hello")
//   res.send(req.body.message);
// });

// Attach the Express app to Cloud Code.
app.listen();
