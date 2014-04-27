if( "acc" == _function ) {
    return (string) acc( _json_args );
} else if( "sub" == _function ) {
    return (string) sub( _json_args );
} else if( "echo" == _function ) {
    return echo( _json_args );
} else if( "wait" == _function ) {
    return (string)wait( _json_args );
} else if( "stateacc" == _function ) {
    return (string)stateacc( _json_args );
}