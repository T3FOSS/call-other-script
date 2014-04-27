basic(integer _verbose) {
    
    assertEqual(
        "basic",
        _verbose,
        cos_send( "cos_test_receiver.lsl2", "acc", "{\"num\":1}" ),
        "2",
        "The COS Engine works." );
}

noscript(integer _verbose) {
    
    assertEqual(
        "noscript",
        _verbose,
        cos_send( "cos_test_receiver.lsl29million", "echo", "{\"string\":\"cat\"}" ),
        "✖",
        "The COS Engine fails noisily when the target script does not exist." );
        
    assertEqual(
        "noscript",
        _verbose,
        COS_ERROR,
        "➀",
        "The COS Engine correctly indicates the cause of the failure when the target script does not exist." );
}

nofunc(integer _verbose) {
    
    assertEqual(
        "nofunc",
        _verbose,
        cos_send( "cos_test_receiver.lsl2", "echo noexist", "{\"string\":\"cat\"}" ),
        "✖",
        "The COS Engine fails noisily when the target function does not exist." );
}

long_response(integer _verbose) {
    
    string slipsum = "Your bones don't break, mine do. That's clear. Your cells react to bacteria and viruses differently than mine. You don't get sick, I do. That's also clear. But for some reason, you and I react the exact same way to water. We swallow it too fast, we choke. We get some in our lungs, we drown. However unreal it may seem, we are connected, you and I. We're on the same curve, just on opposite ends.";
    
    assertEqual(
        "long_response",
        _verbose,
        cos_send( "cos_test_receiver.lsl2", "echo", "{\"string\":\"" + slipsum + "\"}" ),
        slipsum,
        "The COS Engine fails noisily when the remote response string is too long." );
}

rapid(integer _verbose) {
    
    assertEqual(
        "rapid",
        _verbose,
        cos_send( "cos_test_receiver.lsl2", "acc", "{\"num\":1}" ) +
        cos_send( "cos_test_receiver.lsl2", "acc", "{\"num\":2}" ) +
        cos_send( "cos_test_receiver.lsl2", "acc", "{\"num\":3}" ),
        "234",
        "The COS engine can handle multiple, immediate calls." );
}
        
very_rapid(integer _verbose) {
    
    integer count = 0;
    integer prev = (integer)cos_send( "cos_test_receiver.lsl2", "stateacc", "" );
    for( count = 0; count < 50; count++ ) {
        integer next = (integer)cos_send( "cos_test_receiver.lsl2", "stateacc", "" );
        
        integer should_continue = assertEqual(
            "very_rapid",
            _verbose,
            (string)next,
            (string)(prev + 1),
            "Multiple rapid COS invocations in one script should be answered in the order they are invoked. Invocation (" + (string)(count+1) + "/50) failed." );
            
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
        cos_send( "cos_test_receiver.lsl2", "echo", "{\"string\":\"pipes: | and newlines\nare cool\"}" ),
        "pipes: | and newlines\nare cool",
        "The COS engine can handle characters forbidden in object descriptions." );
}
        
cleanup(integer _verbose) {
            
    cos_send( "cos_test_receiver.lsl2", "acc", "{\"num\":1}" );        
    
    assertEqual(
        "cleanup",
        _verbose,
        llGetObjectDesc(),
        "",
        "The COS Engine leaves the object description clean after it runs." );
}
        
a2s_note(integer _verbose) {
        
    assertEqual(
        "a2s_note",
        _verbose,
        (string)cos_send( "synchronous_events.lsl2", "getNotecardLineSync", "{\"notecard\":\"cos_notes\",\"line\":2}" ),
        "this is line 3.",
        "The COS Async2Sync Engine can get a notecard line synchronously." );
}
        
a2s_note_missing(integer _verbose) {
        
    assertEqual(
        "a2s_note_missing",
        _verbose,
        (string)cos_send( "synchronous_events.lsl2", "getNotecardLineSync", "{\"notecard\":\"cos_notes_nonexist\",\"line\":2}" ),
        "✖",
        "The COS Async2Sync Engine reports failure correctly when asked for a notecard that doesn't exist." );
}
        
a2s_http(integer _verbose) {
        
    string header_json = cos_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"http://headers.jsontest.com/\"}" );
    
    assertEqual(
        "a2s_http",
        _verbose,
        llJsonGetValue( header_json, [ "body", "X-SecondLife-Object-Key"] ),
        (string)llGetKey(),
        "The COS Async2Sync Engine can complete an HTTP request synchronously." );    
}
        
a2s_http_404(integer _verbose) {
        
    string not_found = cos_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"http://google.com/notreal\"}" );
    
    assertEqual(
        "a2s_http_404",
        _verbose,
        llJsonGetValue( not_found, [ "status"] ),
        "404",
        "The COS Async2Sync Engine gracefully handles 404 errors." );    
}
        
a2s_http_504(integer _verbose) {
        
    string not_found = cos_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"http://notarealwebsite.pleaesdontactuallybereal.fooblaggle.com/\"}" );
    
    assertEqual(
        "a2s_http_504",
        _verbose,
        llJsonGetValue( not_found, [ "status"] ),
        "504",
        "The COS Async2Sync Engine gracefully handles remote gateway timeouts." );    
}
        
a2s_http_invalid(integer _verbose) {
        
    string invalid = cos_send( "synchronous_events.lsl2", "HTTPRequestSync", "{\"url\":\"thisisnotaurl\"}" );

    assertEqual(
        "a2s_http_invalid",
        _verbose,
        invalid,
        "✖",
        "The COS Async2Sync Engine gracefully handles invalid URLs." );    
}
        
timeout_cleanup(integer _verbose) {
    
    cos_send( "cos_test_receiver.lsl2", "wait", "{\"seconds\":12}" );
    assertEqual(
        "timeout_cleanup",
        _verbose,
        llGetObjectDesc(),
        "",
        "The COS Engine leaves the object description clean after an operation times out." );
    
    llSleep( 14 );
    
    integer simple = (integer)cos_send( "cos_test_receiver.lsl2", "wait", "{\"seconds\":1}" );
    
    assertEqual(
        "timeout_cleanup",
        _verbose,
        (string)simple,
        "1",
        "The COS Engine can still function after a timeout in the remote operation." );
}

// TODO: This test doesn't actually do anything.
concurrent(integer _verbose) {
    
    assertEqual(
        "concurrent",
        _verbose,
        cos_send( "cos_test_receiver.lsl2", "wait", "{\"seconds\":2}" ) + 
        cos_send( "cos_test_receiver.lsl2", "wait", "{\"seconds\":6}" ),
        "26",
        "The COS Engine can handle multiple concurrent, overlapping requests." );
}
        
timeout(integer _verbose) {
    
    assertEqual(
        "timeout",
        _verbose,
        cos_send( "cos_test_receiver.lsl2", "wait", "{\"seconds\":12}" ),
        "✖",
        "The COS Engine's sender times out if the other script takes too long." );
        
    assertEqual(
        "timeout",
        _verbose,
        COS_ERROR,
        "➃",
        "The COS Engine correctly indicates the cause when the call failes due to the other script taking too long." );
}