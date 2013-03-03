// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.

import mx.video.*;

/**
 * <p>Creates <code>NetConnection</code> for <code>VideoPlayer</code>, a
 * helper class for that user facing class.</p>
 *
 * <p>NCManager supports a subset of SMIL to handle multiple streams
 * for multiple bandwidths.  NCManager assumes any URL that does not
 * begin with "rtmp://", does not end with ".flv" and does not
 * have any parameters is a SMIL url.  See SMILParser for more on SMIL
 * support.</p>
 *
 * @see SMILParser
 */

class mx.video.NCManager implements INCManager {

	#include "ComponentVersion.as"

	// my VideoPlayer
	private var _owner:VideoPlayer;

	// server connection info
	private var _contentPath:String;
	private var _protocol:String;
	private var _serverName:String;
	private var _portNumber:String;
	private var _wrappedURL:String;
	private var _appName:String;
	private var _streamName:String;
	private var _streamLength:Number;
	private var _streamWidth:Number;
	private var _streamHeight:Number;
	private var _streams:Array;
	private var _isRTMP:Boolean;
	private var _smilMgr:SMILManager;
	private var _fpadMgr:FPADManager;
	public var fpadZone:Number;
	private var _bitrate:Number;

	/**
	 * <p>fallbackServerName is exposed in two ways:</p>
	 * 
	 * <p>User can supply second <meta base> in smil and that base
	 * attr will be taken as the fallbackServerName (note that only
	 * the server name will be taken from this and not the application
	 * name or anything else).</p>
	 *
	 * <p>The second way is the user can directly set this by
	 * accessing the ncMgr property in FLVPlayback or VideoPlayer and
	 * set fallbackServerName property directly.</p>
	 */
	public var fallbackServerName:String;

	// interval for xn timeout
	private var _timeoutIntervalId:Number;
	private var _timeout:Number;

	/**
	 * Default connection timeout in milliseconds.
	 *
	 * @see #getTimeout()
	 * @see #setTimeout()
	 */
	public var DEFAULT_TIMEOUT:Number = 60000;

	// bandwidth detection stuff
	public var _payload:Number;
	private var _autoSenseBW:Boolean;

	// info on successful xn
	private var _nc:NetConnection;
	private var _ncUri:String;
	private var _ncConnected:Boolean;

	// info on mult xns we try
	public var _tryNC:Array;
	private var _tryNCIntervalId:Number;

	// Counter that tracks the next connection to use in _tryNC array
	private var _connTypeCounter:Number;

	public function NCManager()	{
		initNCInfo();
		initOtherInfo();

		// intervals
		_timeoutIntervalId = 0;
		_tryNCIntervalId = 0;

		// actually calls setter
		_timeout = DEFAULT_TIMEOUT;

		_nc = undefined;
		_ncConnected = false;
	}

	private function initNCInfo():Void {
		_isRTMP = undefined;
		_serverName = undefined;
		_wrappedURL = undefined;
		_portNumber = undefined;
		_appName = undefined;
	}

	private function initOtherInfo():Void {
		_contentPath = undefined;
		_streamName = undefined;
		_streamLength = undefined;
		_streamWidth = undefined;
		_streamHeight = undefined;
		_streams = undefined;
		_autoSenseBW = false;
		fpadZone = undefined;

		_payload = 0;
		_connTypeCounter = 0;
		cleanConns();
	}

	/*
	 * @see INCManager#getTimeout()
	 */
	public function getTimeout():Number {
		return _timeout;
	}

	/*
	 * @see INCManager#setTimeout()
	 */
	public function setTimeout(t:Number):Void {
		_timeout = t;
		if (_timeoutIntervalId != 0) {
			clearInterval(_timeoutIntervalId);
			_timeoutIntervalId = setInterval(this, "_onFCSConnectTimeOut", _timeout);
		}
	}

	/**
	 * For RTMP streams, returns value calculated from autodetection,
	 * not value set via setBitrate().
	 *
	 * @see INCManager#getBitrate()
	 */
	public function getBitrate():Number {
		return _bitrate;
	}

	/**
	 * This value is only used with progressive download (HTTP), with
	 * RTMP streaming uses autodetection.
	 *
	 * @see INCManager#getBitrate()
	 */
	public function setBitrate(b:Number):Void {
		if (_isRTMP == undefined || !_isRTMP) {
			_bitrate = b;
		}
	}

