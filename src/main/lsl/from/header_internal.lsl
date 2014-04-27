/**
➀: TARGET SCRIPT NOEXIST (frm send)
➁: TARGET FCN NOEXIST (frm recv [ not atually served yet] )
➂: LOCK TIMED OUT (frm send)
➃: SENDER TIMED OUT WAITING FOR RECEIVER (frm send)
➄: ERROR IN TARGET SCRIPT
✖: SOME ERROR
*/
string COS_ERROR = "";
/**
 * ${library.name} Access Boilerplate v${library.version} - leave as-is
 *
 * Invoke a specific funtion in some other script in this prim.
 * Requires that the other script has been set up with the COS Boilerplate to allow
 * function calls from other scripts.
 *
 * If you try to make an COS call to a script that is not configured to handle them,
 * your own script will lock up.
 *
 * @param _target_script the name of the script that contains the function to call
 * @param _target_function the name of the function to call
 * @param _json_args the arguments to pass to the _target_function, as JSON.
**/
string cos_send(string _target_script, string _target_function, string _json_args) {
    
    // If the named script isn't in this prim, we can't possibly succeed.
    if( INVENTORY_NONE == llGetInventoryType( _target_script ) ) {
        COS_ERROR = "➀";
        return "✖";
    }
    
    // We need to be able to uniquely identify this COS request from all others.
    key this_call = llGenerateKey();
    
    // And we will need to have a relatively-normative string format to identify COS intentions
    string lock_text = "cos:lock:" + (string)this_call;
    
    // We are going to obtain a lock on the prim's description field,
    // preventing any other COS processes from using it until we get an answer
    // from our target script.
    integer have_lock = FALSE;
    integer start = llGetUnixTime();
    do {
        
        // Wait for everyone else to be done with the description.
        // TODO: Race condition
        while( 
        "" != llGetObjectDesc() 
        && llGetUnixTime() - start < ${timeout} );
        
        if( "" != llGetObjectDesc() ) {
            // we timed out.
            COS_ERROR = "➂";
            return "✖";
        }
        
        // claim the description for ourselves.
        llSetObjectDesc( lock_text );
        
        // If we got the lock, continue on.
        if( lock_text == llGetObjectDesc() ) {
            have_lock = TRUE;
        }
        
        // Otherwise, go around and try again.
    } while( 
        !have_lock &&
        llGetUnixTime() - start < 10 ); //TODO: this is set very low for testing purposes.
        
    if( !have_lock ) {
        // We timed out
        COS_ERROR = "➃";
        return "✖";
    }
    
    // We need to attach some metadata to the arguments for the receiving script:
    // The name of the script we're trying to reach,
    // The function to call,
    // and the UUID of this call.
    string full_json_args = _json_args;
    
    full_json_args = llJsonSetValue( full_json_args, ["_s"], _target_script );
    full_json_args = llJsonSetValue( full_json_args, ["_f"], _target_function );
    full_json_args = llJsonSetValue( full_json_args, ["_k"], this_call );
    
    // Send out the COS request.
    llMessageLinked( LINK_THIS, 0, full_json_args, "cos_send" );
    
    // When we see this string as the start of the object description,
    // we'll know that the target script has processed our COS request.
    string result_text = "cos:out:" + (string)this_call;
    string stream_text = "cos:stp:" + (string)this_call;
    
    string desc;
    string desc_check;
    start = llGetUnixTime();
    do {
        
        // Read the object's description.
        desc = llGetObjectDesc();
        desc_check = llGetSubString( desc, 0, 43 );
        
        // As long as we DON'T see the result we're looking for, keep reading it.
    } while( 
        result_text != desc_check && 
        stream_text != desc_check &&
        llGetUnixTime() - start <= $timeout ); // TODO: This is set very low for testing purposes.
    
    COS_ERROR = "➄";
    string result = "✖";
    
    if( desc_check == stream_text ) {
        // The response is longer than the description field would allow.
        // We need to read it in in pieces.
        string stream_consumed_text = "cos:stc:" + (string)this_call;
        
        result = "";
        result += llGetSubString( desc, 45, llStringLength( desc ) -1 );
        do {
            
            // Say that we're ready for the next chunk
            llSetObjectDesc( stream_consumed_text );
            
            // Wait for the next chunk to be published
            do {
                
                // Read the object's description.
                desc = llGetObjectDesc();
                desc_check = llGetSubString( desc, 0, 43 );
                
                // As long as we DON'T see the result we're looking for, keep reading it.
            } while( 
                result_text != desc_check && // end of stream
                stream_text != desc_check ); // continuation of stream
            
            // Read the chunk.
            result += llGetSubString( desc, 45, llStringLength( desc ) -1 );
            // If that wasn't the last chunk, we need to do this again.
        } while( result_text != desc_check );
        
        // All done; we need to close the stream.
        llSetObjectDesc( stream_consumed_text );
        
        result = llBase64ToString( result );
        COS_ERROR = "";
        
    } else if( desc_check == result_text ) {
        // We can simply return the result.
        result = llBase64ToString( llGetSubString( desc, 45, llStringLength( desc ) -1 ) );
        COS_ERROR = "";
    } else {
        COS_ERROR = "➃";
    }
    
    // Clear the object description so other COS requests can use it.
    llSetObjectDesc( "" );
    
    // return the results of the function call from the _target_script
    return result;
}