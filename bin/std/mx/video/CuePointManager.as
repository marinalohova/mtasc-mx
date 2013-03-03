// Copyright © 2004-2007. Adobe Systems Incorporated. All Rights Reserved.

import mx.video.*;

/**
 * <p>Event dispatched when a cue point is reached.  Event Object has an
 * info property that contains the info object received by the
 * <code>NetStream.onCuePoint</code> callback for FLV cue points or
 * the object passed into the AS cue point APIs for AS cue points.</p>
 *
 * @tiptext cuePoint event
 * @helpid 3483
 */
[Event("cuePoint")]

/**
 * <p>CuePointManager manages AS cue points and enabling/disabling FLV
 * embedded cue points for the FLVPlayback class.</p>
 *
 * @author copyright 2004-2005 Macromedia, Inc.
 */

class mx.video.CuePointManager {

	private var _owner:FLVPlayback;

	private var _metadataLoaded:Boolean;
	private var _disabledCuePoints:Array;
	private var _disabledCuePointsByNameOnly:Object;
	private var _asCuePointIndex:Number;
	private var _asCuePointTolerance:Number;
	private var _linearSearchTolerance:Number;
	private var _id:Number;

	private static var DEFAULT_LINEAR_SEARCH_TOLERANCE:Number = 50;

	var allCuePoints:Array;
	var asCuePoints:Array;
	var flvCuePoints:Array;
	var navCuePoints:Array;
	var eventCuePoints:Array;

	//ifdef DEBUG
	//private static var _debugSingleton:CuePointManager;
	//endif

	//
	// public APIs
	//

	/**
	 * <p>Constructor.</p>
	 *
	 * @helpid 0
	 */
	function CuePointManager(owner:FLVPlayback, id:Number) {
		_owner = owner;
		_id = id;
		reset();
		_asCuePointTolerance = _owner.getVideoPlayer(_id).playheadUpdateInterval / 2000;
		_linearSearchTolerance = DEFAULT_LINEAR_SEARCH_TOLERANCE;
		//ifdef DEBUG
		//_debugSingleton = this;
		//endif
	}

	/**
	 * Reset cue point lists
	 */
	function reset() {
		//ifdef DEBUG
		//debugTrace("reset()");
		//endif
		_metadataLoaded = false;
		allCuePoints = null;
		asCuePoints = null;
		_disabledCuePoints = null;
		flvCuePoints = null;
		navCuePoints = null;
		eventCuePoints = null;
		_asCuePointIndex = 0;
	}

	/**
	 * read only, has metadata been loaded
	 */
	function get metadataLoaded():Boolean {
		return _metadataLoaded;
	}

	/**
	 * <p>Set by FLVPlayback to update _asCuePointTolerance</p>
	 *
	 * @private
	 */
	function set playheadUpdateInterval(aTime:Number):Void {
		_asCuePointTolerance = aTime / 2000;
	}

	/**
	 * <p>corresponds to _vp and _cpMgr array index in FLVPlayback
	 *
	 * @private 
	 */
	function get id():Number {
		return _id;
	}

