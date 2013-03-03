//****************************************************************************
//Copyright (C) 2004-2005 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.events.EventDispatcher;
import mx.video.*;

/**
 * <p>Event dispatched when <code>NetConnection</code> is closed,
 * whether by being timed out or by calling <code>close()</code> API.
 * Only dispatched with RTMP streams, never HTTP.  Event Object has
 * properties state and playheadTime.</p>
 *
 */
[Event("close")]

/**
 * <p>Event dispatched when playing completes by reaching the end of
 * the FLV.  Is not dispatched if the APIs <code>stop()</code> or
 * <code>pause()</code> are called.  Event Object has properties state and
 * playheadTime.</p>
 *
 * <p>When using progressive download and not setting totalTime
 * explicitly and downloading an FLV with no metadata duration,
 * the totalTime will be set to an approximate total value, now
 * that we have played the whole file we can make a guess.  That
 * value is set by the time this event is dispatched.</p>
 *
 */
[Event("complete")]

/**
 * <p>Event dispatched when a cue point is reached.  Event Object has an
 * info property that contains the info object received by the
 * <code>NetStream.onCuePoint</code> callback for FLV cue points or
 * the object passed into the AS cue point APIs for AS cue points.</p>
 *
 */
[Event("cuePoint")]

/**
 * <p>Event dispatched the first time the FLV metadata is reached.
 * Event Object has an info property that contains the info object
 * received by the <code>NetStream.onMetaData</code> callback.</p>
 *
 */
[Event("metadataReceived")]

/**
 * <p>While FLV is playing, this event is dispatched every .25
 * seconds.  Not dispatched when we are paused or stopped, unless a
 * seek occurs.  Event Object has properties state and playheadTime.</p>
 *
 */
[Event("playheadUpdate")]

/**
 * <p>Indicates progress made in number of bytes downloaded.  User can
 * use this to check bytes loaded or number of bytes in the buffer.
 * Fires every .25 seconds, starting when load is called and ending
 * when all bytes are loaded or if there is a network error.  Event Object is
 * of type <code>mx.events.ProgressEvent</code>.</p>
 *
 */
[Event("progress")]

/**
 * <p>Event dispatched when FLV is loaded and ready to display.  Event
 * object has properties state and playheadTime.</p>
 *
 * <p>Fired the first time we enter a responsive state after we
 * load a new flv with play() or load() API.  Only fires once
 * for each FLV loaded.</p>
 *
 */
[Event("ready")]

/**
 * <p>Event dispatched when video is autoresized due to
 * maintainAspectRatio or autoSize properties set to true.  Event
 * Object has properties x, y, width and height.</p>
 *
 */
[Event("resize")]

/**
 * <p>Event dispatched when video autorewinds.  Event Object has properties
 * state and playheadTime.</p>
 *
 */
[Event("rewind")]

/**
 * <p>Event dispatched when playback state changes.  Event Object has
 * properties state and playheadTime.</p>
 *
 * <p>This event can be used to track when playback enters/leaves
 * unresponsive states (for example in the middle of connecting,
 * resizing or rewinding) during which times APIs <code>play()</code>,
 * <code>pause()</code>, <code>stop()</code> and <code>seek()</code>
 * will queue the requests to be executed when the player enters
 * a responsive state.</p>
 */
[Event("stateChange")]

/**
 * <p>VideoPlayer is an easy to use wrapper for Video, NetConnection,
 * NetStream, etc. that makes playing FLV easy.  It supports streaming
 * from Flash Communication Server (FCS) and http download of FLVs.</p>
 *
 * <p>VideoPlayer extends MovieClip and wraps a Video object.  It also
 * "extends" EventDispatcher using mixins.</p>
 *
 * @author copyright 2004-2005 Macromedia, Inc.
 */

class mx.video.VideoPlayer extends MovieClip {

	#include "ComponentVersion.as"

	// public state constants

	/**
	 * <p>State constant.  This is the state when the VideoPlayer is
	 * constructed and when the stream is closed by a call to
	 * <code>close()</code> or timed out on idle.</p>
	 *
	 * <p>This is a responsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 * @see #connected
	 * @see #idleTimeout
	 * @see #close()
	 */
	public static var DISCONNECTED:String = "disconnected";

	/**
	 * <p>State constant.  FLV is loaded and play is stopped.  This state
	 * is entered when <code>stop()</code> is called and when the
	 * playhead reaches the end of the stream.</p>
	 *
	 * <p>This is a responsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 * @see #stop()
	 */
	public static var STOPPED:String = "stopped";

	/**
	 * <p>State constant.  FLV is loaded and is playing.
	 * This state is entered when <code>play()</code>
	 * is called.</p>
	 *
	 * <p>This is a responsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 * @see #play()
	 */
	public static var PLAYING:String = "playing";

	/**
	 * <p>State constant.  FLV is loaded, but play is paused.
	 * This state is entered when <code>pause()</code> is
	 * called or when <code>load()</code> is called.</p>
	 *
	 * <p>This is a responsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 * @see #pause()
	 * @see #load()
	 */
	public static var PAUSED:String = "paused";

	/**
	 * <p>State constant.  State entered immediately after
	 * <code>play()</code> or <code>load()</code> is called.</p>
	 *
	 * <p>This is a responsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 */
	public static var BUFFERING:String = "buffering";

	/**
	 * <p>State constant.  State entered immediately after
	 * <code>play()</code> or <code>load()</code> is called.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 * @see #load()
	 * @see #play()
	 */
	public static var LOADING:String = "loading";

	/**
	 * <p>State constant.  Stream attempted to load was unable to load
	 * for some reason.  Could be no connection to server, stream not
	 * found, etc.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 */
	public static var CONNECTION_ERROR:String = "connectionError";

	/**
	 * <p>State constant.  State entered during a autorewind triggered
	 * by a stop.  After rewind is complete, the state will be
	 * <code>STOPPED</code>.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #autoRewind
	 * @see #state
	 * @see #stateResponsive
	 */
	public static var REWINDING:String = "rewinding";

	/**
	 * <p>State constant.  State entered after <code>seek()</code>
	 * is called.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 * @see #seek()
	 */
	public static var SEEKING:String = "seeking";

	/**
	 * <p>State constant.  State entered during autoresize.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #autoSize
	 * @see #maintainAspectRatio
	 * @see #state
	 * @see #stateResponsive
	 */
	public static var RESIZING:String = "resizing";

	/**
	 * <P>State constant.  State during execution of queued command.
	 * There will never get a "stateChange" event notification with
	 * this state; it is internal only.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 */
	static var EXEC_QUEUED_CMD:String = "execQueuedCmd";

	// buffer states
	private static var BUFFER_EMPTY:String = "bufferEmpty";
	private static var BUFFER_FULL:String = "bufferFull";
	private static var BUFFER_FLUSH:String = "bufferFlush";

	// state
	private var _state:String;
	private var _cachedState:String;
	private var _bufferState:String;
	private var _sawPlayStop:Boolean;
	private var _cachedPlayheadTime:Number;
	private var _metadata:Object;
	private var _startingPlay:Boolean;
	private var _invalidSeekTime:Boolean;
	private var _invalidSeekRecovery:Boolean;
	private var _readyDispatched:Boolean;
	private var _autoResizeDone:Boolean;
	private var _lastUpdateTime:Number;
	private var _sawSeekNotify:Boolean;

	// Video object
	private var _video:Video;

	// INCManager
	private var _ncMgr:INCManager;
	public var ncMgrClassName:String;

	/**
	 * <p>Set this property to the name of your custom class to
	 * make all VideoPlayer objects created use that class as the
	 * default INCManager implementation.  The default value is
	 * "mx.video.NCManager".</p>
	 */
	public static var DEFAULT_INCMANAGER:String = "mx.video.NCManager";

	// info about NetStream
	private var _ns:NetStream;
	private var _currentPos:Number;
	private var _atEnd:Boolean;
	private var _streamLength:Number;

	// store properties
	private var _autoSize:Boolean;
	private var _aspectRatio:Boolean;

	/**
	 * <p>If true, then video plays immediately, if false waits for
	 * <code>play</code> to be called.  Set to true if stream is
	 * loaded with call to <code>play()</code>, false if loaded
	 * by call to <code>load()</code>.</p>
	 *
	 * <p>Even if <code>_autoPlay</code> is set to false, we will start
	 * loading the video after <code>initialize()</code> is called.
	 * In the case of FCS, this means creating the stream and loading
	 * the first frame to display (and loading more if
	 * <code>autoSize</code> or <code>aspectRatio</code> is true).  In
	 * the case of HTTP download, we will start downloading the stream
	 * and show the first frame.</p>
	 *
	 * @private
	 */
	private var _autoPlay:Boolean;

	private var _autoRewind:Boolean;
	private var _contentPath:String;
	private var _bufferTime:Number;
	private var _isLive:Boolean;
	private var _volume:Number;
	private var _sound:Sound;
	private var __visible:Boolean;
	private var _hiddenForResize:Boolean;
	private var _hiddenForResizeMetadataDelay:Number;
	private var _hiddenRewindPlayheadTime:Number;
	private var _videoWidth:Number;
	private var _videoHeight:Number;
	private var _prevVideoWidth:Number;
	private var _prevVideoHeight:Number;

	// intervals
	private var _updateTimeIntervalID:Number;
	private var _updateTimeInterval:Number;
	private var _updateProgressIntervalID:Number;
	private var _updateProgressInterval:Number;
	private var _idleTimeoutIntervalID:Number;
	private var _idleTimeoutInterval:Number;
	private var _autoResizeIntervalID:Number;
	private var _rtmpDoStopAtEndIntervalID:Number;
	private var _rtmpDoSeekIntervalID:Number;
	private var _httpDoSeekIntervalID:Number;
	private var _httpDoSeekCount:Number
	private var _finishAutoResizeIntervalID:Number;
	private var _delayedBufferingIntervalID:Number;
	private var _delayedBufferingInterval:Number

