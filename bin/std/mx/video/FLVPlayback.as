// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.

import mx.events.EventDispatcher;
import mx.utils.Delegate;
import mx.video.*;

/**
 * <p>Event dispatched when <code>FLVPlayback.BUFFERING</code> state
 * entered.  This state is typically entered immediately after
 * <code>play()</code> is called or the corresponding control is
 * clicked, before the playing state is entered.  Event Object has
 * properties state and playheadTime.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * <p>"stateChange" event will also be dispatched.</p>
 *
 * @see #BUFFERING
 * @see #play()
 * @tiptext buffering event
 * @helpid ???
 */
[Event("buffering")]

/**
 * <p>Event dispatched when <code>NetConnection</code> is closed,
 * whether by being timed out or by calling <code>close()</code>
 * API.  Only ever dispatched when streaming from FCS or FVSS.
 * Event Object has properties state and playheadTime.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @tiptext close event
 * @helpid 3482
 */
[Event("close")]

/**
 * <p>Event dispatched when playing completes by reaching the end of
 * the FLV.  Is not dispatched if the APIs <code>stop()</code> or
 * <code>pause()</code> are called or the corresponding controls are
 * clicked.  Event Object has properties state and playheadTime.</p>
 *
 * <p>When using progressive download and not setting totalTime
 * explicitly and downloading an FLV with no metadata duration,
 * the totalTime will be set to an approximate total value, now
 * that we have played the whole file we can make a guess.  That
 * value is set by the time this event is dispatched.</p>
 *
 * <p>"stateChange" and "stopped" events will also be dispatched.</p>
 *
 * @tiptext complete event
 * @helpid 3482
 */
[Event("complete")]

/**
 * <p>Event dispatched when a cue point is reached.  Event Object has an
 * info property that contains the info object received by the
 * <code>NetStream.onCuePoint</code> callback for FLV cue points or
 * the object passed into the AS cue point APIs for AS cue points.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @tiptext cuePoint event
 * @helpid 3483
 */
[Event("cuePoint")]

/**
 * <p>Event dispatched when location of playhead is moved forwards by a call
 * to <code>seek()</code>.  The <code>playheadTime</code> property
 * will reflect the destination time.  Event Object has properties state and
 * playheadTime.</p>
 *
 * <p>"seek" will be dispatched.  "playheadUpdate" will be
 * dispatched.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @see #seek()
 * @tiptext fastForward event
 * @helpid ???
 */
[Event("fastForward")]

/**
 * <p>Event dispatched the first time the FLV metadata is reached.
 * Event Object has an info property that contains the info object
 * received by the <code>NetStream.onMetaData</code> callback.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @tiptext metadataReceived event
 */
[Event("metadataReceived")]

/**
 * <p>Event dispatched when pause state entered.  This happens when the
 * <code>pause()</code> API is called or the correpsonding control is
 * clicked and also happens in some cases when the FLV is loaded if
 * autoPlay is false (state may go to stopped instead).  Event Object has
 * properties state and playheadTime.</p>
 *
 * <p>"stateChange" event will also be dispatched.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @see #PAUSED
 * @see #pause()
 * @tiptext paused event
 * @helpid 3489
 */
[Event("paused")]

/**
 * <p>Event dispatched when play state entered.  This may not occur
 * immediately after the <code>play()</code> API is called or
 * corresponding control is clicked; often the buffering state is
 * entered first, and then playing.  Event Object has properties state and
 * playheadTime.</p>
 *
 * <p>"stateChange" event will also be dispatched.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @see #PLAYING
 * @see #play()
 * @tiptext playing event
 * @helpid ???
 */
[Event("playing")]

/**
 * <p>While FLV is playing, this event is dispatched every .25
 * seconds.  Not dispatched when we are paused or stopped, unless a
 * seek occurs.  Event Object has properties state and playheadTime.</p>
 *
 * @tiptext change event
 * @helpid 3480
 */
[Event("playheadUpdate")]

/**
 * <p>Indicates progress made in number of bytes downloaded.  User can
 * use this to check bytes loaded or number of bytes in the buffer.
 * Fires every .25 seconds, starting when load is called and ending
 * when all bytes are loaded or if there is a network error.  Event Object is
 * of type <code>mx.events.ProgressEvent</code>.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @tiptext progress event
 * @helpid 3485
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
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 */
[Event("ready")]

/**
 * <p>Event dispatched when video is resized.  Event Object has
 * properties x, y, width, height, auto and vp, index number of
 * VideoPlayer to which this event applies.  See activeVideoPlayerIndex and
 * visibleVideoPlayerIndex.</p>
 *
 * <p>Auto is true when resize is automatic due to maintainAspectRatio
 * or autoSize set to true.  In this case, the event may be firing for
 * a VideoPlayer other than the visible VideoPlayer.  May be
 * dispatched even if the dimensions were not actually changed after
 * an attempt to autoresize occurs.</p>
 * 
 * <p>When auto is false, the event always applies to the visible
 * VideoPlayer.  The vp property still appears, but will always be
 * equal to visibleVideoPlayerIndex.</p>
 *
 * <p>Will be triggered (with auto = fals) when setting
 * visibleVideoPlayerIndex if switching to a player with different
 * dimensions than the currently visible player.</p>
 *
 * @tiptext resize event
 * @helpid ????
 */
[Event("resize")]

/**
 * <p>Event dispatched when location of playhead is moved backward by
 * a call to <code>seek()</code> or when the an autoRewind is
 * completed.  The <code>playheadTime</code> property will reflect the
 * destination time.  Event Object has properties auto, state and
 * playheadTime.  Property auto is true if event was triggered by
 * autoRewind, false otherwise.</p>
 *
 * <p>"stateChange" event will be dispatched with a state of
 * <code>FLVPlayback.REWINDING</code> when the autoRewind is
 * triggered; this event will not fire until it has completed.
 * "seek" will be dispatched when there is a seek.  "playheadUpdate"
 * will be dispatched.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @see #REWINDING
 * @see #autoRewind
 * @see #seek()
 * @tiptext rewind event
 * @helpid ???
 */
[Event("rewind")]

/**
 * <p>Event dispatched when user finishes scrubbing timeline with
 * seekbar.  Event object has properties state and playheadTime.</p>
 *
 * <p>Event "stateChange" will also be dispatched with new state
 * (should be PLAYING, PAUSED, STOPPED or BUFFERING).  State will
 * be <code>SEEKING</code> until user finishes scrubbing.</p>
 */
[Event("scrubFinish")]

/**
 * <p>Event dispatched when user starts scrubbing timeline with
 * seekbar.  Event object has properties state and playheadTime.</p>
 *
 * <p>Event "stateChange" will also be dispatched with state
 * <code>SEEKING</code>.  State will remain <code>SEEKING</code>
 * while user is scrubbing.</p>
 */
[Event("scrubStart")]

/**
 * <p>Event dispatched when location of playhead is changed by a call to
 * <code>seek()</code> or by using the corresponding control.  The
 * <code>playheadTime</code> property will reflect the destination
 * time.  Event Object has properties state and playheadTime.</p>
 *
 * <p>"stateChange" event also may be dispatched, but may not.
 * "rewind" will be dispatched when the seek is backwards and
 * "fastForward" will be dispatched when the seek is forwards.
 * "playheadUpdate" will be dispatched.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @see #seek()
 * @tiptext seek event
 * @helpid ???
 */
[Event("seek")]

/**
 * <p>Event dispatched when error occurs loading skin swf.  Has
 * message property with error message.  If a skin swf is set,
 * playback will not begin until "ready" event and "skinLoaded" (or
 * "skinError") event have both fired.</p>
 *
 * @see #skin
 */
[Event("skinError")]

/**
 * <p>Event dispatched when skin swf is loaded.  No properties (other
 * than normal target property).  If a skin swf is set, playback will
 * not begin until "ready" event and "skinLoaded" (or "skinError")
 * event have both fired.</p>
 *
 * @see #skin
 */
[Event("skinLoaded")]

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
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @see #state
 */
[Event("stateChange")]

/**
 * <p>Event dispatched when <code>FLVPlayback.STOPPED</code> state entered.
 * This happens when the <code>stop()</code> API is called or the
 * corresponding control is clicked and also happens in some cases
 * when the FLV is loaded if autoPlay is false (state may go to paused
 * instead).  The event is also dispatched when the playhead stops
 * because it has reached the end of the timeline.  Event Object has
 * properties state and playheadTime.</p>
 *
 * <p>"stateChange" event will also be dispatched.</p>
 *
 * <p>Event has property vp, index number of VideoPlayer to which this
 * event applies.  See activeVideoPlayerIndex and visibleVideoPlayerIndex.</p>
 *
 * @see #STOPPED
 * @see #stop()
 * @tiptext stopped event
 * @helpid 3487
 */
[Event("stopped")]

/**
 * <p>Event dispatched when volume is changed by changing
 * <code>volume</code> property (a.k.a. by user).
 * Event Object has a volume property.</p>
 *
 * @tiptext volumeUpdate event
 * @helpid 3486
 */
[Event("volumeUpdate")]

[IconFile("FLVPlayback.png")]
[minimumPlayerVersion("8")]
[RequiresDataBinding(true)]
[LivePreviewVersion("1")]

/**
 * <p>FLVPlayback extends MovieClip and wraps a VideoPlayer object.
 * It also "extends" EventDispatcher using mixins.</p>
 *
 * @author copyright 2004-2005 Macromedia, Inc.
 * @tiptext	FLVPlayback
 * @helpid ???
 */

class mx.video.FLVPlayback extends MovieClip {

	#include "ComponentVersion.as"

	//
	// public state constants
	//

	/**
	 * <p>State constant.  This is the state when the VideoPlayer is
	 * constructed and when the stream is closed by a call to
	 * <code>close()</code> or timed out on idle.</p>
	 *
	 * <p>This is a responsive state.</p>
	 *
	 * @see #state
	 * @see #stateResponsive
	 * @see #idleTimeout
	 * @see #closeVideoPlayer()
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
	 * @see #stopped
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
	 * @see #playing
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
	 * @see #paused
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
	 * @see #buffering
	 * @see #state
	 * @see #stateResponsive
	 */
	public static var BUFFERING:String = "buffering";

	/**
	 * <p>State constant.  State entered immediately after
	 * <code>play()</code> or <code>load()</code> is called or
	 * after <code>contentPath</code> property is set.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #contentPath
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
	 * is called and also while user is scrubbing with seek bar.</p>
	 *
	 * <p>This is a unresponsive state.</p>
	 *
	 * @see #stateResponsive
	 * @see #state
	 * @see #seek()
	 */
	public static var SEEKING:String = "seeking";

	/**
	 * Constant passed into findCuePoint or findNearestCuePoint type parameter.
	 */
	public static var ALL = "all";

	/**
	 * Constant passed into findCuePoint or findNearestCuePoint type parameter.
	 */
	public static var EVENT = "event";

	/**
	 * Constant passed into findCuePoint or findNearestCuePoint type parameter.
	 */
	public static var NAVIGATION = "navigation";

	/**
	 * Constant passed into findCuePoint or findNearestCuePoint type parameter.
	 */
	public static var FLV = "flv";

	/**
	 * Constant passed into findCuePoint or findNearestCuePoint type parameter.
	 */
	public static var ACTIONSCRIPT = "actionscript";

	//
	// private instance vars
	//

	/**
	 * bounding box movie clip inside of component on stage
	 *
	 * @private
	 */
	public var boundingBox_mc:MovieClip;

	// live preview movie clip
	private var preview_mc:MovieClip;

	// the VideoPlayers
	private var _vp:Array;
	var _vpState:Array;
	private var _activeVP:Number;
	private var _visibleVP:Number;
	private var _topVP:Number;
	private static var VP_DEPTH_OFFSET:Number = 100;

	// the UIManager
	private var _uiMgr:UIManager;

	// the CuePointManagers (one for each VideoPlayer)
	private var _cpMgr:Array;

	// state
	private var _preSeekTime:Number;
	private var _firstStreamReady:Boolean;
	private var _firstStreamShown:Boolean; // true once we have shown the first stream

