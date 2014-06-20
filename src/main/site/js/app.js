define([
	"jquery"
], function($) {
	
	var app = {};
	
	app.show_content = function( data, setup ) {
		
		var $content_div = $("#content_div");
		
		$content_div.html( data );
		
		if( "undefined" !== typeof setup ) {
			require( [setup], function(PageView) {
				var view = new PageView({el: $content_div});
				view.initialize();
				view.render();
			});
		}
		
		SyntaxHighlighter.highlight();
	};
	
	app.failure = function(jqXHR, textStatus, data) {
		alert( "failure: " + data );
	};
	
	
	var Router = Backbone.Router.extend({
		routes: {
			"": "about",
			"about": "about",
			"use": "use",
			"build": "build",
			"doc": "documentation",
			"bugs": "bugs"
		},

		about: function() {
			$.ajax({
				url: "html/about.html",
				cache: false,
				success: function(data, textStatus, jqXHR) {
					app.show_content( data );
				},
				failure: app.failure
			});
		},

		use: function() {
			$.ajax({
				url: "html/use.html",
				cache: false,
				success: function(data, textStatus, jqXHR) {
					app.show_content( data, "use" );
				},
				failure: app.failure
			});
		},

		build: function() {
			$.ajax({
				url: "html/build.html",
				cache: false,
				success: function(data, textStatus, jqXHR) {
					app.show_content( data );
				},
				failure: app.failure
			});
		},

		documentation: function() {
			$.ajax({
				url: "html/doc.html",
				cache: false,
				success: function(data, textStatus, jqXHR) {
					app.show_content( data );
				},
				failure: app.failure
			});
		}, 

		bugs: function() {
			$.ajax({
				url: "html/bugs.html",
				cache: false,
				success: function(data, textStatus, jqXHR) {
					app.show_content( data );
				},
				failure: app.failure
			});
		}
	});

	var router = new Router();
	
	Backbone.history.start({pushState: true});
	
	$(document).ready(function(){
		// Don't do anything 'till we're ready.

		$(".nav li").click(function(event){
			router.navigate( $(this).attr( "id" ).replace( "nav_", "" ), {trigger: true} );
		});
	});
});