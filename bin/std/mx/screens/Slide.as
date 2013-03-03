//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.screens.Screen;


/**
* @tiptext hideChild event
* @helpid 1853
*/
[Event("hideChild")]

/**
* @tiptext revealChild event
* @helpid 1862
*/
[Event("revealChild")]


/**
* Slide class
* - extends Screen
* - Adds management of sequential slides, automatic keyboard navigation and overlaying
*
* @tiptext Slide class.  Extends Screen.
* @helpid 1872
*/ 
[InspectableList("autoKeyNav", "overlayChildren", "playHidden", "autoLoad","contentPath")]
class mx.screens.Slide extends Screen {

	// SymbolName for object
	static var symbolName:String = "Slide";

	// Class used in createClassObject
	static var symbolOwner:Object = mx.screens.Slide;

	// name of this class
	var className:String = "Slide";

	// indicates whether this object is a Slide
	private var _isSlide = true;

	// list of immediate child Slides of this Slide.  Does not include Form children
	private var _childSlides:Array;

	// which child slide contains the current leaf slide
	private var _currentChildSlide:Slide = null;

	// current leaf child (descendant) of this slide that is active.  
	private var _currentSlide:Slide = null;

	// 0-based index of where this screen is in its parent's childSlides array	
	private var _indexInParentSlide:Number = -1;

	// used during gotoSlide(), indicates which childSlide contains the leaf slide we are going to
	private var _childThatContainsGotoSlide:Number = -1;

	// keydown handler to call to process keys for this slide
	private var _defaultKeyDownHandler:Function = null;

	// has this slide ever been revealed
	private var _shown = false;

	// prevents arrow keys doing slide navigation while focus is on a text field
	private static var _disableArrowKeys:Boolean = false;

	// allows arrow keys to enable slide navigation when focus is on a non-text field component (e.g. button)
	private static var _focusFixup:Object = null;

	// prevents re-entrancy in gotoSlide
	private static var _gotoSlideNesting = 0;

	// deferred gotoSlide, when gotoSlide has been attempted to be called re-entrantly
	private var _laterGotoSlide = null;

	// are we handling a keyDown
	private static var _inKeyDown:Boolean = false;

	// for handling default clicks to set focus 
	private static var _focusSeq:Number = 0;

	// for handling default clicks to set focus 
	private static var _clickFocusSeq:Number = 0;



// //////////////////////////////////////////////////
//
// properties
//
// //////////////////////////////////////////////////

	[Inspectable(defaultValue="inherit", enumeration="true,false,inherit")]
/**
* Use default keydown handling of arrow keys to navigate slides
* @tiptext Use default keydown handling of arrow keys to navigate slides
* @helpid 1873
*/
	public var autoKeyNav:String = "inherit";

	[Inspectable(defaultValue=false)]
/**
* Display child slides as bullet-style overlays
* @tiptext Display child slides as bullet-style overlays
* @helpid 1874
*/
	public var overlayChildren:Boolean = false;

	[Inspectable(defaultValue=true)]
/**
* Continue to play the slide's timeline when the slide is not visible
* @tiptext Continue to play the slide's timeline when the slide is not visible
* @helpid 1875
*/
	public var playHidden:Boolean = true;


// //////////////////////////////////////////////////
//
// getters/setters
//
// //////////////////////////////////////////////////

/**
* Immediate child slide that contains the current (leaf-node) slide.
* Read-Only: use gotoSlide() to set the currentChildSlide
* @tiptext  Immediate child slide that contains the current (leaf-node) slide
* @helpid   1876
*/
	public function get currentChildSlide():Slide
	{
		return _currentChildSlide;
	}


/**
* Leaf-node slide that is currently active
* Read-Only: use gotoSlide() to set the currentChildSlide
* @tiptext  Leaf-node slide that is currently active
* @helpid   1877
*/
	public function get currentSlide():Slide
	{
		return _currentSlide;
	}

/**
* Leaf-node slide that contains the current focused field or component
* Read-Only: use setFocus() to set the focus
* @tiptext  Leaf-node slide that contains the current focused field or component
* @helpid   1878
*/
	public static function get currentFocusedSlide():Slide
	{
		var curFocus:Object;
		curFocus = _root.focusManager.getFocus();
		if (!curFocus || (curFocus == undefined)) {
			curFocus = eval(Selection.getFocus());
		}
		while (curFocus && !curFocus._isSlide) {
			curFocus = curFocus._parent;
		}
		if (curFocus == undefined)
			return(null);
		else
			return(mx.screens.Slide(curFocus));
	}


/**
* keydown handler to call to process keys for this slide
* @tiptext  keydown handler to call to process keys for this slide
* @helpid   1879
*/
	public function get defaultKeyDownHandler():Function
	{
		return _defaultKeyDownHandler;
	}

