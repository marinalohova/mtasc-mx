//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.core.UIObject;
import mx.core.ScrollView;

/**
* @tiptext complete event
* @helpid 3931
*/
[Event("complete")]
/**
* @tiptext progress event
* @helpid 3935
*/
[Event("progress")]
/**
* @tiptext scroll event
* @helpid 3426
*/
[Event("scroll")]

[IconFile("ScrollPane.png")]

/**
* Simple pixel scrolling of
* 1. content loaded from library
* 2. contents loaded from Internet 
*
* @helpid 3018
* @tiptext ScrollPane provides a scrollable field to display a MovieClip, JPEG or SWF
*/
class mx.containers.ScrollPane extends ScrollView
{
	/**
	* @private
	* SymbolName for ScrollPane
	*/
	static var symbolName:String = "ScrollPane";

	/**
	* @private
	* Class used in createClassObject
	*/
	static var symbolOwner:Object = ScrollPane;


	/**
	* name of this class
	*/
	var className:String = "ScrollPane";

// Version string
#include "../core/ComponentVersion.as"

	var __hScrollPolicy:String = "auto";
	var __scrollDrag:Boolean = false;
	var __vLineScrollSize:Number = 5;
	var __hLineScrollSize:Number = 5;
	var __vPageScrollSize:Number= 20;
	var __hPageScrollSize:Number = 20;

	var clipParameters:Object = {contentPath : 1,scrollDrag : 1,hScrollPolicy : 1,
											vScrollPolicy : 1, vLineScrollSize : 1, hLineScrollSize : 1, 
											vPageScrollSize : 1, hPageScrollSize : 1};
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(ScrollPane.prototype.clipParameters, ScrollView.prototype.clipParameters);
	var initializing:Boolean = true;
	
	var _total:Number;
	var _loaded:Number;
	
	var lastX:Number;
	var lastY:Number;

	var __scrollContent:String;
	var spContentHolder:MovieClip;
	var keyDown:Function;

	/**
	* Returns the total number of bytes of the content to be loaded in the ScrollPane.
	* @return : Number 
	* @tiptext Returns the size of the ScrollPane content in bytes
	* @helpid 3019
	*/	
	function getBytesTotal():Number
	{ 
		return _total;
	}
	
	/**
	* Returns the number of bytes loaded in the ScrollPane. 
	* Can be called at regular intervals while loading the content to check the progress.
	* @return : Number 
	* @tiptext Returns the number of bytes loaded of the ScrollPane content
	* @helpid 3020
	*/	
	function getBytesLoaded():Number
	{
		return _loaded;
	}
	
	/**
	* The URL or linkage name of the SWF or JPEG that is to be loaded, 
	* or has been loaded, into the ScrollPane. 
	* @tiptext	Specifies the name of the MovieClip, JPEG or SWF to be loaded
	* @helpid 3021
	*/	
	[Bindable("writeonly")]
	[Inspectable(defaultValue="")]
	function set contentPath(scrollableContent:String)
	{
		if (!initializing)
		{
			if (scrollableContent == undefined)
			{
				destroyChildAt(0);
			}
			else
			{ 
				if (this[childNameBase + 0] != undefined)
					destroyChildAt(0);
				createChild(scrollableContent, "spContentHolder");	
			}			
		}
		__scrollContent = scrollableContent;
	}
	
	function get contentPath():String
	{
		return __scrollContent;
	}
	
	/**
	* The URL or linkage name of the SWF or JPEG has been loaded into the ScrollPane. 
	* @tiptext	Returns the content of the ScrollPane
	* @helpid 3932
	*/	
	function get content():MovieClip
	{
		return spContentHolder;
	}

	/**
	* @private 
	* Sets the position of horizontal scrollbar and corresponding changes the _x value of content
	* This method is defined in ScrollView & overridden in ScrollPane
	* @param	Number		Position of the horizontal scrollbar 
	* @tiptext The pixel offset into the content from the left edge 
	* @helpid 3022
	*/	
	function setHPosition(position:Number) 
	{
		if (position <= hScroller.maxPos && position >= hScroller.minPos)
		{
			super.setHPosition(position);
			spContentHolder._x = -position; // - bounds.xMin;
		}
	}
	
	/**
	* @private 
	* Sets the position of horizontal scrollbar and corresponding changes the _x value of content
	* This method is defined in ScrollView & overridden in ScrollPane
	* @param	Number		Position of the vertical scrollbar 
	* @tiptext The pixel offset into the content from the top edge
	* @helpid 3023
	*/	
	function setVPosition(position:Number) 
	{
		if (position <= vScroller.maxPos && position >= vScroller.minPos)
		{
			super.setVPosition(position);
			spContentHolder._y = -position; // - bounds.yMin;
		}
	}
	