	/**
	 * @see INCManager#getVideoPlayer()
	 */
	public function getVideoPlayer():VideoPlayer {
		return _owner;
	}

	/**
	 * @see INCManager#setVideoPlayer()
	 */
	public function setVideoPlayer(v:VideoPlayer):Void {
		_owner = v;
	}

	/**
	 * @see INCManager#getNetConnection()
	 */
	public function getNetConnection():NetConnection {
		return _nc;
	}

	/**
	 * @see INCManager#getStreamName()
	 */
	public function getStreamName():String {
		return _streamName;
	}

	/**
	 * @see INCManager#isRTMP()
	 */
	public function isRTMP():Boolean {
		return _isRTMP;
	}
	
	/**
	 * @see INCManager#getStreamLength()
	 */
	public function getStreamLength():Number {
		return _streamLength;
	}

	/**
	 * @see INCManager#getStreamWidth()
	 */
	public function getStreamWidth():Number {
		return _streamWidth;
	}

	/**
	 * @see INCManager#getStreamHeight()
	 */
	public function getStreamHeight():Number {
		return _streamHeight;
	}

	/**
	 * @see INCManager#connectToURL()
	 */
	public function connectToURL(url:String):Boolean {
		//ifdef DEBUG
		//debugTrace("connectToURL(" + url + ")");
		//endif

		// init
		initOtherInfo();
		_contentPath = url;
		if (_contentPath == null || _contentPath == "") {
			throw new VideoError(VideoError.INVALID_CONTENT_PATH);
		}

		// parse URL to determine what to do with it
		var parseResults:Object = parseURL(_contentPath);
		if (parseResults.streamName == undefined || parseResults.streamName == "") {
			throw new VideoError(VideoError.INVALID_CONTENT_PATH, url);
		}

		// connect to either rtmp or http or download and parse smil
		if (parseResults.isRTMP) {
			var canReuse:Boolean = canReuseOldConnection(parseResults);
			_isRTMP = true;
			_protocol = parseResults.protocol;
			_streamName = parseResults.streamName;
			_serverName = parseResults.serverName;
			_wrappedURL = parseResults.wrappedURL;
			_portNumber = parseResults.portNumber;
			_appName = parseResults.appName;
			if ( _appName == undefined || _appName == "" ||
			     _streamName == undefined || _streamName == "" ) {
				throw new VideoError(VideoError.INVALID_CONTENT_PATH, url);				
			}
			_autoSenseBW = (_streamName.indexOf(",") >= 0);
			return (canReuse || connectRTMP());
		} else {
			var name:String = parseResults.streamName;
			if ( name.indexOf("?") < 0 &&
			     (name.length < 4 || name.slice(-4).toLowerCase() != ".txt") && 
			     (name.length < 4 || name.slice(-4).toLowerCase() != ".xml") &&
			     (name.length < 5 || name.slice(-5).toLowerCase() != ".smil") ) {
				var canReuse:Boolean = canReuseOldConnection(parseResults);
				_isRTMP = false;
				_streamName = name;
				return (canReuse || connectHTTP());
			}
			if (name.indexOf("/fms/fpad") >= 0) {
				try {
					return connectFPAD(name);
				} catch (err:Error) {
					// just use SMILManager if there is any error
					//ifdef DEBUG
					//debugTrace("fpad error: " + err);
					//endif
				}
			}
			_smilMgr = new SMILManager(this);
			return _smilMgr.connectXML(name);
		}
	}

	/**
	 * @see INCManager#connectAgain()
	 */
	public function connectAgain():Boolean
	{
		//ifdef DEBUG
		//debugTrace("connectAgain()");
		//endif

		var slashIndex:Number = _appName.indexOf("/");
		if (slashIndex < 0) {
			// return the appName and streamName back to original form
			// so we can start this process all over again with the
			// fallback server if necessary
			slashIndex = _streamName.indexOf("/");
			if (slashIndex >= 0) {
				_appName += "/";
				_appName += _streamName.slice(0, slashIndex);
				_streamName = _streamName.slice(slashIndex + 1);
			}
			return false;
		}

		var newStreamName = _appName.slice(slashIndex + 1);
		newStreamName += "/";
		newStreamName += _streamName;
		_streamName = newStreamName;
		_appName = _appName.slice(0, slashIndex);
		close();
		_payload = 0;
		_connTypeCounter = 0;
		cleanConns();
		connectRTMP();
		return true;
	}

