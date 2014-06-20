define([
	"jquery",
	"fetch"
], function($, Fetch) {
	
	var view = Backbone.View.extend({
		
		events: {
			"click #fetch_script": "fetch_script",
			"click .option_button": "toggle_button",
			"click #clipboard_button": "copy"
		},
		
		initialize: function() {
			
		},
		
		render: function() {
			this.fetch_script();
		},
		
		afterRender: function() {
			$("[data-toggle='tooltip']").tooltip();
		},
		
		fetch_script: function() {
			Fetch.fetch( "script", "src/main/lsl/to/header_internal.lsl", {
				comments: $("#comment_button").hasClass("btn-primary"),
				whitespace: $("#whitespace_button").hasClass("btn-primary")
			} );
		},
		
		toggle_button: function(event) {
			var $button = $(event.target);
			
			$button.toggleClass( "btn-primary btn-default" );
			$( "span:first", $button ).toggleClass( "glyphicon-ok glyphicon-remove" );
		},
		
		copy: function() {
			$("#script")
		}
		
	});
	
	return view;
});