	// default times for intervals
	static var DEFAULT_UPDATE_TIME_INTERVAL:Number = 250;   // .25 seconds
	static var DEFAULT_UPDATE_PROGRESS_INTERVAL:Number = 250;   // .25 seconds
	static var DEFAULT_IDLE_TIMEOUT_INTERVAL:Number = 300000; // five minutes
	private static var AUTO_RESIZE_INTERVAL:Number = 100;        // .1 seconds
	private static var AUTO_RESIZE_PLAYHEAD_TIMEOUT = .5;       // .5 seconds
	private static var AUTO_RESIZE_METADATA_DELAY_MAX:Number = 5;        // .5 seconds
	private static var FINISH_AUTO_RESIZE_INTERVAL:Number = 250;  // .25 seconds
	private static var RTMP_DO_STOP_AT_END_INTERVAL:Number = 500; // .5 seconds
	private static var RTMP_DO_SEEK_INTERVAL:Number = 100; // .1 seconds
	private static var HTTP_DO_SEEK_INTERVAL:Number = 250; // .25 seconds
	private static var HTTP_DO_SEEK_MAX_COUNT:Number = 4; // 4 times * .25 seconds = 1 second
	private static var CLOSE_NS_INTERVAL:Number = .25; // .25 secconds
	private static var HTTP_DELAYED_BUFFERING_INTERVAL:Number = 100; // .1 seconds

	// queues up Objects describing queued commands to be run later
	private var _cmdQueue:Array;

	// values for command types for _cmdQueue
	static var PLAY:Number = 0;
	static var LOAD:Number = 1;
	static var PAUSE:Number = 2;
	static var STOP:Number = 3;
	static var SEEK:Number = 4;

	// EventDispatcher mixins
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;

	//ifdef DEBUG
	//private static var _debugSingleton:VideoPlayer;
	//endif

	//
	// public APIs
	//

	/**
	 * <p>Constructor.</p>
	 *
	 * @see INCManager
	 * @see NCManager
	 */
	public function VideoPlayer() {
		// add EventDispatcher mixins
		EventDispatcher.initialize(this);

		// init state variables
		_state = DISCONNECTED;
		_cachedState = _state;
		_bufferState = BUFFER_EMPTY;
		_sawPlayStop = false;
		_cachedPlayheadTime = 0;
		_metadata = null;
		_startingPlay = false;
		_invalidSeekTime = false;
		_invalidSeekRecovery = false;
		_currentPos = 0;
		_atEnd = false;
		_cmdQueue = new Array();
		_readyDispatched = false;
		_autoResizeDone = false;
		_lastUpdateTime = -1;
		_sawSeekNotify = false;

		// put off creation of INCManager until last minute to
		// give time to customize DEFAULT_INCMANAGER

		// setup intervals
		_updateTimeIntervalID = 0;
		_updateTimeInterval = DEFAULT_UPDATE_TIME_INTERVAL;
		_updateProgressIntervalID = 0;
		_updateProgressInterval = DEFAULT_UPDATE_PROGRESS_INTERVAL;
		_idleTimeoutIntervalID = 0;
		_idleTimeoutInterval = DEFAULT_IDLE_TIMEOUT_INTERVAL;
		_autoResizeIntervalID = 0;
		_rtmpDoStopAtEndIntervalID = 0;
		_rtmpDoSeekIntervalID = 0;
		_httpDoSeekIntervalID = 0;
		_httpDoSeekCount = 0;
		_finishAutoResizeIntervalID = 0;
		_delayedBufferingIntervalID = 0;
		_delayedBufferingInterval = HTTP_DELAYED_BUFFERING_INTERVAL;

		// init get/set properties
		if (_isLive == undefined) _isLive = false;
		if (_autoSize == undefined) _autoSize = false;
		if (_aspectRatio == undefined) _aspectRatio = true;
		if (_autoPlay == undefined) _autoPlay = true;
		if (_autoRewind == undefined) _autoRewind = true;
		if (_bufferTime == undefined) _bufferTime = 0.1;
		if (_volume == undefined) _volume = 100;
		_sound = new Sound(this);
		_sound.setVolume(_volume);
		__visible = true;
		_hiddenForResize = false;
		_hiddenForResizeMetadataDelay = 0;
		_contentPath = "";

		//ifdef DEBUG
		//_debugSingleton = this;
		//endif
	}

	/**
	 * <p>set width and height simultaneously.  Since setting either
	 * one can trigger an autoresize, this can be better than invoking
	 * set width and set height individually.</p>
	 *
	 * <p>If autoSize is true then this has no effect, since the player
	 * sets its own dimensions.  If maintainAspectRatio is true and
	 * autoSize is false, then changing width or height will trigger
	 * an autoresize.</p>
	 *
	 * @param width
	 * @param height
	 * @see width
	 * @see height
	 */
	public function setSize(w:Number, h:Number):Void
	{
		if ( (w == _video._width && h == _video._height) || _autoSize ) return;
		_video._width = w;
		_video._height = h;
		if (_aspectRatio) {
			startAutoResize();
		}
	}

	/**
	 * <p>set scaleX and scaleY simultaneously.  Since setting either
	 * one can trigger an autoresize, this can be better than invoking
	 * set width and set height individually.</p>
	 *
	 * <p>If autoSize is true then this has no effect, since the player
	 * sets its own dimensions.  If maintainAspectRatio is true and
	 * autoSize is false, then changing scaleX or scaleY will trigger an
	 * autoresize.</p>
	 *
	 * @param scaleX
	 * @param scaleY
	 * @see scaleX
	 * @see scaleY
	 */
	public function setScale(xs:Number, ys:Number) {
		if ( (xs == _video._xscale && ys == _video._yscale) || _autoSize ) return;
		_video._xscale = xs;
		_video._yscale = ys;
		if (_aspectRatio) {
			startAutoResize();
		}
	}

	/**
	 * <p>Causes the video to play.  Can be called while the video is
	 * paused, stopped, or while the video is already playing.  Call this
	 * method with no arguments to play an already loaded video or pass
	 * in a url to load a new stream.</p>
	 *
	 * <p>If player is in an unresponsive state, queues the request.</p>
	 *
	 * <p>Throws an exception if called with no args and no stream
	 * is connected.  Use "stateChange" event and
	 * <code>connected</code> property to determine when it is
	 * safe to call this method.</p>
	 *
	 * @param url Pass in a url string if you want to load and play a
	 * new FLV.  If you have already loaded an FLV and want to continue
	 * playing it, pass in <code>null</code>.
	 * @param isLive Pass in true if streaming a live feed from FCS.
	 * Defaults to false.
	 * @param totalTime Pass in length of FLV.  Pass in 0 or null or
	 * undefined to automatically detect length from metadata, server
	 * or xml.  If <code>INCManager.streamLength</code> is not 0 or
	 * null or undefined when <code>ncConnected</code> is called, then
	 * that value will trump this one in any case.  Default is
	 * undefined.
	 * @see #connected
	 * @see #stateResponsive
	 * @see #load()
	 */
	public function play(url:String, isLive:Boolean, totalTime:Number):Void {
		//ifdef DEBUG
		//debugTrace("play(" + url + ")");
		//endif

		// if new url passed, ask the INCManager to reconnect for us
		if (url != null) {
			if (_state == EXEC_QUEUED_CMD) {
				_state = _cachedState;
			} else if (!stateResponsive && _state != CONNECTION_ERROR) {
				queueCmd(PLAY, url, isLive, totalTime);
				return;
			} else {
				execQueuedCmds();
			}
			_autoPlay = true;
			_load(url, isLive, totalTime);
			// playing will start automatically once stream is setup, so return.
			return;
		}

		if (!isXnOK()) {
			if ( _state == CONNECTION_ERROR || _ncMgr == null || _ncMgr.getNetConnection() == null ) {
				throw new VideoError(VideoError.NO_CONNECTION);
			} else {
				//ifdef DEBUG
				//debugTrace("RECONNECTING!!!");
				//endif
				flushQueuedCmds();
				queueCmd(PLAY);
				setState(LOADING);
				_cachedState = LOADING;
				_ncMgr.reconnect();
				// playing will start automatically once stream is setup, so return.
				return;
			}
		} else if (_state == EXEC_QUEUED_CMD) {
			_state = _cachedState;
		} else if (!stateResponsive) {
			queueCmd(PLAY);
			return;
		} else {
			execQueuedCmds();
		}

		// recreate stream if necessary (this will never happen with
		// http download, just rtmp)
		if (_ns == null) {
			_createStream();
			_video.attachVideo(_ns);
			this.attachAudio(_ns);
		}

		switch (_state) {
		case BUFFERING:
			if (_ncMgr.isRTMP()) {
				_play(0);
				if (_atEnd) {
					_atEnd = false;
					_currentPos = 0;
					setState(REWINDING);
				} else if (_currentPos > 0) {
					_seek(_currentPos);
					_currentPos = 0;
				}
			}
			// no break
		case PLAYING:
			// already playing
			return;
		case STOPPED:
			if (_ncMgr.isRTMP()) {
				if (_isLive) {
					_play(-1);
					setState(BUFFERING);
				} else {
					_play(0);
					if (_atEnd) {
						_atEnd = false;
						_currentPos = 0;
						_state = BUFFERING;
						setState(REWINDING);
					} else if (_currentPos > 0) {
						_seek(_currentPos);
						_currentPos = 0;
						setState(BUFFERING);
					} else {
						setState(BUFFERING);
					}
				}
			} else {
				_pause(false);
				if (_atEnd) {
					_atEnd = false;
					_seek(0);
					_state = BUFFERING;
					setState(REWINDING);
				} else {
					if (_bufferState == BUFFER_EMPTY) {
						setState(BUFFERING);
					} else {
						setState(PLAYING);
					}
				}
			}
			break;
		case PAUSED:
			_pause(false);
			if (!_ncMgr.isRTMP()) {
				if (_bufferState == BUFFER_EMPTY) {
					setState(BUFFERING);
				} else {
					setState(PLAYING);
				}
			} else {
				setState(BUFFERING);
			}
			break;
		} // switch
	}