	/**
	 * @see INCManager#reconnect()
	 */
	public function reconnect():Void
	{
		//ifdef DEBUG
		//debugTrace("reconnect()");
		//endif

		if (!_isRTMP) {
			throw new Error("Cannot call reconnect on an http connection");
		}
		_nc.onStatus = function(info:Object):Void { this.mc.reconnectOnStatus(this, info); };
		_nc.onBWDone = function():Void { this.mc.onReconnected(); };
		//ifdef DEBUG
		//debugTrace("_ncUri = " + _ncUri);
		//endif
		_nc.connect(_ncUri, false);
	}

	/**
	 * dispatches reconnect event, called by
	 * <code>NetConnection.onBWDone</code>
	 *
	 * @private
	 */
	public function onReconnected():Void {
		delete _nc.onStatus;
		delete _nc.onBWDone;
		_ncConnected = true;
		_owner.ncReconnected();
	}

	/**
	 * @see INCManager#close
	 */
	public function close():Void {
		if (_nc) {
			_nc.close();
			_ncConnected = false;
		}
	}

	/**
	 * Called by <code>SMILManager</code> when done.
	 *
	 * @see INCManager#helperDone()
	 */
	public function helperDone(helper:Object, success:Boolean) {
		if (!success) {
			_nc = undefined;
			_ncConnected = false;
			_owner.ncConnected();
			_smilMgr = undefined;
			_fpadMgr = undefined;
			return;
		}

		var parseResults:Object;
		var url:String;

		if (helper == _fpadMgr) {
			url = _fpadMgr.rtmpURL;
			_fpadMgr = undefined;
			parseResults = parseURL(url);
			_isRTMP = parseResults.isRTMP;
			_protocol = parseResults.protocol;
			_serverName = parseResults.serverName;
			_portNumber = parseResults.portNumber;
			_wrappedURL = parseResults.wrappedURL;
			_appName = parseResults.appName;
			_streamName = parseResults.streamName;

			// if fpad autodetect is set up and we used the fpad
			// xml instead, we need to set fpadZone to -1 or we
			// will autodetect on top of our xml detection and
			// things will not work!
			var fpadZoneCached:Number = fpadZone;
			fpadZone = -1;
			connectRTMP();
			// after connecting, set fpadZone back to previous
			// value
			fpadZone = fpadZoneCached;

			return;
		}

		if (helper != _smilMgr) return;
		
		// success!

		// grab width and height
		_streamWidth = _smilMgr.width;
		_streamHeight = _smilMgr.height;
		
		// get correct streamname
		url = _smilMgr.baseURLAttr[0];

		if (url != undefined && url != "") {
			if (url.charAt(url.length - 1) != "/") {
				url += "/";
			}
			parseResults = parseURL(url);
			_isRTMP = parseResults.isRTMP;
			_streamName = parseResults.streamName;
			if (_isRTMP) {
				_protocol = parseResults.protocol;
				_serverName = parseResults.serverName;
				_portNumber = parseResults.portNumber;
				_wrappedURL = parseResults.wrappedURL;
				_appName = parseResults.appName;
				if (_appName == undefined || _appName == "") {
					_smilMgr = undefined;
					throw new VideoError(VideoError.INVALID_XML, "Base RTMP URL must include application name: " + url);
				}
				if (_smilMgr.baseURLAttr.length > 1) {
					var parseResults:Object = parseURL(_smilMgr.baseURLAttr[1]);
					if (parseResults.serverName != undefined) {
						fallbackServerName = parseResults.serverName;
					}
				}
			}
		}
		_streams = _smilMgr.videoTags;
		_smilMgr = undefined;
		for (var i:Number = 0; i < _streams.length; i++) {
			url = _streams[i].src;
			parseResults = parseURL(url);
			if (_isRTMP == undefined) {
				_isRTMP = parseResults.isRTMP;
				if (_isRTMP) {
					_protocol = parseResults.protocol;
					if (_streams.length > 1) {
						throw new VideoError(VideoError.INVALID_XML, "Cannot switch between multiple absolute RTMP URLs, must use meta tag base attribute.");
					}
					_serverName = parseResults.serverName;
					_portNumber = parseResults.portNumber;
					_wrappedURL = parseResults.wrappedURL;
					_appName = parseResults.appName;
					if (_appName == undefined || _appName == "") {
						throw new VideoError(VideoError.INVALID_XML, "Base RTMP URL must include application name: " + url);
					}
				} else if (parseResults.streamName.indexOf("/fms/fpad") >= 0 && _streams.length > 1) {
					throw new VideoError(VideoError.INVALID_XML, "Cannot switch between multiple absolute fpad URLs, must use meta tag base attribute.");
				}
			} else if ( _streamName != undefined && _streamName != "" &&
			            !parseResults.isRelative && _streams.length > 1 ) {
				throw new VideoError(VideoError.INVALID_XML, "When using meta tag base attribute, cannot use absolute URLs for video or ref tag src attributes.");
			}
			_streams[i].parseResults = parseResults;
		}
		_autoSenseBW = _streams.length > 1;

		if (!_autoSenseBW) {
			if (_streamName != undefined) {
				_streamName += _streams[0].parseResults.streamName;
			} else {
				_streamName = _streams[0].parseResults.streamName;
			}
			_streamLength = _streams[0].dur;
		}
		if (_isRTMP) {
			connectRTMP();
		} else if (_streamName != undefined && _streamName.indexOf("/fms/fpad") >= 0) {
			connectFPAD(_streamName);
		} else {
			if (_autoSenseBW) bitrateMatch();
			connectHTTP();
			_owner.ncConnected();
		}
	}