	public function set defaultKeyDownHandler(newHandler:Function)
	{
		_defaultKeyDownHandler = newHandler;
	}


/**
* First leaf slide in this slide's subtree
* Read-Only: use createChild() to create new slides
* @tiptext  First leaf slide in this slide's subtree
* @helpid   1880
*/
	public function get firstSlide():Slide
	{
		// Find the first leaf in our subtree
		var newSlide:Slide = this;
		while (newSlide.numChildSlides > 0) {
			newSlide = newSlide.getChildSlide(0);
		}
		return(newSlide);
	}


/**
* Last leaf slide in this slide's subtree
* Read-Only: use createChild() to create new slides
* @tiptext  Last leaf slide in this slide's subtree
* @helpid   1881
*/
	public function get lastSlide():Slide
	{
		// Find the last leaf in our subtree
		var newSlide:Slide = this;
		while (newSlide.numChildSlides > 0) {
			newSlide = newSlide.getChildSlide(newSlide.numChildSlides-1);
		}
		return(newSlide);
	}


/**
* zero-based index of this slide in its parent (getChildSlide)
* Read-Only: use createChild() to add new child slides
* @tiptext  index of this slide in its parent (getChildSlide)
* @helpid   1882
*/
	public function get indexInParentSlide():Number
	{
		return _indexInParentSlide;
	}


/**
* next slide after this slide in the slide outline
* Read-Only: use createChild() to add new child slides
* @tiptext  next slide after this slide in the slide outline
* @helpid   1883
*/
	public function get nextSlide():Slide
	{
		// Walk up to first ancestor that we can move from
		var newSlide:Slide = this;
		while (true) {
			if (!newSlide.parentIsSlide) {
				break;
			} else if (newSlide.indexInParentSlide == newSlide.parentSlide.numChildSlides-1) {
				newSlide = newSlide.parentSlide;
			} else {
				newSlide = newSlide.parentSlide.getChildSlide(newSlide.indexInParentSlide+1);
				break;
			}
		}

		// newSlide is now the first subtree that we can move to.
		if (!newSlide.parentIsSlide) {
			// Can't move
			return(null);
		} else {
			newSlide = newSlide.firstSlide;
			return(newSlide);
		}

	}


/**
* number of children of this slide that are slides, not including forms
* Read-Only: use createChild() to add new child slides
* @tiptext  number of child slides of this slide
* @helpid   1884
*/
	public function get numChildSlides():Number
	{
		return _childSlides.length;
	}

/**
* True if this slide's _parent is a slide
* Read-Only: use createChild() to add new child slides
* @tiptext  True if this slide's _parent is a slide
* @helpid   1885
*/
	public function get parentIsSlide():Boolean
	{
		return((parentSlide != null) && (parentSlide._isSlide));
	}

/**
* Slide containing this slide.  May be null for the root slide.
* Read-Only: use createChild() to add new child screens
* @tiptext  Slide containing this slide
* @helpid   1886
*/
	public function get parentSlide():Slide
	{
		var theParent:Object = _parent;
		while (true) {
			if (theParent == null) {
				return(null);
			} else if (theParent._isSlideContainer) {  // test for zombized Slide caused by createChild
				theParent = theParent._parent;
			} else if (theParent._isSlide) {
				return(Slide(theParent));
			} else {
				return(null);
			}
		}
	}



/**
* previous slide before this slide in the slide outline
* Read-Only: use createChild() to add new child slides
* @tiptext  previous slide before this slide in the slide outline
* @helpid   1887
*/
	public function get previousSlide():Slide
	{
		// Walk up to first ancestor that we can move from
		var newSlide:Slide = this;
		while (true) {
			if (!newSlide.parentIsSlide) {
				break;
			} else if (newSlide.indexInParentSlide == 0) {
				newSlide = newSlide.parentSlide;
			} else {
				newSlide = newSlide.parentSlide.getChildSlide(newSlide.indexInParentSlide-1);
				break;
			}
		}

		// newSlide is now the first subtree that we can move to.

		if (!newSlide.parentIsSlide) {
			// Can't move
			return(null);
		} else {
			newSlide = newSlide.lastSlide;
			return(newSlide);
		}

	}


/**
* Root slide of the slide subtree that contains this screen
* Read-Only: use createChild() to add new child screens
* @tiptext  Root slide of the slide subtree that contains this screen
* @helpid   1888
*/
	public function get rootSlide():Slide
	{
		var sld:Slide = this;
		while (sld.parentIsSlide) {
			sld = sld.parentSlide;
		}
		return(sld);
	}


// //////////////////////////////////////////////////
//
// Public methods
//
// //////////////////////////////////////////////////

/**
* Get the nth child of this slide (zero-based)
* @param childIndex which slide to get
* @tiptext	Get the nth child of this slide
* @helpid	1889
*/
	function getChildSlide(childIndex:Number): Slide
	{
		return _childSlides[childIndex];
	}

/**
* Navigate to the first leaf slide below this slide
* @tiptext	Navigate to the first leaf slide below this slide
* @helpid	1890
*/
	public function gotoFirstSlide()
	{
		if (firstSlide == null) {
			return(false);
		} else {
			return(gotoSlide(firstSlide));
		}
	}

/**
* Navigate to the last leaf slide below this slide
* @tiptext	Navigate to the last leaf slide below this slide
* @helpid	1891
*/
	public function gotoLastSlide()
	{
		if (lastSlide == null) {
			return(false);
		} else {
			return(gotoSlide(lastSlide));
		}
	}

/**
* Navigate to the next leaf slide after this slide
* @tiptext	Navigate to the next leaf slide after this slide
* @helpid	1892
*/
	public function gotoNextSlide():Boolean
	{
		if (nextSlide == null) {
			return(false);
		} else {
			return(gotoSlide(nextSlide));
		}
	}

/**
* Navigate to the previous leaf slide before this slide
* @tiptext	Navigate to the previous leaf slide before this slide
* @helpid	1893
*/
	public function gotoPreviousSlide():Boolean
	{
		if (!previousSlide) {
			return(false);
		} else {
			return(gotoSlide(previousSlide));
		}
	}



/**
* Navigate to a different slide
* @param newSlide which slide to navigate to
* @tiptext	Navigate to a different slide
* @helpid	1894
*/
	public function gotoSlide(newSlide:Slide):Boolean
	{
		if (_gotoSlideNesting > 0) {
			_laterGotoSlide = newSlide;
			doLater(this, "doLaterGotoSlide");
			return(false);
		}
		_gotoSlideNesting++;

		if (newSlide == null) {
			// Nowhere to go
			_gotoSlideNesting--;
			return(false);
		}

		// Walk up from destination slide to go to, marking our way as we go
		var destSlide:Object = newSlide;
		var whichChild = 0;


		while (true) {
			destSlide._childThatContainsGotoSlide = whichChild;
			whichChild = destSlide.indexInParentSlide;
			if (!destSlide.parentIsSlide)
				break;
			else
				destSlide = destSlide.parentSlide;
		}

		// Walk up from current slide, hiding slides until we reach a common ancestor
		// of the new destSlide and the old currentSlide;
		var curSlide:Slide= null;
		var origCurSlide:Slide = null;
		var i:Number;

		if (rootSlide.currentSlide == null) {
			// No current slide yet.  Nothing to hide.
			curSlide = rootSlide;
			origCurSlide = curSlide;
		} else {
			curSlide = rootSlide.currentSlide;
			origCurSlide = curSlide;
			while (curSlide._childThatContainsGotoSlide == -1) {
				// See if we should hide ourselves and possibly our
				// siblings too
				if (curSlide.parentIsSlide) {
					if (curSlide.parentSlide._childThatContainsGotoSlide == -1) {
						// Slide we're going to is not a sibling of curSlide
						if (curSlide.shouldHideDuringGoto()) {
							if (curSlide.parentSlide.overlayChildren) {
								// If curSlide's parent was marked as overlay,
								// curSlide and its siblings
								// are currently being displayed, so we
								// have to hide it and all its siblings,
								// unless an ancestor is overlayed and will
								// remain visible
								for (i = 0; i <= curSlide.indexInParentSlide; i++) {
									curSlide.parentSlide.getChildSlide(i).hideSlide();
								}
							} else {
								curSlide.hideSlide();
							}
						}
					} else {
						// Slide we're going to IS a sibling of curSlide
						if (!curSlide.parentSlide.overlayChildren) {
							curSlide.hideSlide();	// No overlay...just hide
						} else {
							// If our parent is overlay, hide all the
							// slides between us and the destination if
							// the destination is before us (i.e. we're
							// moving backwards).
							for (i = curSlide.parentSlide._childThatContainsGotoSlide+1; i <= curSlide.indexInParentSlide; i++) {
								curSlide.parentSlide.getChildSlide(i).hideSlide();
							}
						}
					}
				}
				if (!curSlide.parentIsSlide)
					break;
				else
					curSlide = curSlide.parentSlide;
			}
		}

		if (curSlide._childThatContainsGotoSlide == -1) {
			_gotoSlideNesting--;
			return(false);
		}

		// Clear _currentSlide for outgoing/hidden slides
		var tempSlide:Slide = origCurSlide;
		while (true) {
			tempSlide._currentSlide = null;
			tempSlide._currentChildSlide = null;
			if (!tempSlide.parentIsSlide) break;
			tempSlide = tempSlide.parentSlide;
		}

		// Set the currentSlide for all ancestors of the new current slide
		tempSlide = newSlide;
		var tempChildSlide:Slide = null;
		while (true) {
			tempSlide._currentSlide = newSlide;
			tempSlide._currentChildSlide = tempChildSlide;
			if (!tempSlide.parentIsSlide) break;
			tempChildSlide = tempSlide;
			tempSlide = tempSlide.parentSlide;
		}


		// We're at a common ancestor, now walk down the tree to the new dest,
		// showing slides as we go.
		curSlide.showSlide();
		while (curSlide != newSlide) {
			var childSlide = curSlide.getChildSlide(curSlide._childThatContainsGotoSlide);
			if (childSlide == null) {
				break;
			}
			if (curSlide.overlayChildren) {
				for (i = 0; i < curSlide._childThatContainsGotoSlide; i++) {
					curSlide._childSlides[i].showSlide();
				}
			}
			curSlide = childSlide;
			curSlide.showSlide();
		}

		if (rootSlide.allAncestorsVisible()) {
			// Only set keyboard focus on visible slide subtrees
			if (_inKeyDown) {
				doLater(newSlide, "setFocus"); // don't setFocus while handling a keyDown event
			} else {
				newSlide.setFocus();
			}
		}

		// Clear the flag we marked up the tree from the current slide
		tempSlide = origCurSlide;
		while (true) {
			tempSlide._currentSlide = null;
			tempSlide._currentChildSlide = null;
			tempSlide._childThatContainsGotoSlide = -1;
			if (!tempSlide.parentIsSlide) break;
			tempSlide = tempSlide.parentSlide;
		}

		// Clear the flag we marked up the tree from the new slide.
		// Also set the currentSlide for all ancestors of the new
		// current slide
		tempSlide = newSlide;
		tempChildSlide = null;
		while (true) {
			tempSlide._currentSlide = newSlide;
			tempSlide._currentChildSlide = tempChildSlide;
			tempSlide._childThatContainsGotoSlide = -1;
			if (!tempSlide.parentIsSlide) break;
			tempChildSlide = tempSlide;
			tempSlide = tempSlide.parentSlide;
		}


		_gotoSlideNesting--;
		return true;
	}


// //////////////////////////////////////////////////
//
// Private methods
//
// //////////////////////////////////////////////////

