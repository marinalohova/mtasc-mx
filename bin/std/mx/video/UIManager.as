// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.

import mx.utils.Delegate;
import mx.video.*;

/**
 * <p>Functions you can plugin to seek bar or volume bar with, to
 * override std behavior: startHandleDrag(), stopHandleDrag(),
 * positionHandle(), calcPercentageFromHandle(), positionBar().
 * Return true to override standard behavior or return false to allow
 * standard behavior to execute.  These do not override default
 * behavior, but allow you to add addl functionality:
 * addBarControl()</p>
 *
 * <p>Functions you can use for swf based skin controls: layoutSelf()
 * - called after control is laid out to do additional layout.
 * Properties that can be set to customize layout: anchorLeft,
 * anchorRight, anchorTop, anchorLeft.</p>
 *
 * <p>Possible seek bar and volume bar customization variables:
 * handleLeftMargin, handleRightMargin, handleY, handle_mc,
 * progressLeftMargin, progressRightMargin, progressY, progress_mc,
 * fullnessLeftMargin, fullnessRightMargin, fullnessY, fullness_mc,
 * percentage.  These variables will also be set to defaults by
 * UIManager if values are not passed in.  Percentage is constantly
 * updated, others will be set by UIManager in addBarControl or
 * finishAddBarControl.</p>
 *
 * <p>These seek bar and volume bar customization variables do not
 * work with external skin swfs and are not set if no value is passed
 * in: handleLinkageID, handleBelow, progressLinkageID, progressBelow,
 * fullnessLinkageID, fullnessBelow</p>
 *
 * <p>Note that in swf skins, handle_mc must have same parent as
 * correpsonding bar.  fullness_mc and progress_mc may be at the same
 * level or nested, and either of those may have a fill_mc at the same
 * level or nested.  Note that if any of these nestable clips are
 * nested, then they must be scaled at 100% on stage, because
 * UIManager uses xscale and yscale to resize them and assumes 100% is
 * the original size.  If they are not scaled at 100% when placed on
 * stage, weird stuff might happen.</p>
 *
 * <p>Variables set in seek bar and volume bar that can be used by
 * custom methods, but should be treated as read only: isDragging,
 * uiMgr, controlIndex.  Also set on handle mc: controlIndex</p>
 *
 * <p>Note that when skinAutoHide is true, skin is hidden unless
 * mouse if over visible VideoPlayer or over the skin.  Over the
 * skin is measured by hitTest on bg1_mc clip from the layout_mc.
 * If there is no bg1_mc, then mouse over the skin doesn't make
 * it visible (unless skin is completely over the video, of course.)</p>
 */
class mx.video.UIManager {

	#include "ComponentVersion.as"

	static var PAUSE_BUTTON:Number = 0;
	static var PLAY_BUTTON:Number = 1;
	static var STOP_BUTTON:Number = 2;
	static var SEEK_BAR_HANDLE:Number = 3;
	static var BACK_BUTTON:Number = 4;
	static var FORWARD_BUTTON:Number = 5;
	static var MUTE_ON_BUTTON:Number = 6;
	static var MUTE_OFF_BUTTON:Number = 7;
	static var VOLUME_BAR_HANDLE:Number = 8;
	static var NUM_BUTTONS:Number = 9;

	static var PLAY_PAUSE_BUTTON:Number = 9;
	static var MUTE_BUTTON:Number = 10;
	static var BUFFERING_BAR:Number = 11;
	static var SEEK_BAR:Number = 12;
	static var VOLUME_BAR:Number = 13;
	static var NUM_CONTROLS:Number = 14;
	
	static var UP_STATE:Number = 0;
	static var OVER_STATE:Number = 1;
	static var DOWN_STATE:Number = 2;

	// controls
	private var controls:Array;
	private var customClips:Array;       // bg1, bg2... and fg1, fg2... clips

	// for layout
	private var skin_mc:MovieClip;          // loaded skin swf
	private var skinLoader:MovieClipLoader;
	private var layout_mc:MovieClip;        // layout_mc from the skin_mc
	private var border_mc:MovieClip;        // determines bounds of whether mouse is over skin for autohide
	private var placeholderLeft:Number;
	private var placeholderRight:Number;
	private var placeholderTop:Number;
	private var placeholderBottom:Number;
	private var videoLeft:Number;
	private var videoRight:Number;
	private var videoTop:Number;
	private var videoBottom:Number;

	// properties
	private var _bufferingBarHides:Boolean;
	private var _controlsEnabled:Boolean;
	private var _skin:String;
	private var _skinAutoHide:Boolean;
	private var _skinReady:Boolean;
	private var __visible:Boolean;
	private var _seekBarInterval:Number;
	private var _seekBarScrubTolerance:Number;

	// progress
	private var _progressPercent:Number;
	
	//volume and mute
	private var cachedSoundLevel:Number;
	private var _lastVolumePos:Number;
	private var _isMuted:Boolean;
	private var _volumeBarInterval:Number;
	private var _volumeBarIntervalID:Number;
	private var _volumeBarScrubTolerance:Number;

	// my FLVPlayback
	var _vc:FLVPlayback;

	// buffering
	private var _bufferingDelayIntervalID:Number;
	private var _bufferingDelayInterval:Number;
	private var _bufferingOn:Boolean;

	// seeking
	private var _seekBarIntervalID:Number;
	private var _lastScrubPos:Number;
	private var _playAfterScrub:Boolean;

	// skin autohide
	private var _skinAutoHideIntervalID:Number;
	private static var SKIN_AUTO_HIDE_INTERVAL:Number = 200;
	
	/**
	 * Default value of volumeBarInterval
	 *
	 * @see #volumeBarInterval
	 */
	public static var VOLUME_BAR_INTERVAL_DEFAULT:Number = 250;

	/**
	 * Default value of volumeBarScrubTolerance.
	 *
	 * @see #volumeBarScrubTolerance
	 */
	public static var VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT:Number = 0;

	/**
	 * Default value of seekBarInterval
	 *
	 * @see #seekBarInterval
	 */
	public static var SEEK_BAR_INTERVAL_DEFAULT:Number = 250;

	/**
	 * Default value of seekBarScrubTolerance.
	 *
	 * @see #seekBarScrubTolerance
	 */
	public static var SEEK_BAR_SCRUB_TOLERANCE_DEFAULT:Number = 5;

	/**
	 * Default value of bufferingDelayInterval.
	 *
	 * @see #seekBarInterval
	 */
	public static var BUFFERING_DELAY_INTERVAL_DEFAULT:Number = 1000;

	/**
	 * UIManager.
	 */
	public function UIManager(vc:FLVPlayback) {
		// init properties
		_vc = vc;
		_skin = undefined;
		_skinAutoHide = false;
		_skinReady = true;
		__visible = true;
		_bufferingBarHides = false;
		_controlsEnabled = true;
		_lastScrubPos = 0;
		_lastVolumePos = 0;
		cachedSoundLevel = _vc.volume;
		_isMuted = false;
		controls = new Array();
		customClips = undefined;
		skin_mc = undefined;
		skinLoader = undefined;
		layout_mc = undefined;
		border_mc = undefined;
		_seekBarIntervalID = 0
		_seekBarInterval = SEEK_BAR_INTERVAL_DEFAULT;
		_seekBarScrubTolerance = SEEK_BAR_SCRUB_TOLERANCE_DEFAULT;
		_volumeBarIntervalID = 0
		_volumeBarInterval = VOLUME_BAR_INTERVAL_DEFAULT;
		_volumeBarScrubTolerance = VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT;
		_bufferingDelayIntervalID = 0
		_bufferingDelayInterval = BUFFERING_DELAY_INTERVAL_DEFAULT;
		_bufferingOn = false;
		_skinAutoHideIntervalID = 0;

		// listen to the VideoPlayer
		_vc.addEventListener("metadataReceived", this);
		_vc.addEventListener("playheadUpdate", this);
		_vc.addEventListener("progress", this);
		_vc.addEventListener("stateChange", this);
		_vc.addEventListener("ready", this);
		_vc.addEventListener("resize", this);
		_vc.addEventListener("volumeUpdate", this);
		
	}