	/**
	 * matches bitrate with stream
	 *
	 * @private
	 */
	private function bitrateMatch():Void {
		var whichStream:Number;
		var checkBitrate:Number = _bitrate;
		if (isNaN(checkBitrate)) {
			checkBitrate = 0;
		}
		for (var j:Number = 0; j < _streams.length; j++) {
			if (isNaN(_streams[j].bitrate) || checkBitrate >= _streams[j].bitrate) {
				whichStream = j;
				break;
			}
		}
		if (isNaN(whichStream)) {
			throw new VideoError(VideoError.NO_BITRATE_MATCH);
		}
		if (_streamName != undefined) {
			_streamName += _streams[whichStream].src;
		} else {
			_streamName = _streams[whichStream].src;
		}
		if (_isRTMP && _streamName.slice(-4).toLowerCase() == ".flv") {
			_streamName = _streamName.slice(0, -4);
		}
		_streamLength = _streams[whichStream].dur;
	}

	/**
	 * <p>Parses URL to determine if it is http or rtmp.  If it is rtmp,
	 * breaks it into pieces to extract server URL and port, application
	 * name and stream name.  If .flv is at the end of an rtmp URL, it
	 * will be stripped off.</p>
	 *
	 * @private
	 */
	private function parseURL(url:String):Object {
		//ifdef DEBUG
		//debugTrace("parseURL()");
		//endif

		var parseResults = new Object();
		
		// get protocol
		var startIndex:Number = 0;
		var endIndex:Number = url.indexOf(":/", startIndex);
		if (endIndex >= 0) {
			endIndex += 2;
			parseResults.protocol = url.slice(startIndex, endIndex);
			parseResults.isRelative = false;
		} else {
			parseResults.isRelative = true;
		}
		
		if ( parseResults.protocol != undefined &&
		     ( parseResults.protocol == "rtmp:/" ||
		       parseResults.protocol == "rtmpt:/" ||
		       parseResults.protocol == "rtmps:/" ||
		       parseResults.protocol == "rtmpe:/" ||
		       parseResults.protocol == "rtmpte:/" ) ) {
			parseResults.isRTMP = true;
			
			startIndex = endIndex;

			if (url.charAt(startIndex) == '/') {
				startIndex++;
				// get server (and maybe port)
				var colonIndex:Number = url.indexOf(":", startIndex);
				var slashIndex:Number = url.indexOf("/", startIndex);
				if (slashIndex < 0) {
					if (colonIndex < 0) {
						parseResults.serverName = url.slice(startIndex);
					} else {
						endIndex = colonIndex;
						parseResults.portNumber = url.slice(startIndex, endIndex);
						startIndex = endIndex + 1;
						parseResults.serverName = url.slice(startIndex);
					}
					return parseResults;
				}
				if (colonIndex >= 0 && colonIndex < slashIndex) {
					endIndex = colonIndex;
					parseResults.serverName = url.slice(startIndex, endIndex);
					startIndex = endIndex + 1;
					endIndex = slashIndex;
					parseResults.portNumber = url.slice(startIndex, endIndex);
				} else {
					endIndex = slashIndex;
					parseResults.serverName = url.slice(startIndex, endIndex);
				}
				startIndex = endIndex + 1;
			}

			// handle wrapped RTMP servers bit recursively, if it is there
			if (url.charAt(startIndex) == '?') {
				var subURL = url.slice(startIndex + 1);
				var subParseResults = parseURL(subURL);
				if (subParseResults.protocol == undefined || !subParseResults.isRTMP) {
					throw new VideoError(VideoError.INVALID_CONTENT_PATH, url);
				}
				parseResults.wrappedURL = "?";
				parseResults.wrappedURL += subParseResults.protocol;
				if (subParseResults.serverName != undefined) {
					parseResults.wrappedURL += "/";
					parseResults.wrappedURL +=  subParseResults.serverName;
				}
				if (subParseResults.wrappedURL != undefined) {
					parseResults.wrappedURL += "/?";
					parseResults.wrappedURL +=  subParseResults.wrappedURL;
				}
				parseResults.appName = subParseResults.appName;
				parseResults.streamName = subParseResults.streamName;
				return parseResults;
			}
			
			// get application name
			endIndex = url.indexOf("/", startIndex);
			if (endIndex < 0) {
				parseResults.appName = url.slice(startIndex);
				return parseResults;
			}
			parseResults.appName = url.slice(startIndex, endIndex);
			startIndex = endIndex + 1;

			// check for instance name to be added to application name
			endIndex = url.indexOf("/", startIndex);
			if (endIndex < 0) {
				parseResults.streamName = url.slice(startIndex);
				// strip off .flv if included
				if (parseResults.streamName.slice(-4).toLowerCase() == ".flv") {
					parseResults.streamName = parseResults.streamName.slice(0, -4);
				}
				return parseResults;
			}
			parseResults.appName += "/";
			parseResults.appName += url.slice(startIndex, endIndex);
			startIndex = endIndex + 1;
				
			// get flv name
			parseResults.streamName = url.slice(startIndex);
			// strip off .flv if included
			if (parseResults.streamName.slice(-4).toLowerCase() == ".flv") {
				parseResults.streamName = parseResults.streamName.slice(0, -4);
			}
			
		} else {
			// is http, just return the full url received as streamName
			parseResults.isRTMP = false;
			parseResults.streamName = url;
		}
		return parseResults;
	}