	// deferred gotoSlide processing when gotoSlide() is called re-entrantly
	function doLaterGotoSlide() {
		gotoSlide(_laterGotoSlide);
	}

	// Slide class constructor
	function Slide()
	{
	}

	// initialize this slide
	private function init()
	{
		_childSlides = [];

		doLater(this, "stop");

		super.init();

		tabEnabled = false;
		focusEnabled = true;
		_visible = false;


		if (_focusFixup == null) // initialize keyDown event listener and selection listener if not done already
		{

			_focusFixup = new Object()
			_focusFixup.onSetFocus = function(o, n)
			{
				_focusSeq++;
				if ((n != null) && (typeof(n) != "movieclip") && !n._isSlide) {
					mx.screens.Slide._disableArrowKeys = true;
				} else
					mx.screens.Slide._disableArrowKeys = false;

			}

			Selection.addListener(_focusFixup);

			_focusFixup.onKeyDown = function(Void):Void
			{
				var o = {type:"keyDown", code:Key.getCode(), ascii:Key.getAscii(),
							shiftKey:Key.isDown(Key.SHIFT), ctrlKey:Key.isDown(Key.CONTROL)};

				Slide._inKeyDown = true;
				if (Slide.currentFocusedSlide.useDefaultKeyDownHandler()) {
					Slide.currentFocusedSlide.callDefaultKeyDownHandler(o);
				}
				_inKeyDown = false;

			}

			Key.addListener(_focusFixup);
		}

		if (_parent._name == _parent._parent._childLoading) {
			// We're the root of the slide subtree being loaded.
			// Do nothing...fixups will happen in childLoaded()
		} else if (!parentIsSlide) {
			// We're the root slide.
			// Show first leaf node
			_defaultKeyDownHandler = autoKeyDownHandler;
			addEventListener("mouseDownSomewhere", this);
			doLater(this, "gotoFirstSlide");
		} else if (parentSlide && parentSlide._isSlide) {
			parentSlide.registerChildSlide(this);
		}
	}