	public function handleEvent(e:Object):Void {
		// UI only handles events from visible player, must set it to active
		if (e.vp != undefined && e.vp != _vc.visibleVideoPlayerIndex) return;

		// set activeVideoPlayerIndex to visibleVideoPlayerIndex
		var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
		_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

		//ifdef DEBUG
		////debugTrace("handleEvent :: " + e.type );
		//endif
		if (e.type == "stateChange") {
			if (e.state == FLVPlayback.BUFFERING) {
				if (!_bufferingOn) {
					clearInterval(_bufferingDelayIntervalID);
					_bufferingDelayIntervalID = setInterval(this, "doBufferingDelay", _bufferingDelayInterval);
				}
			} else {
				clearInterval(_bufferingDelayIntervalID);
				_bufferingDelayIntervalID = 0;
				_bufferingOn = false;
			}
			if (e.state == FLVPlayback.LOADING) {
				_progressPercent = (_vc.getVideoPlayer(e.vp).isRTMP) ? 100 : 0;
				for (var i:Number = SEEK_BAR; i <= VOLUME_BAR; i++) {
					var ctrl:MovieClip = controls[i];
					if (ctrl.progress_mc != undefined) {
						positionBar(ctrl, "progress", _progressPercent);
					}
				}
			}
			for (var i:Number = 0; i < NUM_CONTROLS; i++) {
				if (controls[i] == undefined) continue;
				setEnabledAndVisibleForState(i, e.state);
				if (i < NUM_BUTTONS) skinButtonControl(controls[i]);
			}
		} else if (e.type == "ready" || e.type == "metadataReceived") {
			for (var i:Number = 0; i < NUM_CONTROLS; i++) {
				if (controls[i] == undefined) continue;
				setEnabledAndVisibleForState(i, _vc.state);
				if (i < NUM_BUTTONS) skinButtonControl(controls[i]);
			}
			if (_vc.getVideoPlayer(e.vp).isRTMP) {
				_progressPercent = 100;
				for (var i:Number = SEEK_BAR; i <= VOLUME_BAR; i++) {
					var ctrl:MovieClip = controls[i];
					if (ctrl.progress_mc != undefined) {
						positionBar(ctrl, "progress", _progressPercent);
					}
				}
			}
		} else if (e.type == "resize") {
			layoutSkin();
			setupSkinAutoHide();
		} else if (e.type == "volumeUpdate") {
			if (_isMuted && e.volume > 0) {
				_isMuted = false;
				setEnabledAndVisibleForState(MUTE_OFF_BUTTON, FLVPlayback.PLAYING);
				skinButtonControl(controls[MUTE_OFF_BUTTON]);
				setEnabledAndVisibleForState(MUTE_ON_BUTTON, FLVPlayback.PLAYING);
				skinButtonControl(controls[MUTE_ON_BUTTON]);
			}
			var volumeBar:MovieClip = controls[VOLUME_BAR];
			volumeBar.percentage = (_isMuted) ? cachedSoundLevel : e.volume;
			if (volumeBar.percentage < 0) {
				volumeBar.percentage = 0;
			} else if (volumeBar.percentage > 100) {
				volumeBar.percentage = 100;
			}
			positionHandle(VOLUME_BAR);
		} else if (e.type == "playheadUpdate" && controls[SEEK_BAR] != undefined) {
			if (!_vc.isLive && _vc.totalTime > 0) {
				var percentage:Number = e.playheadTime / _vc.totalTime * 100;
				if (percentage < 0) {
					percentage = 0;
				} else if (percentage > 100) {
					percentage = 100;
				}
				var seekBar:MovieClip = controls[SEEK_BAR];
				seekBar.percentage = percentage;
				positionHandle(SEEK_BAR);
			}
		} else if (e.type == "progress") {
			_progressPercent = (e.bytesTotal <= 0) ? 100 : (e.bytesLoaded / e.bytesTotal * 100);
			var minProgressPercent:Number = _vc._vpState[e.vp].minProgressPercent;
			if (!isNaN(minProgressPercent) && minProgressPercent > _progressPercent) {
				_progressPercent = minProgressPercent;
			}
			if (_vc.totalTime > 0) {
				var playheadPercent:Number = _vc.playheadTime / _vc.totalTime * 100;
				if (playheadPercent > _progressPercent) {
					_progressPercent = playheadPercent;
					_vc._vpState[e.vp].minProgressPercent = _progressPercent;
				}
			}
			for (var i:Number = SEEK_BAR; i <= VOLUME_BAR; i++) {
				var ctrl:MovieClip = controls[i];
				if (ctrl.progress_mc != undefined) {
					positionBar(ctrl, "progress", _progressPercent);
				}
			}
		}
		
		// set activeVideoPlayerIndex back to prev value
		_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
	}

	/**
	 * <p>If true, we hide and disable certain controls when the
	 * buffering bar is displayed.  The seek bar will be hidden, the
	 * play, pause, play/pause, forward and back buttons would be
	 * disabled.  Default is false.  This only has effect if there
	 * is a buffering bar control.</p>
	 */
	public function get bufferingBarHidesAndDisablesOthers():Boolean {
		return _bufferingBarHides;
	}
	public function set bufferingBarHidesAndDisablesOthers(b:Boolean):Void {
		_bufferingBarHides = b;
	}

	public function get controlsEnabled():Boolean {
		return _controlsEnabled;
	}
	public function set controlsEnabled(flag:Boolean):Void {
		if (_controlsEnabled == flag) return;
		_controlsEnabled = flag;
		for (var i:Number = 0; i < NUM_BUTTONS; i++) {
			if (controls[i] == undefined) continue;
			controls[i].releaseCapture();
			controls[i].enabled = (_controlsEnabled && controls[i].myEnabled);
			skinButtonControl(controls[i]);
		}
	}

	public function get skin():String {
		return _skin;
	}
	public function set skin(s:String) {
		if (s == _skin) return;
		if (_skin != undefined) {
			removeSkin();
		}
		_skin = s;
		_skinReady = (_skin == null || _skin == "");
		if (!_skinReady) {
			downloadSkin();
		}
	}

	public function get skinAutoHide():Boolean {
		return _skinAutoHide;
	}
	public function set skinAutoHide(b:Boolean) {
		if (b == _skinAutoHide) return;
		_skinAutoHide = b;
		setupSkinAutoHide();
	}

	public function get skinReady():Boolean {
		return _skinReady;
	}

	/**
	 * Determines how often check the seek bar handle location when
	 * scubbing, in milliseconds.  Default is 250.
	 * 
	 * @see #SEEK_BAR_INTERVAL_DEFAULT
	 */
	public function get seekBarInterval():Number {
		return _seekBarInterval;
	}
	public function set seekBarInterval(s:Number) {
		if (_seekBarInterval == s) return;
		_seekBarInterval = s;
		if (_seekBarIntervalID > 0) {
			clearInterval(_seekBarIntervalID);
			_seekBarIntervalID = setInterval(this, "seekBarListener", _seekBarInterval, false);
		}
	}
	
	/**
	 * Determines how often check the volume bar handle location when
	 * scubbing, in milliseconds.  Default is 250.
	 * 
	 * @see #VOLUME_BAR_INTERVAL_DEFAULT
	 */
	public function get volumeBarInterval():Number {
		return _volumeBarInterval;
	}
	public function set volumeBarInterval(s:Number) {
		if (_volumeBarInterval == s) return;
		_volumeBarInterval = s;
		if (_volumeBarIntervalID > 0) {
			clearInterval(_volumeBarIntervalID);
			_volumeBarIntervalID = setInterval(this, "volumeBarListener", _volumeBarInterval, false);
		}
	}
	
	/**
	 * Determines how long after FLVPlayback.BUFFERING state entered
	 * we disable controls for buffering.  This delay is put into
	 * place to avoid annoying rapid switching between states.
	 * Default is 1000.
	 * 
	 * @see #BUFFERING_DELAY_INTERVAL_DEFAULT
	 */
	public function get bufferingDelayInterval():Number {
		return _bufferingDelayInterval;
	}
	public function set bufferingDelayInterval(s:Number) {
		if (_bufferingDelayInterval == s) return;
		_bufferingDelayInterval = s;
		if (_bufferingDelayIntervalID > 0) {
			clearInterval(_bufferingDelayIntervalID);
			_bufferingDelayIntervalID = setInterval(this, "doBufferingDelay", _bufferingDelayIntervalID);
		}
	}