	/**
	 * <p>Compares connection info with previous NetConnection,
	 * will reuse existing connection if possible.
	 */
	private function canReuseOldConnection(parseResults:Object):Boolean {
		// no reuse if no prior connection
		if (_nc == null || !_ncConnected) return false;

		// http connection
		if (!parseResults.isRTMP) {
			// can reuse if prev connection was http
			if (!_isRTMP) return true;
			// cannot reuse if was rtmp--close
			_owner.close();
			_nc = undefined;
			_ncConnected = false;
			initNCInfo();
			return false;
		}

		// rtmp connection
		if (_isRTMP) {
			if ( parseResults.serverName == _serverName && parseResults.appName == _appName &&
			     parseResults.protocol == _protocol && parseResults.portNumber == _portNumber &&
			     parseResults.wrappedURL == _wrappedURL ) {
				return true;
			}
			// cannot reuse this rtmp--close
			_owner.close();
			_nc = undefined;
			_ncConnected = false;
		}

		initNCInfo();
		return false;
	}

	/**
	 * <p>Handles creating <code>NetConnection</code> instance for
	 * progressive download of FLV via http.</p>
	 *
	 * @private
	 */
	private function connectHTTP():Boolean {
		//ifdef DEBUG
		//debugTrace("connectHTTP()");
		//endif

		_nc = new NetConnection();
		_nc.connect(null);
		_ncConnected = true;
		return true;
	}