	/**
	 * <p>Similar to play, but causes the FLV to be loaded without
	 * playing.  Autoresizing will occur if appropriate and the first
	 * frame of FLV will be shown (except for maybe not in the live case).
	 * After initial load and autoresize, state will be <code>PAUSED</code>.</p>
	 *
	 * <p>Takes same arguments as <code>play()</code>, but unlike that
	 * method it is never acceptable to call <code>load()</code> with
	 * no url.  If you do, an <code>Error</code> will be thrown.</p>
	 *
	 * <p>If player is in an unresponsive state, queues the request.</p>
	 *
	 * @param url Pass in a url string for the FLV you want to load.
	 * @param isLive Pass in true if streaming a live feed from FCS.
	 * Defaults to false.
	 * @param totalTime Pass in length of FLV.  Pass in 0 or null or
	 * undefined to automatically detect length from metadata, server
	 * or xml.  If <code>INCManager.streamLength</code> is not 0 or
	 * null or undefined when <code>ncConnected</code> is called, then
	 * that value will trump this one in any case.  Default is
	 * undefined.
	 * @see #connected
	 * @see #play()
	 */
	public function load(url:String, isLive:Boolean, totalTime:Number):Void {
		if (url == null) {
			throw new Error("null url sent to VideoPlayer.load");
		}

		//ifdef DEBUG
		//debugTrace("load(" + url + ")");
		//endif

		if (_state == EXEC_QUEUED_CMD) {
			_state = _cachedState;
		} else if (!stateResponsive && _state != CONNECTION_ERROR) {
			queueCmd(LOAD, url, isLive, totalTime);
			return;
		} else {
			execQueuedCmds();
		}
		_autoPlay = false;
		_load(url, isLive, totalTime);
	}

	/*
	 * does loading work for play and load
	 */
	private function _load(url:String, isLive:Boolean, totalTime:Number):Void {
		//ifdef DEBUG
		//debugTrace("_load(" + url + ", " + isLive + ", " + totalTime + ")");
		//endif
		_prevVideoWidth = this.videoWidth;
		if (_prevVideoWidth == undefined) {
			_prevVideoWidth = _video.width;
			if (_prevVideoWidth == undefined) _prevVideoWidth = 0;
		}
		_prevVideoHeight = this.videoHeight;
		if (_prevVideoHeight == undefined) {
			_prevVideoHeight = _video.height;
			if (_prevVideoHeight == undefined) _prevVideoHeight = 0;
		}

		// reset state
		_autoResizeDone = false;
		_cachedPlayheadTime = 0;
		_bufferState = BUFFER_EMPTY;
		_sawPlayStop = false;
		_metadata = null;
		_startingPlay = false;
		_invalidSeekTime = false;
		_invalidSeekRecovery = false;
		_isLive = (isLive == undefined) ? false : isLive;
		_contentPath = url;
		_currentPos = 0;
		_streamLength = totalTime;
		_atEnd = false;
		_videoWidth = undefined;
		_videoHeight = undefined;
		_readyDispatched = false;
		_lastUpdateTime = -1;
		_sawSeekNotify = false;

		// must stop ALL intervals here
		clearInterval(_updateTimeIntervalID);
		_updateTimeIntervalID = 0;
		clearInterval(_updateProgressIntervalID);
		_updateProgressIntervalID = 0;
		clearInterval(_idleTimeoutIntervalID);
		_idleTimeoutIntervalID = 0;
		clearInterval(_autoResizeIntervalID);
		_autoResizeIntervalID = 0;
		clearInterval(_rtmpDoStopAtEndIntervalID);
		_rtmpDoStopAtEndIntervalID = 0;
		clearInterval(_rtmpDoSeekIntervalID);
		_rtmpDoSeekIntervalID = 0;
		clearInterval(_httpDoSeekIntervalID);
		_httpDoSeekIntervalID = 0;
		clearInterval(_finishAutoResizeIntervalID);
		_finishAutoResizeIntervalID = 0;
		clearInterval(_delayedBufferingIntervalID);
		_delayedBufferingIntervalID = 0;

		// close netstream
		closeNS(false);

		// if returns false, wait for a "connected" message and
		// then do these things
		if (_ncMgr == null) {
			createINCManager();
		}
		var instantConnect:Boolean = _ncMgr.connectToURL(_contentPath);
		setState(LOADING);
		_cachedState = LOADING;
		if (instantConnect) {
			_createStream();
			_setUpStream();
		}
		if (!_ncMgr.isRTMP()) {
			clearInterval(_updateProgressIntervalID);
			_updateProgressIntervalID = setInterval(this, "doUpdateProgress", _updateProgressInterval);
		}
	}

	/**
	 * <p>Pauses video playback.  If video is paused or stopped, has
	 * no effect.  To start playback again, call <code>play()</code>.
	 * Takes no parameters</p>
	 *
	 * <p>If player is in an unresponsive state, queues the request.</p>
	 *
	 * <p>Throws an exception if called when no stream is
	 * connected.  Use "stateChange" event and
	 * <code>connected</code> property to determine when it is
	 * safe to call this method.</p>
	 *
	 * <p>If state is already stopped, pause is does nothing and state
	 * remains stopped.</p>
	 *
	 * @see #connected
	 * @see #stateResponsive
	 * @see #play()
	 */
	public function pause():Void {
		//ifdef DEBUG
		//debugTrace("pause()");
		//endif

		if (!isXnOK()) {
			if ( _state == CONNECTION_ERROR || _ncMgr == null || _ncMgr.getNetConnection() == null ) {
				throw new VideoError(VideoError.NO_CONNECTION);
			} else {
				return;
			}
		} else if (_state == EXEC_QUEUED_CMD) {
			_state = _cachedState;
		} else if (!stateResponsive) {
			queueCmd(PAUSE);
			return;
		} else {
			execQueuedCmds();
		}
		if (_state == PAUSED || _state == STOPPED || _ns == null) return;
		_pause(true);
		setState(PAUSED);
	}

	/**
	 * <p>Stops video playback.  If <code>autoRewind</code> is set to
	 * <code>true</code>, rewinds to first frame.  If video is already
	 * stopped, has no effect.  To start playback again, call
	 * <code>play()</code>.  Takes no parameters</p>
	 *
	 * <p>If player is in an unresponsive state, queues the request.</p>
	 *
	 * <p>Throws an exception if called when no stream is
	 * connected.  Use "stateChange" event and
	 * <code>connected</code> property to determine when it is
	 * safe to call this method.</p>
	 *
	 * @see #connected
	 * @see #stateResponsive
	 * @see #autoRewind
	 * @see #play()
	 */
	public function stop():Void
	{
		//ifdef DEBUG
		//debugTrace("stop()");
		//endif

		if (!isXnOK()) {
			if ( _state == CONNECTION_ERROR || _ncMgr == null || _ncMgr.getNetConnection() == null ) {
				throw new VideoError(VideoError.NO_CONNECTION);
			} else {
				return;
			}
		} else if (_state == EXEC_QUEUED_CMD) {
			_state = _cachedState;
		} else if (!stateResponsive) {
			queueCmd(STOP);
			return;
		} else {
			execQueuedCmds();
		}
		if (_state == STOPPED || _ns == null) return;
		if (_ncMgr.isRTMP()) {
			if (_autoRewind && !_isLive) {
				_currentPos = 0;
				_play(0, 0);
				_state = STOPPED;
				setState(REWINDING);
			} else {
				closeNS(true);
				setState(STOPPED);
			}
		} else {
			_pause(true);
			if (_autoRewind) {
				_seek(0);
				_state = STOPPED;
				setState(REWINDING);
			} else {
				setState(STOPPED);
			}
		}
	}

	/**
	 * <p>Seeks to given second in video.  If video is playing,
	 * continues playing from that point.  If video is paused, seek to
	 * that point and remain paused.  If video is stopped, seek to
	 * that point and enters paused state.  Has no effect with live
	 * streams.</p>
	 *
	 * <p>If time is less than 0 or NaN, throws exeption.  If time
	 * is past the end of the stream, or past the amount of file
	 * downloaded so far, then will attempt seek and when fails
	 * will recover.</p>
	 *
	 * <p>If player is in an unresponsive state, queues the request.</p>
	 *
	 * <p>Throws an exception if called when no stream is
	 * connected.  Use "stateChange" event and
	 * <code>connected</code> property to determine when it is
	 * safe to call this method.</p>
	 *
	 * @param time seconds
	 * @throws VideoError if time is < 0
	 * @see #connected
	 * @see #stateResponsive
	 */
	public function seek(time:Number):Void
	{
		//ifdef DEBUG
		//debugTrace("seek:"+time);
		//endif
		// we do not allow more seeks until we are out of an invalid seek time state
		if (_invalidSeekTime) return;
		if (isNaN(time) || time < 0) throw new VideoError(VideoError.INVALID_SEEK);
		if (!isXnOK()) {
			if ( _state == CONNECTION_ERROR || _ncMgr == null || _ncMgr.getNetConnection() == null ) {
				throw new VideoError(VideoError.NO_CONNECTION);
			} else {
				//ifdef DEBUG
				//debugTrace("RECONNECTING!!!");
				//endif
				flushQueuedCmds();
				queueCmd(SEEK, null, false, time);
				setState(LOADING);
				_cachedState = LOADING;
				_ncMgr.reconnect();
				// playing will start automatically once stream is setup, so return.
				return;
			}
		} else if (_state == EXEC_QUEUED_CMD) {
			_state = _cachedState;
		} else if (!stateResponsive) {
			queueCmd(SEEK, null, false, time);
			return;
		} else {
			execQueuedCmds();
		}

		// recreate stream if necessary (this will never happen with
		// http download, just rtmp)
		if (_ns == null) {
			_createStream();
			_video.attachVideo(_ns);
			this.attachAudio(_ns);
		}

		if (_atEnd && time < playheadTime) {
			_atEnd = false;
		}

		switch (_state) {
		case PLAYING:
			_state = BUFFERING;
			// no break;
		case BUFFERING:
		case PAUSED:
			_seek(time);
			setState(SEEKING);
			break;
		case STOPPED:
			if (_ncMgr.isRTMP()) {
				_play(0);
				_pause(true);
			}
			_seek(time);
			_state = PAUSED;
			setState(SEEKING);
			break;
		}
	}

	/**
	 * <p>Forces close of video stream and FCS connection.  Triggers
	 * "close" event.  Typically calling this directly is not necessary
	 * because the idle timeout functionality will take care of this.</p>
	 *
	 * @see idleTimeout
	 */
	public function close():Void {
		//ifdef DEBUG
		//debugTrace("close()");
		//endif
		closeNS(true);
		// never makes sense to close an http NetConnection, it doesn't really maintain
		// any kind of network connection!
		if (_ncMgr != null && _ncMgr.isRTMP()) {
			_ncMgr.close();
		}
		setState(DISCONNECTED);
		dispatchEvent({type:"close", state:_state, playheadTime:playheadTime});
	}


