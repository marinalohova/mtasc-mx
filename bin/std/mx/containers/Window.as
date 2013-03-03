//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.core.ScrollView;
import mx.controls.SimpleButton;
import mx.skins.SkinElement;
import mx.core.UIObject;
import mx.managers.DepthManager

/**
* @tiptext click event
* @helpid 3985
*/
[Event("click")]
/**
* @tiptext mouseDownOutside event
* @helpid 3990
*/
[Event("mouseDownOutside")]

[TagName("Window")]
[IconFile("Window.png")]

/**
* a window with a title bar, caption and optional close button
* The title bar can be used to drag the window to a new location.
*
* @helpid 3033
* @tiptext	A window with a title bar, caption and optional close button
*/
class mx.containers.Window extends ScrollView
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "Window";
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = Window;

	// Version string
#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "Window";

/**
* @private
* index of border skin
*/
	static var skinIDBorder:Number = 0;
/**
* @private
* index of background of title bar
*/
	static var skinIDTitleBackground:Number = 1;
/**
* @private
* index of content
*/
	static var skinIDForm:Number = 2;

/**
* @private
* instance names for window skins
*/
	var idNames:Array = new Array("border_mc", "back_mc", "content");

/**
* symbol name of skin element for background of the title bar
*/
	[Inspectable(verbose=1, category="Skins")]
	var skinTitleBackground:String = "TitleBackground";

/**
* symbol name of skin element for the up state of the close button
*/
	[Inspectable(verbose=1, category="Skins")]
	var skinCloseUp:String = "CloseButtonUp";

/**
* symbol name of skin element for the over state of the close button
*/
	[Inspectable(verbose=1, category="Skins")]
	var skinCloseOver:String = "CloseButtonOver";

/**
* symbol name of skin element for the down state of the close button
*/
	[Inspectable(verbose=1, category="Skins")]
	var skinCloseDown:String = "CloseButtonDown";

/**
* symbol name of skin element for the disabled state of the close button
*/
	[Inspectable(verbose=1, category="Skins")]
	var skinCloseDisabled:String = "CloseButtonDisabled";

/**
* @private
* list of clip parameters to check at init
*/
	var clipParameters:Object = { title: 1, contentPath: 1, closeButton: 1};
/**
* @private
* all components must use this mechanism to merge their clip parameters with their base class clip parameters
*/
	static var mergedClipParameters:Boolean = UIObject.mergeClipParameters(Window.prototype.clipParameters, ScrollView.prototype.clipParameters);

/**
* @private
* true until the component has finished initializing
*/
	var initializing:Boolean = true;

/**
* the location on the window the mouse was clicked
*/
	var regX : Number;
	var regY : Number;

/**
* style declaration name for the text in the title bar
*
* @tiptext	The CSSStyleDeclaration name for setting styles on the title bar's text
* @helpid 3992
*/
	[Inspectable(defaultValue="", verbose=1, category="Skins")]
	var titleStyleDeclaration:String;

/**
* true if you want the close button displayed
*
* @tiptext	If true, the close button is displayed
* @helpid 3986
*/
	[Inspectable(defaultValue=false)]
	var closeButton:Boolean;

	var loadingChild:Boolean = false;

	// stored value of the contentPath property
	var __contentPath:String;

	// setup by PopUpManager
	var modalWindow:MovieClip;

	// these are just here so they can have helpids
/**
* The URL or linkage name of the SWF or JPEG has been loaded into the ScrollPane.
* @tiptext	Returns the content of the Window
* @helpid 3987
*/
	var content:MovieClip;
/**
* modal windows must be destroyed via deletePopUp
* @tiptext  Deletes the Window and removes the modal state
* @helpid 3989
*/
    var deletePopUp:Function;

