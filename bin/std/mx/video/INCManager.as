//****************************************************************************
//Copyright (C) 2004-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.video.*;

/**
 * <p>Creates <code>NetConnection</code> for <code>VideoPlayer</code>, a
 * helper class for that user facing class.</p>
 */

interface mx.video.INCManager {

	/**
	 * Called by <code>VideoPlayer</code> to ask for connection to
	 * URL.  Once connection is either successful or failed, call
	 * <code>VideoPlayer.ncConnected()</code>.  If connection failed,
	 * set <code>nc = null</code> before calling.
	 *
	 * @return true if connection made synchronously, false attempt
	 * made asynchronously so caller should expect a "connected"
	 * event coming.
	 * @see #getNetConnection()
	 * @see #reconnect()
	 * @see VideoPlayer#ncConnected()
	 */
	public function connectToURL(url:String):Boolean;

	/**
	 * <p>Called by <code>VideoPlayer</code> if connection
	 * successfully made but stream not found.  If multiple alternate
	 * interpretations of the rtmp URL are possible, it should retry
	 * to connect to the server with a different URL and hand back a
	 * different stream name.</p>
	 *
	 * <p>This can be necessary in cases where the URL is something
	 * like rtmp://servername/path1/path2/path3.  The user could be
	 * passing in an application name and an instance name, so the
	 * NetConnection should be opened with
	 * rtmp://servername/path1/path2, or they might want to use the
	 * default instance so the stream should be opened with
	 * path2/path3.  In general this is possible whenever there are
	 * more than two parts to the path, but not possible if there are
	 * only two (there should never only be one).</p>
	 *
	 * @return true if will attempt to make another connection,
	 * false if already made attempt or no additional attempts
	 * are merited.
	 * @see #connectToURL()
	 * @see VideoPlayer#rtmpOnStatus()
	 */
	public function connectAgain():Boolean;

	/**
	 * Called by <code>VideoPlayer</code> to ask for reconnection
	 * after connection is lost.  Once connection is either successful
	 * or failed, call <code>VideoPlayer.ncReconnected()</code>.  If
	 * connection failed, set <code>nc = null</code> before calling.
	 *
	 * @see #getNetConnection()
	 * @see #connect()
	 * @see VideoPlayer#idleTimeout
	 * @see VideoPlayer#ncReonnected()
	 */
	public function reconnect():Void;

	/**
	 * Called by any helper object doing a task for the
	 * <code>INCManager</code> to signal it has completed
	 * and whether it was successful.  <code>NCManager</code>
	 * uses this with <code>SMILManager</code>.
	 */
	public function helperDone(helper:Object, success:Boolean);

	/**
	 * Close the NetConnection
	 */
	public function close():Void;

	/**
	 * Get the <code>VideoPlayer</code> object which owns this object.
	 */
	public function getVideoPlayer():VideoPlayer;

	/**
	 * Set the <code>VideoPlayer</code> object which owns this object.
	 */
	public function setVideoPlayer(v:VideoPlayer):Void;

	/**
	 * Get the timeout after which we give up on connection in
	 * milliseconds.
	 */
	public function getTimeout():Number;

	/**
	 * Set the timeout after which we give up on connection in
	 * milliseconds.
	 */
	public function setTimeout(t:Number):Void;

	/**
	 * Get <code>NetConnection</code>.
	 */
	public function getNetConnection():NetConnection;

	/**
	 * Get the bandwidth to be used to switch between multiple
	 * streams.  Numerical value in bits per second.
	 */
	public function getBitrate():Number;

	/**
	 * Set the bandwidth to be used to switch between multiple
	 * streams.  Numerical value in bits per second.
	 */
	public function setBitrate(b:Number):Void;

	/**
	 * Get stream name to be passed into
	 * <code>NetStream.play</code>
	 */
	public function getStreamName():String;

	/**
	 * Whether URL is for rtmp streaming from Flash Communication
	 * Server or progressive download.
	 *
	 * @returns true if stream is rtmp streaming from FCS, false if
	 * progressive download of http, local or other file
	 */
	public function isRTMP():Boolean;

	/**
	 * Get length of stream.  After
	 * <code>VideoPlayer.ncConnected()</code> is called, if this is
	 * undefined, null or less than 0, that indicates to the
	 * VideoPlayer that we have determined no stream length
	 * information.  Any stream length information that is returned
	 * will be assumed to trump any other, including that set via the
	 * <code>totalTime</code> parameter of the
	 * <code>VideoPlayer.play()</code> or
	 * <code>VideoPlayer.load()</code> method or from FLV metadata.
	 *
	 * VideoPlayer#ncConnected()
	 * VideoPlayer#play()
	 * VideoPlayer#load()
	 */
	public function getStreamLength():Number;

	/**
	 * Get width of stream.  After
	 * <code>VideoPlayer.ncConnected()</code> is called, if this is
	 * undefined, null or less than 0, that indicates to the
	 * VideoPlayer that we have determined no stream width
	 * information.  If the VideoPlayer has autoSize or
	 * maintainAspectRatio set to true, then this value will be used
	 * and the resizing will happen instantly, rather than waiting.
	 *
	 * VideoPlayer#ncConnected()
	 * VideoPlayer#autoSize
	 * VideoPlayer#maintainAspectRatio
	 */
	public function getStreamWidth():Number;

	/**
	 * Get height of stream.  After
	 * <code>VideoPlayer.ncConnected()</code> is called, if this is
	 * undefined, null or less than 0, that indicates to the
	 * VideoPlayer that we have determined no stream height
	 * information.  If the VideoPlayer has autoSize or
	 * maintainAspectRatio set to true, then this value will be used
	 * and the resizing will happen instantly, rather than waiting.
	 *
	 * VideoPlayer#ncConnected()
	 * VideoPlayer#autoSize
	 * VideoPlayer#maintainAspectRatio
	 */
	public function getStreamHeight():Number;

} // Interface INCManager
