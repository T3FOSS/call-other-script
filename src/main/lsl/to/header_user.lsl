/**
 * ${library.name} Access Boilerplate v${library.version} - add your code here.
 * 
 * For each function in THIS SCRIPT that you want other scripts to be able to call,
 * you should ensure that when this function is called with that function's name as
 * the _function parameter, that this function returns the result of invoking that
 * function with the provided string of JSON arguments.
 *
 * @param _function the function in this script to invoke
 * @param _json_args the arguments to pass to the _function
 * @return the result of invoking the named _function with the provided _json_args as the arguments, cast to a string.
**/
string slc_switch( string _function, string _json_args ) {
    
    #{${exposed.functions exposed_functions.lsl}}
    
    return "✖";
}

/**
 * ${library.name} User Function - Sample
 * 
 * @param JSON/num: The number to add one to.
 * @return 1 more than the input number.
**/
integer sample(string _args) {
    return 1 + (integer)llJsonGetValue( _args, ["num"] );
}