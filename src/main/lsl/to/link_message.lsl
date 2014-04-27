/**
 * ${library.name} Boilerplate v${library.version}- Leave as-is
 * This makes sure that the COS framework in this script
 * is notified when another script in this prim tries to make
 * a COS request, enabling it to service the request if appropriate.
**/
if( "cos_send" == _id ) {
    cos_recv( _str );
}