	// Methods defined only in ScrollPane
	/**
	* number of pixels to move when UP/DOWN arrow button (in vertical scrollbar) is pressed
	* @tiptext The number of pixels to move upon clicking the vertical scrollbar's arrows
	* @helpid 3024
	*/	
	function get vLineScrollSize():Number
	{
		return __vLineScrollSize;
	}	
	
	[Inspectable(defaultValue=5)]
	function set vLineScrollSize(vLineSize:Number)
	{
		__vLineScrollSize = vLineSize;
		vScroller.lineScrollSize = vLineSize;
	}
	
	/**
	* number of pixels to move when UP/DOWN arrow button (in horizontal scrollbar) is pressed
	* @tiptext The number of pixels to move upon clicking the horizontal scrollbar's arrows
	* @helpid 3025
	*/	
	function get hLineScrollSize():Number
	{
		return __hLineScrollSize;
	}	
	
	[Inspectable(defaultValue=5)]
	function set hLineScrollSize(hLineSize:Number)
	{
		__hLineScrollSize = hLineSize;
		hScroller.lineScrollSize = hLineSize;
	}
	
	/**
	* number of pixels to move when the track in vertical scrollbar is pressed
	* @tiptext The number of pixels to move upon clicking the vertical scrollbar's track
	* @helpid 3026
	*/	
	function get vPageScrollSize():Number
	{
		return __vPageScrollSize;
	}	
	
	[Inspectable(defaultValue=20)]
	function set vPageScrollSize(vPageSize:Number)
	{
		__vPageScrollSize = vPageSize;
		vScroller.pageScrollSize = vPageSize;
	}
	
	/**
	* number of pixels to move when the track in horizontal scrollbar is pressed
	* @tiptext The number of pixels to move upon clicking the horizontal scrollbar's track
	* @helpid 3027
	*/	
	function get hPageScrollSize():Number
	{
		return __hPageScrollSize;
	}	
	
	[Inspectable(defaultValue=20)]
	function set hPageScrollSize(hPageSize:Number)
	{
		__hPageScrollSize = hPageSize;
		hScroller.pageScrollSize = hPageSize;
	}
	
	/**
	* Sets the horizontal scroll of a Scroll Pane to on/off 
	* or to real-time generation according to the size of the image.(Default value "auto")
	* @tiptext Specifies if horizontal scrollbar is on, off or automatically adjusts 
	* @helpid 3028
	*/
	[Inspectable(enumeration="auto,on,off", defaultValue="auto")]
	function set hScrollPolicy(policy:Object)
	{
		__hScrollPolicy = policy.toLowerCase();
		setScrollProperties(spContentHolder._width,1,spContentHolder._height,1);
	}

	/**
	* Sets the vertical scroll of a Scroll Pane to on/off 
	* or to real-time generation according to the size of the image.(Default value "auto")	
	* @tiptext Specifies if vertical scrollbar is on, off or automatically adjusts 
	* @helpid 3029
	*/
	[Inspectable(enumeration="auto,on,off", defaultValue="auto")]
	function set vScrollPolicy(policy:Object)
	{
		__vScrollPolicy = policy.toLowerCase();

		setScrollProperties(spContentHolder._width,1,spContentHolder._height,1);
	}

	// For Drag feature
	/**
	* Sets/returns the drag property of a scroll pane. 
	* This enables realtime mouse scrolling within the Scroll Pane.	
	* @tiptext If true, enables mouse scrolling of the content with a hand-cursor
	* @helpid 3993
	*/
	[Inspectable(defaultValue=false)]
	function get scrollDrag():Boolean
	{
		return __scrollDrag;
	}

	function set scrollDrag(s:Boolean)
	{
		__scrollDrag = s;
		if (__scrollDrag) {
			spContentHolder.useHandCursor = true;
			spContentHolder.onPress = function(){
				_parent.startDragLoop();
			}
			spContentHolder.tabEnabled = false;
			spContentHolder.onRelease = spContentHolder.onReleaseOutside = function()	{
				delete onMouseMove;
			}
			__scrollDrag = true;
		}
		else {
			delete spContentHolder.onPress;
			spContentHolder.tabEnabled = false;
			spContentHolder.tabChildren = true;
			spContentHolder.useHandCursor = false;
			__scrollDrag = false;
		}
	}
	
	function ScrollPane()
	{
	}

	//  ::: PUBLIC METHODS
	function init(Void):Void
	{
		super.init();
		tabEnabled = true;
		keyDown = _onKeyDown;
	}
	
	function createChildren(Void):Void
	{
		super.createChildren();
		mask_mc._visible = false;
		initializing = false;
		if (__scrollContent != undefined && __scrollContent!=""){
			// fire setters
			contentPath = __scrollContent;
		}
	
		
	}
	