	// properties
	private var _autoPlay:Boolean;
	private var _autoRewind:Boolean;
	private var _autoSize:Boolean;
	private var _bufferTime:Number;
	private var _contentPath:String;
	private var _cuePoints:Array;
	private var _idleTimeout:Number;
	private var _isLive:Boolean;
	private var _aspectRatio:Boolean;
	private var _playheadUpdateInterval:Number;
	private var _progressInterval:Number;
	private var _origWidth:Number;
	private var _origHeight:Number;
	private var _scaleX:Number;
	private var _scaleY:Number;
	private var _seekToPrevOffset:Number;
	private var _totalTime:Number;
	private var _transform:Object;
	private var _volume:Number;
	private var __height:Number;
	private var __width:Number;

	// cache properties set directly on UIManager
	private var _backButton:MovieClip;
	private var _bufferingBar:MovieClip;
	private var _bufferingBarHides:Boolean;
	private var _forwardButton:MovieClip;
	private var _pauseButton:MovieClip;
	private var _playButton:MovieClip;
	private var _playPauseButton:MovieClip;
	private var _seekBar:MovieClip;
	private var _seekBarInterval:Number;
	private var _seekBarScrubTolerance:Number;
	private var _skin:String;
	private var _skinAutoHide:Boolean;
	private var _stopButton:MovieClip;
	private var _muteButton:MovieClip;
	private var _volumeBar:MovieClip;
	private var _volumeBarInterval:Number;
	private var _volumeBarScrubTolerance:Number;

	// EventDispatcher mixins
	public var addEventListener:Function;
	public var removeEventListener:Function;
	public var dispatchEvent:Function;
	public var dispatchQueue:Function;

	// this line forces compilation of the NCManager
	private var __forceNCMgr:NCManager;

	//ifdef DEBUG
	///**
	// * @private
	// */
	//var _debuggingOn:Boolean = false;
	///**
	// * @private
	// */
	//var _debugFn:Function = null;
	//endif

	// when seekToPrevNavCuePoint compares its time against the
	// previous cue point, it uses this delta to be sure that if
	// you are just ahead of a cue point, you can hop over it to
	// the previous and not get stuck going to the same one over
	// and over if you are playing.  In seconds
	private static var SEEK_TO_PREV_OFFSET_DEFAULT:Number = 1;

	//
	// public methods
	//

	/**
	 * constructor
	 */
	public function FLVPlayback() {
		// add EventDispatcher mixins
		EventDispatcher.initialize(this);

		// set properties to defaults note that these faults are
		// in line with the VideoPlayer defaults, so they do not
		// have to be set on the VideoPlayer object as well.
		if (_autoPlay == undefined) _autoPlay = true;
		if (_autoRewind == undefined) _autoRewind = true;
		if (_autoSize == undefined) _autoSize = false;
		if (_bufferTime == undefined) _bufferTime = 0.1;
		if (_contentPath == undefined) _contentPath = "";
		if (_cuePoints == undefined) _cuePoints = null;
		if (_idleTimeout == undefined) _idleTimeout = VideoPlayer.DEFAULT_IDLE_TIMEOUT_INTERVAL;
		if (_isLive == undefined) _isLive = false;
		if (_aspectRatio == undefined) _aspectRatio = true;
		if (_seekToPrevOffset == undefined) _seekToPrevOffset = SEEK_TO_PREV_OFFSET_DEFAULT;
		if (_playheadUpdateInterval == undefined) _playheadUpdateInterval = VideoPlayer.DEFAULT_UPDATE_PROGRESS_INTERVAL;
		if (_progressInterval == undefined) _progressInterval = VideoPlayer.DEFAULT_UPDATE_TIME_INTERVAL;
		if (_totalTime == undefined) _totalTime = 0;
		if (_transform == undefined) _transform = null;
		if (_volume == undefined) _volume = 100;
		if (_skinAutoHide == undefined) _skinAutoHide = false;
		if (_bufferingBarHides == undefined) _bufferingBarHides = false;

		// have to manage our own height and width and set scale
		// to 100 otherwise VideoPlayer and skins within component
		// will be scaled.
		_origHeight = __height = this._height;
		_origWidth = __width = this._width;
		_scaleX = 100;
		_scaleY = 100;
		this._xscale = 100;
		this._yscale = 100;

		// state
		_preSeekTime = -1;
		_firstStreamReady = false;
		_firstStreamShown = false;
		
		// create UIManager
		createUIManager();

		// create VideoPlayer and CuePointManager
		_activeVP = 0;
		_visibleVP = 0;
		_topVP = 0;
		_vp = new Array();
		_vpState = new Array();
		_cpMgr = new Array();
		createVideoPlayer(0);
		// hide until skin and stream ready
		_vp[0].visible = false;
		_vp[0].volume = 0;

		// remove boundingBox_mc
		boundingBox_mc._visible = false;
		boundingBox_mc.unloadMovie();
		delete boundingBox_mc;

		// setup live preview look
		if (_global.isLivePreview) {
			createLivePreviewMovieClip();
			setSize(__width, __height);
		}

		// if cuePoints property set, add and disable now that CuePointManager is created
		_cpMgr[0].processCuePointsProperty(_cuePoints);
		delete _cuePoints;
		_cuePoints = null;
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
		if (_global.isLivePreview) {
			if (preview_mc == undefined) createLivePreviewMovieClip();
			preview_mc.box_mc._width = w;
			preview_mc.box_mc._height = h;
			if ( preview_mc.box_mc._width < preview_mc.icon_mc._width ||
			     preview_mc.box_mc._height < preview_mc.icon_mc._height ) {
				preview_mc.icon_mc._visible = false;
			} else {
				preview_mc.icon_mc._visible = true;
				preview_mc.icon_mc._x = (preview_mc.box_mc._width - preview_mc.icon_mc._width) / 2;
				preview_mc.icon_mc._y = (preview_mc.box_mc._height - preview_mc.icon_mc._height) / 2;
			}
		}
		if (w == width && h == height) return;
		__width = w;
		__height = h;
		for (var i:Number = 0; i < _vp.length; i++) {
			if (_vp[i] != undefined) {
				_vp[i].setSize(w, h);
			}
		}
		dispatchEvent({type:"resize", x:this.x, y:this.y, width:w, height:h});
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
		if (xs == scaleX && ys == scaleY) return;
		_scaleX = xs;
		_scaleY = ys;
		for (var i:Number = 0; i < _vp.length; i++) {
			if (_vp[i] != undefined) {
				_vp[i].setSize(_origWidth * xs / 100, _origHeight * ys / 100);
			}
		}
		dispatchEvent({type:"resize", x:this.x, y:this.y, width:this.width, height:this.height});
	}

