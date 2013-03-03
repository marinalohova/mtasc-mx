// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.

import mx.video.*;

class mx.video.VideoError extends Error {

	#include "ComponentVersion.as"

	private static var BASE_ERROR_CODE:Number = 1000;

	/**
	 * Unable to make connection to server or to find FLV on server
	 */
	public static var NO_CONNECTION:Number = 1000;

	/**
	 * No matching cue point found
	 */
	public static var NO_CUE_POINT_MATCH:Number = 1001;

	/**
	 * Illegal cue point
	 */
	public static var ILLEGAL_CUE_POINT:Number = 1002;

	/**
	 * Invalid seek
	 */
	public static var INVALID_SEEK:Number = 1003;

	/**
	 * Invalid content path
	 */
	public static var INVALID_CONTENT_PATH:Number = 1004;

	/**
	 * Invalid xml
	 */
	public static var INVALID_XML:Number = 1005;

	/**
	 * No bitrate match
	 */
	public static var NO_BITRATE_MATCH:Number = 1006;

	/**
	 * Cannot delete default VideoPlayer
	 */
	public static var DELETE_DEFAULT_PLAYER:Number = 1007;

	private var _code:Number;

	public function VideoError(errCode:Number , msg:String) {
		_code = errCode;
		message = "" + errCode + ": " + ERROR_MSG[errCode - BASE_ERROR_CODE] + ((msg == undefined) ? "" : (": " + msg));
		name = "VideoError";
	}

	/**
	 * Error code
	 */
	public function get code():Number { return _code; }

	private static var ERROR_MSG:Array = [
	                                      "Unable to make connection to server or to find FLV on server",
	                                      "No matching cue point found",
	                                      "Illegal cue point",
	                                      "Invalid seek",
	                                      "Invalid contentPath",
	                                      "Invalid xml",
	                                      "No bitrate match, must be no default flv",
	                                      "Cannot delete default VideoPlayer"
	];

} // class mx.video.VideoError