	// set up the relationship between this slide and a new child slide
	private function registerChildSlide(slide:Slide)
	{
		slide._indexInParentSlide = _childSlides.push (slide) - 1;
	}


	// walks the tree to see if the combination of ancestor autoKeyNav flags
	// means we should use default keyboard handling for this slide
	private function useDefaultKeyDownHandler():Boolean
	{
		var sld:Slide = this;
		while (sld.parentIsSlide && (sld.autoKeyNav == "inherit")) {
			sld = sld.parentSlide;
		}
		var retVal:Boolean;

		retVal = ((sld.autoKeyNav == "true") ||
				  (sld.autoKeyNav == "inherit"));
		return(retVal)
	}

	// invoke default keydown handling, gotten from rootSlide
	private function callDefaultKeyDownHandler(o:Object) {
		var sld:Slide = this;
		while (sld.parentIsSlide && (sld.defaultKeyDownHandler == null)) {
			sld = sld.parentSlide;
		}
		if (sld.defaultKeyDownHandler) {
			sld.defaultKeyDownHandler.call(sld, o);
		}
	}


	// default keyboard navigation handling for slides
	private function autoKeyDownHandler(o:Object)
	{
		if (!mx.screens.Slide._disableArrowKeys) {
			switch (o.code) {
				case Key.SPACE:
					if (getFocusManager().bDrawFocus) // if focus halo is on, don't advance slide with space bar
						break;
				case Key.RIGHT:
					currentSlide.gotoNextSlide();
					break;
				case Key.LEFT:
					currentSlide.gotoPreviousSlide();
					break;
				default:
					break;
			}
		 }
	}