	/**
	 * <p>Top level function for creating <code>NetConnection</code>
	 * instance for streaming playback of FLV via rtmp.  Actually
	 * tries to create several different connections using different
	 * protocols and ports in a pipeline, so multiple connection
	 * attempts may be occurring simultaneously, and will use the
	 * first one that connects successfully.</p>
	 *
	 * @private
	 */
	private function connectRTMP():Boolean {
		//ifdef DEBUG
		//debugTrace("connectRTMP()");
		//endif

		// setup timeout
		clearInterval(_timeoutIntervalId);
		_timeoutIntervalId = setInterval(this, "_onFCSConnectTimeOut", _timeout);

		_tryNC = new Array();
		var numXns:Number = (_protocol == "rtmp:/" || _protocol == "rtmpe:/") ? 2 : 1;
		for (var i:Number = 0; i < numXns; i++) {
			//ifdef DEBUG
			//debugTrace("Creating connection " + i);
			//endif
			_tryNC[i] = new NetConnection();
			if (fpadZone != null) {
				_tryNC[i].fpadZone = fpadZone;
			}
			_tryNC[i].mc = this;
			_tryNC[i].pending = false;
			_tryNC[i].connIndex = i;
			_tryNC[i].onBWDone = function(p_bw:Number):Void {
				this.mc.onConnected(this, p_bw);
			}
			_tryNC[i].onBWCheck = function():Number {
				return ++this.mc._payload;
			}
			_tryNC[i].onStatus = function(info:Object):Void { this.mc.connectOnStatus(this, info); };
		}

		nextConnect();
		return false;
	}

	/**
	 * <p>Top level function for downloading fpad XML from FMS 2.0
	 * server.  Creates and kicks off a FPADManager instance
	 * which does all the work.</p>
	 *
	 * @private
	 */
	private function connectFPAD(url:String):Boolean {
		//ifdef DEBUG
		//debugTrace("connectFPAD( " + url + ")");
		//endif

		// extract uri from requesting url
		var urlPrefix:String;
		var uriParam:String;
		var urlSuffix:String;
		var i:Number = url.indexOf("?");
		while (i >= 0) {
			i++;
			var ampIndex:Number = url.indexOf("&", i);
			if (url.substr(i, 4).toLowerCase() == "uri=") {
				urlPrefix = url.slice(0, i);
				i += 4;
				if (ampIndex >= 0) {
					uriParam = url.slice(i, ampIndex);
					urlSuffix = url.slice(ampIndex);
				} else {
					uriParam = url.slice(i);
					urlSuffix = "";
				}
				break;
			} else {
				i = ampIndex;
			}
		}

		if (i < 0) {
			throw new VideoError(VideoError.INVALID_CONTENT_PATH, "fpad url must include uri parameter: " + url);
		}

		var uriParamParseResults:Object = parseURL(uriParam);

		if (!uriParamParseResults.isRTMP) {
			throw new VideoError(VideoError.INVALID_CONTENT_PATH, "fpad url uri parameter must be rtmp url: " + url);
		}

		_fpadMgr = new FPADManager(this);
		return _fpadMgr.connectXML(urlPrefix, uriParam, urlSuffix, uriParamParseResults);
	}


	/**
	 * <p>Does work of trying to open rtmp connections.  Called either
	 * by <code>connectRTMP</code> or on an interval set up in
	 * that method.</p>
	 *
	 * <p>For creating rtmp connections.</p>
	 *
	 * @see #connectRTMP()
	 * @private
	 */
	private function nextConnect():Void {
		//ifdef DEBUG
		//debugTrace("nextConnect()");
		//endif

		clearInterval(_tryNCIntervalId);
		_tryNCIntervalId = 0;
		var protocol:String;
		var port:String;
		if (_connTypeCounter == 0) {
			protocol = _protocol;
			port = _portNumber;
		} else {
			port = null;
			if (_protocol == "rtmp:/") {
				protocol = "rtmpt:/";
			} else if (_protocol == "rtmpe:/") {
				protocol = "rtmpte:/";
			} else {
				_tryNC.pop();
				return;
			}
		}
		var xnURL:String = protocol + ((_serverName == undefined) ? "" : "/" + _serverName + ((port == null) ? "" : (":" + port)) + "/") + ((_wrappedURL == undefined) ? "" : _wrappedURL + "/") + _appName;
		//ifdef DEBUG
		//debugTrace( "_tryNC[" + _connTypeCounter + "] connecting to room: " + xnURL );
		//endif
		_tryNC[_connTypeCounter].pending = true;
		_tryNC[_connTypeCounter].connect( xnURL, _autoSenseBW);
		if (_connTypeCounter < (_tryNC.length-1)) {
			_connTypeCounter++;
			_tryNCIntervalId = setInterval(this, "nextConnect", 1500);
		}
	}

