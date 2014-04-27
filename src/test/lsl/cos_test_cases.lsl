basic(integer _verbose) {
    
    assertEqual(
        "basic",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "acc", "{\"num\":1}" ),
        "2",
        "The ${library.name.abbr.upper} Engine works." );
}

noscript(integer _verbose) {
    
    assertEqual(
        "noscript",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl29million", "echo", "{\"string\":\"cat\"}" ),
        "✖",
        "The ${library.name.abbr.upper} Engine fails noisily when the target script does not exist." );
        
    assertEqual(
        "noscript",
        _verbose,
        ${library.name.abbr.upper}_ERROR,
        "➀",
        "The ${library.name.abbr.upper} Engine correctly indicates the cause of the failure when the target script does not exist." );
}

nofunc(integer _verbose) {
    
    assertEqual(
        "nofunc",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "echo noexist", "{\"string\":\"cat\"}" ),
        "✖",
        "The ${library.name.abbr.upper} Engine fails noisily when the target function does not exist." );
}

long_response(integer _verbose) {
    
    string slipsum = "Your bones don't break, mine do. That's clear. Your cells react to bacteria and viruses differently than mine. You don't get sick, I do. That's also clear. But for some reason, you and I react the exact same way to water. We swallow it too fast, we choke. We get some in our lungs, we drown. However unreal it may seem, we are connected, you and I. We're on the same curve, just on opposite ends.";
    
    assertEqual(
        "long_response",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "echo", "{\"string\":\"" + slipsum + "\"}" ),
        slipsum,
        "The ${library.name.abbr.upper} Engine fails noisily when the remote response string is too long." );
}

rapid(integer _verbose) {
    
    assertEqual(
        "rapid",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "acc", "{\"num\":1}" ) +
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "acc", "{\"num\":2}" ) +
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "acc", "{\"num\":3}" ),
        "234",
        "The ${library.name.abbr.upper} engine can handle multiple, immediate calls." );
}
        
very_rapid(integer _verbose) {
    
    integer count = 0;
    integer prev = (integer)${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "stateacc", "" );
    for( count = 0; count < 50; count++ ) {
        integer next = (integer)${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "stateacc", "" );
        
        integer should_continue = assertEqual(
            "very_rapid",
            _verbose,
            (string)next,
            (string)(prev + 1),
            "Multiple rapid ${library.name.abbr.upper} invocations in one script should be answered in the order they are invoked. Invocation (" + (string)(count+1) + "/50) failed." );
            
        if( !should_continue ) {
            return;
        }
        
        prev = next;
    }
}
        
badchar(integer _verbose) {
    
    assertEqual(
        "rapid",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "echo", "{\"string\":\"pipes: | and newlines\nare cool\"}" ),
        "pipes: | and newlines\nare cool",
        "The ${library.name.abbr.upper} engine can handle characters forbidden in object descriptions." );
}
        
cleanup(integer _verbose) {
            
    ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "acc", "{\"num\":1}" );        
    
    assertEqual(
        "cleanup",
        _verbose,
        llGetObjectDesc(),
        "",
        "The ${library.name.abbr.upper} Engine leaves the object description clean after it runs." );
}
        
a2s_note(integer _verbose) {
        
    assertEqual(
        "a2s_note",
        _verbose,
        (string)${library.name.abbr.lower}_send( "synchronous_events.lsl2", "getNotecardLineSync", "{\"notecard\":\"${library.name.abbr.lower}_notes\",\"line\":2}" ),
        "this is line 3.",
        "The ${library.name.abbr.upper} Async2Sync Engine can get a notecard line synchronously." );
}
        
a2s_note_missing(integer _verbose) {
        
    assertEqual(
        "a2s_note_missing",
        _verbose,
        (string)${library.name.abbr.lower}_send( "synchronous_events.lsl2", "getNotecardLineSync", "{\"notecard\":\"${library.name.abbr.lower}_notes_nonexist\",\"line\":2}" ),
        "✖",
        "The ${library.name.abbr.upper} Async2Sync Engine reports failure correctly when asked for a notecard that doesn't exist." );
}
        
a2s_http(integer _verbose) {
        
    string header_json = ${library.name.abbr.lower}_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"http://headers.jsontest.com/\"}" );
    
    assertEqual(
        "a2s_http",
        _verbose,
        llJsonGetValue( header_json, [ "body", "X-SecondLife-Object-Key"] ),
        (string)llGetKey(),
        "The ${library.name.abbr.upper} Async2Sync Engine can complete an HTTP request synchronously." );    
}
        
a2s_http_404(integer _verbose) {
        
    string not_found = ${library.name.abbr.lower}_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"http://google.com/notreal\"}" );
    
    assertEqual(
        "a2s_http_404",
        _verbose,
        llJsonGetValue( not_found, [ "status"] ),
        "404",
        "The ${library.name.abbr.upper} Async2Sync Engine gracefully handles 404 errors." );    
}
        
a2s_http_504(integer _verbose) {
        
    string not_found = ${library.name.abbr.lower}_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"http://notarealwebsite.pleaesdontactuallybereal.fooblaggle.com/\"}" );
    
    assertEqual(
        "a2s_http_504",
        _verbose,
        llJsonGetValue( not_found, [ "status"] ),
        "504",
        "The ${library.name.abbr.upper} Async2Sync Engine gracefully handles remote gateway timeouts." );    
}
        
a2s_http_invalid(integer _verbose) {
        
    string invalid = ${library.name.abbr.lower}_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"thisisnotaurl\"}" );

    assertEqual(
        "a2s_http_invalid",
        _verbose,
        invalid,
        "✖",
        "The ${library.name.abbr.upper} Async2Sync Engine gracefully handles invalid URLs." );    
}
        
timeout_cleanup(integer _verbose) {
    
    ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "wait", "{\"seconds\":12}" );
    assertEqual(
        "timeout_cleanup",
        _verbose,
        llGetObjectDesc(),
        "",
        "The ${library.name.abbr.upper} Engine leaves the object description clean after an operation times out." );
    
    llSleep( 14 );
    
    integer simple = (integer)${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "wait", "{\"seconds\":1}" );
    
    assertEqual(
        "timeout_cleanup",
        _verbose,
        (string)simple,
        "1",
        "The ${library.name.abbr.upper} Engine can still function after a timeout in the remote operation." );
}

// TODO: This test doesn't actually do anything.
concurrent(integer _verbose) {
    
    assertEqual(
        "concurrent",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "wait", "{\"seconds\":2}" ) + 
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "wait", "{\"seconds\":6}" ),
        "26",
        "The ${library.name.abbr.upper} Engine can handle multiple concurrent, overlapping requests." );
}
        
timeout(integer _verbose) {
    
    assertEqual(
        "timeout",
        _verbose,
        ${library.name.abbr.lower}_send( "${library.name.abbr.lower}_test_receiver.lsl2", "wait", "{\"seconds\":12}" ),
        "✖",
        "The ${library.name.abbr.upper} Engine's sender times out if the other script takes too long." );
        
    assertEqual(
        "timeout",
        _verbose,
        ${library.name.abbr.upper}_ERROR,
        "➃",
        "The ${library.name.abbr.upper} Engine correctly indicates the cause when the call failes due to the other script taking too long." );
}