	// set focus after transitions complete
	private function allTransitionsOutDone(o:Object)
	{
		super.allTransitionsOutDone(o);

		// If we pick do an OUT transition, make sure that if this
		// slide is the current slide, it still has focus.  This is
		// because OUT transitions auto-hide their contents after the
		// transition finishes, but this transition might not have been
		// attached to an on(hide)...it might have been on some other
		// handler.
		if (this == currentSlide) {
			this.setFocus();
		}
	}

	// make a slide visible
	private function showSlide()
	{
		if (_visible && (__transitionManager.numOutTransitions > 0)) {
			_visible = false; // to get the on(reveal) to happen
			this.__transitionManager.removeAllTransitions();
			this.__transitionManager.restoreContentAppearance();
		}
		visible = true;
	}

	// make a slide invisible
	private function hideSlide()
	{
		if (__transitionManager.numTransitions > 0) {
			this.__transitionManager.removeAllTransitions();
			this.__transitionManager.restoreContentAppearance();
		}
		visible = false;
	}

	// for deferred stop in hideHandler
	private function doStop():Void
	{
		gotoAndStop(1);
	}

	// propagate hideChild to our ancestors
	private function hideHandler(o: Object)
	{
		if (!playHidden) {
			doLater(this, "doStop");
		}
		// Fire a hideChild event on our ancestors
		var ancestorSlide: Slide;
		ancestorSlide = this;
		while (ancestorSlide.parentIsSlide) {
			ancestorSlide = ancestorSlide.parentSlide;
			ancestorSlide.dispatchEvent({type:"hideChild", target:this});
		}

	}