	//
	// public getters, setters
	//


	public function get x():Number {
		return this._x;
	}
	public function set x(xpos:Number) {
		this._x = xpos;
	}

	public function get y():Number {
		return this._y;
	}
	public function set y(ypos:Number) {
		this._y = ypos;
	}

	/**
	 * 100 is standard scale
	 *
	 * @see #setScale()
	 */
	function get scaleX():Number
	{
		return _video._xscale;
	}
	function set scaleX(xs:Number):Void
	{
		setScale(xs, this.scaleY);
	}

	/**
	 * 100 is standard scale
	 *
	 * @see #setScale()
	 */
	function get scaleY():Number
	{
		return _video._yscale;
	}
	function set scaleY(ys:Number):Void
	{
		setScale(this.scaleX, ys);
	}

	/**
	 * <p>Width of video instance.  Not same as Video.width, that is videoWidth.</p>
	 *
	 * @see #setSize()
	 * @see #videoWidth
	 */
	public function get width():Number {
		return _video._width;
	}
	public function set width(w:Number):Void
	{
		setSize(w, _video._height);
	}

	/**
	 * <p>Height of video.  Not same as Video.height, that is videoHeight.</p>
	 *
	 * @see #setSize()
	 * @see #videoHeight
	 */
	public function get height():Number {
		return _video._height;
	}
	public function set height(h:Number):Void
	{
		setSize(_video._width, h);
	}

	/**
	 * <p>Source width of loaded FLV file.  Read only.  Returns
	 * undefined if no information available yet.</p>
	 *
	 * @see #width
	 */
	public function get videoWidth() {
		if (_readyDispatched) {
			_videoWidth = _video.width;
		}
		return _videoWidth;
	}

	/**
	 * <p>Source height of loaded FLV file.  Read only.  Returns
	 * undefined if no information available yet.</p>
	 *
	 * @see #height
	 */
	public function get videoHeight() {
		if (_readyDispatched) {
			_videoHeight = _video.height;
		}
		return _videoHeight;
	}

	/**
	 * <p>Use this instead of <code>_visible</code> because we
	 * sometimes do internal visibility management when doing an
	 * autoresize.</p>
	 */
	public function get visible():Boolean {
		if (!_hiddenForResize) {
			__visible = _visible;
		}
		return __visible;
	}

	public function set visible(v:Boolean):Void {
		__visible = v;
		if (!_hiddenForResize) {
			_visible = __visible;
		}
	}

	/**
	 * <p>Determines whether the instance is automatically resized to
	 * the source dimensions.  If this is set from false to true after
	 * an FLV has been loaded, an automatic resize will start
	 * immediately.</p>
	 *
	 */
	public function get autoSize():Boolean
	{
		return _autoSize;
	}
	public function set autoSize(flag:Boolean):Void
	{
		if (_autoSize != flag) {
			_autoSize = flag;
			if (_autoSize) {
				startAutoResize();
			}
		}
	}

	/**
	 * <p>Determines whether video aspect ratio is maintained.  If
	 * this is set from false to true and <code>autoSize</code is
	 * false after an FLV has been loaded, an automatic resize will
	 * start immediately.</p>
	 *
	 * @see #autoSize
	 */
	public function get maintainAspectRatio():Boolean
	{
		return _aspectRatio;
	}
	public function set maintainAspectRatio(flag:Boolean):Void
	{
		if (_aspectRatio != flag) {
			_aspectRatio = flag;
			if (_aspectRatio && !_autoSize) {
				startAutoResize();
			}
		}
	}

	/**
	 * <p>Determines whether the FLV is rewound to the first frame
	 * when play stops, either by calling <code>stop()</code> or by
	 * reaching the end of the stream.  Meaningless for live streams.</p>
	 *
	 */
	public function get autoRewind():Boolean
	{
		return _autoRewind;
	}
	public function set autoRewind(flag:Boolean):Void
	{
		_autoRewind = flag;
	}

	/**
	 * <p>The current playhead time in seconds.  Setting does a seek
	 * and has all the restrictions of a seek.</p>
	 *
	 * <p>The event "playheadUpdate" is dispatched when the playhead
	 * time changes, including every .25 seconds while the FLV is
	 * playing.</p>
	 *
	 * @return The playhead position, measured in seconds since the start.  Will return a fractional value.
	 * @see #seek()
	 */
	public function get playheadTime():Number
	{
		var nowTime:Number = (_ns == null) ? _currentPos : _ns.time;
		if (_metadata.audiodelay != undefined) {
			nowTime -= _metadata.audiodelay;
			if (nowTime < 0) nowTime = 0;
		}
		return nowTime;
	}
	public function set playheadTime(position:Number):Void
	{
		seek(position);
	}

	/**
	 * <p>url of currently loaded (or loading) stream. Will be url
	 * last sent to <code>play()</code> or <code>load()</code>, <code>null</code>
	 * if no stream is loaded.</p>
	 *
	 */
	public function get url():String
	{
		return _contentPath;
	}

	/**
	 * <p>Volume control in range from 0 to 100.</p>
	 *
	 * @return The most recent volume setting
	 * @see #transform
	 */
	public function get volume():Number
	{
		return _volume;
	}
	public function set volume(aVol:Number):Void
	{
		_volume = aVol;
		if (!_hiddenForResize) {
			_sound.setVolume(_volume);
		}
	}

	/**
	 * <p>Provides direct access to the
	 * <code>Sound.setTransform()</code> and
	 * <code>Sound.getTransform()</code> APIs. to expose more sound
	 * control.  Must set property for changes to take effect, get
	 * property just to get a copy of the current settings to tweak.</p>
	 *
	 * @see #volume
	 */
	public function get transform():Object {
		return _sound.getTransform();
	}
	public function set transform(s:Object):Void {
		_sound.setTransform(s);
	}

	/**
	 * True if stream is RTMP download (streaming from Flash
	 * Communication Server), read only.
	 */
	public function get isRTMP():Boolean {
		if (_ncMgr == null) return undefined;
		return _ncMgr.isRTMP();
	}

	/**
	 * <p>True if stream is live, read only.  isLive only makes sense when
	 * streaming from FVSS or FCS, value is ignored when doing http
	 * download.</p>
	 */
	public function get isLive():Boolean {
		return _isLive;
	}

	/**
	 * Get state.  Read only.  Set with <code>load</code>,
	 * <code>play()</code>, <code>stop()</code>,
	 * <code>pause()</code> and <code>seek()</code>.
	 */
	public function get state():String {
		return _state;
	}

	/**
	 * Read only. Gets whether state is responsive.  If state is
	 * unresponsive, calls to APIs <code>play()</code>,
	 * <code>load()</code>, <code>stop()</code>,
	 * <code>pause()</code> and <code>seek()</code> will queue the
	 * requests for later, when the state changes to a responsive
	 * one.
	 *
	 * @see #connected
	 * @see #DISCONNECTED
	 * @see #STOPPED
	 * @see #PLAYING
	 * @see #PAUSED
	 * @see #LOADING
	 * @see #RESIZING
	 * @see #CONNECTION_ERROR
	 * @see #REWINDING
	 */
	public function get stateResponsive():Boolean {
		switch (_state) {
		case DISCONNECTED:
		case STOPPED:
		case PLAYING:
		case PAUSED:
		case BUFFERING:
			return true;
		default:
			return false;
		}
	}

	/**
	 * <p>property bytesLoaded, read only.  Returns -1 when there
	 * is no stream, when the stream is FCS or if the information
	 * is not yet available.  Return value only useful for HTTP
	 * download.</p>
	 *
	 */
	public function get bytesLoaded():Number
	{
		if (_ns == null || _ncMgr.isRTMP()) return -1;
		return _ns.bytesLoaded;
	}

	/**
	 * <p>property bytesTotal, read only.  Returns -1 when there
	 * is no stream, when the stream is FCS or if the information
	 * is not yet available.  Return value only useful for HTTP
	 * download.</p>
	 *
	 */
	public function get bytesTotal():Number
	{
		if (_ns == null || _ncMgr.isRTMP()) return -1;
		return _ns.bytesTotal;
	}

	/**
	 * <p>property totalTime.  read only.  0 or null or undefined
	 * means that property was not passed into <code>play()</code> or
	 * <code>load()</code> and was unable to detect automatically, or
	 * have not yet.</p>
	 *
	 * @return The total running time of the FLV in seconds
	 */
	public function get totalTime():Number
	{
		return _streamLength;
	}

	/**
	 * <p>Sets number of seconds to buffer in memory before playing
	 * back stream.  For slow connections streaming over rtmp, it is
	 * important to increase this from the default.  Default is
	 * 0.1</p>
	 */
	public function get bufferTime():Number
	{
		return _bufferTime;
	}
	public function set bufferTime(aTime:Number):Void
	{
		_bufferTime = aTime;
		if (_ns != null) {
			_ns.setBufferTime(_bufferTime);
		}
	}

	/**
	 * <p>Property idleTimeout, which is amount of time in
	 * milliseconds before connection is idle (playing is paused
	 * or stopped) before connection to the FCS server is
	 * terminated.  Has no effect to HTTP download of FLV.</p>
	 *
	 * <p>If set when stream already idle, restarts idle timeout with
	 * new value.</p>
	 */
	public function get idleTimeout():Number {
		return _idleTimeoutInterval;
	}
	public function set idleTimeout(aTime:Number):Void {
		_idleTimeoutInterval = aTime;
		if (_idleTimeoutIntervalID > 0) {
			clearInterval(_idleTimeoutIntervalID);
			_idleTimeoutIntervalID = setInterval(this, "doIdleTimeout", _idleTimeoutInterval);
		}
	}

	/**
	 * <p>Property playheadUpdateInterval, which is amount of time
	 * in milliseconds between each "playheadUpdate" event.</p>
	 *
	 * <p>If set when stream is playing, will restart interval.</p>
	 */
	public function get playheadUpdateInterval():Number {
		return _updateTimeInterval;
	}
	public function set playheadUpdateInterval(aTime:Number):Void {
		_updateTimeInterval = aTime;
		if (_updateTimeIntervalID > 0) {
			clearInterval(_updateTimeIntervalID);
			_updateTimeIntervalID = setInterval(this, "doUpdateTime", _updateTimeInterval);
		}
	}