	/**
	 * <p>Determines how far user can move scrub bar before an update
	 * will occur.  Specified in percentage from 1 to 100.  Set to 0
	 * to indicate no scrub tolerance--always update volume on
	 * volumeBarInterval regardless of how far user has moved handle.
	 * Default is 0.</p>
	 *
	 * @see #VOLUME_BAR_SCRUB_TOLERANCE_DEFAULT
	 */
	public function get volumeBarScrubTolerance():Number {
		return _volumeBarScrubTolerance;
	}
	public function set volumeBarScrubTolerance(s:Number) {
		_volumeBarScrubTolerance = s;
	}
	

	/**
	 * <p>Determines how far user can move scrub bar before an update
	 * will occur.  Specified in percentage from 1 to 100.  Set to 0
	 * to indicate no scrub tolerance--always update position on
	 * seekBarInterval regardless of how far user has moved handle.
	 * Default is 5.</p>
	 *
	 * @see #SEEK_BAR_SCRUB_TOLERANCE_DEFAULT
	 */
	public function get seekBarScrubTolerance():Number {
		return _seekBarScrubTolerance;
	}
	public function set seekBarScrubTolerance(s:Number) {
		_seekBarScrubTolerance = s;
	}

	/**
	 * whether or not skin swf controls
	 * should be shown or hidden
	 */
	public function get visible():Boolean {
		return __visible;
	}
	public function set visible(v:Boolean) {
		if (__visible == v) return;
		__visible = v;
		if (!__visible) {
			skin_mc._visible = false;
		} else {
			setupSkinAutoHide();
		}
	}

	function getControl(index:Number):MovieClip {
		return controls[index];
	}

	function setControl(index:Number, s:MovieClip) {
		// do nothing if the same
		if (s == null) s = undefined;
		if (s == controls[index]) return;

		// for some controls, extra stuff we do to keep connections correct
		switch (index) {
		case PAUSE_BUTTON:
		case PLAY_BUTTON:
			resetPlayPause();
			break;
		case PLAY_PAUSE_BUTTON:
			if (s._parent != layout_mc) {
				resetPlayPause();
				setControl(PAUSE_BUTTON, s.pause_mc);
				setControl(PLAY_BUTTON, s.play_mc);
			}
			break;
		case MUTE_BUTTON:
			if (s._parent != layout_mc) {
				setControl(MUTE_ON_BUTTON, s.on_mc);
				setControl(MUTE_OFF_BUTTON, s.off_mc);
			}
			break;
	
		} // switch

		if (index >= NUM_BUTTONS) {
			controls[index] = s;
			switch (index) {
			case SEEK_BAR:
				addBarControl(SEEK_BAR);
				break;
			case VOLUME_BAR:
				addBarControl(VOLUME_BAR);
				controls[VOLUME_BAR].percentage = _vc.volume;
				break;
			case BUFFERING_BAR:
				controls[BUFFERING_BAR].uiMgr = this;
				controls[BUFFERING_BAR].controlIndex = BUFFERING_BAR;
				// do right away if from loaded swf, wait to give time for
				// initialization if control defined in this swf
				if (controls[BUFFERING_BAR]._parent == skin_mc) {
					finishAddBufferingBar();
				} else {
					controls[BUFFERING_BAR].onEnterFrame = function() {
						this.uiMgr.finishAddBufferingBar();
					}
				}
				break;
			} // switch
			setEnabledAndVisibleForState(index, _vc.state);
		} else {
			removeButtonControl(index);
			controls[index] = s;
			addButtonControl(index);
		}
	}

	private function resetPlayPause():Void {
		if (controls[PLAY_PAUSE_BUTTON] == undefined) return;
		for (var i:Number = PAUSE_BUTTON; i <= PLAY_BUTTON; i++) {
			removeButtonControl(i);
		}
		controls[PLAY_PAUSE_BUTTON] = undefined;
	}

	private function addButtonControl(index:Number):Void {
		var ctrl:MovieClip = controls[index];
		if (ctrl == undefined) return;

		// set activeVideoPlayerIndex to visibleVideoPlayerIndex
		var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
		_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

		ctrl.id = index;
		ctrl.state = UP_STATE;
		ctrl.uiMgr = this;
		setEnabledAndVisibleForState(index, _vc.state);
		ctrl.onRollOver = function() {
			this.state = UIManager.OVER_STATE;
			this.uiMgr.skinButtonControl(this);
		}
		ctrl.onRollOut = function() {
			this.state = UIManager.UP_STATE;
			this.uiMgr.skinButtonControl(this);
		}

		if (index == SEEK_BAR_HANDLE || index == VOLUME_BAR_HANDLE ) {
			ctrl.onPress = function() {
				if (_root.focusManager) {
					this._focusrect = false;
					Selection.setFocus(this);
				}
				this.state = UIManager.DOWN_STATE;
				this.uiMgr.dispatchMessage(this);
				this.uiMgr.skinButtonControl(this);
			}
			ctrl.onRelease = function() {
				this.state = UIManager.OVER_STATE;
				this.uiMgr.handleRelease(this.controlIndex);
				this.uiMgr.skinButtonControl(this);
			}
			ctrl.onReleaseOutside = function() {
				this.state = UIManager.UP_STATE;
				this.uiMgr.handleRelease(this.controlIndex);
				this.uiMgr.skinButtonControl(this);
			}
		} else {
			ctrl.onPress = function() {
				if (_root.focusManager) {
					this._focusrect = false;
					Selection.setFocus(this);
				}
				this.state = UIManager.DOWN_STATE;
				this.uiMgr.skinButtonControl(this);
			}
			ctrl.onRelease = function() {
				this.state = UIManager.OVER_STATE;
				this.uiMgr.dispatchMessage(this);
				this.uiMgr.skinButtonControl(this);
			}
			ctrl.onReleaseOutside = function() {
				this.state = UIManager.UP_STATE;
				this.uiMgr.skinButtonControl(this);
			}
		}
		
		
		// do right away if from loaded swf, wait to give time for
		// initialization if control defined in this swf
		if (ctrl._parent == skin_mc) {
			skinButtonControl(ctrl);
		} else {
			ctrl.onEnterFrame = function() {
				this.uiMgr.skinButtonControl(this);
			}
		}

		// set activeVideoPlayerIndex back to prev value
		_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
	}

	private function removeButtonControl(index:Number):Void {
		if (controls[index] == undefined) return;
		controls[index].uiMgr = undefined;
		controls[index].onRollOver = undefined;
		controls[index].onRollOut = undefined;
		controls[index].onPress = undefined;
		controls[index].onRelease = undefined;
		controls[index].onReleaseOutside = undefined;
		controls[index] = undefined;
	}

	/**
	 * start download of skin swf, called when skin property set.
	 *
	 * @private
	 */
	private function downloadSkin():Void {
		if (skinLoader == undefined) {
			skinLoader = new MovieClipLoader();
			skinLoader.addListener(this);
		}
		if (skin_mc == undefined) {
			skin_mc = _vc.createEmptyMovieClip("skin_mc", _vc.getNextHighestDepth());
		}
		skin_mc._visible = false;
		skin_mc._x = Stage.width + 100;
		skin_mc._y = Stage.height + 100;
		skinLoader.loadClip(_skin, skin_mc);
	}

	/**
	 * MovieClipLoader event handler function
	 */
	private function onLoadError(target_mc:MovieClip, errorCode:String):Void {
		_skinReady = true;
		_vc.skinError("Unable to load skin swf");
	}

