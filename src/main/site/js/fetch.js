define([
	"jquery"
], function($) {
	
	var do_fetch = function(element_id, script_path, options) {
		$.ajax({
			url: "/rb/index.rb?prop_path=properties/defaults.properties&org=T3FOSS&repo=call-other-script&file=" + script_path,
			cache: false,
			success: function(data, textStatus, jqXHR) {
				// delegate to loader widget
				
				if( !options.comments ) {
					// Strips single-line comments, multi-line comments, and hashed comments.
					data = data.replace( /[ \t]*(#|\/\/|(\/\*(.|[\r\n])*?\*\/)).*(\r|\r\n|\n)?/gm, "");
				}
				
				if( !options.whitespace ) {
					
					// remove non-semantic whitespace.
					
					if( !!options.comments ) {
						// Must not remove whitespace at end of single-line comments
						data = data.replace( /(?=([^#]|!\/\/)*)[\r\n \t\s]*[\r\n]+(?!=[^\r\n \t\s])/g, "");
					} else {
						data = data.replace( /(?=.*)[\r\n \t\s]*[\r\n]+(?!=[^\r\n \t\s])/g, "");
					}
				}
				
				$("#" + element_id).html( data );
			},
			failure: function(jqXHR, textStatus, data) {
				// delegate to loader widget.
				$("#" + element_id).html( textStatus );
			}
		});
	};
	
	return {
		fetch: do_fetch
	};
});