	/**
	 * handles events
	 *
	 * @private
	 */
	private function handleEvent(e:Object):Void {
		var eventState:String = e.state;
		if (e.state != undefined && e.target._name == _visibleVP && scrubbing) {
			eventState = SEEKING;
		}
		if (e.type == "metadataReceived") {
			_cpMgr[e.target._name].processFLVCuePoints(e.info.cuePoints);
			dispatchEvent({type:e.type, info:e.info, vp:e.target._name});
		} else if (e.type == "cuePoint") {
			if (_cpMgr[e.target._name].isFLVCuePointEnabled(e.info)) {
				dispatchEvent({type:e.type, info:e.info, vp:e.target._name});
			}
		} else if (e.type == "rewind") {
			dispatchEvent({type:e.type, auto:true, state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
			_cpMgr[e.target._name].resetASCuePointIndex(e.playheadTime);
		} else if (e.type == "resize") {
			dispatchEvent({type:e.type, x:x, y:y, width:width, height:height, auto:true, vp:e.target._name});
		} else if (e.type == "playheadUpdate") {
			dispatchEvent({type:e.type, state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
			if (_preSeekTime >= 0 && e.target.state != SEEKING) {
				var preSeekTime:Number = _preSeekTime;
				_preSeekTime = -1;
				_cpMgr[e.target._name].resetASCuePointIndex(e.playheadTime);
				dispatchEvent({type:"seek", state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
				if (preSeekTime < e.playheadTime) {
					dispatchEvent({type:"fastForward", state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
				} else if (preSeekTime > e.playheadTime) {
					dispatchEvent({type:"rewind", auto:false, state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
				}
			}
			_cpMgr[e.target._name].dispatchASCuePoints();
		} else if (e.type == "stateChange") {
			var whichVP:Number = e.target._name;

			// suppress stateChange events while scrubbing
			if (whichVP == _visibleVP && scrubbing) return;

			// suppress RESIZING state, just needed for internal
			// VideoPlayer use anyways, make it LOADING, less confusing
			// for user, esp when suppressing STOPPED as we do below...
			if (e.state == VideoPlayer.RESIZING) return;

			// suppress STOPPED stateChange at beginning when autoPlay
			// is on and waiting for skin to download to show all at once
			if (_vpState[whichVP].prevState == LOADING && _vpState[whichVP].autoPlay && e.state == STOPPED) {
				return;
			}

			_vpState[whichVP].prevState = e.state;
			dispatchEvent({type:e.type, state:eventState, playheadTime:e.playheadTime, vp:e.target._name});

			// check to be sure did not change out from under me before dispatching second event
			if (_vp[e.target._name].state != eventState) return;

			switch (eventState) {
			case BUFFERING:
				dispatchEvent({type:"buffering", state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
				break;
			case PAUSED:
				dispatchEvent({type:"paused", state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
				break;
			case PLAYING:
				dispatchEvent({type:"playing", state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
				break;
			case STOPPED:
				dispatchEvent({type:"stopped", state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
				break;
			} // switch

		} else if (e.type == "progress") {
			dispatchEvent({type:e.type, bytesLoaded:e.bytesLoaded, bytesTotal:e.bytesTotal, vp:e.target._name});
		} else if(e.type == "ready") {
			var whichVP:Number = e.target._name;
			if (!_firstStreamReady) {
				if (whichVP == _visibleVP) {
					_firstStreamReady = true;
					if (_uiMgr.skinReady && !_firstStreamShown) {
						_uiMgr.visible = true;
						showFirstStream();
					}
				}
			} else if (_firstStreamShown && eventState == STOPPED && _vpState[whichVP].autoPlay) {
				_vp[whichVP].play();
			}
			dispatchEvent({type:e.type, state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
		} else if (e.type == "close" || e.type == "complete") {
			dispatchEvent({type:e.type, state:eventState, playheadTime:e.playheadTime, vp:e.target._name});
		}
	}

	/**
	 * <p>Shortcut for setting property <code>autoPlay</code> to false
	 * and setting isLive, totalTime and contentPath properties if
	 * given.  If totalTime and/or isLive properties are undefined
	 * then they will not be set.  If contentPath is undefined, null
	 * or empty string then this function does nothing.</p>
	 *
	 * @param contentPath
	 * @param totalTime
	 * @param isLive
	 */
	public function load(contentPath:String, totalTime:Number, isLive:Boolean):Void {
		if (_vp[_activeVP] == undefined) return;
		if (contentPath == null || contentPath == "") {
			return;
		}
		this.autoPlay = false;
		if (totalTime != undefined) this.totalTime = totalTime;
		if (isLive != undefined) this.isLive = isLive;
		this.contentPath = contentPath;
	}

	/**
	 * <p>play.  With no args, just takes FLV from paused or stop
	 * state to play state.</p>
	 *
	 * <p>With args, acts as a shortcut for setting property
	 * <code>autoPlay</code> to true and setting isLive, totalTime and
	 * contentPath properties if given.  If totalTime and/or isLive
	 * properties are undefined then they will not be set.</p>
	 *
	 * @param contentPath
	 * @param totalTime
	 * @param isLive
	 */
	public function play(contentPath:String, totalTime:Number, isLive:Boolean):Void {
		if (_vp[_activeVP] == undefined) return;
		if (contentPath == undefined) {
			_vp[_activeVP].play();
		} else {
			this.autoPlay = true;
			if (totalTime != undefined) this.totalTime = totalTime;
			if (isLive != undefined) this.isLive = isLive;
			this.contentPath = contentPath;
		}
	}

	/**
	 * pause
	 */
	public function pause():Void {
		if (_vp[_activeVP] == undefined) return;
		_vp[_activeVP].pause();
	}

	/**
	 * stop
	 */
	public function stop():Void {
		if (_vp[_activeVP] == undefined) return;
		_vp[_activeVP].stop();
	}

	/**
	 * <p>Seeks to a given time in the file, given in seconds,
	 * decimal precision up to milliseconds.</p>
	 *
	 * @throws VideoError if time is < 0
	 * @see VideoPlayer#seek()
	 */
	public function seek(time:Number):Void {
		if (_vp[_activeVP] == undefined) return;
		_preSeekTime = playheadTime;
		_vp[_activeVP].seek(time);
	}

	/**
	 * <p>Same as <code>seek()</code></p>
	 *
	 * @see #seek()
	 */
	public function seekSeconds(time:Number):Void {
		seek(time);
	}

	/**
	 * <p>Seeks to a percentage of the way through the file.
	 * Takes a number between 0 and 100.</p>
	 *
	 * @throws VideoError if percent is invalid or if totalTime is
	 * undefined, null or <= 0
	 * @see #seek()
	 */
	public function seekPercent(percent:Number):Void {
		if (_vp[_activeVP] == undefined) return;
		if ( percent < 0 || percent > 100 ||
		     _vp[_activeVP].totalTime == null ||
		     _vp[_activeVP].totalTime <= 0 ) {
			throw new VideoError(VideoError.INVALID_SEEK);
		}
		seek(_vp[_activeVP].totalTime * percent / 100);
	}
	
	/**
	 * <p>Gets the percentage played.
	 * Returns a number between 0 and 100.</p>
	 *
	 */
	public function get playheadPercentage():Number
	{
		if ( _vp[_activeVP].totalTime == null ||
		     _vp[_activeVP].totalTime <= 0 ) {
			return undefined;
		}
		return _vp[_activeVP].playheadTime / _vp[_activeVP].totalTime * 100;
	}
	
	/**
	 * <p>Seeks to a percentage of the way through the file.
	 * Takes a number between 0 and 100.</p>
	 *
	 * @throws VideoError if percent is invalid or if totalTime is
	 * undefined, null or <= 0
	 * @see #seek()
	 */
	public function set playheadPercentage(percent:Number)
	{
		seekPercent(percent);
	}

	/**
	 * <p>Seeks to navigation cue point with the given name at or
	 * after given time.  Starts search at time 0 if time is
	 * undefined, null or less than 0.  If name is undefined or null,
	 * behaves like seekToNextNavCuePoint().</p>
	 *
	 * @param timeNameOrCuePoint If String, then name of cue point to
	 * search for.  Seeks to first enabled navigation cue point with
	 * this name.
	 *
	 * <p>If Number, time of cue point to seek to.  If only time
	 * given, behaves like seekToNextNavCuePoint</p>
	 *
	 * <p>If Object, then cuepoint object containing time and/or name
	 * properties for search.  Seek to next cue point with this name
	 * at or after the given time.
	 * @throws VideoError if no cue point that matches criteria is found
	 * @see #seek()
	 * @see #seekToPrevNavCuePoint()
	 * @see #seekToNextNavCuePoint()
	 * @see #findCuePoint()
	 * @see #isFLVCuePointEnabled()
	 */
	public function seekToNavCuePoint(timeNameOrCuePoint:Object):Void {
		var cuePoint:Object;
		switch (typeof timeNameOrCuePoint) {
		case "string":
			cuePoint = {name:timeNameOrCuePoint};
			break;
		case "number":
			cuePoint = {time:timeNameOrCuePoint};
			break;
		case "object":
			cuePoint = timeNameOrCuePoint;
			break;
		} // switch

		// just seek to next if no name
		if ( cuePoint.name == null ||
		     typeof cuePoint.name != "string" ) {
			seekToNextNavCuePoint(cuePoint.time);
			return;
		}

		// get next enabled cue point with this name
		if (isNaN(cuePoint.time)) cuePoint.time = 0;
		var navCuePoint:Object = findNearestCuePoint(timeNameOrCuePoint, NAVIGATION);
		while ( navCuePoint != null &&
		        ( navCuePoint.time < cuePoint.time || (!isFLVCuePointEnabled(navCuePoint)) ) ) {
			navCuePoint = findNextCuePointWithName(navCuePoint);
		}
		if (navCuePoint == null) throw new VideoError(VideoError.INVALID_SEEK);
		seek(navCuePoint.time);
	}

	/**
	 * <p>Seeks to next navigation cue point, based on current
	 * playheadTime.  Goes to the end if there is no next cue
	 * point.  Navigation cue points disabled by ActionScript
	 * will be skipped.</p>
	 *
	 * @param time starting time from where to look for next
	 * navigation cue point.  Default is current playheadTime
	 * @see #cuePoints
	 * @see #seek()
	 * @see #seekToNavCuePoint()
	 * @see #seekToPrevNavCuePoint()
	 * @see #findCuePoint()
	 * @see #isFLVCuePointEnabled()
	 */
	public function seekToNextNavCuePoint(time:Number):Void {
		if (_vp[_activeVP] == undefined) return;
		if (isNaN(time) || time < 0) {
			time = _vp[_activeVP].playheadTime + 0.001;
		}
		var cuePoint:Object;
		cuePoint = findNearestCuePoint(time, NAVIGATION);
		if (cuePoint == null) {
			//if no cue points could be found, go to the end
			seek(_vp[_activeVP].totalTime);
			return;
		}
		var index:Number = cuePoint.index;
		if (cuePoint.time < time) index++;
		while (index < cuePoint.array.length && !isFLVCuePointEnabled(cuePoint.array[index])) {
			index++;
		}
		if (index >= cuePoint.array.length) {
			//if no cue points could be found, go to the end
			var seekTime:Number = _vp[_activeVP].totalTime;
			// if the last navigation point in the array is past what
			// we think is the end time, use that instead (even if
			// disabled).
			if (cuePoint.array[cuePoint.array.length - 1].time > seekTime) {
				seekTime = cuePoint.array[cuePoint.array.length - 1];
			}
			seek(seekTime);
		} else {
			seek(cuePoint.array[index].time);
		}
	}

	/**
	 * <p>Seeks to previous navigation cue point, based on current
	 * playheadTime.  Goes to beginning if there is no previous
	 * cue point.  Navigation cue points disabled by ActionScript
	 * will be skipped.</p>
	 *
	 * @param time starting time from where to look for next
	 * navigation cue point.  Default is current playheadTime
	 * @see #cuePoints
	 * @see #seek()
	 * @see #seekToNavCuePoint()
	 * @see #seekToNextNavCuePoint()
	 * @see #findCuePoint()
	 * @see #isFLVCuePointEnabled()
	 */
	public function seekToPrevNavCuePoint(time:Number):Void {
		if (_vp[_activeVP] == undefined) return;
		if (isNaN(time) || time < 0) {
			time = _vp[_activeVP].playheadTime;
		}
		var cuePoint:Object = findNearestCuePoint(time, NAVIGATION);
		if (cuePoint == null) {
			// if no cue points could be found, go to the beginning
			seek(0);
			return;
		}
		var index:Number = cuePoint.index;
		while ( index >= 0 &&
		        ( !isFLVCuePointEnabled(cuePoint.array[index]) ||
		          cuePoint.array[index].time >= time - _seekToPrevOffset ) ) {
			index--;
		}
		if (index < 0) {
			seek(0);
		} else {
			seek(cuePoint.array[index].time);
		}
	}

	/**
	 * <p>Add an ActionScript cue point.</p>
	 *
	 * <p>Cue point information is wiped out when contentPath property
	 * is set, so to set cue point info for the next FLV to be loaded,
	 * set contentPath first.</p>
	 *
	 * <p>It is legal to add multiple AS cue points with the same
	 * name and time.  When removeASCuePoint is called with this
	 * name and time, all will be removed.</p>
	 *
	 * @param timeOrCuePoint If Object, then object describing the cue
	 * point.  Must have a name:String and time:Number (in seconds)
	 * property.  May have a parameters:Object property that holds
	 * name/value pairs.  May have type:String set to "actionscript",
	 * if it is missing or set to something else it will be set
	 * automatically.  If the Object does not conform to these
	 * conventions, a <code>VideoError</code> will be thrown.
	 *
	 * <p>If Number, then time for new cue point to be added
	 * and name parameter must follow.</p>
	 * @param name Name for cuePoint if timeOrCuePoint parameter
	 * is a Number.
	 * @param parameters Optional parameters for cuePoint if
	 * timeOrCuePoint parameter is a Number.
	 * @returns The cuePoint Object added.  Read only: edits to this
	 * Object will effect "cuePoint" event dispatch.
	 * 
	 * @throws VideoError if parameters are invalid
	 * @see #findCuePoint()
	 * @see #removeASCuePoint()
	 * @see CuePointManager#addASCuePoint()
	 */
	public function addASCuePoint(timeOrCuePoint:Object, name:String, parameters:Object):Number {
		return _cpMgr[_activeVP].addASCuePoint(timeOrCuePoint, name, parameters);
	}

	/**
	 * <p>Remove an ActionScript cue point from the currently
	 * loaded FLV.  Only the name and time properties are used
	 * from the cuePoint parameter to find the cue point to be
	 * removed.</p>
	 *
	 * <p>If multiple AS cue points match the search criteria, only
	 * one will be removed.  To remove all, call this function
	 * repeatedly in a loop with the same parameters until it returns
	 * <code>null</code>.</p>
	 *
	 * <p>Cue point information is wiped out when contentPath property
	 * is set, so to set cue point info for the next FLV to be loaded,
	 * set contentPath first.</p>
	 *
	 * @param timeNameOrCuePoint If string, name of cue point to
	 * remove; remove first cue point with this name.  If number, time
	 * of cue point to remove; remove first cue point at this time.
	 * If Object, then object with name and time properties, remove
	 * cue point with both this name and time.
	 * @returns The cue point that was removed.  If there was no
	 * matching cue point then <code>null</code> is returned.
	 * @see #addASCuePoint()
	 * @see #findCuePoint()
	 * @see #removeASCuePoint()
	 */
	public function removeASCuePoint(timeNameOrCuePoint:Object):Object {
		return _cpMgr[_activeVP].removeASCuePoint(timeNameOrCuePoint);
	}

	/**
	 * <p>Find the cue point at the given time and/or with given name.
	 * Which type of cue points searched is determined by optional
	 * <code>type</code> parameter.  Default is to search all cue
	 * points.  Note that disabled cue points are also included in the
	 * search, use isFLVCuePointEnabled.  How the cue points are
	 * searched depends on the type of the first argument.</p>
	 *
	 * @param timeNameOrCuePoint If String, then name of cue point to
	 * search for.  Return the first cue point with this name, or null
	 * if no match.
	 *
	 * <p>If Number, time of cue point to search for.  Only first
	 * three decimal places of time used for search, any more than
	 * that will be rounded.  Returns the first cue point with this
	 * time (If there are multiples with same time, which is only
	 * possible with ActionScript cue points, then the one with the
	 * first name alphabetically will be returned.)  Returns null if
	 * no match.</p>
	 *
	 * <p>If Object, then cuepoint object containing time and/or name
	 * properties for search.  If name is undefined or null, then
	 * search behaves same as described above for time only search.
	 * If time is undefined, null or less than 0, then search behaves
	 * same as described above for name only search.  If both time
	 * and name are defined and a cue point exists with both that
	 * time and name, then it is returned, otherwise null is returned.</p>
	 *
	 * <p>If time is null, undefined or less than 0 and name is null
	 * or undefined, a VideoError is thrown.</p>
	 *
	 * @param type determines what class of cue points is searched.
	 * possible values are "all", "navigation", "event", "flv",
	 * "actionscript".  There are constants defined for each of these.
	 * 
	 * @returns <code>null</code> if no match was found, otherwise
	 * copy of cuePoint object with additional properties:
	 *
	 * <ul>
	 * 
	 * <li><code>array</code> - the array of cue points that was
	 * searched.  Treat this array as read only as adding, removing or
	 * editing objects within it can cause cue points to
	 * malfunction.</li>
	 *
	 * <li><code>index</code> - the index into the array for the
	 * returned cuepoint.</li>
	 *
	 * </ul>
	 * @see #ALL
	 * @see #EVENT
	 * @see #NAVIGATION
	 * @see #FLV
	 * @see #ACTIONSCRIPT
	 * @see #cuePoints
	 * @see #addASCuePoint()
	 * @see #removeASCuePoint()
	 * @see #findNearestCuePoint()
	 * @see CuePointManager#getCuePoint()
	 */
	public function findCuePoint(timeNameOrCuePoint:Object, type:String):Object {
		switch (type) {
		case "event":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].eventCuePoints, false, timeNameOrCuePoint);
		case "navigation":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].navCuePoints, false, timeNameOrCuePoint);
		case "flv":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].flvCuePoints, false, timeNameOrCuePoint);
		case "actionscript":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].asCuePoints, false, timeNameOrCuePoint);
		case "all":
		default:
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].allCuePoints, false, timeNameOrCuePoint);
		}
	}

	/**
	 * <p>Find the cue point at or near the given time and/or with
	 * given name.  Which type of cue points searched is determined by
	 * optional <code>type</code> parameter.  Default is to search all
	 * cue points.  Note that disabled cue points are also included in
	 * the search, use isFLVCuePointEnabled.  How the cue points are
	 * searched depends on the type of the first argument.</p>
	 *
	 * @param timeNameOrCuePoint If String, then name of cue point to
	 * search for.  Return the first cue point with this name, or null
	 * if no match.
	 *
	 * <p>If Number, time of cue point to search for.  Only first
	 * three decimal places of time used for search, any more than
	 * that will be rounded.  If there is an exact time match, returns
	 * the first cue point with this time (If there are multiples with
	 * same time, which is only possible with ActionScript cue points,
	 * then the one with the first name alphabetically will be
	 * returned.)  If the specific time is not found then the closest
	 * time earlier than that is returned.  If there is no cue point
	 * earlier than time, the first cue point is returned.  If there
	 * are no cue points, null is returned.</p>
	 *
	 * <p>If Object, then cuepoint object containing time and/or name
	 * properties for search.  If name is undefined or null, then
	 * search behaves same as described above for time only search.
	 * If time is undefined, null or less than 0, then search behaves
	 * same as described above for name only search.  If both time
	 * and name are defined and a cue point exists with both that
	 * time and name, then it is returned.  If there is no exact
	 * match, then the cue point with that exact name and with the
	 * closest time earlier than that is returned.  If there is
	 * no cue point with that name earlier than that time, then
	 * the first cue point with that name is returned.  If there
	 * are no cue points with that name, null is returned.</p>
	 *
	 * <p>If time is null, undefined or less than 0 and name is null
	 * or undefined, a VideoError is thrown.</p>
	 *
	 * @param type determines what class of cue points is searched.
	 * possible values are "all", "navigation", "event", "flv",
	 * "actionscript".  There are constants defined for each of these.
	 *
	 * @returns <code>null</code> if no match was found, otherwise
	 * copy of cuePoint object with additional properties:
	 *
	 * <ul>
	 * 
	 * <li><code>array</code> - the array of cue points that was
	 * searched.  Treat this array as read only as adding, removing or
	 * editing objects within it can cause cue points to
	 * malfunction.</li>
	 *
	 * <li><code>index</code> - the index into the array for the
	 * returned cuepoint.</li>
	 *
	 * </ul>
	 * @see #ALL
	 * @see #EVENT
	 * @see #NAVIGATION
	 * @see #FLV
	 * @see #ACTIONSCRIPT
	 * @see #cuePoints
	 * @see #addASCuePoint()
	 * @see #removeASCuePoint()
	 * @see #findCuePoint()
	 * @see CuePointManager#getCuePoint()
	 */
	public function findNearestCuePoint(timeNameOrCuePoint:Object, type:String):Object {
		switch (type) {
		case "event":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].eventCuePoints, true, timeNameOrCuePoint);
		case "navigation":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].navCuePoints, true, timeNameOrCuePoint);
		case "flv":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].flvCuePoints, true, timeNameOrCuePoint);
		case "actionscript":
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].asCuePoints, true, timeNameOrCuePoint);
		case "all":
		default:
			return _cpMgr[_activeVP].getCuePoint(_cpMgr[_activeVP].allCuePoints, true, timeNameOrCuePoint);
		}
	}

	/**
	 * <p>Given a cue point object returned from findCuePoint or
	 * findNearestCuePoint (needs the index and array properties added
	 * to those cue points), returns the next cue point in that array
	 * after that one with the same name.  Returns null if no cue
	 * point after that one with that name.  Throws VideoError if
	 * argument is invalid.</p>
	 *
	 * @returns <code>null</code> if no match was found, otherwise
	 * copy of cuePoint object with additional properties:
	 *
	 * <ul>
	 * 
	 * <li><code>array</code> - the array that was searched.  Treat
	 * this array as read only as adding, removing or editing objects
	 * within it can cause cue points to malfunction.</li>
	 *
	 * <li><code>index</code> - the index into the array for the
	 * returned cuepoint.</li>
	 *
	 * </ul>
	 */
	public function findNextCuePointWithName(cuePoint:Object):Object {
		return _cpMgr[_activeVP].getNextCuePointWithName(cuePoint);
	}

	/**
	 * <p>Enable or disable one or more FLV cue point.  Disabled cue
	 * points are disabled for being dispatched as events and
	 * navigating to them with <code>seekToPrevNavCuePoint()</code>,
	 * <code>seekToNextNavCuePoint()</code> and
	 * <code>seekToNavCuePoint()</code>.</p>
	 *
	 * <p>Cue point information is wiped out when contentPath property
	 * is set, so to set cue point info for the next FLV to be loaded,
	 * set contentPath first.</p>
	 *
	 * <p>Changes caused by calls to this function will not be
	 * reflected in results returned from
	 * <code>isFLVCuePointEnabled</code> until
	 * <code>metadataLoaded</code> is true.</p>
	 *
	 * @param enabled whether to enable or disable FLV cue point
	 * @param timeNameOrCuePoint If string, name of cue point to
	 * enable/disable.  If number, time of cue point to
	 * enable/disable.  If Object, then object with name and time
	 * properties, enable/disable cue point that matches both name and
	 * time.
	 * @returns If <code>metadataLoaded</code> is true, returns number
	 * of cue points whose enabled state was changed.  If
	 * <code>metadataLoaded</code> is false, always returns -1.
	 * @see #cuePoints
	 * @see #isFLVCuePointEnabled()
	 * @see #findCuePoint()
	 * @see #findNearestCuePoint()
	 * @see #findNextCuePointWithName()
	 * @see CuePointManager#setFLVCuePointEnabled()
	 */
	public function setFLVCuePointEnabled(enabled:Boolean, timeNameOrCuePoint:Object):Number {
		return _cpMgr[_activeVP].setFLVCuePointEnabled(enabled, timeNameOrCuePoint);
	}

	/**
	 * <p>Returns false if FLV embedded cue point is disabled by
	 * ActionScript.  Cue points are disabled via setting the
	 * <code>cuePoints</code> property or by calling
	 * <code>setFLVCuePointEnabled()</code>.</p>
	 *
	 * <p>The return value from this function is only meaningful when
	 * <code>metadataLoaded</code> is true (or <code>metadata</code>
	 * property is nonnull, or after "metadataReceived" event).  It always
	 * returns true when <code>metadataLoaded</code> is false.</p>
	 *
	 * @param timeNameOrCuePoint If string, name of cue point to
	 * check; return false only if ALL cue points with this name are
	 * disabled.  If number, time of cue point to check.  If Object,
	 * then object with name and time properties, check cue point that
	 * matches both name and time.
	 * @returns false if cue point(s) is found and is disabled, true
	 * either if no such cue point exists or if it is not disabled.
	 * If time given is undefined, null or less than 0 then returns
	 * false only if all cue points with this name are disabled.
	 *
	 * <p>The return value from this function is only meaningful when
	 * <code>metadataLoaded</code> is true.  It always returns true when it
	 * is false.</p>
	 * @see #findCuePoint()
	 * @see #findNearestCuePoint()
	 * @see #findNextCuePointWithName()
	 * @see #setFLVCuePointEnabled()
	 * @see CuePointManager#isFLVCuePointEnabled()
	 */
	public function isFLVCuePointEnabled(timeNameOrCuePoint:Object):Boolean {
		return _cpMgr[_activeVP].isFLVCuePointEnabled(timeNameOrCuePoint);
	}

	/**
	 * Override MovieClip functionality to reserve depths less than
	 * 1000 for internal use (used for VideoPlayer and live preview
	 * placeholder.
	 */
	public function getNextHighestDepth():Number {
		var depth:Number = super.getNextHighestDepth();
		return (depth < 1000) ? 1000 : depth;
	}

	/**
	 * Brings VideoPlayer to the front of the stack of VideoPlayers.
	 * Useful for custom transitions between VideoPlayers.
	 */
	public function bringVideoPlayerToFront(index:Number):Void {
		if (index == _topVP || _vp[index] == undefined) return;
		_vp[_topVP].swapDepths(_vp[index].getDepth());
		_topVP = index;
	}

	/**
	 * Get VideoPlayer with given index.  When possible, it is
	 * best to access VideoPlayer APIs via FLVPlayback APIs.
	 * Each VideoPlayer._name proprety is its index.
	 */
	public function getVideoPlayer(index:Number):VideoPlayer {
		return _vp[index];
	}

	/**
	 * Close VideoPlayer with given index.  Closes NetStream and
	 * deletes VideoPlayer.  If the closed video player is the active
	 * or visible VideoPlayer, then active and/or visible VideoPlayer
	 * will be set to the default player (with index 0).  You cannot
	 * close the default player, and trying to will throw an error.
	 */
	public function closeVideoPlayer(index:Number):VideoPlayer {
		if (_vp[index] == undefined) return;
		if (index == 0) throw new VideoError(VideoError.DELETE_DEFAULT_PLAYER);
		if (_visibleVP == index) visibleVideoPlayerIndex = 0;
		if (_activeVP == index) activeVideoPlayerIndex = 0;
		_vp[index].close();
		_vp[index].unloadMovie();
		delete _vp[index];
		_vp[index] = undefined;
	}

	//
	// public properties
	//


	/**
	 * <p>Use activeVideoPlayerIndex to manage multiple FLV streams.  Sets
	 * which <code>VideoPlayer</code> instance is affected by most
	 * other APIs.  Default is 0.  Does not make the
	 * <code>VideoPlayer</code> visible, to do this use
	 * <code>visibleVideoPlayerIndex</code>.</p>
	 *
	 * <p>A new VideoPlayer is created the first time
	 * <code>activeVideoPlayerIndex</code> is set to a given number.  When
	 * the new VideoPlayer is created, its properties are set to the
	 * value of the default VideoPlayer (<code>activeVideoPlayerIndex ==
	 * 0</code>) except for contentPath, totalTime and isLive, which
	 * are always set to the default values (empty string, 0 and
	 * false, respectively), autoPlay which is always false (default
	 * is true for the default VideoPlayer, aka 0), and height and
	 * width which match those of the visibleVideoPlayerIndex.  Note that
	 * the cuePoints property will have no effect, just as it would
	 * have no effect on a subsequent load into the default
	 * VideoPlayer.</p>
	 * 
	 * <p>APIs that control volume, positioning, dimensions,
	 * visibility and UI controls are always global and their behavior
	 * is NOT affected by setting <code>activeVideoPlayerIndex</code>.  The
	 * APIs unaffected are: backButton, bufferingBar,
	 * bufferingBarHidesAndDisablesOthers, forwardButton, height,
	 * muteButton, pauseButton, playButton, playPauseButton, scaleX,
	 * scaleY, seekBar, seekBarInterval, seekBarScrubTolerance,
	 * seekToPrevOffset, skin, transform, stopButton, visible, volume,
	 * volumeBar, volumeBarInterval, volumeBarScrubTolerance, width,
	 * x, y, setSize(), setScale()</p>
	 *
	 * <p>APIs that control dimensions do interact with
	 * <code>visibleVideoPlayerIndex</code>, however.  See that property
	 * for more on that.</p>
	 * 
	 * <p>APIs that target specific VideoPlayer depending on setting
	 * of activeVideoPlayerIndex: all the rest!</p>
	 *
	 * <p>When listening for events, you will get all events for all
	 * VideoPlayers.  To distinguish which VideoPlayer the vent is for
	 * use the events <code>vp</code> property, a Number corresponding
	 * to the number set in activeVideoPlayerIndex and
	 * visibleVideoPlayerIndex.  All events have this property EXCEPT for
	 * "resize" and "volumeUpdate" which are not specific to a VideoPlayer
	 * but are global for the FLVPlayback instance.</p>
	 * 
	 * <p>For example, to load a second FLV in the background, set
	 * <code>activeVideoPlayerIndex</code> to 1 and call <code>load()</code>.
	 * When you are ready to show this one and hide the other one, set
	 * visibleVideoPlayerIndex to 1.</p>
	 * 
	 * @see #visibleVideoPlayerIndex
	 */
	[Bindable]
	public function get activeVideoPlayerIndex():Number {
		return _activeVP;
	}
	public function set activeVideoPlayerIndex(i:Number):Void {
		if (_activeVP == i) return;
		// if have not done the delay load of first FLV, force it now.
		if (_vp[_activeVP].onEnterFrame != undefined) {
			doContentPathConnect();
		}
		_activeVP = i;
		if (_vp[_activeVP] == undefined) {
			createVideoPlayer(_activeVP);
			_vp[_activeVP].visible = false;
			_vp[_activeVP].volume = 0;
		}
	}

	/**
	 * <p>Determines whether the FLV is played immediately when
	 * contentPath property is set or if we wait.  Even if
	 * autoPlay is false, we do load the content immediately.</p>
	 *
	 * <p>If set  between loads of  new FLVs, has no effect until
	 * next set of contentPath.</p>
	 *
	 * @see #contentPath
	 * @helpid 0
	 */
	[Inspectable(defaultValue=true)]
	public function get autoPlay():Boolean
	{
		if (_vpState[_activeVP] == undefined) return _autoPlay;
		return _vpState[_activeVP].autoPlay;
	}
	public function set autoPlay(flag:Boolean):Void
	{
		if (_activeVP == 0 || _activeVP == undefined) _autoPlay = flag;
		_vpState[_activeVP].autoPlay = flag;
	}

	/**
	 * <p>Determines whether the FLV is rewound to the first frame
	 * when play stops, either by calling <code>stop()</code> or by
	 * reaching the end of the stream.  Meaningless for live streams.</p>
	 *
	 * @helpid 0
	 */
	[Inspectable(defaultValue=true)]
	public function get autoRewind():Boolean
	{
		if (_vp[_activeVP] == undefined) return _autoRewind;
		return _vp[_activeVP].autoRewind;
	}
	public function set autoRewind(flag:Boolean):Void
	{
		if (_activeVP == 0 || _activeVP == undefined) _autoRewind = flag;
		_vp[_activeVP].autoRewind = flag;
	}

	/**
	 * <p>Determines whether the instance is automatically resized to
	 * the source dimensions.  If this is set from false to true after
	 * an FLV has been loaded, an automatic resize will start
	 * immediately.</p>
	 *
	 * @see #maintainAspectRatio
	 * @see #preferredHeight
	 * @see #preferredWidth
	 * @tiptext Determines whether the display sizes itself according to the preferred size of the media
	 * @helpid 3543
	 */
	[Inspectable(defaultValue=false)]
	public function get autoSize():Boolean
	{
		if (_vp[_activeVP] == undefined) return _autoSize;
		return _vp[_activeVP].autoSize;
	}
	public function set autoSize(flag:Boolean):Void
	{
		if (_activeVP == 0 || _activeVP == undefined) _autoSize = flag;
		_vp[_activeVP].autoSize = flag;
	}

	/**
	 * <p>Get the bandwidth.  Numerical Value in bits per second.</p>
	 *
	 * <p>When streaming from FCS, can provide SMIL file that
	 * describes how to switch between multiple streams based on
	 * bandwidth.  Bandwidth is automatically detected by FCS server
	 * and if this value is set, it will be ignored.</p>
	 *
	 * <p>When doing http progressive download, can use the same SMIL
	 * format, but must set the bitrate as there is no automatic
	 * detection.</p>
	 */
	public function get bitrate():Number {
		return ncMgr.getBitrate();
	}
	public function set bitrate(b:Number):Void {
		ncMgr.setBitrate(b);
	}

	/**
	 * If state is buffering.  Read only.
	 */
	public function get buffering():Boolean {
		if (_vp[_activeVP] == undefined) return false;
		return (_vp[_activeVP].state == BUFFERING);
	}

	/**
	 * <p>buffering bar control.  Displays when in loading or
	 * buffering type state.</p>
	 */
	public function get bufferingBar():MovieClip {
		if (_uiMgr != null) _bufferingBar = _uiMgr.getControl(UIManager.BUFFERING_BAR);
		return _bufferingBar;
	}
	public function set bufferingBar(s:MovieClip):Void {
		_bufferingBar = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.BUFFERING_BAR, s);
	}

	/**
	 * <p>If true, we hide and disable certain controls when the
	 * buffering bar is displayed.  The seek bar will be hidden, the
	 * play, pause, play/pause, forward and back buttons would be
	 * disabled.  Default is false.  This only has effect if there
	 * is a buffering bar control.</p>
	 */
	public function get bufferingBarHidesAndDisablesOthers():Boolean {
		if (_uiMgr != null) {
			_bufferingBarHides = _uiMgr.bufferingBarHidesAndDisablesOthers;
		}
		return _bufferingBarHides;
	}
	public function set bufferingBarHidesAndDisablesOthers(b:Boolean):Void {
		_bufferingBarHides = b;
		if (_uiMgr != null) {
			_uiMgr.bufferingBarHidesAndDisablesOthers = b;
		}
	}

	/**
	 * <p>back button control.  Clicking calls
	 * seekToPrevNavCuePoint().
	 * 
	 * @see #seekToPrevNavCuePoint()</p>
	 */
	public function get backButton():MovieClip {
		if (_uiMgr != null) _backButton = _uiMgr.getControl(UIManager.BACK_BUTTON);
		return _backButton;
	}
	public function set backButton(s:MovieClip):Void {
		_backButton = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.BACK_BUTTON, s);
	}