	/**
	 * MovieClipLoader event handler function
	 */
	private function onLoadInit():Void {
		try {
			skin_mc._visible = false;
			skin_mc._x = 0;
			skin_mc._y = 0;
			// get layout_mc from skin swf.  This defines the layout
			layout_mc = skin_mc.layout_mc;
			if (layout_mc == undefined) throw new Error("No layout_mc");
			layout_mc._visible = false;
	
			// load any custom background clips
			customClips = new Array();
			setCustomClips("bg");
	
			// load all the controls
			if (layout_mc.playpause_mc != undefined) {
				setSkin(PLAY_PAUSE_BUTTON, layout_mc.playpause_mc);
			} else {
				setSkin(PAUSE_BUTTON, layout_mc.pause_mc);
				setSkin(PLAY_BUTTON, layout_mc.play_mc);
			}
			setSkin(STOP_BUTTON, layout_mc.stop_mc);
			setSkin(BACK_BUTTON, layout_mc.back_mc);
			setSkin(FORWARD_BUTTON, layout_mc.forward_mc);
			setSkin(MUTE_BUTTON, layout_mc.volumeMute_mc);
			setSkin(SEEK_BAR, layout_mc.seekBar_mc);
			setSkin(VOLUME_BAR, layout_mc.volumeBar_mc);
			setSkin(BUFFERING_BAR, layout_mc.bufferingBar_mc);
			
			// load any custom foreground clips
			setCustomClips("fg");
	
			// layout all the clips and controls
			layoutSkin();
			setupSkinAutoHide();
			skin_mc._visible = __visible;

			_skinReady = true;
			_vc.skinLoaded();

			// set activeVideoPlayerIndex to visibleVideoPlayerIndex
			var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
			_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;
			
			// set enabledness for current state
			var state:String = _vc.state;
			for (var i:Number = 0; i < NUM_CONTROLS; i++) {
				if (controls[i] == undefined) continue;
				setEnabledAndVisibleForState(i, state);
				if (i < NUM_BUTTONS) skinButtonControl(controls[i]);
			}

			// set activeVideoPlayerIndex back to prev value
			_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
			
		} catch (err:Error) {
			_vc.skinError(err.message);
			removeSkin();
		}
	}

	/**
	 * layout all controls from loaded swf
	 *
	 * @private
	 */
	function layoutSkin():Void {
		if (layout_mc == undefined) return;
		// get bounds of placeholder
		var video_mc:MovieClip = layout_mc.video_mc;
		if (video_mc == undefined) throw new Error("No layout_mc.video_mc");
		placeholderLeft = video_mc._x;
		placeholderRight = video_mc._x + video_mc._width;
		placeholderTop = video_mc._y;
		placeholderBottom = video_mc._y + video_mc._height;

		// get bounds of real video
		videoLeft = 0;
		videoRight = _vc.width;
		videoTop = 0;
		videoBottom = _vc.height;

		// do not go below min dimensions
		if (!isNaN(layout_mc.minWidth) && layout_mc.minWidth > 0 && layout_mc.minWidth > videoRight) {
			videoLeft -= ((layout_mc.minWidth - videoRight) / 2);
			videoRight = layout_mc.minWidth + videoLeft;
		}
		if (!isNaN(layout_mc.minHeight) && layout_mc.minHeight > 0 && layout_mc.minHeight > videoBottom) {
			videoTop -= ((layout_mc.minHeight - videoBottom) / 2);
			videoBottom = layout_mc.minHeight + videoTop;
		}

		// iterate over customClips
		var i:Number;
		for (i = 0; i < customClips.length; i++) {
			layoutControl(customClips[i]);
		}
		// iterate over controls
		for (i = 0; i < NUM_CONTROLS; i++) {
			layoutControl(controls[i]);
		}
	}

	/**
	 * layout individual control from loaded swf
	 *
	 * @private
	 */
	private function layoutControl(ctrl:MovieClip):Void {
		if (ctrl == undefined) return;
		if (ctrl.skin.anchorRight) {
			if (ctrl.skin.anchorLeft) {
				ctrl._x = ctrl.skin._x - placeholderLeft + videoLeft;
				ctrl._width = ctrl.skin._x + ctrl.skin._width - placeholderRight + videoRight - ctrl._x;
				if (ctrl.origWidth != undefined) ctrl.origWidth = undefined;
			} else {
				ctrl._x = ctrl.skin._x - placeholderRight + videoRight;
			}
		} else {
			ctrl._x = ctrl.skin._x - placeholderLeft + videoLeft;
		}
		if (ctrl.skin.anchorTop) {
			if (ctrl.skin.anchorBottom) {
				ctrl._y = ctrl.skin._y - placeholderTop + videoTop;
				ctrl._height = ctrl.skin._y + ctrl.skin._height - placeholderBottom + videoBottom - ctrl._y;
				if (ctrl.origHeight != undefined) ctrl.origHeight = undefined;

			} else {
				ctrl._y = ctrl.skin._y - placeholderTop + videoTop;
			}
		} else {
			ctrl._y = ctrl.skin._y - placeholderBottom + videoBottom;
		}

		switch (ctrl.controlIndex) {
		case SEEK_BAR:
		case VOLUME_BAR:
			if (ctrl.progress_mc != undefined) {
				if (_progressPercent == undefined) {
					_progressPercent = (_vc.isRTMP ? 100 : 0);
				}
				positionBar(ctrl, "progress", _progressPercent);
			}
			positionHandle(ctrl.controlIndex);
			break;
		case BUFFERING_BAR:
			if (ctrl.fill_mc != undefined) {
				positionMaskedFill(ctrl, ctrl.fill_mc, 100);
			}
			break;
		}

		// optional callback
		if (ctrl.layoutSelf != undefined) ctrl.layoutSelf();
	}

	/**
	 * remove controls from prev skin swf
	 *
	 * @private
	 */
	private function removeSkin():Void {
		if (skin_mc != undefined) {
			for (var i:Number = 0; i < NUM_BUTTONS; i++) {
				removeButtonControl(i);
			}
			for (var i:Number = NUM_BUTTONS; i < NUM_CONTROLS; i++) {
				controls[i] = undefined;
			}
			skin_mc.unloadMovie();
			layout_mc = undefined;
			border_mc = undefined;
		}
	}

	/**
	 * set custom clip from loaded swf
	 *
	 * @private
	 */
	private function setCustomClips(prefix:String):Void {
		var i:Number = 1;
		while (true) {
			var clip:MovieClip = layout_mc[prefix + i++ + "_mc"];
			if (clip == undefined) break;
			var ctrl:MovieClip = clip.mc;
			// default is movie clip with same instance name at root
			if (ctrl == undefined) ctrl = clip._parent._parent[clip._name];
			if (ctrl == undefined) throw new Error("Bad clip in skin: " + clip);
			ctrl.skin = clip;
			customClips.push(ctrl);

			// take bg1 for border_mc
			if (prefix == "bg" && i == 2) {
				border_mc = ctrl;
			}
		}
	}

	/**
	 * set skin clip from loaded swf
	 *
	 * @private
	 */
	private function setSkin(index:Number, s:MovieClip):Void {

		if (s == undefined) return;
		var ctrl:MovieClip = s.mc;
		if (ctrl == undefined) ctrl = s._parent._parent[s._name];
		if (ctrl == undefined) throw new Error("Bad clip in skin: " + s);

		ctrl.skin = s;
			
		if (index < NUM_BUTTONS) {
			setupSkinStates(ctrl);
		} else {
			switch (index) {
			case PLAY_PAUSE_BUTTON:
				setupSkinStates(ctrl.play_mc)
				setupSkinStates(ctrl.pause_mc)
				break;
			case MUTE_BUTTON:
				setupSkinStates(ctrl.on_mc)
				setupSkinStates(ctrl.off_mc)
				break;
			case SEEK_BAR:
			case VOLUME_BAR:
				var type:String = (index == SEEK_BAR) ? "seekBar" : "volumeBar";
				if (ctrl.handle_mc == undefined) {
					ctrl.handle_mc = ctrl.skin.handle_mc;
					if (ctrl.handle_mc == undefined) {
						ctrl.handle_mc = ctrl.skin._parent._parent[type + "Handle_mc"];
					}
				}
				if (ctrl.progress_mc == undefined) {
					ctrl.progress_mc = ctrl.skin.progress_mc;
					if (ctrl.progress_mc == undefined) {
						ctrl.progress_mc = ctrl.skin._parent._parent[type + "Progress_mc"];
					}
				}
				if (ctrl.fullness_mc == undefined) {
					ctrl.fullness_mc = ctrl.skin.fullness_mc;
					if (ctrl.fullness_mc == undefined) {
						ctrl.fullness_mc = ctrl.skin._parent._parent[type + "Fullness_mc"];
					}
				}
				break;
			case BUFFERING_BAR:
				if (ctrl.fill_mc == undefined) {
					ctrl.fill_mc = ctrl.skin.fill_mc;
					if (ctrl.fill_mc == undefined) {
						ctrl.fill_mc = ctrl.skin._parent._parent.bufferingBarFill_mc;
					}
				}
				break;
			}
		}
		setControl(index, ctrl);
	}
	/**
	 * will layout the contnents of a toggle buton - for debugging - this is temporary will roll into setSkin
	 *
	 * @private
	 */
	private function setupSkinStates(ctrl:MovieClip):Void {
		// if no up_mc, then we have no states at all
		if (ctrl.up_mc == undefined) {
			ctrl.up_mc = ctrl;
			ctrl.over_mc = ctrl;
			ctrl.down_mc = ctrl;
			ctrl.disabled_mc = ctrl;
		} else {
			ctrl._x = 0;
			ctrl._y = 0;
			ctrl.up_mc._x = 0;
			ctrl.up_mc._y = 0;
			ctrl.up_mc._visible = true;
			if (ctrl.over_mc == undefined) {
				ctrl.over_mc = ctrl.up_mc;
			} else {
				ctrl.over_mc._x = 0;
				ctrl.over_mc._y = 0;
				ctrl.over_mc._visible = false;
			}
			if (ctrl.down_mc == undefined) {
				ctrl.down_mc = ctrl.up_mc;
			} else {
				ctrl.down_mc._x = 0;
				ctrl.down_mc._y = 0;
				ctrl.down_mc._visible = false;
			}
			if (ctrl.disabled_mc == undefined) {
				ctrl.disabled_mc_mc = ctrl.up_mc;
			} else {
				ctrl.disabled_mc._x = 0;
				ctrl.disabled_mc._y = 0;
				ctrl.disabled_mc._visible = false;
			}
		}
	}