	// for deferred play of first frame in revealHandler
	private function doPlay():Void
	{
		play();
		_shown = true;

	}

	// propagate revealChild to our ancestors
	private function revealHandler(o: Object)
	{
		if (!_shown || !playHidden) {
			doLater(this, "doPlay");	// doLater for player 6 compatibility
		}

		// Fire a revealChild event on our ancestors
		var ancestorSlide: Slide;
		ancestorSlide = this;
		while (ancestorSlide.parentIsSlide) {
			ancestorSlide = ancestorSlide.parentSlide;
			ancestorSlide.dispatchEvent({type:"revealChild", target:this});
		}

	}


	// handle fixups when we load a subtree in from an external movie using createChild()
	function childLoaded(obj:MovieClip):Void
	{
		super.childLoaded(obj);

		// Load content at topleft of stage, rather than at regpt of
		// slide, which by default is auto-snapped to center
		var pt:Object = {x:0, y:0};
		globalToLocal(pt);
		obj.move(pt.x, pt.y);

		if (obj._containedScreen._isSlide) {

			var loadedSlide:Slide = obj._containedScreen;
			var realParentSlide: Slide = mx.screens.Slide(obj._parent);

			obj._isSlideContainer = true;
			obj._containedSlide = loadedSlide;

			loadedSlide._indexInParentSlide = realParentSlide._childSlides.push(loadedSlide) - 1;

			if (realParentSlide.currentSlide) {
				doLater(realParentSlide, "gotoFirstSlide");
			} 
		}
	}

	// Helper function to determine when to hide overlay children during gotoSlide()
	private function shouldHideDuringGoto():Boolean
	{
		if ((this._childThatContainsGotoSlide != -1) || !this.parentIsSlide)
			return false;

		var ancestorSlide:Object = this.parentSlide;
		var childThatContainsFromSlide = this.indexInParent;

		while (true) {
			if (ancestorSlide._childThatContainsGotoSlide != -1) {
				// first common ancestor of this slide and destination Slide
				if (childThatContainsFromSlide > ancestorSlide._childThatContainsGotoSlide) {
					// moving backwards -- always hide
					return true;
				}
				else if (ancestorSlide.overlayChildren)
					return false;
				else
					return true;
			}
			// Should only remain visible if all ancestors between from slide and to
			// slide are marked as overlay
			if (!ancestorSlide.overlayChildren)
				return true;

			if (!ancestorSlide.parentIsSlide)
				return false;
			else {
				childThatContainsFromSlide = ancestorSlide.indexInParent;
				ancestorSlide = ancestorSlide.parentSlide;

			}
		}
		return false;
	}