	/**
	 * <p>Add an ActionScript cue point.</p>
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
	 * @returns A copy of the cuePoint Object added.  The copy has the
	 * following additional properties:
	 *
	 * <ul>
	 * 
	 * <li><code>array</code> - the array of all AS cue points.  Treat
	 * this array as read only as adding, removing or editing objects
	 * within it can cause cue points to malfunction.</li>
	 *
	 * <li><code>index</code> - the index into the array for the
	 * returned cuepoint.</li>
	 *
	 * </ul>
	 * 
	 * @throws VideoError if parameters are invalid
	 * @see #removeASCuePoint()
	 * @see #getCuePoint()
	 */
	public function addASCuePoint(timeOrCuePoint:Object, name:String, parameters:Object):Object {
		//ifdef DEBUG
		//debugTrace("addASCuePoint()");
		//endif

		// make sense of param
		var cuePoint:Object;
		if (typeof timeOrCuePoint == "object") {
			cuePoint = deepCopyObject(timeOrCuePoint);
		} else {
			cuePoint = { time:timeOrCuePoint, name:name, parameters:deepCopyObject(parameters) };
		}

		// sanity check
		var timeUndefined:Boolean = (isNaN(cuePoint.time) || cuePoint.time < 0);
		if (timeUndefined) throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "time must be number");
		var nameUndefined:Boolean = (cuePoint.name == null);
		if (nameUndefined) throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "name cannot be undefined or null");

		// add cue point to AS cue point array
		var index:Number;
		cuePoint.type = "actionscript";
		if ( asCuePoints == null || asCuePoints.length < 1 ) {
			index = 0;
			asCuePoints = new Array();
			asCuePoints.push(cuePoint);
		} else {
			index = getCuePointIndex(asCuePoints, true, cuePoint.time);
			index = (asCuePoints[index].time > cuePoint.time) ? 0 : index + 1;
			asCuePoints.splice(index, 0, cuePoint);
		}

		// add cue point to all cue points array
		if ( allCuePoints == null || allCuePoints.length < 1 ) {
			index = 0;
			allCuePoints = new Array();
			allCuePoints.push(cuePoint);
		} else {
			index = getCuePointIndex(allCuePoints, true, cuePoint.time);
			index = (allCuePoints[index].time > cuePoint.time) ? 0 : index + 1;
			allCuePoints.splice(index, 0, cuePoint);
		}

		// adjust _asCuePointIndex
		var now:Number = _owner.getVideoPlayer(_id).playheadTime;
		if (now > 0) {
			if (_asCuePointIndex == index) {
				if (now > asCuePoints[index].time) {
					_asCuePointIndex++;
				}
			} else if (_asCuePointIndex > index) {
				_asCuePointIndex++;
			}
		} else {
			_asCuePointIndex = 0;
		}

		// return the cue point
		var returnObject:Object = deepCopyObject(asCuePoints[index]);
		returnObject.array = asCuePoints;
		returnObject.index = index;
		return returnObject;
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
	 * @param timeNameOrCuePoint If string, name of cue point to
	 * remove; remove first cue point with this name.  If number, time
	 * of cue point to remove; remove first cue point at this time.
	 * If Object, then object with name and time properties, remove
	 * cue point with both this name and time.
	 * @returns The cue point that was removed.  If there was no
	 * matching cue point then <code>null</code> is returned.
	 * @see #addASCuePoint()
	 * @see #getCuePoint()
	 */
	public function removeASCuePoint(timeNameOrCuePoint:Object):Object {
		//ifdef DEBUG
		//debugTrace("removeASCuePoint()");
		//endif

		// bail if no cue points
		if ( asCuePoints == null || asCuePoints.length < 1 ) {
			return null;
		}

		// make sense of param
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

		// remove cue point from AS cue point array
		var index:Number = getCuePointIndex(asCuePoints, false, cuePoint.time, cuePoint.name);
		if (index < 0) return null;
		cuePoint = asCuePoints[index];
		asCuePoints.splice(index, 1);

		// remove cue point from all cue points array
		index = getCuePointIndex(allCuePoints, false, cuePoint.time, cuePoint.name);
		if (index > 0) {
			allCuePoints.splice(index, 1);
		}

		// adjust _asCuePointIndex
		if (_owner.getVideoPlayer(_id).playheadTime > 0) {
			if (_asCuePointIndex > index) {
				_asCuePointIndex--;
			}
		} else {
			_asCuePointIndex = 0;
		}

		// return the cue point
		return cuePoint;
	}

	/**
	 * <p>Enable or disable one or more FLV cue point.  Disabled cue
	 * points are disabled for being dispatched as events and
	 * navigating to them with <code>seekToPrevNavCuePoint()</code>,
	 * <code>seekToNextNavCuePoint()</code> and
	 * <code>seekToNavCuePoint()</code>.</p>
	 *
	 * <p>If this API is called just after setting the
	 * <code>contentPath</code> property or if no FLV is loaded, then
	 * the cue point will be enabled or disabled in the FLV to be
	 * loaded.  Otherwise, it will be enabled or disabled in the
	 * currently loaded FLV (even if it is called immediately before
	 * setting the <code>contentPath</code> property to load another
	 * FLV).</p>
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
	 * @see #isFLVCuePointEnabled()
	 * @see #getCuePoint()
	 */
	public function setFLVCuePointEnabled(enabled:Boolean, timeNameOrCuePoint:Object):Number {
		//ifdef DEBUG
		//debugTrace("setFLVCuePointEnabled()");
		//endif

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

		// sanity check
		var timeUndefined:Boolean = (isNaN(cuePoint.time) || cuePoint.time < 0);
		var nameUndefined:Boolean = (cuePoint.name == null);
		if (timeUndefined && nameUndefined) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "time must be number and/or name must not be undefined or null");
		}

		var numChanged:Number = 0;
		var matchIndex:Number;
		var index:Number

		// deal with name only case

		if (timeUndefined) {
			// if metadata not loaded, save the name in
			// _disabledCuePointsByNameOnly to use in
			// processFLVCuePoints()
			if (!_metadataLoaded) {
				// check if already in _disabledCuePointsByNameOnly,
				// if so one stop shopping because dupes with specific
				// times would have already been removed or never
				// would have been inserted
				if (_disabledCuePointsByNameOnly[cuePoint.name] == null) {
					// Still need to weed out specific matches of name AND time
					if (!enabled) {
						if ( _disabledCuePointsByNameOnly == null ||
							 _disabledCuePointsByNameOnly.length < 0 ) {
							_disabledCuePointsByNameOnly = new Object();
						}
						// disable it!
						_disabledCuePointsByNameOnly[cuePoint.name] = new Array;
					}
				} else {
					// enable it or already disabled, we are done
					if (enabled) {
						_disabledCuePointsByNameOnly[cuePoint.name] = undefined;
					}
					return -1;
				}
				// remove any matches with specific times (either redudant if enabled == true
				// or need to remove them anyways
				removeCuePoints(_disabledCuePoints, cuePoint);
				return -1;
			} // if (!_metadataLoaded)

			// if enabled == true, then we are removing from _disabledCuePoints
			if (enabled) {
				numChanged = removeCuePoints(_disabledCuePoints, cuePoint);
			} else {
				// if enable == false, we search for matches in
				// flvCuePoints to insert into _disabledCuePoints
				var matchCuePoint:Object;
				for ( matchIndex = getCuePointIndex(flvCuePoints, true, -1, cuePoint.name);
				      matchIndex >= 0;
				      matchIndex = getNextCuePointIndexWithName(matchCuePoint.name, flvCuePoints, matchIndex) ) {
					matchCuePoint = flvCuePoints[matchIndex];
					// look for matching cue point already inserted in disabled array
					index = getCuePointIndex(_disabledCuePoints, true, matchCuePoint.time);
					if (index < 0 || _disabledCuePoints[index].time != matchCuePoint.time) {
						_disabledCuePoints =
							insertCuePoint( index, _disabledCuePoints,
							                {name:matchCuePoint.name, time:matchCuePoint.time} );
						numChanged += 1;
					}
				} // for
			} // else if (enabled)
			return numChanged;
		} // if (timeUndefined)

		// deal with time where we are given time

		// look for matching cue point already in _disabledCuePoints
		matchIndex = getCuePointIndex(_disabledCuePoints, false, cuePoint.time, cuePoint.name);
		// if we found a match...
		if (matchIndex < 0) {
			// if no match and enabled is true, we are done
			// since no disabled entry to remove found
			if (enabled) {
				if (!_metadataLoaded) {
					// check for time only match before giving up
					matchIndex = getCuePointIndex(_disabledCuePoints, false, cuePoint.time);
					if (matchIndex < 0) {
						// _disabledCuePointsByNameOnly contains arrays hashed for cue point names
						// which are disabled globally.  The array has cue point objects which define
						// the exception to the global shutdown.
						
						// look for insertion point in diabled array
						index = getCuePointIndex(_disabledCuePointsByNameOnly[cuePoint.name], true, cuePoint.time);
						// insert it if not there already
						if (cuePointCompare(cuePoint.time, null, _disabledCuePointsByNameOnly[cuePoint.name]) != 0) {
							_disabledCuePointsByNameOnly[cuePoint.name] =
								insertCuePoint(index, _disabledCuePointsByNameOnly[cuePoint.name], cuePoint);
						}
					} else {
						// remove that time only match
						_disabledCuePoints.splice(matchIndex, 1);
					}
				}
				return (_metadataLoaded) ? 0 : -1;
			}
		} else {
			// if enabled is true, remove it and done
			if (enabled) {
				_disabledCuePoints.splice(matchIndex, 1);
				numChanged = 1;
			} else {
				// if enabled is false, then we do not have to add one, still done
				numChanged = 0;
			}
			return (_metadataLoaded) ? numChanged : -1;
		}

		// might still be looking if enabled == false

		// if we have metadata loaded, look for a matching cue point
		if (_metadataLoaded) {
			// check for match
			matchIndex = getCuePointIndex(flvCuePoints, false, cuePoint.time, cuePoint.name);
			// no match, return zero cue points disabled
			if (matchIndex < 0) return 0;
			// if did not specify name, take name from flv cue point array
			if (nameUndefined) cuePoint.name = flvCuePoints[matchIndex].name;
		}

		// need to insert, get pointer into _disabledCuePoints array in right spot
		index = getCuePointIndex(_disabledCuePoints, true, cuePoint.time);
		_disabledCuePoints = insertCuePoint(index, _disabledCuePoints, cuePoint);
		numChanged = 1;
		return (_metadataLoaded) ? numChanged : -1;
	}

	/**
	 * removes enabled cue points from _disabledCuePoints
	 *
	 * @private
	 */
	private function removeCuePoints(cuePointArray:Array, cuePoint:Object):Number {
		//ifdef DEBUG
		//debugTrace("removeCuePoints()");
		//endif

		var matchIndex:Number;
		var matchCuePoint:Object;
		var numChanged:Number = 0;
		for ( matchIndex = getCuePointIndex(cuePointArray, true, -1, cuePoint.name);
		      matchIndex >= 0;
		      matchIndex = getNextCuePointIndexWithName(matchCuePoint.name, cuePointArray, matchIndex) ) {
			// remove match
			matchCuePoint = cuePointArray[matchIndex];
			cuePointArray.splice(matchIndex, 1);
			matchIndex--;
			numChanged++;
		}
		return numChanged;
	}

	/**
	 * inserts cue points into array
	 *
	 * @private
	 */
	private function insertCuePoint(insertIndex:Number, cuePointArray:Array, cuePoint:Object):Array {
		//ifdef DEBUG
		//debugTrace("insertCuePoint()");
		//endif

		if (insertIndex < 0) {
			cuePointArray = new Array();
			cuePointArray.push(cuePoint);
		} else {
			// find insertion point
			if (cuePointArray[insertIndex].time > cuePoint.time) {
				insertIndex = 0;
			} else {
				insertIndex++;
			}
			// insert into sorted cuePointArray
			cuePointArray.splice(insertIndex, 0, cuePoint);
		}
		return cuePointArray;
	}

	/**
	 * <p>Returns false if FLV embedded cue point is disabled by
	 * ActionScript.  Cue points are disabled via setting the
	 * <code>cuePoints</code> property or by calling
	 * <code>setFLVCuePointEnabled()</code>.</p>
	 *
	 * <p>The return value from this function is only meaningful when
	 * <code>metadata</code> is true.  It always returns false
	 * when it is null.</p>
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
	 * <code>metadata</code> is true.  It always returns true when it
	 * is false.</p>
	 * @see #getCuePoint()
	 * @see #setFLVCuePointEnabled()
	 */
	public function isFLVCuePointEnabled(timeNameOrCuePoint:Object):Boolean {
		//ifdef DEBUG
		//debugTrace("isFLVCuePointEnabled()");
		//endif
		if (!_metadataLoaded) return true;

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

		// sanity check
		var timeUndefined:Boolean = (isNaN(cuePoint.time) || cuePoint.time < 0);
		var nameUndefined:Boolean = (cuePoint.name == null);
		if (timeUndefined && nameUndefined) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "time must be number and/or name must not be undefined or null");
		}

		// look to see if ALL cue points with name are disabled
		if (timeUndefined) {
			var index:Number = getCuePointIndex(flvCuePoints, true, -1, cuePoint.name);
			// return true if no cue points with that name at all
			if (index < 0) return true;
			// check all the cue points, return true if any enabled
			while (index >= 0) {
				if ( getCuePointIndex( _disabledCuePoints, false,
				                       flvCuePoints[index].time,
				                       flvCuePoints[index].name) < 0 ) {
					return true;
				}
				index = getNextCuePointIndexWithName(cuePoint.name, flvCuePoints, index);
			}
			return false;
		}

		// check for match in _disabledCuePoints, return true if no
		// match which means not disabled, and may mean does not exist
		// at all
		return (getCuePointIndex(_disabledCuePoints, false, cuePoint.time, cuePoint.name) < 0);
	}


	//
	// package internal methods, called by FLVPlayback
	//


	/**
	 * <p>Called by FLVPlayback on "playheadUpdate" event
	 * to throw "cuePoint" events when appropriate.</p>
	 *
	 * @private
	 */
	function dispatchASCuePoints():Void {
		//ifdef DEBUG
		////debugTrace("dispatchASCuePoints()");
		//endif
		var now:Number = _owner.getVideoPlayer(_id).playheadTime;
		if (_owner.getVideoPlayer(_id).stateResponsive && asCuePoints != null) {
			while ( _asCuePointIndex < asCuePoints.length &&
			        asCuePoints[_asCuePointIndex].time <= now + _asCuePointTolerance ) {
				_owner.dispatchEvent({type:"cuePoint", info:deepCopyObject(asCuePoints[_asCuePointIndex++]), vp:_id});
			}
		}
	}

	/**
	 * When our place in the stream is changed, this is called
	 * to reset our index into actionscript cue point array.
	 * Another method is used when AS cue points are added
	 * are removed.
	 *
	 * @private
	 */
	function resetASCuePointIndex(time:Number):Void {
		if (time <= 0 || asCuePoints == null) {
			_asCuePointIndex = 0;
			return;
		}
		var index:Number = getCuePointIndex(asCuePoints, true, time);
		_asCuePointIndex = (asCuePoints[index].time < time) ? index + 1 : index;
	}

	/**
	 * Called by FLVPlayback "metadataReceived" event handler to process flv
	 * embedded cue points array.
	 *
	 * @private
	 */
	function processFLVCuePoints(metadataCuePoints:Array):Void {
		// metadata was received
		_metadataLoaded = true;

		// if no flv cue points, bail
		if (metadataCuePoints == null || metadataCuePoints.length < 1) {
			flvCuePoints = null;
			navCuePoints = null;
			eventCuePoints = null;
			return;
		}

		flvCuePoints = metadataCuePoints;
		navCuePoints = new Array();
		eventCuePoints = new Array();

		var index:Number;
		var prevTime:Number = -1;
		var cuePoint:Object;
		
		var dArray:Array = _disabledCuePoints;
		var dArrayIndex:Number = 0;
		_disabledCuePoints = new Array();

		var i:Number = 0;
		while ((cuePoint = flvCuePoints[i++]) != null) {
			// sanity check
			if (prevTime > 0 && prevTime >= cuePoint.time) {
				flvCuePoints = null;
				navCuePoints = null;
				eventCuePoints = null;
				_disabledCuePoints = null;
				_disabledCuePointsByNameOnly = null;
				throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "Unsorted cuePoint found after time: " + prevTime);
			}
			prevTime = cuePoint.time;

			// disable cue points
			while ( dArrayIndex < dArray.length &&
			        cuePointCompare(dArray[dArrayIndex].time, null, cuePoint) < 0 ) {
				dArrayIndex++;
			}
			if ( _disabledCuePointsByNameOnly[cuePoint.name] != null ||
			     ( dArrayIndex < dArray.length &&
			       cuePointCompare(dArray[dArrayIndex].time, dArray[dArrayIndex].name, cuePoint) == 0 ) ) {
				_disabledCuePoints.push({time:cuePoint.time, name:cuePoint.name});
			}

			// sort into nav and event arrays
			if (cuePoint.type == "navigation") {
				// push on nav cue points list
				navCuePoints.push(cuePoint);
			} else if (cuePoint.type == "event") {
				// push on event cue points list
				eventCuePoints.push(cuePoint);
			}

			// add to all cue points array
			if ( allCuePoints == null || allCuePoints.length < 1 ) {
				allCuePoints = new Array();
				allCuePoints.push(cuePoint);
			} else {
				index = getCuePointIndex(allCuePoints, true, cuePoint.time);
				index = (allCuePoints[index].time > cuePoint.time) ? 0 : index + 1;
				allCuePoints.splice(index, 0, cuePoint);
			}
		} // while

		// clear out old disable cue point stuff
		delete _disabledCuePointsByNameOnly;
		_disabledCuePointsByNameOnly = null;

		//ifdef DEBUG
		////debugTraceProcessFLVCuePoints();
		////debugCuePointSearchSuite();
		//endif
	}

	/**
	 * <p>Process Array passed into FLVPlayback cuePoints property.
	 * Array actually holds name value pairs.  Each cue point starts
	 * with 5 pairs: t,time,n,name,t,type,d,disabled,p,numparams.
	 * time is a Number in milliseconds (e.g. 3000 = 3 seconds), name
	 * is a String, type is a Number (0 = event, 1 = navigation, 2 =
	 * actionscript), disabled is a Number (0 for false, 1 for true)
	 * and numparams is a Number.  After this, there are numparams
	 * name/value pairs which could be any simple type.</p>
	 *
	 * <p>Note that all Strings are escaped with html/xml entities for
	 * ampersand (&amp;), double quote (&quot;), single quote (&#39;)
	 * and comma (&#44;), so must be unescaped.</p>
	 *
	 * @see FLVPlayback#cuePoints
	 * @private
	 */
	function processCuePointsProperty(cuePoints:Array):Void {
		//ifdef DEBUG
		//debugTrace("cuePoints = [");
		//for (var zzz:Number = 0; zzz < cuePoints.length; zzz+=2) {
		//	debugTrace("    " + cuePoints[zzz] + ", " + cuePoints[zzz+1]);
		//}
		//debugTrace("];");
		//endif

		if (cuePoints == null || cuePoints.length == 0) {
			return;
		}

		var state:Number = 0;
		var numParamsLeft:Number;
		var name:String, value:String;
		var cuePoint:Object;
		var disable:Boolean;

		for (var i:Number = 0; i < cuePoints.length - 1; i++) {
			switch (state) {
			case 6:
				// add cuePoint appropriately
				addOrDisable(disable, cuePoint);
				// reset and process the next
				state = 0;
				// no break
			case 0:
				if (cuePoints[i++] != "t") {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "unexpected cuePoint parameter format");
				}
				if (isNaN(cuePoints[i])) {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "time must be number");
				}
				cuePoint = new Object();
				cuePoint.time = cuePoints[i] / 1000;
				state++;
				break;
			case 1:
				if (cuePoints[i++] != "n") {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "unexpected cuePoint parameter format");
				}
				if (cuePoints[i] == null) {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "name cannot be null or undefined");
				}
				cuePoint.name = unescape(cuePoints[i]);
				state++;
				break;
			case 2:
				if (cuePoints[i++] != "t") {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "unexpected cuePoint parameter format");
				}
				if (isNaN(cuePoints[i])) {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "type must be number");
				}
				switch (cuePoints[i]) {
				case 0:
					cuePoint.type = "event";
					break;
				case 1:
					cuePoint.type = "navigation";
					break;
				case 2:
					cuePoint.type = "actionscript";
					break;
				default:
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "type must be 0, 1 or 2");
				} // switch
				state++;
				break;
			case 3:
				if (cuePoints[i++] != "d") {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "unexpected cuePoint parameter format");
				}
				if (isNaN(cuePoints[i])) {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "disabled must be number");
				}
				disable = (cuePoints[i] != 0);
				state++;
				break;
			case 4:
				if (cuePoints[i++] != "p") {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "unexpected cuePoint parameter format");
				}
				if (isNaN(cuePoints[i])) {
					throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "num params must be number");
				}
				numParamsLeft = cuePoints[i];
				state++;
				if (numParamsLeft == 0) {
					state++;
				} else {
					cuePoint.parameters = new Object();
				}
				break;
			case 5:
				name = cuePoints[i++];
				value = cuePoints[i];
				if (typeof name == "string") name = unescape(name);
				if (typeof value == "string") value = unescape(value);
				cuePoint.parameters[name] = value;
				numParamsLeft--;
				if (numParamsLeft == 0) state++;
				break;
			} // switch
		} // for

		if (state == 6) {
			addOrDisable(disable, cuePoint);
		} else {
			// ended badly, throw error
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "unexpected end of cuePoint param string");
		}

		//ifdef DEBUG
		//debugTraceProcessFLVCuePoints();
		//endif
	}


	//
	// private functions
	//


	/**
	 * Used by processCuePointsProperty
	 *
	 * @private
	 */
	private function addOrDisable(disable:Boolean, cuePoint:Object):Void {
		if (disable) {
			if (cuePoint.type == "actionscript") {
				throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "Cannot disable actionscript cue points");
			}
			setFLVCuePointEnabled(false, cuePoint);
		} else if (cuePoint.type == "actionscript") {
			addASCuePoint(cuePoint);
		}
	}

	private static var cuePointsReplace:Array = [
		"&quot;", "\"",
		"&#39;", "'",
		"&#44;", ",",
		"&amp;", "&"
	];

	/**
	 * Used by processCuePointsProperty
	 *
	 * @private
	 */
	private function unescape(origStr:String):String {
		var newStr:String = origStr;
		for (var i:Number = 0; i < cuePointsReplace.length; i++) {
			var broken:Array = newStr.split(cuePointsReplace[i++]);
			if (broken.length > 1) {
				newStr = broken.join(cuePointsReplace[i]);
			}
		}
		return newStr;
	}

	/**
	 * Search for a cue point in an array sorted by time.  See
	 * closeIsOK parameter for search rules.
	 *
	 * @param cuePointArray array to search
	 * @param closeIsOK If true, the behavior differs depending on the
	 * parameters passed in:
	 * 
	 * <ul>
	 *
	 * <li>If name is null or undefined, then if the specific time is
	 * not found then the closest time earlier than that is returned.
	 * If there is no cue point earlier than time, the first cue point
	 * is returned.</li>
	 *
	 * <li>If time is null, undefined or less than 0 then the first
	 * cue point with the given name is returned.</li>
	 *
	 * <li>If time and name are both defined then the closest cue
	 * point, then if the specific time and name is not found then the
	 * closest time earlier than that with that name is returned.  If
	 * there is no cue point with that name and with an earlier time,
	 * then the first cue point with that name is returned.  If there
	 * is no cue point with that name, null is returned.</li>
	 * 
	 * <li>If time is null, undefined or less than 0 and name is null
	 * or undefined, a VideoError is thrown.</li>
	 * 
	 * </ul>
	 *
	 * <p>If closeIsOK is false the behavior is:</p>
	 *
	 * <ul>
	 *
	 * <li>If name is null or undefined and there is a cue point with
	 * exactly that time, it is returned.  Otherwise null is
	 * returned.</li>
	 *
	 * <li>If time is null, undefined or less than 0 then the first
	 * cue point with the given name is returned.</li>
	 *
	 * <li>If time and name are both defined and there is a cue point
	 * with exactly that time and name, it is returned.  Otherwise null
	 * is returned.</li>
	 *
	 * <li>If time is null, undefined or less than 0 and name is null
	 * or undefined, a VideoError is thrown.</li>
	 * 
	 * </ul>
	 * @param time search criteria
	 * @param name search criteria
	 * @param start index of first item to be searched, used for
	 * recursive implementation, defaults to 0 if undefined
	 * @param len length of array to search, used for recursive
	 * implementation, defaults to cuePointArray.length if undefined
	 * @returns index for cue point in given array or -1 if no match found
	 * @throws VideoError if time and/or name parameters are bad
	 * @see #cuePointCompare()
	 * @private
	 */
	private function getCuePointIndex( cuePointArray:Array, closeIsOK:Boolean,
	                                   time:Number, name:String,
	                                   start:Number, len:Number):Number {
		// sanity checks
		if (cuePointArray == null || cuePointArray.length < 1) {
			return -1;
		}
		var timeUndefined:Boolean = (isNaN(time) || time < 0);
		var nameUndefined:Boolean = (name == null);
		if (timeUndefined && nameUndefined) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "time must be number and/or name must not be undefined or null");
		}

		if (start == null) start = 0;
		if (len == null) len = cuePointArray.length;

		// name is passed in and time is undefined or closeIsOK is
		// true, search for first name starting at either start
		// parameter index or index at or after passed in time, respectively
		if (!nameUndefined && (closeIsOK || timeUndefined)) {
			var firstIndex:Number;
			var index:Number;
			if (timeUndefined) {
				firstIndex = start;
			} else {
				firstIndex = getCuePointIndex(cuePointArray, closeIsOK, time);
			}
			for (index = firstIndex; index >= start; index--) {
				if (cuePointArray[index].name == name) break;
			}
			if (index >= start) return index;
			for (index = firstIndex + 1; index < len; index++) {
				if (cuePointArray[index].name == name) break;
			}
			if (index < len) return index;
			return -1;
		}

		var result:Number;

		// iteratively check if short length
		if (len <= _linearSearchTolerance) {
			var max:Number = start + len;
			for (var i:Number = start; i < max; i++) {
				result = cuePointCompare(time, name, cuePointArray[i]);
				if (result == 0) return i;
				if (result < 0) break;
			}
			if (closeIsOK) {
				if (i > 0) return i - 1;
				return 0;
			}
			return -1;
		}

		// split list and recurse
		var halfLen:Number = Math.floor(len / 2);
		var checkIndex:Number = start + halfLen;
		result = cuePointCompare(time, name, cuePointArray[checkIndex]);
		if (result < 0) {
			return getCuePointIndex( cuePointArray, closeIsOK, time, name,
			                         start, halfLen );
		}
		if (result > 0) {
			return getCuePointIndex( cuePointArray, closeIsOK, time, name,
			                         checkIndex + 1, halfLen - 1 + (len % 2) );
		}
		return checkIndex;
	}	

	/**
	 * <p>Given a name, array and index, returns the next cue point in
	 * that array after given index with the same name.  Returns null
	 * if no cue point after that one with that name.  Throws
	 * VideoError if argument is invalid.</p>
	 *
	 * @returns index for cue point in given array or -1 if no match found
	 * @private
	 */
	private function getNextCuePointIndexWithName(name:String, array:Array, index:Number):Number {
		// sanity checks
		if (name == null) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "name cannot be undefined or null");
		}
		if (array == null) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "cuePoint.array undefined");
		}
		if (isNaN(index) || index < -1 || index >= array.length) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "cuePoint.index must be number between -1 and cuePoint.array.length");
		}

		// find it
		var i:Number;
		for (i = index + 1; i < array.length; i++) {
			if (array[i].name == name) break;
		}
		if (i < array.length) return i;
		return -1;
	}

	/**
	 * Takes two cue point Objects and returns -1 if first sorts
	 * before second, 1 if second sorts before first and 0 if they are
	 * equal.  First compares times with millisecond precision.  If
	 * they match, compares name if name parameter is not null or undefined.
	 * 
	 * @private
	 */
	private static function cuePointCompare(time:Number, name:String, cuePoint:Object):Number {
		var compTime1:Number = Math.round(time * 1000);
		var compTime2:Number = Math.round(cuePoint.time * 1000);
		if (compTime1 < compTime2) return -1;
		if (compTime1 > compTime2) return 1;
		if (name != null) {
			if (name == cuePoint.name) return 0;
			if (name < cuePoint.name) return -1;
			return 1;
		}
		return 0;
	}

	/**
	 * <p>Search for a cue point in the given array at the given time
	 * and/or with given name.</p>
	 *
	 * @param closeIsOK If true, the behavior differs depending on the
	 * parameters passed in:
	 * 
	 * <ul>
	 *
	 * <li>If name is null or undefined, then if the specific time is
	 * not found then the closest time earlier than that is returned.
	 * If there is no cue point earlier than time, the first cue point
	 * is returned.</li>
	 *
	 * <li>If time is null, undefined or less than 0 then the first
	 * cue point with the given name is returned.</li>
	 *
	 * <li>If time and name are both defined then the closest cue
	 * point, then if the specific time and name is not found then the
	 * closest time earlier than that with that name is returned.  If
	 * there is no cue point with that name and with an earlier time,
	 * then the first cue point with that name is returned.  If there
	 * is no cue point with that name, null is returned.</li>
	 * 
	 * <li>If time is null, undefined or less than 0 and name is null
	 * or undefined, a VideoError is thrown.</li>
	 * 
	 * </ul>
	 *
	 * <p>If closeIsOK is false the behavior is:</p>
	 *
	 * <ul>
	 *
	 * <li>If name is null or undefined and there is a cue point with
	 * exactly that time, it is returned.  Otherwise null is
	 * returned.</li>
	 *
	 * <li>If time is null, undefined or less than 0 then the first
	 * cue point with the given name is returned.</li>
	 *
	 * <li>If time and name are both defined and there is a cue point
	 * with exactly that time and name, it is returned.  Otherwise null
	 * is returned.</li>
	 *
	 * <li>If time is null, undefined or less than 0 and name is null
	 * or undefined, a VideoError is thrown.</li>
	 * 
	 * </ul>
	 * @param timeOrCuePoint If String, then name for search.  If
	 * Number, then time for search.  If Object, then cuepoint object
	 * containing time and/or name parameters for search.
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
	 * @see #getCuePointIndex()
	 * @private
	 */
	function getCuePoint(cuePointArray:Array, closeIsOK:Boolean, timeNameOrCuePoint:Object):Object {
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
		var index:Number = getCuePointIndex(cuePointArray, closeIsOK, cuePoint.time, cuePoint.name);
		if (index < 0) return null;
		cuePoint = deepCopyObject(cuePointArray[index]);
		cuePoint.array = cuePointArray;
		cuePoint.index = index;
		return cuePoint;
	}

	/**
	 * <p>Given a cue point object returned from getCuePoint (needs
	 * the index and array properties added to those cue points),
	 * returns the next cue point in that array after that one with
	 * the same name.  Returns null if no cue point after that one
	 * with that name.  Throws VideoError if argument is invalid.</p>
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
	 * @private
	 */
	function getNextCuePointWithName(cuePoint:Object):Object {
		// sanity checks
		if (cuePoint == null) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "cuePoint parameter undefined");
		}
		if (isNaN(cuePoint.time) || cuePoint.time < 0) {
			throw new VideoError(VideoError.ILLEGAL_CUE_POINT, "time must be number");
		}

		// get index
		var index:Number = getNextCuePointIndexWithName(cuePoint.name, cuePoint.array, cuePoint.index);
		if (index < 0) return null;

		// return copy
		var returnCuePoint:Object = deepCopyObject(cuePoint.array[index]);
		returnCuePoint.array = cuePoint.array;
		returnCuePoint.index = index;
		return returnCuePoint;
	}

	/**
	 * Used to make copies of cue point objects.
	 *
	 * @private
	 */
	private static function deepCopyObject(obj:Object, recurseLevel:Number):Object {
		if (obj == null || typeof obj != "object") return obj;
		if (recurseLevel == null) recurseLevel = 0;
		var newObj = new Object();
		for (var i in obj) {
			if (recurseLevel == 0 && (i == "array" || i == "index")) {
				// skip it
			} else if (typeof obj[i] == "object") {
				newObj[i] = deepCopyObject(obj[i], recurseLevel+1);
			} else {
				newObj[i] = obj[i];
			}
		}
		return newObj;
	}

	//ifdef DEBUG
	//function debugTrace(s:String):Void {
	//	if (_owner != null) {
	//		_owner.debugTrace(s);
	//	}
	//}
	//
	//function debugTraceCuePoint(name:String, obj:Object, indent:Number):Void {
	//	if (!_owner._debuggingOn) return;
	//	var indentString:String = "";
	//	for (var j:Number = 0; j < indent; j++) indentString += "  ";
	//	var i;
	//	debugTrace(indentString + name + ": " + obj.name + " at " + obj.time + " type " + obj.type);
	//	if (obj.parameters != null) {
	//		debugTrace(indentString + "parameters:");
	//		for (i in obj.parameters) {
	//			debugTrace(indentString + "  " + i + " = " + obj.parameters[i]);
	//		}
	//	}
	//}

	//function debugTraceProcessFLVCuePoints():Void {
	//	var i:Number;
	//	if (flvCuePoints != null && flvCuePoints.length > 0) {
	//		debugTrace("flvCuePoints:");
	//		for (i = 0; i < flvCuePoints.length; i++) {
	//			debugTrace("  flvCuePoints[" + i + "]");
	//			debugTraceCuePoint("flvCuePoints[" + i + "]", flvCuePoints[i], 2);
	//		}
	//	} else {
	//		debugTrace("No flv cue points!");
	//	}
	//	if (navCuePoints != null && navCuePoints.length > 0) {
	//		debugTrace("navCuePoints:");
	//		for (i = 0; i < flvCuePoints.length; i++) {
	//			debugTrace("  navCuePoints[" + i + "]");
	//			debugTraceCuePoint("navCuePoints[" + i + "]", navCuePoints[i], 2);
	//		}
	//	} else {
	//		debugTrace("No nav cue points!");
	//	}
	//	if (eventCuePoints != null && eventCuePoints.length > 0) {
	//		debugTrace("eventCuePoints:");
	//		for (i = 0; i < eventCuePoints.length; i++) {
	//			debugTrace("  eventCuePoints[" + i + "]");
	//			debugTraceCuePoint("eventCuePoints[" + i + "]", eventCuePoints[i], 2);
	//		}
	//	} else {
	//		debugTrace("No event cue points!");
	//	}
	//	if (asCuePoints != null && asCuePoints.length > 0) {
	//		debugTrace("asCuePoints:");
	//		for (i = 0; i < asCuePoints.length; i++) {
	//			debugTrace("  asCuePoints[" + i + "]");
	//			debugTraceCuePoint("asCuePoints[" + i + "]", asCuePoints[i], 2);
	//		}
	//	} else {
	//		debugTrace("No AS cue points!");
	//	}
	//	if (_disabledCuePoints != null && _disabledCuePoints.length > 0) {
	//		debugTrace("_disabledCuePoints:");
	//		for (i = 0; i < _disabledCuePoints.length; i++) {
	//			debugTrace("  _disabledCuePoints[" + i + "]");
	//			debugTraceCuePoint("_disabledCuePoints[" + i + "]", _disabledCuePoints[i], 2);
	//		}
	//	} else {
	//		debugTrace("No disabled cue points!");
	//	}
	//}

	//function debugCuePointSearchSuite():Void {
	//	if (!_owner._debuggingOn) return;
	//	debugTrace("Got metadata, doing search for cue points search suite");
	//	var cp:Object;
	//	var attempt:Number = 1;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(flvCuePoints, false);
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(flvCuePoints, true);
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(flvCuePoints, false, 15.07);
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(flvCuePoints, true, {time:15.07, name:"odd"});
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(navCuePoints, true, 15.07);
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(eventCuePoints, false, "e1");
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(flvCuePoints, false, {time:-1, name:"e1"});
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(navCuePoints, false, {time:20.015, name:"even"});
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(navCuePoints, true, {time:21, name:"even"});
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(navCuePoints, true, {time:30, name:"odd"});
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getNextCuePointWithName(cp);
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(navCuePoints, true, 3);
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(navCuePoints, true, {time:1000, name:"e4"});
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//	debugTrace("doing " + attempt);
	//	try {
	//		cp = getCuePoint(eventCuePoints, true, {time:1000, name:"e3"});
	//		if (cp == null) { debugTrace("cuePoint == null"); } else { debugTraceCuePoint("cuePoint", cp, 1); }
	//	} catch (err:Error) {
	//		debugTrace("Got error! " + err.message);
	//	}
	//	attempt++;

	//}
	//endif

} // class mx.video.CuePointManager
