/**
 * ${library.name} Boilerplate v${library.version}- Leave as-is
 * This makes sure that the ${library.name.abbr.upper} framework in this script
 * is notified when another script in this prim tries to make
 * a ${library.name.abbr.upper} request, enabling it to service the request if appropriate.
**/
if( "cos_send" == _id ) {
    ${library.name.abbr.lower}_recv( _str );
}