	/**
	 * <p>Stops all intervals, closes all unneeded connections, and other
	 * cleanup related to the <code>connectRTMP</code> strategy of
	 * pipelining connection attempts to different protocols and
	 * ports.</p>
	 *
	 * <p>For creating rtmp connections.</p>
	 *
	 * @see #connectRTMP()
	 * @private
	 */
	public function cleanConns() {
		//ifdef DEBUG
		//debugTrace("cleanConns()");
		//endif

		clearInterval(_tryNCIntervalId);
		_tryNCIntervalId = 0;
		if (_tryNC != undefined) {
			for (var i:Number = 0; i < _tryNC.length; i++) {
				if (_tryNC[i] != undefined) {
					//ifdef DEBUG
					//debugTrace("_tryNC[" + i + "] = " + _tryNC[i]);
					//endif
					delete _tryNC[i].onStatus;
					if (_tryNC[i].pending) {
						_tryNC[i].onStatus = function(info:Object):Void { this.mc.disconnectOnStatus(this, info); };
					} else {
						delete _tryNC[i].onStatus;
						_tryNC[i].close();
					}
				}
				delete _tryNC[i];
			}
			delete _tryNC;
		}
	}

	/**
	 * <p>Starts another pipelined connection attempt with
	 * <code>connectRTMP</code> with the fallback server.</p>
	 *
	 * <p>For creating rtmp connections.</p>
	 *
	 * @see #connectRTMP()
	 * @private
	 */
	private function tryFallBack():Void {
		//ifdef DEBUG
		//debugTrace("tryFallBack()");
		//endif

		if (_serverName == fallbackServerName || fallbackServerName == undefined || fallbackServerName == null) {
			//ifdef DEBUG
			//debugTrace("Already tried to fall back!");
			//endif
			//it's not connected
			delete _nc;
			_nc = undefined;
			_ncConnected = false;
			_owner.ncConnected();
		} else {
			_connTypeCounter = 0;
			cleanConns();
			_serverName = fallbackServerName;
			//ifdef DEBUG
			//debugTrace("connect: " + _serverName);
			//endif
			connectRTMP();
		}
	}

	/**
	 * <p>Starts another pipelined connection attempt with
	 * <code>connectRTMP</code> with the fallback server.</p>
	 *
	 * <p>For creating rtmp connections.</p>
	 *
	 * @see #connectRTMP()
	 * @private
	 */
	public function onConnected(p_nc:NetConnection, p_bw:Number):Void
	{
		//ifdef DEBUG
		//debugTrace("onConnected()");
		//endif

		// avoid timeout
		clearInterval(_timeoutIntervalId);
		_timeoutIntervalId = 0;

		// ditch these now unneeded functions and listeners
		delete p_nc.onBWDone;
		delete p_nc.onBWCheck;
		delete p_nc.onStatus;
		
		// store pointers to the successful xn and uri
		_nc = p_nc;
		_ncUri = _nc.uri;
		_ncConnected = true;

		if (_autoSenseBW) {
			_bitrate = p_bw * 1024;
			if (_streams != undefined) {
				bitrateMatch();
			} else {
				var sSplit:Array = _streamName.split(",");
				// remove leading and trailing whitespace from string
				for (var i:Number = 0; i < sSplit.length; i+=2) {
					var sName = stripFrontAndBackWhiteSpace(sSplit[i]);
					if (i + 1 < sSplit.length) {
						// If we have less bw than the next threshold or if
						// there isn't another threshold (last string)
						if (p_bw <= Number(sSplit[i+1])) {
							_streamName = sName;
							break;
						}
					} else {
						_streamName = sName;
						break;
					}
				} // for
				// strip off .flv if included
				if (_streamName.slice(-4).toLowerCase() == ".flv") {
					_streamName = _streamName.slice(0, -4);
				}
			}
		}

		// if we need to get the stream length from the server, do it here
		if (!_owner.isLive && _streamLength == undefined) {
			var res:Object = new Object();
			res.mc = this;
			res.onResult = function(length:Number) { this.mc.getStreamLengthResult(length); };
			_nc.call("getStreamLength", res, _streamName);
		} else {
			_owner.ncConnected();
		}
	}