	/**
	 * skin button
	 *
	 * @private
	 */
	private function skinButtonControl(ctrl:MovieClip):Void {
		if (ctrl.onEnterFrame != undefined) {
			delete ctrl.onEnterFrame;
			ctrl.onEnterFrame = undefined;
		}
		if (ctrl.enabled) {
			switch (ctrl.state) {
			case UP_STATE:
				if (ctrl.up_mc == undefined) {
					ctrl.up_mc = ctrl.attachMovie(ctrl.upLinkageID, "up_mc", ctrl.getNextHighestDepth());
				}
				applySkinState(ctrl, ctrl.up_mc);
				break;
			case OVER_STATE:
				if (ctrl.over_mc == undefined) {
					if (ctrl.overLinkageID == undefined) {
						ctrl.over_mc = ctrl.up_mc;
					} else {
						ctrl.over_mc = ctrl.attachMovie(ctrl.overLinkageID, "over_mc", ctrl.getNextHighestDepth());
					}
				}
				applySkinState(ctrl, ctrl.over_mc);
				break;
			case DOWN_STATE:
				if (ctrl.down_mc == undefined) {
					if (ctrl.downLinkageID == undefined) {
						ctrl.down_mc = ctrl.up_mc;
					} else {
						ctrl.down_mc = ctrl.attachMovie(ctrl.downLinkageID, "down_mc", ctrl.getNextHighestDepth());
					}
				}
				applySkinState(ctrl, ctrl.down_mc);
				break;
			} // switch
		} else {
			ctrl.state = UP_STATE;
			if (ctrl.disabled_mc == undefined) {
				if (ctrl.disabledLinkageID == undefined) {
					ctrl.disabled_mc = ctrl.up_mc;
				} else {
					ctrl.disabled_mc = ctrl.attachMovie(ctrl.disabledLinkageID, "disabled_mc", ctrl.getNextHighestDepth());
				}
			}
			applySkinState(ctrl, ctrl.disabled_mc);
		}
		if (ctrl.placeholder_mc != undefined) {
			ctrl.placeholder_mc.unloadMovie();
			delete ctrl.placeholder_mc;
			ctrl.placeholder_mc = undefined;
		}
	}

	/**
	 * helper to skin button
	 *
	 * @private
	 */
	private function applySkinState(ctrl:MovieClip, state:MovieClip):Void {
		if (state != ctrl.currentState_mc) {
			if (state != undefined) state._visible = true;
			if (ctrl.currentState_mc != undefined) ctrl.currentState_mc._visible = false;
			ctrl.currentState_mc = state;
		}
	}
		
	/**
	 * adds seek bar or volume bar
	 *
	 * @private
	 */
	private function addBarControl(controlIndex:Number):Void {
		var ctrl:MovieClip = controls[controlIndex];

		// init vars
		ctrl.isDragging = false;
		ctrl.percentage = 0;
		ctrl.uiMgr = this;
		ctrl.controlIndex = controlIndex;

		// do right away if from loaded swf, wait to give time for
		// initialization if control defined in this swf
		if (ctrl._parent == skin_mc) {
			finishAddBarControl(controlIndex);
		} else {
			ctrl.onEnterFrame = function() {
				this.uiMgr.finishAddBarControl(this.controlIndex);
			}
		}
	}

	/**
	 * finish adding seek bar or volume bar onEnterFrame to allow for
	 * initialization to complete
	 *
	 * @private
	 */
	private function finishAddBarControl(controlIndex:Number) {
		var ctrl:MovieClip = controls[controlIndex];

		// ditch the onEnterFrame
		delete ctrl.onEnterFrame;
		ctrl.onEnterFrame = undefined;

		// opportunity for custom init code
		if (ctrl.addBarControl != undefined) {
			ctrl.addBarControl();
		}

		// set the margins
		calcBarMargins(ctrl, "handle", true);
		calcBarMargins(ctrl, "progress", false);
		calcBarMargins(ctrl.progress_mc, "fill", false);
		calcBarMargins(ctrl.progress_mc, "mask", false);
		calcBarMargins(ctrl, "fullness", false);
		calcBarMargins(ctrl.fullness_mc, "fill", false);
		calcBarMargins(ctrl.fullness_mc, "mask", false);

		// save orig width and height, used for bars that are not
		// scaled.  If they are scaled in layoutControl, we will
		// set this to undefined so it will be ignored.
		ctrl.origWidth = ctrl._width;
		ctrl.origHeight = ctrl._height;

		// fix up and position the progress bar
		fixUpBar(ctrl, "progress");
		if (ctrl.progress_mc != undefined) {
			fixUpBar(ctrl, "progressBarFill");
			if (_progressPercent == undefined) {
				_progressPercent = (_vc.isRTMP ? 100 : 0);
			}
			positionBar(ctrl, "progress", _progressPercent);
		}

		// fix up the fullness bar, positioned by positionHandle
		fixUpBar(ctrl, "fullness");
		if (ctrl.fullness_mc != undefined) {
			fixUpBar(ctrl, "fullnessBarFill");
		}

		// fix up and position the handle
		fixUpBar(ctrl, "handle");
		ctrl.handle_mc.controlIndex = controlIndex;
		switch (controlIndex) {
		case SEEK_BAR:
			setControl(SEEK_BAR_HANDLE, ctrl.handle_mc);
			break;
		case VOLUME_BAR:
			setControl(VOLUME_BAR_HANDLE, ctrl.handle_mc);
			break;
		} // switch
		positionHandle(controlIndex);
	}

	/**
	 * Fix up progres or fullness bar
	 *
	 * @private
	 */
	private function fixUpBar(ctrl:MovieClip, type:String):Void {
		if (ctrl[type + "LinkageID"] != undefined && ctrl[type + "LinkageID"].length > 0) {
			var depth:Number;
			if (ctrl[type + "Below"]) {
				depth = -1;
				while (ctrl._parent.getInstanceAtDepth(depth) != undefined) {
					depth--;
				}
			} else {
				ctrl[type + "Below"] = false;
				depth = ctrl._parent.getNextHighestDepth();
			}
			// upper case the first character of type for the instance name to put it
			// in standard camel case notation
			var prefix:String = (ctrl.controlIndex == SEEK_BAR) ? "seekBar" : "volumeBar";
			var instanceName = prefix + type.substring(0, 1).toUpperCase() + type.substring(1) + "_mc";
			ctrl[type + "_mc"] = ctrl._parent.attachMovie(ctrl[type + "LinkageID"], instanceName, depth);
		}
	}

