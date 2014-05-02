var app = {};

var Router = Backbone.Router.extend({
	routes: {
		"": "",
		"about": "about",
		"use": "use",
		"build": "build",
		"doc": "documentation",
		"bugs": "bugs"
	},
	
	about: function() {
		$.ajax({
			url: "html/about.html",
			success: function(data, textStatus, jqXHR) {
				app.show_content( data );
			},
			failure: app.failure
		});
	},
	
	use: function() {
		$.ajax({
			url: "html/use.html",
			success: function(data, textStatus, jqXHR) {
				app.show_content( data );
			},
			failure: app.failure
		});
	},
	
	build: function() {
		$.ajax({
			url: "html/build.html",
			success: function(data, textStatus, jqXHR) {
				app.show_content( data );
			},
			failure: app.failure
		});
	},
	
	documentation: function() {
		$.ajax({
			url: "html/doc.html",
			success: function(data, textStatus, jqXHR) {
				app.show_content( data );
			},
			failure: app.failure
		});
	}, 
	
	bugs: function() {
		$.ajax({
			url: "html/bugs.html",
			success: function(data, textStatus, jqXHR) {
				app.show_content( data );
			},
			failure: app.failure
		});
	}
});

var router = new Router();

app.show_content = function( data ) {
	$("#content_div").html( data );
}

app.failure = function(jqXHR, textStatus, data) {
	
}

Backbone.history.start({pushState: true});

$(document).ready(function(){
	// Don't do anything 'till we're ready.
	
	$(".nav li").click(function(event){
		router.navigate( $(this).attr( "id" ).replace( "nav_", "" ), {trigger: true} );
	});
});