	/**
	 * <p>Property progressInterval, which is amount of time
	 * in milliseconds between each "progress" event.</p>
	 *
	 * <p>If set when stream is playing, will restart interval.</p>
	 */
	public function get progressInterval():Number {
		return _updateProgressInterval;
	}
	public function set progressInterval(aTime:Number):Void {
		_updateProgressInterval = aTime;
		if (_updateProgressIntervalID > 0) {
			clearInterval(_updateProgressIntervalID);
			_updateProgressIntervalID = setInterval(this, "doUpdateProgress", _updateProgressInterval);
		}
	}

	/**
	 * <p>Access to instance of the class implementing
	 * <code>INCManager</code>.  Read only.</p>
	 *
	 * <p>One use case for this is that a custom
	 * <code>INCManager</code> implementation may require custom
	 * initialization.</p>
	 */
	public function get ncMgr():INCManager {
		if (_ncMgr == null) {
			createINCManager();
		}
		return _ncMgr;
	}

	/**
	 * <p>Read only.  Object received by call to onMetaData callback.
	 * null if onMetaData callback has not been called since the last
	 * load or play call.  Always null with FLVs with no onMetaData
	 * packet.</p>
	 *
	 * @see #load()
	 * @see #play()
	 */
	public function get metadata() { return _metadata; };

	//
	// public callbacks, not really APIs
	//


	/**
	 * <p>Called on interval determined by
	 * <code>playheadUpdateInterval</code> to send "playheadUpdate"
	 * events.  Events only sent when playhead is moving, sent every
	 * .25 seconds by default.</p>
	 *
	 * @private
	 */
	public function doUpdateTime():Void {
		//ifdef DEBUG
		////debugTrace("doUpdateTime()");
		//endif
		var theTime:Number = playheadTime;

		// stop interval if we are stopped or paused
		switch (_state) {
		case STOPPED:
		case PAUSED:
		case DISCONNECTED:
		case CONNECTION_ERROR:
			clearInterval(_updateTimeIntervalID);
			_updateTimeIntervalID = 0;
			break;
		}

		if (_lastUpdateTime != theTime) {
			dispatchEvent({type:"playheadUpdate", state:_state, playheadTime:theTime});
			_lastUpdateTime = theTime;
		}
	}

	/**
	 * <p>Called at interval determined by
	 * <code>progressInterval</code> to send "progress" events.
	 * Object dispatch starts when <code>_load</code> is called, ends
	 * when all bytes downloaded or a network error of some kind
	 * occurs, dispatched every .25 seconds by default.</p>
	 *
	 * @private
	 */
	public function doUpdateProgress():Void {
		if (_ns == null) return;
		//ifdef DEBUG
		////debugTrace("doUpdateProgress()");
		////debugTrace("_ns.bytesLoaded = " + _ns.bytesLoaded);
		////debugTrace("_ns.bytesTotal = " + _ns.bytesTotal);
		//endif

		if (_ns.bytesTotal >= 0 && _ns.bytesTotal >= 0) {
			dispatchEvent({type:"progress", bytesLoaded:_ns.bytesLoaded, bytesTotal:_ns.bytesTotal});
		}
		if ( _state == DISCONNECTED || _state == CONNECTION_ERROR || _ns.bytesLoaded == _ns.bytesTotal ) {
			clearInterval(_updateProgressIntervalID);
			_updateProgressIntervalID = 0;
		}
	}

	/**
	 * <p><code>NetStream.onStatus</code> callback for rtmp.  Handles
	 * automatic resizing, autorewind and buffering messaging.</p>
	 *
	 * @private
	 */
	public function rtmpOnStatus(info:Object):Void
	{
		//ifdef DEBUG
		//debugTrace("rtmpOnStatus:"+info.code);
		//debugTrace("_state == " + _state);
		//debugTrace("_cachedState == " + _cachedState);
		//debugTrace("_bufferState == " + _bufferState);
		//debugTrace("_sawPlayStop == " + _sawPlayStop);
		//debugTrace("_cachedPlayheadTime == " + _cachedPlayheadTime);
		//debugTrace("playheadTime == " + playheadTime);
		//debugTrace("_ns.bufferLength = " + _ns.bufferLength);
		//debugTrace("_startingPlay = " + _startingPlay);
		//endif

		if (_state == CONNECTION_ERROR) {
			// always do nothing
			return;
		}

		switch (info.code) {
		case "NetStream.Play.Stop":
			if (_startingPlay) return;
			switch (_state) {
			case RESIZING:
				if (_hiddenForResize) finishAutoResize();
				break;
			case LOADING:
			case STOPPED:
			case PAUSED:
				// yes we are stopped, we already know this
				break;
			default:
				_sawPlayStop = true;
				break;
			} // switch (_state)
			break;
		case "NetStream.Buffer.Empty":
			switch (_bufferState) {
			case BUFFER_FULL:
				if (_sawPlayStop) {
					rtmpDoStopAtEnd(true);
				} else if (_state == PLAYING) {
					setState(BUFFERING);
				}
				break;
			}
			_bufferState = BUFFER_EMPTY;
			_sawPlayStop = false;
			break;
		case "NetStream.Buffer.Flush":
			if (_sawSeekNotify && _state == SEEKING) {
				_bufferState = BUFFER_EMPTY;
				_sawPlayStop = false;
				setStateFromCachedState();
				doUpdateTime();
			}
			if ( _sawPlayStop &&
			     ( _bufferState == BUFFER_EMPTY || (_bufferTime <= 0.1 && _ns.bufferLength <= 0.1) ) ) {
				// if we did a seek toward the end of the file so that
				// there is less file left to show than we have
				// buffer, than we will get a NetStream.Play.Stop when
				// the buffer loads rest of the file, but never get
				// a NetStream.Buffer.Full, since it won't fill, so
				// we check if we are done on a timer
				_cachedPlayheadTime = playheadTime;
				clearInterval(_rtmpDoStopAtEndIntervalID);
				_rtmpDoStopAtEndIntervalID = setInterval(this, "rtmpDoStopAtEnd", RTMP_DO_STOP_AT_END_INTERVAL);
			}
			switch (_bufferState) {
			case BUFFER_EMPTY:
				if ( !_hiddenForResize ) {
					if ((_state == LOADING && _cachedState == PLAYING) || _state == BUFFERING) {
						setState(PLAYING);
					} else if (_cachedState == BUFFERING) {
						_cachedState = PLAYING;
					}
				}
				_bufferState = BUFFER_FLUSH;
				break;
			default:
				if (_state == BUFFERING) {
					setStateFromCachedState();
				}
				break;
			} // switch (_bufferState)
			break;
		case "NetStream.Buffer.Full":
			if (_sawSeekNotify && _state == SEEKING) {
				_bufferState = BUFFER_EMPTY;
				_sawPlayStop = false;
				setStateFromCachedState();
				doUpdateTime();
			}
			switch (_bufferState) {
			case BUFFER_EMPTY:
				_bufferState = BUFFER_FULL;
				if ( !_hiddenForResize ) {
					if ((_state == LOADING && _cachedState == PLAYING) || _state == BUFFERING) {
						setState(PLAYING);
					} else if (_cachedState == BUFFERING) {
						_cachedState = PLAYING;
					}
					if (_rtmpDoStopAtEndIntervalID != 0) {
						_sawPlayStop = true;
						clearInterval(_rtmpDoStopAtEndIntervalID);
						_rtmpDoStopAtEndIntervalID = 0;
					}
				}
				break;
			case BUFFER_FLUSH:
				_bufferState = BUFFER_FULL;
				if ( _rtmpDoStopAtEndIntervalID != 0) {
					_sawPlayStop = true;
					clearInterval(_rtmpDoStopAtEndIntervalID);
					_rtmpDoStopAtEndIntervalID = 0;
				}
				break;
			} // switch (_bufferState)
			if (_state == BUFFERING) {
				setStateFromCachedState();
			}
			break;
		case "NetStream.Pause.Notify":
			if (_state == RESIZING && _hiddenForResize) {
				finishAutoResize();
			}
			break;
		case "NetStream.Unpause.Notify":
			if (_state == PAUSED) {
				_state = PLAYING;
				setState(BUFFERING);
			} else {
				_cachedState = PLAYING;
			}
			break;
		case "NetStream.Play.Start":
			clearInterval(_rtmpDoStopAtEndIntervalID);
			_rtmpDoStopAtEndIntervalID = 0;
			_bufferState = BUFFER_EMPTY;
			_sawPlayStop = false;
			if (_startingPlay) {
				_startingPlay = false;
				_cachedPlayheadTime = playheadTime;
			} else if (_state == PLAYING) {
				setState(BUFFERING);
			}
			break;
		case "NetStream.Play.Reset":
			clearInterval(_rtmpDoStopAtEndIntervalID);
			_rtmpDoStopAtEndIntervalID = 0;
			if (_state == REWINDING) {
				clearInterval(_rtmpDoSeekIntervalID);
				_rtmpDoSeekIntervalID = 0;
				if (playheadTime == 0 || playheadTime < _cachedPlayheadTime) {
					setStateFromCachedState();
				} else {
					_cachedPlayheadTime = playheadTime;
					_rtmpDoSeekIntervalID = setInterval(this, "rtmpDoSeek", RTMP_DO_SEEK_INTERVAL);
				}
			}
			break;
		case "NetStream.Seek.Notify":
			if (playheadTime != _cachedPlayheadTime) {
				setStateFromCachedState();
				doUpdateTime();
			} else {
				_sawSeekNotify = true;
				if (_rtmpDoSeekIntervalID == 0) {
					_rtmpDoSeekIntervalID = setInterval(this, "rtmpDoSeek", RTMP_DO_SEEK_INTERVAL);
				}
			}
			break;
		case "Netstream.Play.UnpublishNotify":
			break;
		case "Netstream.Play.PublishNotify":
			break;
		case "NetStream.Play.StreamNotFound":
			closeNS(false);
			if (!_ncMgr.connectAgain()) {
				setState(CONNECTION_ERROR);
			}
			break;
		case "NetStream.Play.Failed":	
		case "NetStream.Failed":
		case "NetStream.Play.FileStructureInvalid":
		case "NetStream.Play.NoSupportedTrackFound":
			setState(CONNECTION_ERROR);
			break;
		} // switch (info.code)
	}

