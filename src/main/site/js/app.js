var app = {};

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
				app.show_content( data, function() {
					$("#fooclick").click(function(event){
						alert("fooclick");
						app.fetch_lsl("foo", "to/header_internal.lsl", {});
					});
				});
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

app.show_content = function( data, setup ) {
	$("#content_div").html( data );
	SyntaxHighlighter.highlight();
	if( "undefined" !== typeof setup ) {
		setup();
	} else {
		alert("setup undef");
	}
}

app.failure = function(jqXHR, textStatus, data) {
	
}

app.fetch_lsl = function(element_id, script_path, options) {
	$.ajax({
		url: "/rb/index.rb?prop_path=properties/defaults.properties&org=T3FOSS&repo=call-other-script&file=" + script_path,
		cache: false,
		success: function(data, textStatus, jqXHR) {
			// delegate to loader widget
			$("#" + element_id).html( data );
		},
		failure: function(jqXHR, textStatus, data) {
			// delegate to loader widget.
			$("#" + element_id).html( textStatus );
		}
	});
}

Backbone.history.start({pushState: true});

$(document).ready(function(){
	// Don't do anything 'till we're ready.
	
	$(".nav li").click(function(event){
		router.navigate( $(this).attr( "id" ).replace( "nav_", "" ), {trigger: true} );
	});
});