	/**
	 * <p>Sets number of seconds to buffer in memory before playing
	 * back stream.  For slow connections streaming over rtmp, it is
	 * important to increase this from the default.  Default is
	 * 0.1</p>
	 */
	[Inspectable(defaultValue=0.1)]
	public function get bufferTime():Number
	{
		if (_vp[_activeVP] == undefined) return _bufferTime;
		return _vp[_activeVP].bufferTime;
	}
	public function set bufferTime(aTime:Number):Void
	{
		if (_activeVP == 0 || _activeVP == undefined) _bufferTime = aTime;
		_vp[_activeVP].bufferTime = aTime;
	}

	/**
	 * <p>property bytesLoaded, read only.  Returns -1 when there
	 * is no stream, when the stream is FCS or if the information
	 * is not yet available.  Return value only useful for HTTP
	 * download.</p>
	 *
	 * @tiptext Number of bytes already loaded
	 * @helpid 3455
	 */
	[ChangeEvent("progress")]
	[Bindable]
	public function get bytesLoaded():Number
	{
		return _vp[_activeVP].bytesLoaded;
	}

	/**
	 * <p>property bytesTotal, read only.  Returns -1 when there
	 * is no stream, when the stream is FCS or if the information
	 * is not yet available.  Return value only useful for HTTP
	 * download.</p>
	 *
	 * @tiptext Number of bytes to be loaded
	 * @helpid 3456
	 */
	[ChangeEvent("progress")]
	[Bindable]
	public function get bytesTotal():Number
	{
		return _vp[_activeVP].bytesTotal;
	}