	/**
	 * <p><code>NetStream.onStatus</code> callback for http.  Handles
	 * autorewind.</p>
	 *
	 * @private
	 */
	public function httpOnStatus(info:Object):Void
	{
		//ifdef DEBUG
		//debugTrace("httpOnStatus:"+info.code);
		//debugTrace("_state == " + _state);
		//debugTrace("playheadTime == " + playheadTime);
		//debugTrace("_bufferState = " + _bufferState);
		//endif

		switch (info.code) {
		case "NetStream.Play.Stop":
			clearInterval(_delayedBufferingIntervalID);
			_delayedBufferingIntervalID = 0;
			if (_invalidSeekTime) {
				_invalidSeekTime = false;
				_invalidSeekRecovery = true;
				setState(_cachedState);
				seek(playheadTime);
			} else {
				switch (_state) {
				case SEEKING:
					httpDoSeek();
					// no break;
				case PLAYING:
				case BUFFERING:
					httpDoStopAtEnd();
					break;
				}
			}
			break;
		case "NetStream.Seek.InvalidTime":
			if (_invalidSeekRecovery) {
				_invalidSeekTime = false;
				_invalidSeekRecovery = false;
				setState(_cachedState);
				seek(0);
			} else {
				_invalidSeekTime = true;
			}
			break;
		case "NetStream.Buffer.Empty":
			_bufferState = BUFFER_EMPTY;
			if (_state == PLAYING) {
				clearInterval(_delayedBufferingIntervalID);
				_delayedBufferingIntervalID = setInterval(this, "doDelayedBuffering", _delayedBufferingInterval);
			}
			break;
		case "NetStream.Buffer.Full":
		case "NetStream.Buffer.Flush":
			clearInterval(_delayedBufferingIntervalID);
			_delayedBufferingIntervalID = 0;
			_bufferState = BUFFER_FULL;
			if ( !_hiddenForResize ) {
				if ((_state == LOADING && _cachedState == PLAYING) || _state == BUFFERING) {
					setState(PLAYING);
				} else if (_cachedState == BUFFERING) {
					_cachedState = PLAYING;
				}
			}
			break;
		case "NetStream.Seek.Notify":
			_invalidSeekRecovery = false;
			switch (_state) {
			case SEEKING:
			case REWINDING:
				if (_httpDoSeekIntervalID == 0) {
					_httpDoSeekCount = 0;
					_httpDoSeekIntervalID = setInterval(this, "httpDoSeek", HTTP_DO_SEEK_INTERVAL);
				}
				break;
			} // switch (_state)
			break;
		case "NetStream.Play.StreamNotFound":
		case "NetStream.Play.FileStructureInvalid":
		case "NetStream.Play.NoSupportedTrackFound":
			setState(CONNECTION_ERROR);
			break;
		} // switch (info.code)
	}

	/**
	 * <p>Called by INCManager after when connection complete or
	 * failed after call to <code>INCManager.connectToURL</code>.
	 * If connection failed, set <code>INCManager.nc = null</code>
	 * before calling.</p>
	 *
	 * @see #ncReconnected()
	 * @see INCManager#connectToURL
	 * @see NCManager#connectToURL
	 */
	public function ncConnected():Void	{
		//ifdef DEBUG
		//debugTrace("ncConnected()");
		//endif

		if ( _ncMgr == null || _ncMgr.getNetConnection() == null ) {
			setState(CONNECTION_ERROR);
		} else if (_ns == null) {
			_createStream();
			_setUpStream();
		}
	}

	/**
	 * <p>Called by INCManager after when reconnection complete or
	 * failed after call to <code>INCManager.reconnect</code>.  If
	 * connection failed, set <code>INCManager.nc = null</code>
	 * before calling.</p>
	 *
	 * @see #ncConnected()
	 * @see INCManager#reconnect
	 * @see NCManager#reconnect
	 */
	public function ncReconnected():Void
	{
		//ifdef DEBUG
		//debugTrace("reconnected called!");
		//endif
		if ( _ncMgr == null || _ncMgr.getNetConnection() == null ) {
			setState(CONNECTION_ERROR);
		} else {
			_ns = null;
			_state = STOPPED;
			execQueuedCmds();
		}
	}

	/**
	 * handles NetStream.onMetaData callback
	 *
	 * @private
	 */
	public function onMetaData(info:Object):Void {
		if (_metadata != null) return;
		_metadata = info;
		if ( _streamLength == null || _streamLength <= 0 ) {
			_streamLength = info.duration;
		}
		if (isNaN(_videoWidth) || _videoWidth <= 0) _videoWidth = info.width;
		if (isNaN(_videoHeight) || _videoHeight <= 0) _videoHeight = info.height;
		dispatchEvent({type:"metadataReceived", info:info});
	}

	/**
	 * handles NetStream.onCuePoint callback
	 *
	 * @private
	 */
	public function onCuePoint(info:Object):Void {
		if (!_hiddenForResize || (!isNaN(_hiddenRewindPlayheadTime) && playheadTime < _hiddenRewindPlayheadTime)) {
			dispatchEvent({type:"cuePoint", info:info});
		}
	}


	//
	// private functions
	//


	/**
	 * sets state, dispatches event, execs queued commands.  Always try to call
	 * this AFTER you do your work, because the state might change again after
	 * you call this if you set it to a responsive state becasue of the call
	 * to exec queued commands.  If you set this to a responsive state and
	 * then do more state based logic, check _state to make sure it did not
	 * change out from under you.
	 * 
	 * @private
	 */
	private function setState(s:String):Void {
		if (s == _state) return;
		_hiddenRewindPlayheadTime = undefined;
		_cachedState = _state;
		_cachedPlayheadTime = playheadTime;
		_state = s;
		var newState:String = _state;
		//ifdef DEBUG
		//debugTrace("state = " + newState);
		//debugTrace("_cachedState == " + _cachedState);
		////debugTrace("_cachedPlayheadTime == " + _cachedPlayheadTime);
		//endif
		dispatchEvent({type:"stateChange", state:newState, playheadTime:playheadTime});
		if (!_readyDispatched) {
			switch (newState) {
			case STOPPED:
			case PLAYING:
			case PAUSED:
			case BUFFERING:
				_readyDispatched = true;
				dispatchEvent({type:"ready", state:newState, playheadTime:playheadTime});
				break;
			} // switch
		}
		switch (_cachedState) {
		case REWINDING:
			dispatchEvent({type:"rewind", state:newState, playheadTime:playheadTime});
			if (_ncMgr.isRTMP() && newState == STOPPED) {
				closeNS();
			}
			break;
		} // switch
		switch (newState) {
		case STOPPED:
		case PAUSED:
			if (_ncMgr.isRTMP() && _idleTimeoutIntervalID == 0) {
				_idleTimeoutIntervalID = setInterval(this, "doIdleTimeout", _idleTimeoutInterval);
			}
			break;
		case SEEKING:
		case REWINDING:
			_bufferState = BUFFER_EMPTY;
			_sawPlayStop = false;
			// no break
		case PLAYING:
		case BUFFERING:
			if (_updateTimeIntervalID == 0) {
				_updateTimeIntervalID = setInterval(this, "doUpdateTime", _updateTimeInterval);
			}
			// no break
		case LOADING:
		case RESIZING:
			clearInterval(_idleTimeoutIntervalID);
			_idleTimeoutIntervalID = 0;
			break;
		} // switch
		execQueuedCmds();
	}

	/**
	 * Sets state to _cachedState if the _cachedState is PLAYING,
	 * PAUSED or BUFFERING, otherwise sets state to STOPPED.
	 *
	 * @private
	 */
	private function setStateFromCachedState():Void {
		switch (_cachedState) {
		case PLAYING:
		case PAUSED:
			setState(_cachedState);
			break;
		case BUFFERING:
			if (_bufferState == BUFFER_EMPTY) {
				setState(BUFFERING);
			} else {
				setState(_cachedState);
			}
			break;
		default:
			setState(STOPPED);
			break;
		}
	}

	/**
	 * creates our implementatino of the <code>INCManager</code>.
	 * We put this off until we need to do it to give time for the
	 * user to customize the <code>DEFAULT_INCMANAGER</code>
	 * static variable.
	 *
	 * @private
	 */
	private function createINCManager():Void {
		if (ncMgrClassName == null) {
			ncMgrClassName = DEFAULT_INCMANAGER;
		}
		var ncMgrConstructor:Function = eval( (ncMgrClassName) );
		_ncMgr = new ncMgrConstructor;
		_ncMgr.setVideoPlayer(this);
	}

	/**
	 * <p>ONLY CALL THIS WITH RTMP STREAMING</p>
	 *
	 * <p>Has the logic for what to do when we decide we have come to
	 * a stop by coming to the end of an rtmp stream.  There are a few
	 * different ways we decide this has happened, and we sometimes
	 * even set an interval that calls this function repeatedly to
	 * check if the time is still changing, which is why it has its
	 * own special function.</p>
	 *
	 * @private
	 */
	private function rtmpDoStopAtEnd(force:Boolean):Void {
		//ifdef DEBUG
		//debugTrace("rtmpDoStopAtEnd(" + force + ")");
		//endif
		// check if we really want to stop if this was triggered on an
		// interval.  If we are running this on an interval (see
		// rtmpOnStatus) we do a stop when the playhead hasn't moved
		// since last time we checked, we check every .25 seconds.
		if (_rtmpDoStopAtEndIntervalID > 0) {
			switch (_state) {
			case DISCONNECTED:
			case CONNECTION_ERROR:
				clearInterval(_rtmpDoStopAtEndIntervalID);
				_rtmpDoStopAtEndIntervalID = 0;
				return;
			}
			if (force || _cachedPlayheadTime == playheadTime) {
				clearInterval(_rtmpDoStopAtEndIntervalID);
				_rtmpDoStopAtEndIntervalID = 0;
			} else {
				_cachedPlayheadTime = playheadTime;
				return;
			}
		}
		_bufferState = BUFFER_EMPTY;
		_sawPlayStop = false;
		_atEnd = true;
		// all this triggers callbacks, so need to keep checking if
		// _state == STOPPED--if no longer, then we bail
		setState(STOPPED);
		if (_state != STOPPED) return;
		doUpdateTime();
		if (_state != STOPPED) return;
		dispatchEvent({type:"complete", state:_state, playheadTime:playheadTime});
		if (_state != STOPPED) return;
		if (_autoRewind && !_isLive && playheadTime != 0) {
			_atEnd = false;
			_currentPos = 0;
			_play(0, 0);
			setState(REWINDING);
		} else {
			closeNS();
		}
	}

