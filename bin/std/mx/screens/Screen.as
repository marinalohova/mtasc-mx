//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.Loader;
import mx.events.UIEventDispatcher;
import mx.core.ext.UIObjectExtensions;
import mx.core.ext.UIComponentExtensions;
import mx.events.LowLevelEvents;

/**
* @tiptext allTransitionsInDone event
* @helpid 1850
*/
[Event("allTransitionsInDone")]
/**
* @tiptext allTransitionsOutDone event
* @helpid 1851
*/
[Event("allTransitionsOutDone")]
/**
* @tiptext hide event
* @helpid 1852
*/
[Event("hide")]
/**
* @tiptext mouseDown event
* @helpid 1854
*/
[Event("mouseDown")]
/**
* @tiptext mouseDownSomewhere event
* @helpid 1855
*/
[Event("mouseDownSomewhere")]
/**
* @tiptext mouseMove event
* @helpid 1856
*/
[Event("mouseMove")]
/**
* @tiptext mouseOut event
* @helpid 1904
*/
[Event("mouseOut")]
/**
* @tiptext mouseOver event
* @helpid 1858
*/
[Event("mouseOver")]
/**
* @tiptext mouseUp event
* @helpid 1859
*/
[Event("mouseUp")]
/**
* @tiptext mouseUpSomewhere event
* @helpid 1860
*/
[Event("mouseUpSomewhere")]
/**
* @tiptext reveal event
* @helpid 1861
*/
[Event("reveal")]


/**
* Screen class
* - extends Loader
* - Adds management of contained child Slides and Forms 
*
* @tiptext Base class for Slide and Form.  Extends Loader
* @helpid 1863
*/ 
[InspectableList("autoLoad","contentPath")]
class mx.screens.Screen extends Loader {

	// SymbolName for object
	static var symbolName:String = "Screen";

	// Class used in createClassObject
	static var symbolOwner:Object = mx.screens.Screen;

	// name of this class
	var className:String = "Screen";

	// indicates whether this is a screen
	private var _isScreen:Boolean = true;

	// list of children of this screen 
	private var _childScreens:Array;

	// 0-based index of where this screen is in its parent's childScreens array
	private var _indexInParent:Number = 0;

	// object to keep track of all active transitions on this screen
	private var __transitionManager = null;

	// Name of the child of this screen in the process of being loaded
	// through createChild
	private var _childLoading:String = "";

    // all screens have no border so components can contain forms inside them
	var borderStyle:String = "none"; 



// //////////////////////////////////////////////////
//
// getters/setters
//
// //////////////////////////////////////////////////

/**
* zero-based index of this screen in its parent (getChildScreen)
* Read-Only: use createChild() to add new child screens
* @tiptext  index of this screen in its parent (getChildScreen)
* @helpid   1864
*/
	public function get indexInParent():Number
	{
		return _indexInParent;
	}

/**
* number of child screens of this screen
* Read-Only: use createChild() to add new child screens
* @tiptext  number of child screens of this screen
* @helpid   1865
*/
	public function get numChildScreens():Number
	{
		return _childScreens.length;
	}

/**
* True if this screen's _parent is a screen
* Read-Only: use createChild() to add new child screens
* @tiptext  True if this screen's _parent is a screen
* @helpid   1866
*/
	public function get parentIsScreen():Boolean
	{
		var retVal:Boolean = ((parentScreen != null) && (parentScreen._isScreen));
		return retVal;
	}

/**
* Screen containing this screen.  May be null for the root screen.
* Read-Only: use createChild() to add new child screens
* @tiptext  Screen containing this screen
* @helpid   1867
*/
	public function get parentScreen():Screen
	{
		var theParent:Screen = mx.screens.Screen(_parent);
		if (theParent == null) {
			return(null);
		} else if (theParent._isScreen) {
			return(theParent);
		} else {
			return(null);
		}
	}


/**
* Root of the screen subtree that contains this screen
* Read-Only: use createChild() to add new child screens
* @tiptext  Root of the screen subtree that contains this screen
* @helpid   1868
*/
	public function get rootScreen():Screen
	{
		var scrn:Screen = this;
		while (scrn.parentIsScreen) {
			scrn = scrn.parentScreen;
		}
		return(scrn);
	}

/**
* Object that manages the current transitions for this single screen
* Read-Only: use transitionManager.start to add new transitions
*/
	public function get transitionManager():Object
	{
		return __transitionManager;
	}

/**
* Current leaf-most screen containing the global focus
* Read-Only: setFocus() to change focus
* @tiptext	Current leaf-most screen containing the global focus
* @helpid   1870
*/
	public static function get currentFocusedScreen():Screen
	{
		var curFocus:Object;
		curFocus = _root.focusManager.getFocus();
		if (!curFocus || (curFocus == undefined)) {
			curFocus = eval(Selection.getFocus());
		}
		while (curFocus && !curFocus._isScreen) {
			curFocus = curFocus._parent;
		}
		if (curFocus == undefined)
			return(null);
		else
			return(mx.screens.Screen(curFocus));
	}


// //////////////////////////////////////////////////
//
// Public methods
//
// //////////////////////////////////////////////////

/**
* Get the nth child of a screen (zero-based)
* @param childIndex which screen to get
* @tiptext	Get the nth child of a screen
* @helpid	1871
*/
	function getChildScreen(childIndex:Number): Screen
	{
		return _childScreens[childIndex];
	}


// //////////////////////////////////////////////////
//
// Private methods
//
// //////////////////////////////////////////////////