	/**
	 * Gets left and right margins for progress or fullness
	 *
	 * @private
	 */
	private function calcBarMargins(ctrl:MovieClip, type:String, symmetricMargins:Boolean):Void {
		//ifdef DEBUG
		//debugTrace("calcBarMargins(" + ctrl + ", " + type + ", " + symmetricMargins + ")");
		//endif
		var bar:MovieClip = ctrl[type + "_mc"];
		if (bar == undefined) return;

		if (ctrl[type + "LeftMargin"] == undefined && bar._parent == ctrl._parent) {
			ctrl[type + "LeftMargin"] = bar._x - ctrl._x;
		}

		if (ctrl[type + "RightMargin"] == undefined) {
			if (symmetricMargins) {
				ctrl[type + "RightMargin"] = ctrl[type + "LeftMargin"];
			} else if (bar._parent == ctrl._parent) {
				ctrl[type + "RightMargin"] = ctrl._width - bar._width - bar._x + ctrl._x;
			}
		}

		if (ctrl[type + "TopMargin"] == undefined && bar._parent == ctrl._parent) {
			ctrl[type + "TopMargin"] = bar._y - ctrl._y;
		}

		if (ctrl[type + "BottomMargin"] == undefined) {
			if (symmetricMargins) {
				ctrl[type + "BottomMargin"] = ctrl[type + "TopMargin"];
			} else if (bar._parent == ctrl._parent) {
				ctrl[type + "BottomMargin"] = ctrl._height - bar._height - bar._y + ctrl._y;
			}
		}

		if (ctrl[type + "X"] == undefined) {
			if (bar._parent == ctrl._parent) {
				ctrl[type + "X"] = bar._x - ctrl._x;
			} else if (bar._parent == ctrl) {
				ctrl[type + "X"] = bar._x;
			}
		}

		if (ctrl[type + "Y"] == undefined) {
			if (bar._parent == ctrl._parent) {
				ctrl[type + "Y"] = bar._y - ctrl._y;
			} else if (bar._parent == ctrl) {
				ctrl[type + "Y"] = bar._y;
			}
		}

		// grab the orig values
		ctrl[type + "XScale"] = bar._xscale;
		ctrl[type + "YScale"] = bar._yscale;
		ctrl[type + "Width"] = bar._width;
		ctrl[type + "Height"] = bar._height;

		//ifdef DEBUG
		//debugTrace(type + "LeftMargin = " + ctrl[type + "LeftMargin"]);
		//debugTrace(type + "RightMargin = " + ctrl[type + "RightMargin"]);
		//debugTrace(type + "TopMargin = " + ctrl[type + "TopMargin"]);
		//debugTrace(type + "BottomMargin = " + ctrl[type + "BottomMargin"]);
		//debugTrace(type + "X = " + ctrl[type + "X"]);
		//debugTrace(type + "Y = " + ctrl[type + "Y"]);
		//debugTrace(type + "XScale = " + ctrl[type + "XScale"]);
		//debugTrace(type + "YScale = " + ctrl[type + "YScale"]);
		//debugTrace(type + "Width = " + ctrl[type + "Width"]);
		//debugTrace(type + "Height = " + ctrl[type + "Height"]);
		//endif
	}
	
	/**
	 * finish adding buffer bar onEnterFrame to allow for initialization to complete
	 *
	 * @private
	 */
	private function finishAddBufferingBar() {
		var bufferingBar:MovieClip = controls[BUFFERING_BAR];

		// ditch the onEnterFrame
		delete bufferingBar.onEnterFrame;
		bufferingBar.onEnterFrame = undefined;

		// set the margins
		calcBarMargins(bufferingBar, "fill", true);

		// fix up the fill
		fixUpBar(bufferingBar, "fill");
		
		// position the fill
		if (bufferingBar.fill_mc != undefined) {
			positionMaskedFill(bufferingBar, bufferingBar.fill_mc, 100);
		}
	}
	
	/**
	 * Place the buffering pattern and mask over the buffering bar
	 * @private
	 */
	private function positionMaskedFill(ctrl:MovieClip, fill:MovieClip, percent:Number):Void {
		// create mask if necessary
		var theParent:MovieClip = fill._parent;
		var mask:MovieClip = ctrl.mask_mc;
		if (mask == undefined) {
			mask = theParent.createEmptyMovieClip(ctrl._name + "Mask_mc", theParent.getNextHighestDepth());
			ctrl.mask_mc = mask;
			mask.beginFill(0xffffff);
			mask.lineTo(0,0);
			mask.lineTo(1,0);
			mask.lineTo(1,1);
			mask.lineTo(0,1);
			mask.lineTo(0,0);
			mask.endFill();
			fill.setMask(mask);
			mask._x = ctrl.fillX;
			mask._y = ctrl.fillY;
			mask._width = ctrl.fillWidth;
			mask._height = ctrl.fillHeight;
			mask._visible = false;
			calcBarMargins(ctrl, "mask", true);
		}

		if (theParent == ctrl) {
			if (fill.slideReveal) {
				// slide fill, mask stays put
				fill._x = ctrl.maskX - ctrl.fillWidth + (ctrl.fillWidth * percent / 100);
			} else {
				// resize mask
				mask._width = ctrl.fillWidth * percent / 100;
			}
		} else if (theParent == ctrl._parent) {
			// in neither of these cases do we ever scale the fill_mc, we just scale the mask
			// and move the fill_mc around, so for skin swf case will usually make sense to
			// make a very long fill_mc that will always be long enough
			if (fill.slideReveal) {
				// place and size mask
				mask._x = ctrl._x + ctrl.maskLeftMargin
				mask._y = ctrl._y + ctrl.maskTopMargin;
				mask._width = ctrl._width - ctrl.maskRightMargin - ctrl.maskLeftMargin;
				mask._height = ctrl._height - ctrl.maskTopMargin - ctrl.maskBottomMargin;

				// put fill in correct place
				fill._x = mask._x - ctrl.fillWidth + (ctrl.maskWidth * percent / 100);
				fill._y = ctrl._y + ctrl.fillTopMargin;
			} else {
				// put fill in correct place, do not scale
				fill._x = ctrl._x + ctrl.fillLeftMargin;
				fill._y = ctrl._y + ctrl.fillTopMargin;
				
				// place mask
				mask._x = fill._x;
				mask._y = fill._y;
				mask._width = (ctrl._width - ctrl.fillRightMargin - ctrl.fillLeftMargin) * percent / 100;
				mask._height = ctrl._height - ctrl.fillTopMargin - ctrl.fillBottomMargin;
			}
		}
	}

	/**
	 * Default startHandleDrag function (can be defined on seek bar
	 * movie clip instance) to handle start dragging the seek bar
	 * handle or volume bar handle.
	 *
	 * @private
	 */
	private function startHandleDrag(controlIndex:Number):Void {
		//ifdef DEBUG
		//debugTrace("startHandleDrag()");
		//endif
		var ctrl:MovieClip = controls[controlIndex];
		var handle:MovieClip = ctrl.handle_mc;

		// call custom implementation instead, if available
		if (ctrl.startHandleDrag == undefined || !ctrl.startHandleDrag()) {
			// calc constriction coords and start drag
			var theY = ctrl._y + ctrl.handleY;
			var theWidth = (ctrl.origWidth == undefined) ? ctrl._width : ctrl.origWidth;
			handle.startDrag( false,
			                  ctrl._x + ctrl.handleLeftMargin,
			                  theY,
			                  ctrl._x + theWidth - ctrl.handleRightMargin,
			                  theY );
		}
		ctrl.isDragging = true;
	}
	
	/**
	 * Default stopHandleDrag function (can be defined on seek bar
	 * movie clip instance) to handle stop dragging the seek bar
	 * handle or volume bar handle.
	 *
	 * @private
	 */
	private function stopHandleDrag(controlIndex:Number):Void {
		//ifdef DEBUG
		//debugTrace("stopHandleDrag()");
		//endif
		var ctrl:MovieClip = controls[controlIndex];
		var handle:MovieClip = ctrl.handle_mc;

		// call custom implementation instead, if available
		if (ctrl.stopHandleDrag == undefined || !ctrl.stopHandleDrag()) {
			// stop drag
			handle.stopDrag();
		}

		ctrl.isDragging = false;
	}

