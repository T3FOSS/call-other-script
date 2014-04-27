#{/src/main/lsl/from/header_internal.lsl}

list UNIT_TESTS = [
    "basic",
    "noscript",
    "nofunc",
    "long_response",
    "rapid",
    "very_rapid",
    "badchar",
    "cleanup",
    "timeout_cleanup",
    "concurrent",
    "timeout"
    ];

list ASYNC_TESTS = [
    "a2s_note",
    "a2s_note_missing",
    "a2s_http",
    "a2s_http_404",
    "a2s_http_504",
    "a2s_http_invalid"
    ];

list BENCHMARK_TESTS = [
    "bench_basic",
    "bench_consist"
    ];
    
list ALL_TESTS;

float cos_testrunner(string _test_name, integer _verbose) {
    if( _verbose ) {
        llSay( PUBLIC_CHANNEL, _test_name );
    }
    
    llResetTime();
    if( "basic" == _test_name ) { basic(_verbose); }
    else if( "noscript" == _test_name ) { noscript(_verbose); }
    else if( "nofunc" == _test_name ) { nofunc(_verbose); }
    else if( "long_response" == _test_name ) { long_response(_verbose); }
    else if( "rapid" == _test_name ) { rapid(_verbose); }
    else if( "very_rapid" == _test_name ) { very_rapid(_verbose); }
    else if( "badchar" == _test_name ) { badchar(_verbose); }
    else if( "cleanup" == _test_name ) { cleanup(_verbose); }
    else if( "a2s_note" == _test_name ) { a2s_note(_verbose); }
    else if( "a2s_note_missing" == _test_name ) { a2s_note_missing(_verbose); }
    else if( "a2s_http" == _test_name ) { a2s_http(_verbose); }
    else if( "a2s_http_404" == _test_name ) { a2s_http_404(_verbose); }
    else if( "a2s_http_504" == _test_name ) { a2s_http_504(_verbose); }
    else if( "a2s_http_invalid" == _test_name ) { a2s_http_invalid(_verbose); }
    else if( "timeout_cleanup" == _test_name ) { timeout_cleanup(_verbose); }
    else if( "concurrent" == _test_name ) { concurrent(_verbose); }
    else if( "timeout" == _test_name ) { timeout(_verbose); }
    
    else if( "bench_basic" == _test_name ) { bench_basic(_verbose);}
    
    else { llSay( PUBLIC_CHANNEL, "No test called [" + _test_name + "] is set up." ); return 0; }
    
    float elapsed = llGetTime();
    if( _verbose ) {
        llSay( PUBLIC_CHANNEL, "\t(" + (string)elapsed + ")" );
    }
    
    return elapsed;
}

integer assertEqual(string _test_name, integer _verbose, string _actual, string _expected, string _message) {
    
    if( _actual != _expected ) {
        TEST_FAILURES++;
        llSay( 
                PUBLIC_CHANNEL, 
                "\nFAILED: [" + _test_name + "] " + _message + "\n" +  
                "\tExpected: [" + _expected + "]\n" + 
                "\tActual: [" + _actual + "]\n" );
        return FALSE;
    }
    
    return TRUE;
}

integer assertLessThan(string _test_name, integer _verbose, float _actual, float _limit, string _message) {
    
    if( _actual >= _limit ) {
        TEST_FAILURES++;
        llSay( 
                PUBLIC_CHANNEL, 
                "\nFAILED: [" + _test_name + "] " + _message + "\n" +  
                "\tExpected: [" + (string)_actual + "] < [" + (string)_limit + "]\n" );
        return FALSE;
    }
    
    return TRUE;
}

#{cos_test_cases.lsl}    

integer acc(string _args) {
    return 1 + (integer)llJsonGetValue( _args, ["num"] );
}

/**
 * Blah blah
 * blee
 * COS is about 17 times slower than normal.
 **/
bench_basic(integer _verbose) {
     
    integer FACTOR = 20;
    
    integer i = 0;

    llResetTime();
    
    for( i = 0; i < 500; i++ ) {
        integer result = acc( "{\"num\":" + (string)i + "}" );
    }
    
    float same_script_elapsed = llGetTime();
    
    llResetTime();
    
    for( i = 0; i < 500; i++ ) {
        string result = cos_send( "cos_test_receiver.lsl2", "acc", "{\"num\":" + (string)i + "}" );
    }
    
    float cos_script_elapsed = llGetTime();
    
    assertLessThan(
        "cos_bench_basic",
        _verbose,
        cos_script_elapsed,
        FACTOR * same_script_elapsed,
        "COS function calls should take less than " + (string)FACTOR + " times as long as in-script calls." );
}
        
/*
Tests to write:
        
    

    (need to somewhat-finalize receive snippet)
    - multi-hop COS works
    - reentrant multi-hop COS fails fast
    - many scripts into one COS 

    Benchmarks:
    - speed (compare in-script fcn calls to COS calls)
    - consitency (run same test many times, ensure all executions are within certian rainge)
*/

string LAST_DESC = "";
integer TEST_FAILURES = 0;
default
{
    state_entry()
    {
        llSetObjectDesc( "" );
        llListen(PUBLIC_CHANNEL, "", NULL_KEY, "" );
        ALL_TESTS = UNIT_TESTS + ASYNC_TESTS + BENCHMARK_TESTS;
        llSay( PUBLIC_CHANNEL, "COS Test Driver Ready" );
    }

    listen(integer _channel, string _name, key _id, string _message)
    {
        list parts = llParseString2List( _message, [" "], [] );
    
        string command = llList2String( parts, 0 );
        
        if( "cost" == command ) {
            
            TEST_FAILURES = 0;
            
            llSetObjectName( "COS Draft " + llGetTimestamp() );
            llSay( PUBLIC_CHANNEL, "Testing COS Engine..." );
            llSetObjectDesc( "" );
            llMessageLinked( LINK_THIS, 0, "start tests", NULL_KEY );
            llSleep( 1 );
        
            integer verbose = 0;
            integer index = 1;
            float elapsed = 0;
            
            if( "-v" == llList2String( parts, index ) ) {
                verbose = 1;
                index++;
            }
            
            list test_list = [];
            string test_name = llList2String( parts, index++ );
            integer break = FALSE;
            while( test_name != "" && !break ) {
                
                if( "bench" == test_name ) {
                    test_list += BENCHMARK_TESTS;
                } else if( "all" == test_name ) {
                    test_list = ALL_TESTS;
                    break = TRUE;
                } else if( "unit" == test_name ) {
                    test_list += UNIT_TESTS;
                } else if( "a2s" == test_name ) {
                    test_list += ASYNC_TESTS;
                } else {
                    test_list = (test_list=[]) + test_list + test_name;
                }
                
                test_name = llList2String( parts, index++ );
            }
            
            integer test_index = 0;
            integer num_tests = llGetListLength( test_list );
            
            for ( test_index = 0; test_index < num_tests; test_index++ ) {
                elapsed += cos_testrunner( llList2String( test_list, test_index ), verbose );
                
                if( !verbose ) {
                    llSay( PUBLIC_CHANNEL, "(" + (string)(test_index + 1) + "/" + (string)num_tests + ")" );
                }
            }
            
            string success_string = "SUCCESS";
            if( TEST_FAILURES > 0 ) {
                success_string = "FAILURES: " + (string)TEST_FAILURES;
            }
            
            llMessageLinked( LINK_THIS, 0, "stop tests", NULL_KEY );
            
            llSay( PUBLIC_CHANNEL, "All tests complete in (" + (string)elapsed + "). " + success_string );
        }
    }
}