	/**
	 * <p>ONLY CALL THIS WITH RTMP STREAMING</p>
	 *
	 * <p>Wait until time goes back to zero to leave rewinding state.</p>
	 *
	 * @private
	 */
	private function rtmpDoSeek():Void {
		//ifdef DEBUG
		//debugTrace("rtmpDoSeek()");
		//endif
		if (_state != REWINDING && _state != SEEKING) {
			clearInterval(_rtmpDoSeekIntervalID);
			_rtmpDoSeekIntervalID = 0;
			_sawSeekNotify = false;
		} else if (playheadTime != _cachedPlayheadTime) {
			clearInterval(_rtmpDoSeekIntervalID);
			_rtmpDoSeekIntervalID = 0;
			_sawSeekNotify = false;
			setStateFromCachedState();
			doUpdateTime();
		}
	}

	/**
	 * <p>ONLY CALL THIS WITH HTTP PROGRESSIVE DOWNLOAD</p>
	 *
	 * <p>Call this when playing stops by hitting the end.</p>
	 *
	 * @private
	 */
	private function httpDoStopAtEnd():Void {
		//ifdef DEBUG
		//debugTrace("httpDoStopAtEnd()");
		//endif
		_atEnd = true;
		if ( _streamLength == null || _streamLength <= 0 ) {
			_streamLength = _ns.time;
		}
		_pause(true);
		setState(STOPPED);
		if (_state != STOPPED) return;
		doUpdateTime();
		if (_state != STOPPED) return;
		dispatchEvent({type:"complete", state:_state, playheadTime:playheadTime});
		if (_state != STOPPED) return;
		if (_autoRewind) {
			_atEnd = false;
			_pause(true);
			_seek(0);
			setState(REWINDING);
		}
	}

	/**
	 * <p>ONLY CALL THIS WITH HTTP PROGRESSIVE DOWNLOAD</p>
	 *
	 * <p>If we get an onStatus callback indicating a seek is over,
	 * but the playheadTime has not updated yet, then we wait on a
	 * timer before moving forward.</p>
	 *
	 * @private
	 */
	private function httpDoSeek():Void {
		//ifdef DEBUG
		//debugTrace("httpDoSeek()");
		//debugTrace("playheadTime = " + playheadTime);
		//debugTrace("_cachedPlayheadTime = " + _cachedPlayheadTime);
		//endif
		var seekState:Boolean = (_state == REWINDING || _state == SEEKING);
		// if seeking or rewinding, then need to wait for playhead time to
		// change or for timeout
		if ( seekState && _httpDoSeekCount < HTTP_DO_SEEK_MAX_COUNT &&
		     (_cachedPlayheadTime == playheadTime || _invalidSeekTime) ) {
			_httpDoSeekCount++;
			return;
		}

		// reset
		_httpDoSeekCount = 0;
		clearInterval(_httpDoSeekIntervalID);
		_httpDoSeekIntervalID = 0;

		// only do the rest if were seeking or rewinding to start with
		if (!seekState) return;

		setStateFromCachedState();
		if (_invalidSeekTime) {
			_invalidSeekTime = false;
			_invalidSeekRecovery = true;
			seek(playheadTime);
		} else {
			doUpdateTime();
		}
	}

	/**
	 * <p>Wrapper for <code>NetStream.close()</code>.  Never call
	 * <code>NetStream.close()</code> directly, always call this
	 * method because it does some other housekeeping.</p>
	 *
	 * @private
	 */
	private function closeNS(updateCurrentPos:Boolean):Void {
		//ifdef DEBUG
		//debugTrace("closeNS()");
		//endif
		if (_ns != null && _ns != undefined) {
			if (updateCurrentPos) {
				clearInterval(_updateTimeIntervalID);
				_updateTimeIntervalID = 0;
				doUpdateTime();
				_currentPos = _ns.time;
			}
			delete _ns.onStatus;
			_ns.onStatus = null;
			_ns.close();
			_ns = null;
		}
	}

	/**
	 * <p>We do a brief timer before entering BUFFERING state to avoid
	 * quick switches from BUFFERING to PLAYING and back.</p>
	 *
	 * @private
	 */
	private function doDelayedBuffering():Void {
		//ifdef DEBUG
		//debugTrace("doDelayedBuffering()");
		//endif
		switch (_state) {
		case LOADING:
		case RESIZING:
			// if loading or resizing, still at beginning so keep whirring, might go into buffering state
			break;
		case PLAYING:
			// still in that playing state, let's go to buffering
			clearInterval(_delayedBufferingIntervalID);
			_delayedBufferingIntervalID = 0;
			setState(BUFFERING);
			break;
		default:
			// any other state, bail and kill timer
			clearInterval(_delayedBufferingIntervalID);
			_delayedBufferingIntervalID = 0;
			break;
		}
	}

	/**
	 * Wrapper for <code>NetStream.pause()</code>.  Never call
	 * <code>NetStream.pause()</code> directly, always call this
	 * method because it does some other housekeeping.
	 *
	 * @private
	 */
	private function _pause(doPause:Boolean):Void {
		//ifdef DEBUG
		//debugTrace("_pause(" + doPause + ")");
		//endif
		clearInterval(_rtmpDoStopAtEndIntervalID);
		_rtmpDoStopAtEndIntervalID = 0;
		_ns.pause(doPause);
	}

	/**
	 * Wrapper for <code>NetStream.play()</code>.  Never call
	 * <code>NetStream.play()</code> directly, always call this
	 * method because it does some other housekeeping.
	 *
	 * @private
	 */
	private function _play():Void {
		//ifdef DEBUG
		//var debugString:String = "_play("
		//if (arguments.length > 0) {
		//	debugString += arguments[0];
		//	if (arguments.length > 1) {
		//		debugString += ", " + arguments[1];
		//	}
		//}
		//debugString += ")";
		//debugTrace(debugString);
		//debugTrace("_ncMgr.getStreamName() = " + _ncMgr.getStreamName());
		//endif
		clearInterval(_rtmpDoStopAtEndIntervalID);
		_rtmpDoStopAtEndIntervalID = 0;
		_startingPlay = true;
		switch (arguments.length) {
		case 0:
			_ns.play(_ncMgr.getStreamName(), (_isLive) ? -1 : 0, -1);
			break;
		case 1:
			_ns.play(_ncMgr.getStreamName(), (_isLive) ? -1 : arguments[0], -1);
			break;
		case 2:
			_ns.play(_ncMgr.getStreamName(), (_isLive) ? -1 : arguments[0], arguments[1]);
			break;
		default:
			throw new Error("bad args to _play");
		}
	}

	/**
	 * Wrapper for <code>NetStream.seek()</code>.  Never call
	 * <code>NetStream.seek()</code> directly, always call
	 * this method because it does some other housekeeping.
	 *
	 * @private
	 */
	private function _seek(time:Number):Void {
		//ifdef DEBUG
		//debugTrace("_seek(" + time + ")");
		//endif
		clearInterval(_rtmpDoStopAtEndIntervalID);
		_rtmpDoStopAtEndIntervalID = 0;
		if (_metadata.audiodelay != undefined && time + _metadata.audiodelay < _streamLength) {
			time += _metadata.audiodelay;
		}
		_ns.seek(time);
		_invalidSeekTime = false;
		_bufferState = BUFFER_EMPTY;
		_sawPlayStop = false;
		_sawSeekNotify = false;
	}

	/**
	 * Gets whether connected to a stream.  If not, then calls to APIs
	 * <code>play() with no args</code>, <code>stop()</code>,
	 * <code>pause()</code> and <code>seek()</code> will throw
	 * exceptions.
	 *
	 * @see #stateResponsive
	 * @private
	 */
	private function isXnOK():Boolean {
		if (_state == LOADING) return true;
		if (_state == CONNECTION_ERROR) return false;
		if (_state != DISCONNECTED) {
			if ( _ncMgr == null || _ncMgr.getNetConnection() == null || !_ncMgr.getNetConnection().isConnected ) {
				setState(DISCONNECTED);
				return false;
			}
			return true;
		}
		return false;
	}

	/**
	 * Kicks off autoresize process
	 *
	 * @private
	 */
	private function startAutoResize() {
		switch (_state) {
		case DISCONNECTED:
		case CONNECTION_ERROR:
			// autoresize will happen later automatically
			return;
		default:
			_autoResizeDone = false;
			if (stateResponsive && _videoWidth != undefined && _videoHeight != undefined) {
				// do it now!
				doAutoResize();
			} else {
				// do it on an interval, it won't happen until we are
				// back in a responsive state
				clearInterval(_autoResizeIntervalID);
				_autoResizeIntervalID = setInterval(this, "doAutoResize", AUTO_RESIZE_INTERVAL);
				break;
			}
		}
	}