	/**
	 * netStatus event listener when connecting
	 *
	 * @private
	 */
	public function connectOnStatus(target:NetConnection, info:Object):Void {
		//ifdef DEBUG
		//debugTrace("_tryNC["+target.connIndex+"].onStatus: " + info.code);
		//var stuff;
		//for (stuff in info) {
		//	debugTrace("info[" + stuff + "] = " + info[stuff]);
		//}
		//endif
		target.pending = false;

		if (info.code == "NetConnection.Connect.Success") {
			//ifdef DEBUG
			//debugTrace( "Connection" + target.uri + " succeeded!" );
			//endif
			_nc = _tryNC[target.connIndex];	
			_tryNC[target.connIndex] = undefined;
			cleanConns();
		} else if (info.code == "NetConnection.Connect.Rejected" && info.ex != null && info.ex.code == 302) {
			_connTypeCounter = 0;
			cleanConns();
			var parseResults:Object = parseURL(info.ex.redirect);
			if (parseResults.isRTMP) {
				_protocol = parseResults.protocol;
				_serverName = parseResults.serverName;
				_wrappedURL = parseResults.wrappedURL;
				_portNumber = parseResults.portNumber;
				_appName = parseResults.appName;
				if (parseResults.streamName != null) {
					_appName += ("/" + parseResults.streamName);
				}
				connectRTMP();
			} else {
				tryFallBack();
			}
		} else if ( ( (info.code == "NetConnection.Connect.Failed") ||
					  (info.code == "NetConnection.Connect.Rejected") ) &&
					( target.connIndex == (_tryNC.length - 1) ) ) {
			// Try rearranging the app URL, then the fallbackServer
			if (!connectAgain()) {
				tryFallBack();
			}
		} else {
			//ifdef DEBUG
			//debugTrace(  "Connection" + target.uri + " onStatus:" + info.code);
			//endif
		}
	}

	/**
	 * netStatus event listener when reconnecting
	 *
	 * @private
	 */
	public function reconnectOnStatus(target:NetConnection, info:Object):Void
	{
		//ifdef DEBUG
		//debugTrace("reconnectOnStatus: " + info.code);
		//endif
		if ( (info.code == "NetConnection.Connect.Failed") ||
			 (info.code == "NetConnection.Connect.Rejected") ) {
			// Try the fallbackServer
			delete _nc;
			_nc = undefined;
			_ncConnected = false;
			_owner.ncReconnected();
		}
	}

	/**
	 * netStatus event listener for disconnecting extra
	 * NetConnections that were opened in parallel
	 *
	 * @private
	 */
	public function disconnectOnStatus(target:NetConnection, info:Object):Void
	{
		//ifdef DEBUG
		//debugTrace("disconnectOnStatus: " + info.code);
		//endif
		if (info.code == "NetConnection.Connect.Success") {
			delete target.onStatus;
			//ifdef DEBUG
			//debugTrace("Closing myself");
			//endif
			target.close();
		}
	}

	/**
	 * Responder function to receive streamLength result from
	 * server after making rpc
	 *
	 * @private
	 */
	public function getStreamLengthResult(length:Number):Void {
		//ifdef DEBUG
		//debugTrace("getStreamLengthResult(" + length + ")");
		//endif
		if (length > 0) _streamLength = length;
		_owner.ncConnected();
	}

	/**
	 * <p>Called on interval to timeout all connection attempts.</p>
	 *
	 * <p>For creating rtmp connections.</p>
	 *
	 * @see #connectRTMP()
	 * @private
	 */
	public function _onFCSConnectTimeOut():Void
	{
		//ifdef DEBUG
		//debugTrace("_onFCSConnectTimeOut()");
		//endif
		cleanConns();
		_nc = undefined;
		_ncConnected = false;
		if (!connectAgain()) {
			_owner.ncConnected();
		}
	}

	private static function stripFrontAndBackWhiteSpace(p_str:String):String
	{
		var i:Number;
		var l:Number = p_str.length;
		var startIndex:Number = 0
		var endIndex:Number = l;
		for (i = 0; i < l; i++) {
			switch (p_str.charCodeAt(i)) {
			case 9: // tab
			case 10: // new line
			case 13: // carriage return
			case 32: // space
				continue;
			}
			startIndex = i;
			break;
		}

		for (i = l; i >= 0; i--) {
			switch (p_str.charCodeAt(i)) {
			case 9: // tab
			case 10: // new line
			case 13: // carriage return
			case 32: // space
				continue;
			}
			endIndex = i + 1;
			break;
		}

		if (endIndex <= startIndex) {
			return "";
		}
		return p_str.slice(startIndex, endIndex);
	}

	//ifdef DEBUG
	//public function debugTrace(s:String):Void
	//{
	//	if (_owner != undefined) {
	//		_owner.debugTrace("#NCManager# " + s);
	//	}
	//}
	//endif
} // class mx.video.NCManager