/**
* name of the symbol or URL to the image or movie to display as the content
*
* @tiptext	Specifies the name of the content to be loaded
* @helpid 3988
*/
	[Inspectable(defaultValue="")]
	[Bindable]
	function set contentPath(scrollableContent:String)
	{
		if (!initializing)
		{
			// trace("Window :: setScrollContent " + scrollableContent);
			if (scrollableContent == undefined)
			{
				destroyChildAt(0);
			}
			else
			{
				if (this[childNameBase + 0] != undefined)
					destroyChildAt(0);
				createChild(scrollableContent, "content", {styleName:this});
			}
		}
		__contentPath = scrollableContent;
	}

	function get contentPath():String
	{
		return __contentPath;
	}

/**
* @private
* instance name of the title bar
*/
	var back_mc:MovieClip;

	// alternate instance name of the content
	var _child0:MovieClip;
/**
* @private
* instance name of bounding box that gets destroyed at init time
*/
	var boundingBox_mc:MovieClip;
/**
* @private
* instance name of the close button
*/
	var button_mc:SimpleButton;
/**
* @private
* stored value of the title text
*/
	var _title:String;

	function Window()
	{
	}

/**
* @private
* init variables.  Components should implement this method and call super.init() at minimum
*/
	function init(Void):Void
	{
		super.init();

		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;

	}

	// forward clicks to the listeners of the owner
	function delegateClick(obj:Object):Void
	{
		 _parent.dispatchEvent({type:"click"});
	}

	function startDragging(Void) : Void
	{
		if (this.modalWindow == undefined)
		{
			var o = this._parent.createChildAtDepth("BoundingBox", DepthManager.kTop, {_visible:false});
			this.swapDepths(o);
			o.removeMovieClip();
		}
		regX = _xmouse;
		regY = _ymouse;
		onMouseMove = dragTracking;
	}

	function stopDragging(Void) : Void
	{
		delete onMouseMove;
	}

	function dragTracking() : Void
	{
		var newX = _parent._xmouse - regX;
		var newY = _parent._ymouse - regY;
		var slop = 5;
		var scr = mx.managers.SystemManager.screen;
		
		if (newX < scr.x -regX + slop)
			newX = scr.x -regX + slop;
		if (newX > scr.width + scr.x - (regX + slop))
			newX = scr.width + scr.x - (regX + slop);
			
		if (newY < scr.y -regY + slop)
			newY = scr.y -regY + slop;
		if (newY > scr.height + scr.y - (regY + slop))
			newY = scr.height + scr.y - (regY + slop);
			
		move(newX, newY);
		updateAfterEvent();
	}

/**
* @private
* create child objects.
*/
	function createChildren(Void):Void
	{
		super.createChildren();

		if (back_mc == undefined)
		{
			createClassObject(UIObject, "back_mc", 1);
			back_mc.createObject(skinTitleBackground, "back_mc", 0);
		}
		back_mc.visible = false;
		depth = 3;		// put first (only?) child at level 3

		var l:Object = new Object();
		back_mc.useHandCursor = false;
		back_mc.onPress = function()
		{
			if (_parent.enabled)
				_parent.startDragging();
		}

		back_mc.onDragOut = back_mc.onRollOut = back_mc.onReleaseOutside = back_mc.onRelease = function()
		{
			var p:MovieClip = _parent;
			p.stopDragging();
		}


		back_mc.tabEnabled = false;

		// title is a child of back so back can be used to drag window
		if (back_mc.title_mc == undefined)
		{
			back_mc.createLabel("title_mc", 1, title);
			var o:UIObject = back_mc.title_mc;
			if (titleStyleDeclaration == undefined)
			{
				o.fontSize = 10;
				o.color = 0xFFFFFF;
				o.fontWeight = "bold";
			}
			else
			{
				o.styleName = titleStyleDeclaration;
			}
			o.invalidateStyle();
		}
		else
			back_mc.title_mc.text = title;
		var initObj:Object = new Object();
		initObj.falseUpSkin = skinCloseUp;
		initObj.falseOverSkin = skinCloseOver;
		initObj.falseDownSkin = skinCloseDown;
		initObj.falseDisabledSkin = skinCloseDisabled;
		initObj.tabEnabled = false;
		createClassObject(SimpleButton, "button_mc", 2, initObj);
		button_mc.clickHandler = delegateClick;

		button_mc.visible = false;
		if (validateNow)
			redraw(true);
		else
			invalidate();
	}