	// Overridden to do screen-specific fixups between new screen tree and parent
	function createChild(className:String, instanceName:String, initProps:Object):MovieClip
	{
		var child:MovieClip;

		_childLoading = instanceName;
		return super.createChild(className, instanceName, initProps);
	}

	// Screen class constructor
	function Screen()
	{
	}


	// Override from View class.  Don't inherit default behavior because screens don't work with
	// skins and it is not appropriate to draw a focus rect for screens
	function drawFocus()
	{
	}

	// initialize this screen
	private function init()
	{
		mx.core.ext.UIObjectExtensions.Extensions();
		mx.core.ext.UIComponentExtensions.Extensions();
		mx.events.LowLevelEvents.enableLowLevelEvents();

		_childScreens = [];
		super.init();

		_loadExternalClass = symbolName;
		scaleContent = false;
		
		UIEventDispatcher.initialize(this);


		if (_parent._childLoading == _name) {
			// do nothing if this is the root of the slide tree being
			// loaded...fixup will happen in childLoaded
		} else if (parentIsScreen) {
			_parent.registerChildScreen(this);
		}
	}

	// set up the relationship between this screen and a new child screen
	private function registerChildScreen(scrn:Screen)
	{
		scrn._indexInParent = _childScreens.push (scrn) -1 ;
	}


	// handle fixups when we load a subtree in from an external movie using createChild()
	function childLoaded(obj:MovieClip):Void
	{
		super.childLoaded(obj);

		// When we get here, we have loaded a movie clip underneath a
		// screen node, as a result of createChild().  If we originally
		// had called myScreen.createChild(myURL, "myChild",...), we end up
		// with
		//    Presentation1
		//        ...
		//			myScreen
		//				myChild (a plain old movie clip, not a screen). This is "obj" passed into this routine.
		//					Presentation2 (root of presentation of movie at myURL). 
		//						Screen2_1
		//						Screen2_2
		//						...
		// what we do is set the flag "_isScreenContainer" on myChild and all
		// the screen acessors, slide navigation, and form operations will ignore it and treat the parent of
		// Presentation2 as if it were myScreen.  Presentation can be
		// either a Presentation (slide) or Application (form).  We do
		// the slide/form-specific fixups in the overriden childLoaded().

		var prop:Object;
		var loadedMC: MovieClip = null;
		var realParentScreen:Screen = mx.screens.Screen(obj._parent);


		// Find the first child movie clip in the loaded movie
		for (prop in obj) {
			if ((typeof(obj[prop]) == "movieclip") && obj[prop]._isScreen) {
				loadedMC = obj[prop];
				break;
			}
		}
		// Is this a screens document?
		if (loadedMC._isScreen) {

			// Fixup loaded root to be at proper screen coordinates
			if (!scaleContent) {
				var pt:Object = new Object();
				pt.x = obj.x;
				pt.y = obj.y;
				this.globalToLocal(pt);
				obj._x = pt.x;
				obj._y = pt.y
			} else {
				var pt:Object = new Object();
				pt.x = x;
				pt.y = y;
				_parent.localToGlobal(pt);
				obj.globalToLocal(pt);
				loadedMC._x = pt.x;
				loadedMC._y = pt.y;
			}

			// Make the real parent think the loaded screen document
			// root is actually its own child
			loadedMC._indexInParent = realParentScreen._childScreens.push(loadedMC) - 1;
			obj._isScreenContainer = true;
			obj._containedScreen = loadedMC;

		}

		realParentScreen._childLoading = "";
	}

	// Never scale the loader/parent screen
	function doScaleLoader():Void
	{
	}

	// override to create a "fake" border movie clip  -- screens do
	// not support borders
	function createChildren():Void
	{
		border_mc = new mx.skins.RectBorder();
		border_mc.__borderMetrics = {top: 0, left: 0, bottom: 0, right: 0};
		super.createChildren();
	}

	// override to propagate events we receive from the transition
	// manager to on(allTransitionsInDone) handlers defined on this
	// screen.
	function allTransitionsInDone() {
		this.dispatchEvent ({type:"allTransitionsInDone", target:this});
	}


	// override to propagate events we receive from the transition
	// manager to on(allTransitionsOutDone) handlers defined on this
	// screen.
	function allTransitionsOutDone() {
		this.dispatchEvent ({type:"allTransitionsOutDone", target:this});
	}


	// Override from View class.  destroy n'th child screen
	function destroyChildAt(childIndex:Number):Void
	{
		_childScreens.splice(childIndex, 1);
		super.destroyChildAt(childIndex);
	}
}