	function size(Void):Void
	{
		super.size();
		setScrollProperties(spContentHolder._width,1,spContentHolder._height,1);

		// set the position with in the bounds of ScrollPane
		hPosition = Math.min(hPosition, maxHPosition);
		vPosition = Math.min(vPosition, maxVPosition);
	}
	
	function setScrollProperties(columnCount:Number, columnWidth:Number, rowCount:Number, rowHeight:Number):Void
	{
		super.setScrollProperties(columnCount, columnWidth, rowCount, rowHeight);
	
		hScroller.lineScrollSize = __hLineScrollSize;
		hScroller.pageScrollSize = __hPageScrollSize;
		vScroller.lineScrollSize = __vLineScrollSize;
		vScroller.pageScrollSize = __vPageScrollSize;
	}
	
	function onScroll(scrollEvent:Object):Void
	{
	  	spContentHolder._x = -__hPosition; // - bounds.xMin; 
	  	spContentHolder._y = -__vPosition; // - bounds.yMin;
		super.onScroll(scrollEvent);
	}	

	function childLoaded(obj:MovieClip):Void
	{
		super.childLoaded(obj);
		onComplete();
	} 
	
	// This method handles the complete event for both types of content
	function onComplete(Void):Void 
	{
		setScrollProperties(spContentHolder._width,1,spContentHolder._height,1);

		// set the position to 0,0 after loading the content
		hPosition = 0;
		vPosition = 0;
		
		// fire setter to get setter logic to run
		scrollDrag = __scrollDrag;
		
		invalidate();
	}
	
	function startDragLoop(Void):Void
	{
		// tabFocused=false; removed during port to AS2.0
		spContentHolder.lastX = spContentHolder._xmouse;
		spContentHolder.lastY = spContentHolder._ymouse;
		spContentHolder.onMouseMove = function() 
		{
			var scrollXMove:Number = lastX-_xmouse;
			var scrollYMove:Number = lastY-_ymouse;
			scrollXMove += _parent.hPosition;
			scrollYMove += _parent.vPosition;
 			var vm = _parent.getViewMetrics();
 			var vs = _parent.__height - vm.top - vm.bottom;
 			var hs = _parent.__width - vm.left - vm.right;
 			_parent.__hPosition = Math.max(0, Math.min( scrollXMove, _width - hs));
 			_parent.__vPosition = Math.max(0, Math.min( scrollYMove, _height - vs));
 			_parent.hScroller.scrollPosition = _parent.__hPosition;
 			_x = -_parent.hPosition; // - bounds.xMin;
 			_parent.vScroller.scrollPosition = _parent.__vPosition;
 			_y = -_parent.vPosition; // - bounds.yMin;
			
			// emit scroll event in case of Dragging as well
			super.dispatchEvent({type:"scroll"});
		}
	}
	
	function dispatchEvent(o:Object):Void
	{
		// fake target so it looks like the container and not the child
		o.target = this;
		// keep track of progress in case we're asked
		_total = o.total;
		_loaded = o.current;
		super.dispatchEvent(o);
	}
	
	/**
	* @tiptext	Reload content and refresh the pane
	* @helpid 3994
	*/
	function refreshPane(Void):Void
	{
		// reloads the contents so that events and everything is emitted again
		contentPath = __scrollContent;
	}
	
	//-- On Key Down ---------------------------------------
	function _onKeyDown(e:Object) : Void
	{
		if (hScroller!=undefined && __hPosition <= hScroller.maxPos && __hPosition >= hScroller.minPos) 
		{
			if (e.code == Key.LEFT)
			{
				hPosition -= hLineScrollSize;
			}
			else if (e.code == Key.RIGHT)
			{
				hPosition += hLineScrollSize;
			}
		}
		if (vScroller!=undefined && __vPosition <= vScroller.maxPos && __vPosition >= vScroller.minPos) 
		{
			if (e.code == Key.PGUP)
			{
				vPosition -= vPageScrollSize;
			}
			else if (e.code == Key.PGDN)
			{
				vPosition += vPageScrollSize;
			}
			if (e.code == Key.DOWN)
			{
				vPosition += vLineScrollSize;
			}
			else if (e.code == Key.UP)
			{
				vPosition -= vLineScrollSize;
			}
		}
		if (e.code == Key.HOME)
			{
				vPosition = vScroller.minPos;
			}
			else if (e.code == Key.END)
			{
				vPosition = vScroller.maxPos;
			}
	}
	
/**
* @tiptext	The pixel offset into the content from the left edge
* @helpid 3429
*/
	var hPosition:Number;
/**
* @tiptext	The pixel offset into the content from the top edge
* @helpid 3430
*/
	var vPosition:Number;
}	