	/**
	 * <p>Does the actual work of resetting the width and height.</p>
	 *
	 * <p>Called on an interval which is stopped when width and height
	 * of the <code>Video</code> object are not zero.  Finishing the
	 * resize is done in another method which is either called on a
	 * interval set up here for live streams or on a
	 * NetStream.Play.Stop event in <code>rtmpOnStatus</code> after
	 * stream is rewound if it is not a live stream.  Still need to
	 * get a http solution.</p>
	 *
	 * @private
	 */
	private function doAutoResize():Void {
		//ifdef DEBUG
		//debugTrace("doAutoResize(), _video.width = " + _video.width + ", _video.height = " + _video.height);
		//endif

		if (_autoResizeIntervalID > 0) {
			switch (_state) {
			case RESIZING:
			case LOADING:
				break;
			case DISCONNECTED:
			case CONNECTION_ERROR:
				// autoresize will happen later automatically
				clearInterval(_autoResizeIntervalID);
				_autoResizeIntervalID = 0;
				return;
			default:
				if (!stateResponsive) {
					// keep trying until we get into a responsive state
					return;
				}
			}
			if ( _video.width != _prevVideoWidth || _video.height != _prevVideoHeight ||
			     _bufferState == BUFFER_FULL || _bufferState == BUFFER_FLUSH ||
			     _ns.time > AUTO_RESIZE_PLAYHEAD_TIMEOUT ) {
				// if have not received metadata yet, slight delay to avoid race condition in player
				// but there may not be any metadata, so cannot wait forever
				if (_hiddenForResize && _metadata == null && _hiddenForResizeMetadataDelay < AUTO_RESIZE_METADATA_DELAY_MAX) {
					//ifdef DEBUG
					//debugTrace("Delaying for metadata: " + _hiddenForResizeMetadataDelay);
					//endif
					_hiddenForResizeMetadataDelay++;
					return;
				}
				_videoWidth = _video.width;
				_videoHeight = _video.height;
				clearInterval(_autoResizeIntervalID);
				_autoResizeIntervalID = 0;
			} else {
				// keep trying until our size is set
				return;
			}
		}
		// do not need to do autoresize, but DO need to signal readyness
		if ((!_autoSize && !_aspectRatio) || _autoResizeDone) {
			setState(_cachedState);
			return;
		}
		//ifdef DEBUG
		//debugTrace("Actually doing autoResize, _videoWidth = " + _videoWidth + ", _videoHeight = " + _videoHeight);
		//endif
		_autoResizeDone = true;
		if (_autoSize) {
			_video._width = _videoWidth;
			_video._height = _videoHeight;
		} else if (_aspectRatio) {
			var newWidth:Number = (_videoWidth * height / _videoHeight);
			var newHeight:Number = (_videoHeight * width / _videoWidth);
			if (newHeight < height) {
				_video._height = newHeight;
			} else if (newWidth < width) {
				_video._width = newWidth;
			}
		}
		if (_hiddenForResize) {
			_hiddenRewindPlayheadTime = playheadTime;
			if (_state == LOADING) {
				_cachedState = PLAYING;
			}
			if (!_ncMgr.isRTMP()) {
				_pause(true);
				_seek(0);
				clearInterval(_finishAutoResizeIntervalID);
				_finishAutoResizeIntervalID = setInterval(this, "finishAutoResize", FINISH_AUTO_RESIZE_INTERVAL);
			} else if (!_isLive) {
				_currentPos = 0;
				_play(0, 0);
				setState(RESIZING)
			} else if (_autoPlay) {
				clearInterval(_finishAutoResizeIntervalID);
				_finishAutoResizeIntervalID = setInterval(this, "finishAutoResize", FINISH_AUTO_RESIZE_INTERVAL);
			} else {
				finishAutoResize();
			}
		} else {
			dispatchEvent({type:"resize", x:_x, y:_y, width:_width, height:_height});
		}
	}

	/**
	 * <p>Makes video visible, turns on sound and starts
	 * playing if live or autoplay.</p>
	 */
	private function finishAutoResize():Void {
		//ifdef DEBUG
		//debugTrace("finishAutoResize()");
		//endif
		clearInterval(_finishAutoResizeIntervalID);
		_finishAutoResizeIntervalID = 0;
		if (stateResponsive) return;
		_visible = __visible;
		_sound.setVolume(_volume);
		_hiddenForResize = false;
		//ifdef DEBUG
		//debugTrace("_autoPlay = " + _autoPlay);
		//endif
		dispatchEvent({type:"resize", x:_x, y:_y, width:_width, height:_height});
		if (_autoPlay) {
			if (_ncMgr.isRTMP()) {
				if (!_isLive) {
					_currentPos = 0;
					_play(0);
				}
				if (_state == RESIZING) {
					setState(LOADING);
					_cachedState = PLAYING;
				}
			} else {
				_pause(false);
				_cachedState = PLAYING;
			}
		} else {
			setState(STOPPED);
		}
	}

	/**
	 * <p>Creates <code>NetStream</code> and does some basic
	 * initialization.</p>
	 *
	 * @private
	 */
	private function _createStream():Void {
		//ifdef DEBUG
		//debugTrace("_createStream()");
		//endif
		_ns = new NetStream(_ncMgr.getNetConnection());
		_ns.mc = this;
		if (_ncMgr.isRTMP()) {
			_ns.onStatus = function(info:Object):Void { this.mc.rtmpOnStatus(info); };
		} else {
			_ns.onStatus = function(info:Object):Void { this.mc.httpOnStatus(info); };
		}
		_ns.onMetaData = function (info:Object) { this.mc.onMetaData(info); };
		_ns.onCuePoint = function (info:Object) { this.mc.onCuePoint(info); };
		_ns.setBufferTime(_bufferTime);
	}

	/**
	 * <p>Does initialization after first connecting to the server
	 * and creating the stream.  Will get the stream duration from
	 * the <code>INCManager</code> if it has it for us.</p>
	 *
	 * <p>Starts resize if necessary, otherwise starts playing if
	 * necessary, otherwise loads first frame of video.  In http case,
	 * starts progressive download in any case.</p>
	 *
	 * @private
	 */
	private function _setUpStream():Void {
		//ifdef DEBUG
		//debugTrace("_setUpStream()");
		//endif

		_video.attachVideo(_ns);
		this.attachAudio(_ns);

		// INCManager MIGHT have gotten the stream length, width and height for
		// us.  If its length is null, undefined or < 0, then it did not.
		if ( !isNaN(_ncMgr.getStreamLength()) && _ncMgr.getStreamLength() >= 0 ) {
			_streamLength = _ncMgr.getStreamLength();
		}
		if ( !isNaN(_ncMgr.getStreamWidth()) && _ncMgr.getStreamWidth() >= 0 ) {
			_videoWidth = _ncMgr.getStreamWidth();
		} else {
			_videoWidth = undefined;
		}
		if ( !isNaN(_ncMgr.getStreamHeight()) && _ncMgr.getStreamHeight() >= 0 ) {
			_videoHeight = _ncMgr.getStreamHeight();
		} else {
			_videoHeight = undefined;
		}

		// resize immediately if height and width set above
		if ((_autoSize || _aspectRatio) && _videoWidth != undefined && _videoHeight != undefined) {
			_prevVideoWidth = undefined;
			_prevVideoHeight = undefined;
			doAutoResize();
		}

		// just start if static, start resize otherwise
		if ((!_autoSize && !_aspectRatio) || (_videoWidth != undefined && _videoHeight != undefined)) {
			if (_autoPlay) {
				if (!_ncMgr.isRTMP()) {
					_cachedState = BUFFERING;
					_play();
				} else if (_isLive) {
					_cachedState = BUFFERING;
					_play(-1);
				} else {
					_cachedState = BUFFERING;
					_play(0);
				}
			} else {
				_cachedState = STOPPED;
				if (_ncMgr.isRTMP()) {
					_play(0, 0);
				} else {
					_play();
					_pause(true);
					_seek(0);
				}
			}
		} else {
			if (!_hiddenForResize) {
				__visible = _visible;
				_visible = false;
				_volume = _sound.getVolume();
				_sound.setVolume(0);
				_hiddenForResize = true;
			}
			_hiddenForResizeMetadataDelay = 0;
			_play(0);
			if (_currentPos > 0) {
				_seek(_currentPos);
				_currentPos = 0;
			}
		}
		clearInterval(_autoResizeIntervalID);
		_autoResizeIntervalID = setInterval(this, "doAutoResize", AUTO_RESIZE_INTERVAL);
	}

	/**
	 * <p>ONLY CALL THIS WITH RTMP STREAMING</p>
	 *
	 * <p>Only used for rtmp connections.  When we pause or stop,
	 * setup an interval to call this after a delay (see property
	 * <code>idleTimeout</code>).  We do this to spare the server from
	 * having a bunch of extra xns hanging around, although this needs
	 * to be balanced with the load that creating connections puts on
	 * the server, and keep in mind that FCS can be configured to
	 * terminate idle connections on its own, which is a better way to
	 * manage the issue.</p>
	 *
	 * @private
	 */
	private function doIdleTimeout():Void
	{
		//ifdef DEBUG
		//debugTrace("Closing NetConnection NOW");
		//endif
		clearInterval(_idleTimeoutIntervalID);
		_idleTimeoutIntervalID = 0;
		close();
	}

	/**
	 * Dumps all queued commands without executing them
	 *
	 * @private
	 */
	private function flushQueuedCmds():Void {
		//ifdef DEBUG
		//debugTrace("flushQueuedCmds()");
		//endif
		while (_cmdQueue.length > 0) _cmdQueue.pop();
	}

	/**
	 * Executes as many queued commands as possible, obviously
	 * stopping when state becomes unresponsive.
	 *
	 * @private
	 */
	private function execQueuedCmds():Void {
		//ifdef DEBUG
		//debugTrace("execQueuedCmds()");
		//endif
		while ( _cmdQueue.length > 0 && (stateResponsive || _state == CONNECTION_ERROR) &&
		        ( (_cmdQueue[0].url != null) || (_state != DISCONNECTED && _state != CONNECTION_ERROR) ) ) {
			//ifdef DEBUG
			//debugTrace("Exec Queued Command!");
			//endif
			var nextCmd:Object = _cmdQueue.shift();
			_cachedState = _state;
			_state = EXEC_QUEUED_CMD;
			switch (nextCmd.type) {
			case PLAY:
				this.play(nextCmd.url, nextCmd.isLive, nextCmd.time);
				break;
			case LOAD:
				this.load(nextCmd.url, nextCmd.isLive, nextCmd.time);
				break;
			case PAUSE:
				this.pause();
				break;
			case STOP:
				this.stop();
				break;
			case SEEK:
				this.seek(nextCmd.time);
				break;
			} // switch
		}
	}

	private function queueCmd( type:Number, url:String, isLive:Boolean, time:Number):Void {
		//ifdef DEBUG
		//debugTrace("queueCmd(" + type + ", " + url + ", " + isLive + ", " + time + ")");
		//endif
		_cmdQueue.push( {type:type, url:url, isLive:isLive, time:time} );
	}

	//ifdef DEBUG
	//function debugTrace(s:String):Void {
	//if (_parent != null) {
	//	_parent.debugTrace(s);
	//}
	//}
	//endif

} // class mx.video.VideoPlayer