/**
* the title/caption displayed in the title bar
*
* @tiptext	Gets or sets the title/caption displayed in the title bar
* @helpid 3991
*/
	[Inspectable(defaultValue="")]
	[Bindable]
	function get title():String
	{
		return _title;
	}

	function set title(s:String)
	{
		_title = s;
		back_mc.title_mc.text = s;
		if (!initializing)
			draw();
	}

	// the close button and content must be disabled/enabled when we are
	function setEnabled(enable:Boolean):Void
	{
		super.setEnabled(enable);
		button_mc.enabled = enable;
		_child0.enabled = enable;

	}

	// used by future live-preview to preview contents in the containers
	function getComponentCount(Void):Number
	{
		return 1;	// splitter bar would return 2
	}

	// used by future live-preview to preview contents in the containers
	function getComponentRect(container:Number):Object
	{
		if (container == 1)
		{
			var m:Object = border_mc.borderMetrics;
			var o:Object = new Object();
			o.x = m.left;
			o.y = m.top + back_mc.height;
			o.width = width - o.x - m.right;
			o.height = height - o.y - m.bottom;
			return o;
		}
		return undefined;
	}

	// draw by making everything visible, then laying out
	function draw(Void):Void
	{
		if (initializing)
		{
			initializing = false;
			if (__contentPath != undefined)
				contentPath = __contentPath;
			_child0.visible = true;
			border_mc.visible = true;
			back_mc.visible = true;
		}
		size();
	}


/**
* get the thickness of the edges of the object taking into account the border, title bar and scrollbars if visible
* @return object with left, right, top and bottom edge thickness in pixels
*/
	function getViewMetrics(Void):Object
	{
		//-!! init __viewMetrics
		var o:Object = super.getViewMetrics();
		o.top += back_mc.height;
		return o;
	}

/**
* @private
* layout the title bar and size the content below it
*/
	function doLayout(Void):Void
	{
		super.doLayout();

		var m:Object = border_mc.borderMetrics;
		m.right += (vScroller.visible == true) ? vScroller.width : 0;
		m.bottom += (hScroller.visible == true) ? hScroller.height : 0;

		// get the thickness of the border's left corner
		var x:Number = m.left;
		var y:Number = m.top;
		// move the caption background into place and stretch to the right edge
		back_mc.move(x, y);
		back_mc.back_mc.setSize(width - x - m.right, back_mc.height);
		// set the form below the caption
		_child0.move(x, y + back_mc.height);

		//-!! this should be a call other than setSize, it's ridiculous!!
		if (_child0.size!=UIObject.prototype.size) {
			_child0.setSize(width - x - m.right,
								 height - y - back_mc.height - m.bottom);
		}

		// set the closebutton next to the upper right corner, offset by the border thickness
		button_mc.visible = (closeButton == true);
		button_mc.move(width - x - x - button_mc.width,
							(back_mc.height - button_mc.height) / 2 + y);
		var h:Number = back_mc.title_mc.textHeight;
		var offset:Number = (back_mc.height - h - 4) / 2;
		back_mc.title_mc.move(offset, offset - 1);
		back_mc.title_mc.setSize(width - offset - offset, h + 4);

	}

/**
* @see mx.core.View
*/
	// the id is not typed so that a ref can be passed
	function createChild(id, name:String, props:Object):MovieClip
	{
		loadingChild = true;
		var newObj:MovieClip = super.createChild(id, name, props);
		loadingChild = false;
		return newObj;
	}

/**
* @private
* this gets called when the child is finished loading
* @param obj the loaded child
*/
	function childLoaded(obj:MovieClip):Void
	{
		super.childLoaded(obj);
		if (loadingChild)
		{
			dispatchEvent({type: "complete", current: obj.getBytesLoaded(), total: obj.getBytesTotal()});
		}
	}

}