	/**
	 * <p>URL that determines FLV to stream and how to stream it.
	 * URL can be http URL to an FLV, rtmp URL to a stream or
	 * http URL to an XML file.</p>
	 *
	 * <p>If set via component inspector or property inspector, the
	 * loading and/or playing of FLV starts on next "enterFrame" event.
	 * Delay is to allow time to set isLive, autoPlay and cuePoints
	 * properties, among others, which effect loading, as well as to
	 * allow ActionScript on frame one to effect the FLVPlayback
	 * component before it starts playing.</p>
	 *
	 * <p>If set via ActionScript, it immediately calls
	 * <code>VideoPlayer.load()</code> if <code>autoPlay</code> is
	 * false or <code>VideoPlayer.play()</code> if
	 * <code>autoPlay</code> is true.  Also sends properties
	 * <code>totalTime</code> and <code>isLive</code> into those
	 * <code>VideoPlayer</code> APIs, so be sure to set those BEFORE
	 * setting this property.</p>
	 *
	 * @see #autoPlay
	 * @see #isLive
	 * @see #totalTime
	 * @see #load()
	 * @see #play()
	 * @see VideoPlayer#load()
	 * @see VideoPlayer#play()
	 */
	[Inspectable(type="Video Content Path")]
	[Bindable]
	public function get contentPath():String {
		if (_vp[_activeVP] == undefined || _vp[_activeVP].onEnterFrame != undefined) {
			return _contentPath;
		}
		return _vp[_activeVP].url;
	}
	public function set contentPath(url:String):Void {
		if (_global.isLivePreview) return;
		if (_vp[_activeVP] == undefined) {
			// if set by component inspector, before constructor called
			if (url == _contentPath) return;
			_contentPath = url;
		} else {
			if (_vp[_activeVP].url == url) return;
			_vpState[_activeVP].minProgressPercent = undefined;
			if (_vp[_activeVP].onEnterFrame != undefined) {
				delete _vp[_activeVP].onEnterFrame;
				_vp[_activeVP].onEnterFrame = undefined;
			}
			_cpMgr[_activeVP].reset();
			if (_vpState[_activeVP].autoPlay && _firstStreamShown) {
				_vp[_activeVP].play(url, _vpState[_activeVP].isLive, _vpState[_activeVP].totalTime);
			} else {
				_vp[_activeVP].load(url, _vpState[_activeVP].isLive, _vpState[_activeVP].totalTime);
			}
			_vpState[_activeVP].isLiveSet = false;
			_vpState[_activeVP].totalTimeSet = false;
		}
	}

	/**
	 * <p>Write only Array that describes ActionScript cue points and
	 * disabled embedded FLV cue points.  This API is created
	 * specifically to be used by the component inspector and
	 * will not work if set in any other way.  Its value only
	 * has an effect on the first FLV loaded, and only if it
	 * is loaded by setting the contentPath property in the
	 * component inspector or property inspector.</p>
	 *
	 * <p>To add, remove, enable or disable cue points with
	 * ActionScript, use use <code>addASCuePoint()</code>,
	 * <code>removeASCuePoint()</code>,
	 * <code>setFLVCuePointEnabled()</code>.</p>
	 *
	 * @see #contentPath
	 * @see #addASCuePoint()
	 * @see #removeASCuePoint()
	 * @see #setFLVCuePointEnabled()
	 */
	[Inspectable(type="Video Cue Points")]
	public function set cuePoints(cp:Array):Void {
		// this can only be set once, and only before the constructor is called
		if (_cuePoints != undefined) return;
		_cuePoints = cp;
	}

	//ifdef DEBUG
	///**
	// * temporary for development
	// */
	//[Inspectable(defaultValue=false)]
	//public function get debuggingOn():Boolean {
	//	return _debuggingOn;
	//}
	//public function set debuggingOn(d:Boolean):Void {
	//	_debuggingOn = d;
	//}

