#{from/header_internal.lsl}

default
{
	touch_start(integer _num_touches)
	{
		integer basenum = 1;
		
		string result = cos_send( "cos_library_template.lsl", "sample", "{\"num\":" + basenum + "}" );
		
		if( "✖" == result ) {
			if( "➀" == COS_ERROR ) {
				llSay( PUBLIC_CHANNEL, "COS ERROR: Target script doesn't exist." );
			} else if( "➁" == COS_ERROR ) {
				llSay( PUBLIC_CHANNEL, "COS ERROR: Target function doesn't exist." );
			} else if( "➂" == COS_ERROR ) {
				llSay( PUBLIC_CHANNEL, "COS ERROR: Sending request from source script timed out." );
			} else if( "➃" == COS_ERROR ) {
				llSay( PUBLIC_CHANNEL, "COS ERROR: Source script timed out waiting for a response." );
			} else if( "➄" == COS_ERROR ) {
				llSay( PUBLIC_CHANNEL, "COS ERROR: An error occurred in the target script." );
			}
		} else {
			llSay( PUBLIC_CHANNEL, (string)basenum + " + 1 = [" + result + "], says the other script." );
		}
	}
}