	/**
	 * Default positionHandle function (can be defined on seek bar
	 * movie clip instance) to handle positioning seek bar handle.
	 *
	 * @private
	 */
	private function positionHandle(controlIndex:Number):Void {
		var ctrl:MovieClip = controls[controlIndex];
		var handle:MovieClip = ctrl.handle_mc;
		if (handle == undefined) return;

		// call custom implementation instead, if available
		if (ctrl.positionHandle != undefined && ctrl.positionHandle()) {
			return;
		}

		var theWidth = (ctrl.origWidth == undefined) ? ctrl._width : ctrl.origWidth;
		var handleSpanLength:Number = theWidth - ctrl.handleRightMargin - ctrl.handleLeftMargin;
		handle._x = ctrl._x + ctrl.handleLeftMargin + (handleSpanLength * ctrl.percentage / 100);
		handle._y = ctrl._y + ctrl.handleY;

		// set fullness mask clip if there is one
		if (ctrl.fullness_mc != undefined) {
			positionBar(ctrl, "fullness", ctrl.percentage);
		}
	}

	/**
	 * helper for other positioning funcs
	 *
	 * @private
	 */
	private function positionBar(ctrl:MovieClip, type:String, percent:Number):Void {
		if (ctrl.positionBar != undefined && ctrl.positionBar(type, percent)) {
			return;
		}
		var bar:MovieClip = ctrl[type + "_mc"];
		if (bar._parent == ctrl) {
			// don't move me, just scale me relative to myself, since
			// I'm already scaled with the parent clip
			if (bar.fill_mc == undefined) {
				bar._xscale = ctrl[type + "XScale"] * percent / 100;
			} else {
				positionMaskedFill(bar, bar.fill_mc, percent);
			}
		} else {
			// assume I'm at the same level of the parent clip, so
			// move and scale to match, taking margins and y pos into
			// account
			bar._x = ctrl._x + ctrl[type + "LeftMargin"];
			bar._y = ctrl._y + ctrl[type + "Y"];
			if (bar.fill_mc == undefined) {
				bar._width = (ctrl._width - ctrl[type + "LeftMargin"] - ctrl[type + "RightMargin"]) * percent / 100;
			} else {
				positionMaskedFill(bar, bar.fill_mc, percent);
			}
		}
	}
	
	/**
	 * Default calcPercentageFromHandle function (can be defined on
	 * seek bar movie clip instance) to handle calculating percentage
	 * from seek bar handle position.
	 *
	 * @private
	 */
	private function calcPercentageFromHandle(controlIndex:Number):Void {
		var ctrl:MovieClip = controls[controlIndex];
		var handle:MovieClip = ctrl.handle_mc;

		// call custom implementation instead, if available
		if (ctrl.calcPercentageFromHandle == undefined || !ctrl.calcPercentageFromHandle()) {
			var theWidth = (ctrl.origWidth == undefined) ? ctrl._width : ctrl.origWidth;
			var handleSpanLength:Number = theWidth - ctrl.handleRightMargin - ctrl.handleLeftMargin;
			var handleLoc:Number = handle._x - (ctrl._x + ctrl.handleLeftMargin);
			ctrl.percentage = handleLoc / handleSpanLength * 100;

			// set fullness mask clip if there is one
			if (ctrl.fullness_mc != undefined) {
				positionBar(ctrl, "fullness", ctrl.percentage);
			}
		}

		// sanity
		if (ctrl.percentage < 0) ctrl.percentage = 0;
		if (ctrl.percentage > 100) ctrl.percentage = 100;
	}

	/**
	 * Called to signal end of seek bar scrub.  Call from
	 * onRelease and onReleaseOutside event listeners.
	 *
	 * @private
	 */		
	private function handleRelease(controlIndex:Number):Void {
		//ifdef DEBUG
		//debugTrace("handleRelease()");
		//endif

		// set activeVideoPlayerIndex to visibleVideoPlayerIndex
		var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
		_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

		if (controlIndex == SEEK_BAR) {
			seekBarListener(true);
		} else if (controlIndex == VOLUME_BAR) {
			volumeBarListener(true);
		}
		stopHandleDrag(controlIndex);

		// set activeVideoPlayerIndex back to prev value
		_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;

		if (controlIndex == SEEK_BAR) {
			_vc._scrubFinish();
		}
	}
	
	/**
	 * Called on interval when user scrubbing by dragging seekbar handle.
	 *
	 * @private
	 */
	function seekBarListener(finish:Boolean):Void {
		// set activeVideoPlayerIndex to visibleVideoPlayerIndex
		var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
		_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;
		
		var seekBar:MovieClip = controls[SEEK_BAR];
		calcPercentageFromHandle(SEEK_BAR);
		var scrubPos:Number = seekBar.percentage;
		if (finish) {
			clearInterval(_seekBarIntervalID);
			_seekBarIntervalID = 0;
			if (scrubPos != _lastScrubPos) {
				_vc.seekPercent(scrubPos);
			}
			_vc.addEventListener("playheadUpdate", this);
			if (_playAfterScrub) {
				_vc.play();
			}
		} else if (_vc.getVideoPlayer(_vc.visibleVideoPlayerIndex).state == VideoPlayer.SEEKING) {
			// do nothing
		} else if ( _seekBarScrubTolerance <= 0 ||
		            Math.abs(scrubPos - _lastScrubPos) > _seekBarScrubTolerance ||
		            scrubPos < _seekBarScrubTolerance ||
		            scrubPos > (100 - _seekBarScrubTolerance) ) {
			if (scrubPos != _lastScrubPos) {
				_lastScrubPos = scrubPos;
				_vc.seekPercent(scrubPos);
			}
		}

		// set activeVideoPlayerIndex back to prev value
		_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
	}
	
	/**
	 * Called on interval when user scrubbing by dragging volumebar handle.
	 *
	 * @private
	 */
	function volumeBarListener(finish:Boolean):Void {
		var volumeBar:MovieClip = controls[VOLUME_BAR];
		calcPercentageFromHandle(VOLUME_BAR);
		var volumePos:Number = volumeBar.percentage;
		if (finish) {
			clearInterval(_volumeBarIntervalID);
			_volumeBarIntervalID = 0;
			_vc.addEventListener("volumeUpdate", this);
		}
		if ( finish || _volumeBarScrubTolerance <= 0 ||
		     Math.abs(volumePos - _lastVolumePos) > _volumeBarScrubTolerance ||
		     volumePos < _volumeBarScrubTolerance ||
		     volumePos > (100 - _volumeBarScrubTolerance) ) {
			if (volumePos != _lastVolumePos) {
				if (_isMuted) {
					cachedSoundLevel = volumePos;
				} else {
					_vc.volume = volumePos;
				}
				_lastVolumePos = volumePos;
			}
		}
	}
	
	/**
	 * Called on interval do delay entering buffering state.
	 *
	 * @private
	 */
	function doBufferingDelay():Void {
		// clear interval
		clearInterval(_bufferingDelayIntervalID);
		_bufferingDelayIntervalID = 0;

		// set activeVideoPlayerIndex to visibleVideoPlayerIndex
		var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
		_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

		if (_vc.state == FLVPlayback.BUFFERING) {
			_bufferingOn = true;
			handleEvent({type:"stateChange", state:FLVPlayback.BUFFERING, vp:_vc.visibleVideoPlayerIndex});
		}

		// set activeVideoPlayerIndex back to prev value
		_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
	}
	
	function dispatchMessage(ctrl:MovieClip):Void {
		if (ctrl.id == SEEK_BAR_HANDLE) {
			_vc._scrubStart();
		}

		// set activeVideoPlayerIndex to visibleVideoPlayerIndex
		var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
		_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

		switch (ctrl.id) {
		case PAUSE_BUTTON:
			_vc.pause();
			break;
		case PLAY_BUTTON:
			_vc.play();
			break;
		case STOP_BUTTON:
			_vc.stop();
			break;
		case SEEK_BAR_HANDLE:
			calcPercentageFromHandle(SEEK_BAR);
			_lastScrubPos = controls[SEEK_BAR].percentage;
			_vc.removeEventListener("playheadUpdate", this);
			if (_vc.playing || _vc.buffering) {
				_playAfterScrub = true;
			} else if (_vc.state != VideoPlayer.SEEKING) {
				_playAfterScrub = false;
			}
			_seekBarIntervalID = setInterval(this, "seekBarListener", _seekBarInterval, false);
			startHandleDrag(SEEK_BAR);
			_vc.pause();
			break;
		case VOLUME_BAR_HANDLE:
			calcPercentageFromHandle(VOLUME_BAR);
			_lastVolumePos = controls[VOLUME_BAR].percentage;
			_vc.removeEventListener("volumeUpdate", this);
			_volumeBarIntervalID = setInterval(this, "volumeBarListener", _volumeBarInterval, false);
			startHandleDrag(VOLUME_BAR);
			break;
		case BACK_BUTTON:
			_vc.seekToPrevNavCuePoint();
			break;
		case FORWARD_BUTTON:
			_vc.seekToNextNavCuePoint();
			break;
		case MUTE_ON_BUTTON:
		case MUTE_OFF_BUTTON:
			if (!_isMuted) {
				_isMuted = true;
				cachedSoundLevel = _vc.volume;
				_vc.volume = 0;
			} else {
				_isMuted = false;
				_vc.volume = cachedSoundLevel;
			}
			setEnabledAndVisibleForState(MUTE_OFF_BUTTON, FLVPlayback.PLAYING);
			skinButtonControl(controls[MUTE_OFF_BUTTON]);
			setEnabledAndVisibleForState(MUTE_ON_BUTTON, FLVPlayback.PLAYING);
			skinButtonControl(controls[MUTE_ON_BUTTON]);
			break;
		default:
			throw new Error("Unknown ButtonControl");
		} // switch

		// set activeVideoPlayerIndex back to prev value
		_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
	}