	///**
	// * temporary for development.  Should be a function that takes
	// * a String argument.
	// */
	//public function get debuggingOutputFunction():Function {
	//	return _debugFn;
	//}
	//public function set debuggingOutputFunction(d:Function):Void {
	//	_debugFn = d;
	//}
	//endif

	/**
	 * <p>forward button control.  Clicking calls
	 * seekToNextNavCuePoint().</p>
	 * 
	 * @see #seekToNextNavCuePoint()
	 */
	public function get forwardButton():MovieClip {
		if (_uiMgr != null) _forwardButton = _uiMgr.getControl(UIManager.FORWARD_BUTTON);
		return _forwardButton;
	}
	public function set forwardButton(s:MovieClip):Void {
		_forwardButton = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.FORWARD_BUTTON, s);
	}

	/**
	 * <p>Height of video</p>
	 *
	 * @see #setSize()
	 * @helpid 0
	 */
	[ChangeEvent("resize")]
	[Bindable]
	public function get height():Number {
		if (_global.isLivePreview) return __height;			
		if (_vp[_visibleVP] != undefined) __height = _vp[_visibleVP].height;
		return __height;
	}
	public function set height(h:Number):Void {
		setSize(this.width, h);
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
		if (_vp[_activeVP] == undefined) return _idleTimeout;
		return _vp[_activeVP].idleTimeout;
	}
	public function set idleTimeout(aTime:Number):Void {
		if (_activeVP == 0 || _activeVP == undefined) _idleTimeout = aTime;
		_vp[_activeVP].idleTimeout = aTime;
	}

	/**
	 * True if stream is RTMP download (streaming from Flash
	 * Communication Server), read only.
	 *
	 * @see VideoPlayer#isRTMP
	 */
	public function get isRTMP():Boolean {
		if (_global.isLivePreview) return true;
		if (_vp[_activeVP] == undefined) return undefined;
		return _vp[_activeVP].isRTMP;
	}

	/**
	 * <p>Whether stream is live.  This property only matters when
	 * streaming from FVSS or FCS; value is ignored when doing
	 * http download.</p>
	 *
	 * <p>If set  between loads of  new FLVs, has no  effect until
	 * next set of contentPath.</p>
	 *
	 * @see #contentPath
	 * @see VideoPlayer#isLive
	 */
	[Inspectable(defaultValue=false)]
	public function get isLive():Boolean {
		if (_vp[_activeVP] == undefined) {
			return _isLive;
		} else if(_vpState[_activeVP].isLiveSet) {
			return _vpState[_activeVP].isLive;
		} else {
			return _vp[_activeVP].isLive;
		}
	}
	public function set isLive(flag:Boolean):Void {
		if (_activeVP == 0 || _activeVP == undefined) _isLive = flag;
		_vpState[_activeVP].isLive = flag;
		_vpState[_activeVP].isLiveSet = true;
	}

	/**
	 * <p>Determines whether video aspect ratio is maintained.  If
	 * this is set from false to true and <code>autoSize</code> is
	 * false after an FLV has been loaded, an automatic resize will
	 * start immediately.</p>
	 *
	 * @see #autoSize
	 * @see #preferredHeight
	 * @see #preferredWidth
	 * @tiptext Determines whether a Display or Playback instance maintains aspect ratio
	 * @helpid 3451
	 */
	[Inspectable(defaultValue=true)]
	public function get maintainAspectRatio():Boolean
	{
		if (_vp[_activeVP] == undefined) return _aspectRatio;
		return _vp[_activeVP].maintainAspectRatio;
	}
	public function set maintainAspectRatio(flag:Boolean):Void
	{
		if (_activeVP == 0 || _activeVP == undefined) _aspectRatio = flag;
		_vp[_activeVP].maintainAspectRatio = flag;
	}

	/**
	 * <p>Read only.  Metadata info packet received in onMetaData
	 * callback, if available.  Ready when "metadataReceived" event
	 * dispatched.</p>
	 *
	 * @see VideoPlayer#metadata
	 */
	public function get metadata():Object {
		if (_vp[_activeVP] == undefined) return null;
		return _vp[_activeVP].metadata;
	}

	/**
	 * <p>Read only.  True if metadata packet has been encountered and
	 * processed OR if it is clear that it will not be.  Use this to
	 * check if useful information can be retreived from there various
	 * cue point APIs (findCuePoint, findNearestCuePoint,
	 * findNextCuePointWithName, isFLVCuePointEnabled) for FLV
	 * embedded cue points.
	 *
	 * @see #findCuePoint()
	 * @see #findNearestCuePoint()
	 * @see #findNextCuePointWithName()
	 * @see #isFLVCuePointEnabled()
	 * @see CuePointManager#metadataLoaded
	 */
	public function get metadataLoaded():Boolean {
		if (_vp[_activeVP] == undefined) return false;
		return _cpMgr[_activeVP].metadataLoaded;
	}

	/**
	 * <p>mute button control.</p>
	 */
	public function get muteButton():MovieClip {
		if (_uiMgr != null) _muteButton = _uiMgr.getControl(UIManager.MUTE_BUTTON);
		return _muteButton;
	}
	public function set muteButton(s:MovieClip):Void {
		_muteButton = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.MUTE_BUTTON, s);
	}

	/**
	 * <p>Access to instance of the class implementing
	 * <code>INCManager</code>.  Read only.</p>
	 *
	 * <p>One use case for this is that a custom
	 * <code>INCManager</code> implementation may require custom
	 * initialization.</p>
	 *
	 * VideoPlayer#ncMgr
	 */
	public function get ncMgr():INCManager {
		if (_vp[_activeVP] == undefined) return null;
		return _vp[_activeVP].ncMgr;
	}

	/**
	 * <p>pause button control.</p>
	 */
	public function get pauseButton():MovieClip {
		if (_uiMgr != null) _pauseButton = _uiMgr.getControl(UIManager.PAUSE_BUTTON);
		return _pauseButton;
	}
	public function set pauseButton(s:MovieClip):Void {
		_pauseButton = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.PAUSE_BUTTON, s);
	}

	/**
	 * If state is paused.  Read only.
	 */
	[ChangeEvent("stateChange")]
	[ChangeEvent("paused")]
	[Bindable]	
	public function get paused():Boolean {
		if (_vp[_activeVP] == undefined) return false;
		return (_vp[_activeVP].state == PAUSED);
	}

	/**
	 * <p>play button control.</p>
	 */
	public function get playButton():MovieClip {
		if (_uiMgr != null) _playButton = _uiMgr.getControl(UIManager.PLAY_BUTTON);
		return _playButton;
	}
	public function set playButton(s:MovieClip):Void {
		_playButton = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.PLAY_BUTTON, s);
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
	 * @tiptext Current position of the playhead in seconds
	 * @helpid 3463
	 * @see #seek()
	 * @see VideoPlayer#playheadTime
	 */
	[ChangeEvent("playheadUpdate")]
	[Bindable]	
	public function get playheadTime():Number
	{
		if (_vp[_activeVP] == undefined) return 0;
		return _vp[_activeVP].playheadTime;
	}
	public function set playheadTime(position:Number):Void
	{
		seek(position);
	}

	/**
	 * <p>Property playheadUpdateInterval, which is amount of time
	 * in milliseconds between each "playheadUpdate" event.</p>
	 *
	 * <p>If set when stream is playing, will restart timer.</p>
	 *
	 * @see VideoPlayer#playheadUpdateInterval
	 */
	public function get playheadUpdateInterval():Number {
		if (_vp[_activeVP] == undefined) return _playheadUpdateInterval;
		return _vp[_activeVP].playheadUpdateInterval;
	}
	public function set playheadUpdateInterval(aTime:Number):Void {
		if (_activeVP == 0 || _activeVP == undefined) _playheadUpdateInterval = aTime;
		_cpMgr[_activeVP].playheadUpdateInterval = aTime;
		_vp[_activeVP].playheadUpdateInterval = aTime;
	}

	/**
	 * If state is playing.  Read only.
	 */
	[ChangeEvent("stateChange")]
	[ChangeEvent("playing")]
	[Bindable]	
	public function get playing():Boolean {
		if (_vp[_activeVP] == undefined) return false;
		return (_vp[_activeVP].state == PLAYING);
	}

	/**
	 * <p>play/pause button control</p>
	 */
	public function get playPauseButton():MovieClip {
		if (_uiMgr != null) _playPauseButton = _uiMgr.getControl(UIManager.PLAY_PAUSE_BUTTON);
		return _playPauseButton;
	}
	public function set playPauseButton(s:MovieClip):Void {
		_playPauseButton = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.PLAY_PAUSE_BUTTON, s);
	}

	/**
	 * <p>property preferredHeight, get only.  Gives the height of the
	 * source FLV.  This information is not valid immediately upon
	 * calling <code>play()</code> or <code>load()</code>.  It is
	 * ready when the "ready" event fires.
	 *
	 * @return The preferred height of the display.
	 * This is the height of the source FLV.
	 * @see #autoSize
	 * @see #maintainAspectRatio
	 * @tiptext The preferred height of the display
	 * @helpid 3465
	 */
	[ChangeEvent("metadataReceived")]
	[Bindable]
	public function get preferredHeight():Number
	{
		if (_vp[_activeVP] == undefined) return 0;
		return _vp[_activeVP].videoHeight;
	}

	/**
	 * <p>property preferredWidth, get only.  Gives the width of the
	 * source FLV.  This information is not valid immediately upon
	 * calling <code>play()</code> or <code>load()</code>.  It is
	 * ready when the "ready" event fires.
	 *
	 * @return The preferred width of the display.
	 * This is the width of the source FLV.
	 * @see #autoSize
	 * @see #maintainAspectRatio
	 * @tiptext The preferred width of the display
	 * @helpid 3466
	 */
	[ChangeEvent("metadataReceived")]
	[Bindable]
	public function get preferredWidth():Number
	{
		if (_vp[_activeVP] == undefined) return 0;
		return _vp[_activeVP].videoWidth;
	}

	/**
	 * <p>Property progressInterval, which is amount of time
	 * in milliseconds between each "progress" event.</p>
	 *
	 * <p>If set when stream is playing, will restart timer.</p>
	 *
	 * @see VideoPlayer#progressInterval
	 */
	public function get progressInterval():Number {
		if (_vp[_activeVP] == undefined) return _progressInterval;
		return _vp[_activeVP].progressInterval;
	}
	public function set progressInterval(aTime:Number):Void {
		if (_activeVP == 0 || _activeVP == undefined) _progressInterval = aTime;
		_vp[_activeVP].progressInterval = aTime;
	}

	/**
	 * 100 is standard scale
	 *
	 * @see #setScale()
	 * @tiptext Specifies the horizontal scale factor
	 * @helpid 3974
	 */
	[ChangeEvent("resize")]
	[Bindable]
	function get scaleX():Number
	{
		if (_vp[_visibleVP] != undefined) _scaleX = _vp[_visibleVP].width / _origWidth * 100;
		return this._scaleX;
	}
	function set scaleX(xs:Number):Void
	{
		setScale(xs, this.scaleY);
	}

	/**
	 * 100 is standard scale
	 *
	 * @see #setScale()
	 * @tiptext Specifies the vertical scale factor
	 * @helpid 3975
	 */
	[ChangeEvent("resize")]
	[Bindable]
	function get scaleY():Number
	{
		if (_vp[_visibleVP] != undefined) _scaleY = _vp[_visibleVP].height / _origHeight * 100;
		return this._scaleY;
	}
	function set scaleY(ys:Number):Void
	{
		setScale(this.scaleX, ys);
	}

	/**
	 * <p>True if user is currently scrubbing with the seek bar.  read only</p>
	 */
	public function get scrubbing():Boolean {
		var seekBar:MovieClip = this.seekBar;
		if (seekBar == undefined || seekBar.isDragging == undefined) {
			return false;
		}
		return seekBar.isDragging;
	}

	/**
	 * <p>seek bar control</p>
	 */
	public function get seekBar():MovieClip {
		if (_uiMgr != null) _seekBar = _uiMgr.getControl(UIManager.SEEK_BAR);
		return _seekBar;
	}
	public function set seekBar(s:MovieClip):Void {
		_seekBar = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.SEEK_BAR, s);
	}

	/**
	 * Determines how often check the seek bar handle location when
	 * scubbing, in milliseconds.  Default is 250.
	 * 
	 * @see UIManager#seekBarInterval
	 * @see UIManager#SEEK_BAR_INTERVAL_DEFAULT
	 */
	public function get seekBarInterval():Number {
		if (_uiMgr != null) _seekBarInterval = _uiMgr.seekBarInterval
		return _seekBarInterval;
	}
	public function set seekBarInterval(s:Number) {
		_seekBarInterval = s;
		if (_uiMgr != null) _uiMgr.seekBarInterval = _seekBarInterval;
	}

	/**
	 * <p>Determines how far user can move scrub bar before an update
	 * will occur.  Specified in percentage from 1 to 100.  Set to 0
	 * to indicate no scrub tolerance--always update position on
	 * seekBarInterval regardless of how far user has moved handle.
	 * Default is 5.</p>
	 *
	 * @see UIManager#seekBarScrubTolerance
	 * @see UIManager#SEEK_BAR_SCRUB_TOLERANCE_DEFAULT
	 */
	public function get seekBarScrubTolerance():Number {
		if (_uiMgr != null) _seekBarScrubTolerance = _uiMgr.seekBarScrubTolerance;
		return _seekBarScrubTolerance;
	}
	public function set seekBarScrubTolerance(s:Number) {
		_seekBarScrubTolerance = s;
		if (_uiMgr != null) _uiMgr.seekBarScrubTolerance = _seekBarScrubTolerance;
	}

	/**
	 * <p>when seekToPrevNavCuePoint compares its time against the
	 * previous cue point, it uses this delta to be sure that if you
	 * are just ahead of a cue point, you can hop over it to the
	 * previous and not get stuck going to the same one over and over
	 * if you are playing.  In seconds</p>
	 *
	 */
	public function get seekToPrevOffset():Number {
		return _seekToPrevOffset;
	}
	public function set seekToPrevOffset(s:Number):Void {
		_seekToPrevOffset = s;
	}

	/**
	 * <p>Skin swf</p>
	 */
	[Inspectable(type="Video Skin")]
	public function get skin():String {
		if (_uiMgr != null) _skin = _uiMgr.skin;
		return _skin;
	}
	public function set skin(s:String):Void {
		_skin = s;
		if (_uiMgr != null) _uiMgr.skin = s;
	}

	/**
	 * <p>Whether to hide the skin when the mouse is not over the video.
	 * Defaults to false.</p>
	 */
	[Inspectable(defaultValue=false)]
	public function get skinAutoHide():Boolean {
		if (_uiMgr != null) _skinAutoHide = _uiMgr.skinAutoHide;
		return _skinAutoHide;
	}
	public function set skinAutoHide(b:Boolean):Void {
		// in live preview always leave to default of false
		if (_global.isLivePreview) return;
		_skinAutoHide = b;
		if (_uiMgr != null) _uiMgr.skinAutoHide = b;
	}

	/**
	 * <p>Provides direct access to the
	 * <code>Sound.setTransform()</code> and
	 * <code>Sound.getTransform()</code> APIs. to expose more sound
	 * control.  Must set property for changes to take effect, get
	 * property just to get a copy of the current settings to tweak.</p>
	 *
	 * @see #volume
	 * @see VideoPlayer#transform
	 */
	public function get transform():Object {
		return _transform;
	}
	public function set transform(s:Object):Void {
		_transform = s;
		if (_vp[_activeVP] != undefined) _vp[_activeVP].transform = _transform;
	}

	/**
	 * <p>Get state.  Read only.  Set with <code>load()</code>,
	 * <code>play()</code>, <code>stop()</code>,
	 * <code>pause()</code> and <code>seek()</code>.</p>
	 *
	 * <p>Descriptive constants for values are defined.</p>
	 *
	 * @see #DISCONNECTED
	 * @see #STOPPED
	 * @see #PLAYING
	 * @see #PAUSED
	 * @see #BUFFERING
	 * @see #LOADING
	 * @see #CONNECTION_ERROR
	 * @see #REWINDING
	 * @see #SEEKING
	 */
	[Bindable]
	[ChangeEvent("stateChange")]
	public function get state():String {
		// for live preview, always make state STOPPED
		if (_global.isLivePreview) {
			return STOPPED;
		}
			
		// if no VideoPlayer exists (would only happen constructor
		// called), return DISCONNECTED
		if (_vp[_activeVP] == undefined) return DISCONNECTED;

		// force state to SEEKING while scrubbing
		if (_activeVP == _visibleVP && scrubbing) return SEEKING;

		var currentState:String = _vp[_activeVP].state;

		// force state to LOADING if it is RESIZING. RESIZING is just
		// needed for internal VideoPlayer use anyways, make it
		// LOADING, less confusing for user, esp when suppressing
		// STOPPED as we do below...
		if (currentState == VideoPlayer.RESIZING) return LOADING;

		// force state to LOADING when STOPPED because autoPlay is
		// true and waiting for skin to download to show all at once
		if ( _vpState[_activeVP].prevState == LOADING &&
		     _vpState[_activeVP].autoPlay &&
		     currentState == STOPPED ) {
			return LOADING;
		}

		return currentState;
	}

	/**
	 * <p>Read only.  Gets whether state is responsive,
	 * i.e. whether controls should be enabled in the current
	 * state.</p>
	 *
	 * @see VideoPlayer#stateResponsive
	 */
	public function get stateResponsive():Boolean {
		if (_vp[_activeVP] == undefined) return false;
		return _vp[_activeVP].stateResponsive;
	}

	/**
	 * <p>stop button control.</p>
	 */
	public function get stopButton():MovieClip {
		if (_uiMgr != null) _stopButton = _uiMgr.getControl(UIManager.STOP_BUTTON);
		return _stopButton;
	}
	public function set stopButton(s:MovieClip):Void {
		_stopButton = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.STOP_BUTTON, s);
	}

	/**
	 * If state is stopped.  Read only.
	 */
	[ChangeEvent("stateChange")]
	[ChangeEvent("stopped")]
	[Bindable]
	public function get stopped():Boolean {
		if (_vp[_activeVP] == undefined) return false;
		return (_vp[_activeVP].state == STOPPED);
	}

	/**
	 * <p>property totalTime.</p>
	 *
	 * <p>When streaming from FCS and using the default
	 * <code>NCManager</code>, this will be determined
	 * automatically using server side APIs and that value will
	 * override anything set through this property or gathered
	 * from metadata.  The property is ready for read when the
	 * STOPPED or PLAYING state is reached after setting the
	 * <code>contentPath</code> property.  When live streaming
	 * from FCS, this property is meaningless.</p>
	 *
	 * <p>With HTTP download, this property will be determined
	 * automatically if the FLV has metadata embedded, otherwise
	 * it must be set explicitly or it will be 0.  If it is set
	 * explicitly than the metadata value in the stream will be
	 * ignored.</p>
	 *
	 * <p>When this is set, the setting takes effect for the next
	 * FLV loaded by setting contentPath, it will have no effect
	 * on a flv that has already been loaded.  Also, reading this
	 * property will not return the new value passed in until an
	 * flv is loaded.</p>
	 *
	 * <p>Playback will still work if this is never set (either
	 * explicitly or automatically), but it may cause problems
	 * with seek controls.</p>
	 *
	 * @return The total running time of the FLV in seconds
	 * @see #contentPath
	 * @tiptext The total length of the FLV in seconds
	 * @helpid 3467
	 */
	[Inspectable(defaultValue=0)]
	[ChangeEvent("metadataReceived")]
	[Bindable]
	public function get totalTime():Number
	{
		if (_global.isLivePreview) return 1;
		if (_vp[_activeVP] == undefined) {
			return _totalTime;
		} else if (_vpState[_activeVP].totalTimeSet) {
			return _vpState[_activeVP].totalTime;
		} else {
			return _vp[_activeVP].totalTime;
		}
	}
	public function set totalTime(aTime:Number):Void
	{
		if (_activeVP == 0 || _activeVP == undefined) _totalTime = aTime;
		_vpState[_activeVP].totalTime = aTime;
		_vpState[_activeVP].totalTimeSet = true;
	}

	/**
	 * read only, only included to appear in the CI
	 */
	[Inspectable(defaultValue="")]
	public function get version_1_0_2():String {
		return "";
	}
	public function set version_1_0_2(v:String) {
	}

	public function get visible():Boolean {
		return this._visible;
	}
	public function set visible(v:Boolean) {
		this._visible = v;
	}

	/**
	 * <p>Use visibleVideoPlayerIndex to manage multiple FLV streams.
	 * qSets which <code>VideoPlayer</code> instance is visible and
	 * audible--only one at a time can be, the rest are hidden and
	 * muted.  Default is 0.  Does not make the <code>VideoPlayer</code>
	 * targeted by most APIs, for that use <code>activeVideoPlayerIndex</code></p>
	 *
	 * <p>APIs that control dimensions interact with this property.
	 * All that set the dimensions (setScale, setSize, set width, set
	 * height, set scaleX, set scaleY) effect all VideoPlayers.
	 * However, depending on whether autoSize or maintaintAspectRatio
	 * are set on those VideoPlayers, they may have different
	 * dimensions.  So APIs that get the dimensions (get width, get
	 * height, get scaleX, get scaleY) get the dimensions of the
	 * visible VideoPlayer only, and while other VideoPlayers may
	 * have the same dimensions, they may not.</p>
	 *
	 * <p>To get the dimensions of various VideoPlayers when they are
	 * not visible, listen for the "resize" event and cache the size
	 * value yourself.</p>
	 *
	 * <p>Does not have any implications for visibility of the
	 * component as a whole, just which VideoPlayer is visible when
	 * the component is visible.  To set visibility for the entire
	 * component, use <code>visible</code> property.</p>
	 *
	 * @see #activeVideoPlayerIndex
	 * @see #visible
	 */
	public function get visibleVideoPlayerIndex():Number {
		return _visibleVP;
	}
	public function set visibleVideoPlayerIndex(i:Number) {
		if (_visibleVP == i) return;
		var oldIndex:Number = _visibleVP;
		if (_vp[i] == undefined) {
			createVideoPlayer(i);
		}
		var needResize:Boolean = (_vp[i].height != _vp[_visibleVP].height || _vp[i].width != _vp[_visibleVP].width);
		_vp[_visibleVP].visible = false;
		_vp[_visibleVP].volume = 0;
		_visibleVP = i;
		// only show it if stream and skin ready
		if (_firstStreamShown) {
			_uiMgr.setupSkinAutoHide();
			_vp[_visibleVP].visible = true;
			if (!scrubbing) {
				_vp[_visibleVP].volume = _volume;
			}
		} else if (_vp[_visibleVP].stateResponsive && _vp[_visibleVP].state != DISCONNECTED && _uiMgr.skinReady) {
			_uiMgr.visible = true;
			_uiMgr.setupSkinAutoHide();
			_firstStreamReady = true;
			showFirstStream();
		}
			
		if (_vp[oldIndex].height != _vp[_visibleVP].height || _vp[oldIndex].width != _vp[_visibleVP].width) {
			dispatchEvent({type:"resize", x:this.x, y:this.y, width:this.width, height:this.height, auto:false, vp:_visibleVP});
		}
		// sending extra bogus events to UIManager so UI is updated propertly for new vp
		_uiMgr.handleEvent({type: "stateChange", state: _vp[_visibleVP].state, vp:_visibleVP});
		_uiMgr.handleEvent({type: "playheadUpdate", playheadTime: _vp[_visibleVP].playheadTime, vp:_visibleVP});
		if (_vp[_visibleVP].isRTMP) {
			_uiMgr.handleEvent({type: "ready", vp:_visibleVP});
		} else {
			_uiMgr.handleEvent({type: "progress", bytesLoaded: _vp[_visibleVP].bytesLoaded, bytesTotal: _vp[_visibleVP].bytesTotal, vp:_visibleVP});
		}
	}

	/**
	 * <p>Volume control in range from 0 to 100.</p>
	 *
	 * @return The most recent volume setting
	 * @tiptext The volume setting in value range from 0 to 100.
	 * @helpid 3468
	 * @see #transform
	 */
	[Inspectable(defaultValue=100)]
	[ChangeEvent("volumeUpdate")]
	[Bindable]
	public function get volume():Number
	{
		return _volume;
	}
	public function set volume(aVol:Number):Void
	{
		if (_volume == aVol) return;
		_volume = aVol;
		if (!scrubbing) {
			_vp[_visibleVP].volume = _volume;
		}
		dispatchEvent({type:"volumeUpdate", volume:aVol});
	}

	/**
	 * <p>volume control</p>
	 */
	public function get volumeBar():MovieClip {
		if (_uiMgr != null) _volumeBar = _uiMgr.getControl(UIManager.VOLUME_BAR);
		return _volumeBar;
	}
	public function set volumeBar(s:MovieClip):Void {
		_volumeBar = s;
		if (_uiMgr != null) _uiMgr.setControl(UIManager.VOLUME_BAR, s);
	}

	/**
	 * Determines how often check the volume bar handle location
	 * when scubbing, in milliseconds.  Default is 250.
	 * 
	 * @see UIManager#volumeBarInterval
	 * @see UIManager#VOLUME_BAR_INTERVAL_DEFAULT
	 */
	public function get volumeBarInterval():Number {
		if (_uiMgr != null) _volumeBarInterval = _uiMgr.volumeBarInterval
		return _volumeBarInterval;
	}
	public function set volumeBarInterval(s:Number) {
		_volumeBarInterval = s;
		if (_uiMgr != null) _uiMgr.volumeBarInterval = _volumeBarInterval;
	}

	/**
	 * <p>Determines how far user can move scrub bar before an update
	 * will occur.  Specified in percentage from 1 to 100.  Set to 0
	 * to indicate no scrub tolerance--always update volume on
	 * volumeBarInterval regardless of how far user has moved handle.
	 * Default is 0.</p>
	 *
	 * @see UIManager#volumeBarScrubTolerance
	 * @see UIManager#VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT
	 */
	public function get volumeBarScrubTolerance():Number {
		if (_uiMgr != null) _volumeBarScrubTolerance = _uiMgr.volumeBarScrubTolerance;
		return _volumeBarScrubTolerance;
	}
	public function set volumeBarScrubTolerance(s:Number) {
		_volumeBarScrubTolerance = s;
		if (_uiMgr != null) _uiMgr.volumeBarScrubTolerance = _volumeBarScrubTolerance;
	}

	/**
	 * <p>Width of video</p>
	 *
	 * @see #setSize()
	 * @helpid 0
	 */
	[ChangeEvent("resize")]
	[Bindable]
	public function get width():Number {
		if (_global.isLivePreview) return __width;			
		if (_vp[_visibleVP] != undefined) __width = _vp[_visibleVP].width;
		return __width;
	}
	public function set width(w:Number):Void {
		setSize(w, this.height);
	}

	[Bindable]
	public function get x():Number {
		return this._x;
	}
	public function set x(xpos:Number) {
		this._x = xpos;
	}

	[Bindable]
	public function get y():Number {
		return this._y;
	}
	public function set y(ypos:Number) {
		this._y = ypos;
	}


	//
	// private and package internal methods
	//


	/**
	 * Creates and configures VideoPlayer movie clip
	 *
	 * @private
	 */
	private function createVideoPlayer(index:Number):Void {
		if (_global.isLivePreview) return;
		// create
		var setWidth:Number = this.width;
		var setHeight:Number = this.height;
		_vp[index] = VideoPlayer(this.attachMovie("VideoPlayer", String(index), VP_DEPTH_OFFSET + index));
		_vp[index].setSize(setWidth, setHeight);
		_topVP = index;
		// init
		_vp[index].autoRewind = _autoRewind;
		_vp[index].autoSize = _autoSize;
		_vp[index].bufferTime = _bufferTime;
		_vp[index].idleTimeout = _idleTimeout;
		_vp[index].maintainAspectRatio = _aspectRatio;
		_vp[index].playheadUpdateInterval = _playheadUpdateInterval;
		_vp[index].progressInterval = _progressInterval;
		_vp[index].transform = _transform;
		_vp[index].volume = _volume;

		// init state object and start onEnterFrame if contentPath set
		if (index == 0) {
			_vpState[index] = { id:index, isLive:_isLive, isLiveSet:true, totalTime:_totalTime, totalTimeSet:true, autoPlay:_autoPlay };
			if (_contentPath != null && _contentPath != undefined && _contentPath != "") {
				_vp[index].onEnterFrame = Delegate.create(this, this.doContentPathConnect);
			}
		} else {
			_vpState[index] = { id:index, isLive:false, isLiveSet:true, totalTime:0, totalTimeSet:true, autoPlay:false };
		}


		// listen to events from VideoPlayer
		_vp[index].addEventListener("resize", this);
		_vp[index].addEventListener("close", this);
		_vp[index].addEventListener("complete", this);
		_vp[index].addEventListener("cuePoint", this);
		_vp[index].addEventListener("playheadUpdate", this);
		_vp[index].addEventListener("progress", this);
		_vp[index].addEventListener("metadataReceived", this);
		_vp[index].addEventListener("stateChange", this);
		_vp[index].addEventListener("ready", this);
		_vp[index].addEventListener("rewind", this);

		// create CuePointManager to pair with VideoPlayer
		_cpMgr[index] = new CuePointManager(this, index);
		_cpMgr[index].playheadUpdateInterval = _playheadUpdateInterval;
	}

	/**
	 * Creates UIManager and sets any properties that need setting
	 *
	 * @private
	 */
	private function createUIManager():Void {
		// create UIManager
		_uiMgr = new UIManager(this);

		// make skin invisible until "ready" and "skinLoaded" fired
		_uiMgr.visible = false;

		// set cached properties
		if (_backButton != null) {
			_uiMgr.setControl(UIManager.BACK_BUTTON, _backButton);
		}
		if (_bufferingBar != null) {
			_uiMgr.setControl(UIManager.BUFFERING_BAR, _bufferingBar);
		}
		_uiMgr.bufferingBarHidesAndDisablesOthers = _bufferingBarHides;
		if (_forwardButton != null) {
			_uiMgr.setControl(UIManager.FORWARD_BUTTON, _forwardButton);
		}
		if (_pauseButton != null) {
			_uiMgr.setControl(UIManager.PAUSE_BUTTON, _pauseButton);
		}
		if (_playButton != null) {
			_uiMgr.setControl(UIManager.PLAY_BUTTON, _playButton);
		}
		if (_playPauseButton != null) {
			_uiMgr.setControl(UIManager.PLAY_PAUSE_BUTTON, _playPauseButton);
		}
		if (_stopButton != null) {
			_uiMgr.setControl(UIManager.STOP_BUTTON, _stopButton);
		}
		if (_seekBar != null) {
			_uiMgr.setControl(UIManager.SEEK_BAR, _seekBar);
		}
		if (_seekBarInterval != null) {
			_uiMgr.seekBarInterval = _seekBarInterval;
		}
		if (_seekBarScrubTolerance != null) {
			_uiMgr.seekBarScrubTolerance = _seekBarScrubTolerance;
		}
		if (_skin != null) {
			_uiMgr.skin = _skin;
		}
		if (_skinAutoHide != null) {
			_uiMgr.skinAutoHide = _skinAutoHide;
		}
		if (_muteButton != null) {
			_uiMgr.setControl(UIManager.MUTE_BUTTON, _muteButton);
		}
		if (_volumeBar != null) {
			_uiMgr.setControl(UIManager.VOLUME_BAR, _volumeBar);
		}
		if (_volumeBarInterval != null) {
			_uiMgr.volumeBarInterval = _volumeBarInterval;
		}
		if (_volumeBarScrubTolerance != null) {
			_uiMgr.volumeBarScrubTolerance = _volumeBarScrubTolerance;
		}
	}

	/**

	 * Creates live preview placeholder
	 *
	 * @private
	 */
	private function createLivePreviewMovieClip():Void {
		preview_mc = this.createEmptyMovieClip("preview_mc", 10);
		preview_mc.createEmptyMovieClip("box_mc", 10);
		preview_mc.box_mc.beginFill(0x000000);
		preview_mc.box_mc.moveTo(0, 0);
		preview_mc.box_mc.lineTo(0, 100);
		preview_mc.box_mc.lineTo(100, 100);
		preview_mc.box_mc.lineTo(100, 0);
		preview_mc.box_mc.lineTo(0, 0);
		preview_mc.box_mc.endFill();
		preview_mc.attachMovie("Icon", "icon_mc", 20);
	}

	/**
	 * Called on <code>onEnterFrame</code> to initiate loading the new
	 * contentPath url.  We delay to give the user time to set other
	 * vars as well.  Only done this way when contentPath set from the
	 * component inspector or property inspector, not when set with AS.
	 *
	 * @see #contentPath
	 * @private
	 */
	private function doContentPathConnect():Void {
		delete _vp[0].onEnterFrame;
		_vp[0].onEnterFrame = undefined;
		if (_global.isLivePreview) return;
		if (_vpState[0].autoPlay && _firstStreamShown) {
			_vp[0].play(_contentPath, _isLive, _totalTime);
		} else {
			_vp[0].load(_contentPath, _isLive, _totalTime);
		}
		_vpState[0].isLiveSet = false;
		_vpState[0].totalTimeSet = false;
	}

	private function showFirstStream():Void {
		_firstStreamShown = true;
		_vp[_visibleVP].visible = true;
		if (!scrubbing) {
			_vp[_visibleVP].volume = _volume;
		}
		// play all autoPlay streams loaded into other video players
		// that have been waiting
		for (var i:Number = 0; i < _vp.length; i++) {
			if (_vp[i] != undefined && _vp[i].state == STOPPED && _vpState[i].autoPlay) {
				_vp[i].play();
			}
		}
	}

	/**
	 * Called by UIManager when seekbar scrubbing starts
	 *
	 * @private
	 */
	function _scrubStart():Void {
		var nowTime:Number = playheadTime;
		_vp[_visibleVP].volume = 0;
		dispatchEvent({type:"stateChange", state:SEEKING, playheadTime:nowTime, vp:_visibleVP});
		dispatchEvent({type:"scrubStart", state:SEEKING, playheadTime:nowTime});
	}

	/**
	 * Called by UIManager when seekbar scrubbing finishes
	 *
	 * @private
	 */
	function _scrubFinish():Void {
		var nowTime:Number = playheadTime;
		var nowState:String = state;
		_vp[_visibleVP].volume = _volume;
		if (nowState != SEEKING) {
			dispatchEvent({type:"stateChange", state:nowState, playheadTime:nowTime, vp:_visibleVP});
		}
		dispatchEvent({type:"scrubFinish", state:nowState, playheadTime:nowTime});
	}

	/**
	 * Called by UIManager when skin errors
	 *
	 * @private
	 */
	function skinError(message:String):Void {
		if (_firstStreamReady && !_firstStreamShown) {
			showFirstStream();
		}
		dispatchEvent({type:"skinError", message:message});
	}

	/**
	 * Called by UIManager when skin loads
	 *
	 * @private
	 */
	function skinLoaded():Void {
		if (_firstStreamReady) {
			_uiMgr.visible = true;
			if (!_firstStreamShown) {
				showFirstStream();
			}
		} else if (_contentPath == null || _contentPath == "") {
			_uiMgr.visible = true;
		}
		dispatchEvent({type:"skinLoaded"});
	}

	
	//ifdef DEBUG
	///**
	// * @private
	// */
	//function debugTrace(s:String):Void {
	//	if (_debuggingOn) {
	//		if (_debugFn != null) {
	//			_debugFn.call(null, s);
	//		} else {
	//			trace(s);
	//		}
	//	}
	//}
	//endif	
} // class mx.video.FLVPlayback
