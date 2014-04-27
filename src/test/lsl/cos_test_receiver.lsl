#{/src/main/lsl/to/header_internal.lsl}

#{/src/main/lsl/to/header_user.lsl exposed.functions=/src/test/lsl/cos_test_receiver_exposed_functions.lsl}

/**
 * Script Library Call Test Function 1 - Accumulator
 * 
 * @param JSON/num: The number to add one to.
 * @return 1 more than the input number.
**/
integer acc(string _args) {
    return 1 + (integer)llJsonGetValue( _args, ["num"] );
}

/**
 * Script Library Call Test Function 2 - Subtractor
 * 
 * @param JSON/num: The number to subtract one from.
 * @return 1 less than the input number.
**/
integer sub(string _args) {
    return (integer)llJsonGetValue( _args, ["num"] ) - 1;
}

/**
 * Script Library Call Test Function 3 - Echo
 * 
 * @param JSON/string: The string to echo.
 * @return the input string
**/
string echo(string _args) {
    return llJsonGetValue( _args, ["string"] );
}
    
/**
 * Script Library Call Test Function 4 - Wait
 * 
 * @param JSON/seconds: The number of seconds to wait.
 * @return the number of seconds waited.
**/
string wait(string _args) {
    
    integer seconds = (integer)llJsonGetValue( _args, ["seconds"] );
    
    llSleep( seconds );

    return (string)seconds;
}

/**
 * Script Library Call Test Function 5 - Stateful Accumulator
 * 
 * @return 1 more than the result of the last invocation.
**/
integer stateacc_counter = 0;
integer stateacc(string _args) {
    stateacc_counter = stateacc_counter + 1;
    return stateacc_counter;
}

default
{   
    link_message( integer _sender, integer _num, string _str, key _id ) {
        
        #{/src/main/lsl/to/link_message.lsl}
    }
}