	private function setEnabledAndVisibleForState(index:Number, state:String):Void {
		// set activeVideoPlayerIndex to visibleVideoPlayerIndex
		var cachedActivePlayerIndex:Number = _vc.activeVideoPlayerIndex;
		_vc.activeVideoPlayerIndex = _vc.visibleVideoPlayerIndex;

		// use effectiveState because BUFFERING has this
		// doBufferingDelay() thing going on
		var effectiveState:String = state;
		if (effectiveState == FLVPlayback.BUFFERING && !_bufferingOn) {
			effectiveState = FLVPlayback.PLAYING;
		}

		switch (index) {
		case VOLUME_BAR:
		case VOLUME_BAR_HANDLE:
			// always enabled
			controls[index].myEnabled = true;
			controls[index].enabled = _controlsEnabled;
			break;
		case MUTE_ON_BUTTON:
			controls[index].myEnabled = !_isMuted;
			if (controls[MUTE_BUTTON] != undefined) {
				controls[index]._visible = controls[index].myEnabled;
			}
			break;
		case MUTE_OFF_BUTTON:
			controls[index].myEnabled = _isMuted;
			if (controls[MUTE_BUTTON] != undefined) {
				controls[index]._visible = controls[index].myEnabled;
			}
			break;
		default:
			switch (effectiveState) {
			case FLVPlayback.LOADING:
			case FLVPlayback.CONNECTION_ERROR:
				controls[index].myEnabled = false;
				break;
			case FLVPlayback.DISCONNECTED:
				controls[index].myEnabled  = (_vc.contentPath != undefined);
				break;
			case FLVPlayback.SEEKING:
				// no change
				break;
			default:
				controls[index].myEnabled = true;
				break;
			} // switch
			break;
		} // switch

		switch (index) {
		case SEEK_BAR:
			// set enabled
			switch (effectiveState) {
			case FLVPlayback.STOPPED:
			case FLVPlayback.PLAYING:
			case FLVPlayback.PAUSED:
			case FLVPlayback.REWINDING:
			case FLVPlayback.SEEKING:
				controls[index].myEnabled = true;
				break;
			case FLVPlayback.BUFFERING:
				controls[index].myEnabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
				break;
			default:
				controls[index].myEnabled = false;
				break;
			} // switch
			if (controls[index].myEnabled) {
				controls[index].myEnabled = (!isNaN(_vc.totalTime) && _vc.totalTime > 0);
			}

			// set handle enabled and visible
			controls[index].handle_mc.myEnabled = controls[index].myEnabled;
			controls[index].handle_mc.enabled = controls[index].handle_mc.myEnabled;
			controls[index].handle_mc._visible = controls[index].myEnabled;

			// hide when buffer bar active
			var vis:Boolean = ( !_bufferingBarHides || controls[index].myEnabled || controls[BUFFERING_BAR] == undefined || !controls[BUFFERING_BAR]._visible );
			controls[index]._visible = vis;
			controls[index].progress_mc._visible = vis;
			controls[index].progress_mc.fill_mc._visible = vis;
			controls[index].fullness_mc._visible = vis;
			controls[index].fullness_mc.fill_mc._visible = vis;
			break;
		case BUFFERING_BAR:
			// set enabled
			switch (effectiveState) {
			case FLVPlayback.STOPPED:
			case FLVPlayback.PLAYING:
			case FLVPlayback.PAUSED:
			case FLVPlayback.REWINDING:
			case FLVPlayback.SEEKING:
				controls[index].myEnabled = false;
				break;
			default:
				controls[index].myEnabled = true;
				break;
			} // switch

			// set visible
			controls[index]._visible = controls[index].myEnabled;
			controls[index].fill_mc._visible = controls[index].myEnabled;
			break;
		case PAUSE_BUTTON:
			switch (effectiveState) {
			case FLVPlayback.DISCONNECTED:
			case FLVPlayback.STOPPED:
			case FLVPlayback.PAUSED:
			case FLVPlayback.REWINDING:
				controls[index].myEnabled = false;
				break;
			case FLVPlayback.PLAYING:
				controls[index].myEnabled = true;
				break;
			case FLVPlayback.BUFFERING:
				controls[index].myEnabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
				break;
			} // switch
			if (controls[PLAY_PAUSE_BUTTON] != undefined) {
				controls[index]._visible = controls[index].myEnabled;
			}
			break;
		case PLAY_BUTTON:
			switch (effectiveState) {
			case FLVPlayback.PLAYING:
				controls[index].myEnabled = false;
				break;
			case FLVPlayback.STOPPED:
			case FLVPlayback.PAUSED:
				controls[index].myEnabled = true;
				break;
			case FLVPlayback.BUFFERING:
				controls[index].myEnabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
				break;
			} // switch
			if (controls[PLAY_PAUSE_BUTTON] != undefined) {
				controls[index]._visible = !controls[PAUSE_BUTTON]._visible;
			}
			break;
		case STOP_BUTTON:
			switch (effectiveState) {
			case FLVPlayback.DISCONNECTED:
			case FLVPlayback.STOPPED:
				controls[index].myEnabled = false;
				break;
			case FLVPlayback.PAUSED:
			case FLVPlayback.PLAYING:
			case FLVPlayback.BUFFERING:
				controls[index].myEnabled = true;
				break;
			} // switch
			break;
		case BACK_BUTTON:
		case FORWARD_BUTTON:
			switch (effectiveState) {
			case FLVPlayback.BUFFERING:
				controls[index].myEnabled = (!_bufferingBarHides || controls[BUFFERING_BAR] == undefined);
				break;
			}
		} // switch index

		controls[index].enabled = (_controlsEnabled && controls[index].myEnabled);

		// set activeVideoPlayerIndex back to prev value
		_vc.activeVideoPlayerIndex = cachedActivePlayerIndex;
	}

	function setupSkinAutoHide():Void {
		if (_skinAutoHide && skin_mc != undefined) {
			// set visibility
			skinAutoHideHitTest();
			// setup interval
			if (_skinAutoHideIntervalID == 0) {
				_skinAutoHideIntervalID = setInterval(this, "skinAutoHideHitTest", SKIN_AUTO_HIDE_INTERVAL);
			}
		} else {
			// set visibility
			skin_mc._visible = __visible;
			// setup interval
			clearInterval(_skinAutoHideIntervalID);
			_skinAutoHideIntervalID = 0;
		}
	}

	private function skinAutoHideHitTest():Void {
		if (!__visible) {
			skin_mc._visible = false;
		} else {
			var visibleVP:VideoPlayer = _vc.getVideoPlayer(_vc.visibleVideoPlayerIndex);
			var hit:Boolean = visibleVP.hitTest(_root._xmouse, _root._ymouse, true);
			if (!hit && border_mc != undefined) {
				hit = border_mc.hitTest(_root._xmouse, _root._ymouse, true);
			}
			skin_mc._visible = hit;
		}
	}

	//ifdef DEBUG
	//function debugTrace(s:String):Void {
	//	if (_vc != null && _vc != undefined) {
	//		_vc.debugTrace(s);
	//	}
	//}
	//endif

} // class mx.video.UIManager
