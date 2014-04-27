/**
 * ${library.name} Public Interface Boilerplate v${library.version} - Leave as-is
 *
 * This is the function that handles incoming COS requests,
 * determines whether they are destined for this script, and dispatches
 * the call to the function in this script.
 *
 * @param _full_json_args the arguments for the target function, as JSON. Includes the three "magic" COS parameters:
 *  _script: the target script (may or may not be THIS script)
 *  _function: the function to call (may or may not be present in this script...)
 *  _key: the UUID identifying this particular COS request.
**/
cos_recv( string _full_json_args ) {
    
    // Is this COS request intended for this script?
    string target_script = llJsonGetValue( _full_json_args, [ "_s" ] );
    if( target_script != llGetScriptName() ) {
        return;
    }
    
    // What function are we supposed to call?
    string target_function = llJsonGetValue( _full_json_args, [ "_f" ] );
    
    // Remove the COS-specific values from the JSON arguments.
    // Not strictly necessary, and could be stripped out of llJsonSetValue is too resource-intensive.
    string stripped_args = _full_json_args;
    stripped_args = llJsonSetValue( stripped_args, [ "_f" ], JSON_DELETE );
    stripped_args = llJsonSetValue( stripped_args, [ "_s" ], JSON_DELETE );
    stripped_args = llJsonSetValue( stripped_args, [ "_k" ], JSON_DELETE );
    
    // Invoke the requested function with the provided arguments and get its result.
    string result = cos_switch( target_function, stripped_args );
    
    // We're ready to write the response out to the script that's waiting on our COS response.
    // We need to be able to identify that response.
    string this_call = llJsonGetValue( _full_json_args, ["_k"] );
    
    // Furthermore, we only want to write out if no one else is using the description
    // e.g, we have the lock.
    string have_lock_str = "cos:lock:" + this_call;
    integer have_lock = FALSE;
    string desc;
    integer start_time = llGetUnixTime();
    do {
        desc = llGetObjectDesc();
        have_lock = llGetSubString( desc, 0, 44 ) == have_lock_str;
    } while ( 
        !have_lock &&
        llGetUnixTime() - start_time < ${timeout} ); // TODO: This is set very low for testing purposes.
        
    if( !have_lock ) {
        return;
    }
    
    if( "✖" == result ) {
        // The target function isn't exposed to COS.
        llSetObjectDesc( "cos:out:" + this_call + ":" + llStringToBase64( result ) );
    } else {
        
        // This is the response we want to send back.
        string enc_result = llStringToBase64( result );
        string result_string = "cos:out:" + this_call + ":" + enc_result;
        
        if( llStringLength( result_string ) <= 127 ) {
            
            // Send it!
            llSetObjectDesc( "cos:out:" + this_call + ":" + enc_result );
        } else {
                
            // But it's too long, so we'll have to send it in pieces.

            integer response_length = llStringLength( enc_result );
            integer sent = 0;
            integer wait_begin = llGetUnixTime();
            while( sent < response_length ) {
                
                // 81 characters per chunk, given our cos:out:key: overhead.
                string chunk = llGetSubString( enc_result, sent, sent + 81 );
                sent += 81 + 1; 

                // Write the chunk out.
                if( sent >= response_length ) {
                    // This is the last chunk; indicate as such.
                    llSetObjectDesc(
                        "cos:out:" + 
                        this_call + ":" + chunk );
                } else {
                    // There will be more chunks, so keep the stream open.
                    llSetObjectDesc(
                        "cos:stp:" + 
                        this_call + ":" + chunk );
                }
                
                // If there's more data to send, wait for confirmation that what's already been sent has been read
                // before trying to send any more.
                if( sent < response_length ) {
                    while( "cos:stc:" + this_call != llGetObjectDesc() );
                };
                
            };
        }
    }
}