	// Override from View class.  destroy n'th child slide
	function destroyChildAt(childIndex:Number):Void
	{
		var theChild:Slide = getChildSlide(childIndex);
		if (theChild == _currentChildSlide) {
			gotoSlide(this);
		}
		_childSlides.splice(childIndex, 1);
		super.destroyChildAt(childIndex);
	}


	// Determine whether all ancestor slides of this slide are visible
	private function allAncestorsVisible(): Boolean
	{
		var theAncestor:Object = this;

		while(theAncestor) {
			if (!theAncestor._visible)
				return(false);
			theAncestor = theAncestor._parent;
		}
		return true;
	}

	private function isAncestor(a:Object, o:Object)
	{
		var p:Object = o;

		while (p && (p != a)) {
			p = p._parent;
		}
		return(p == a);
	}

	// Determine whether object o will handle mouse clicks.
	private function hasMouseHandler(o:Object)
	{
		if (  (o.onPress != undefined) || 
			  (o.onRelease != undefined) ||
			  (o.onReleaseOutside != undefined) ||
			  (o.onDragOut != undefined) ||
			  (o.onDragOver != undefined) ||
			  (o.onRollOver != undefined) ||
			  (o.onRollOut != undefined)  ||
			  (o.delegateClick != undefined) ||
			  (o.clickHandler != undefined) 
		   ) {
			return true;
		} else {
			return false;
		}
	}

	// Get the child of object o that is at (x,y)
	private function getMousedChild(x:Number, y:Number, o:Object):Object
	{
		for (var i in o)
		{
			var j = o[i];
			if (j._parent == o)
			{
				if (j.hitTest(x, y, true))
				{
					if (hasMouseHandler(j))
						return j;
					var k = getMousedChild(x, y, j);
					if (k != undefined)
						return k;
					return j;
				}
			}
		}
		return undefined;
	}

	// Handle clicks on the slide to set focus
	private function mouseDownSomewhereHandler(o: Object): Void
	{
		var x:Number = _root._xmouse;
		var y:Number = _root._ymouse;

		if (this != rootSlide)
			return;
		
		if (allAncestorsVisible() && hitTest(x, y, false)) {
			var mousedChild:Object = getMousedChild(x, y, this);
			var mousedChildGlobally:Object = getMousedChild(x, y, _root);
			var mousedSlide:Object = null;
			if ((mousedChild == undefined) && hitTest(x, y, true)) {
				if ((mousedChildGlobally == this) && !hasMouseHandler(this)) {
					mousedSlide = this;
				}
			} else if (isAncestor(mousedChildGlobally,mousedChild) && !hasMouseHandler(mousedChild)) {
				if (mousedChild._isSlide) {
					mousedSlide = mousedChild;
				} else {
					mousedSlide = mousedChild;
					while (mousedSlide && !mousedSlide._isSlide) {
						mousedSlide = mousedSlide._parent;
					}
				}
			} 

			if (mousedSlide && mousedSlide.allAncestorsVisible() && (Slide.currentFocusedSlide.rootSlide != mousedSlide.rootSlide)) {
				_focusSeq++;
				_clickFocusSeq = _focusSeq;
				doLater(mousedSlide.rootSlide.currentSlide, "clickSetFocus")
			}
			
		} 
	}

	// Deferred focus setting for mouseDownSomewhereHandler
	private function clickSetFocus():Void
	{
		if (_focusSeq == _clickFocusSeq) {
			// no one else changed focus...set focus ourselves
			doLater(this, "setFocus");
		}
	}

}
