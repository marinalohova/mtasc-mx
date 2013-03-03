//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.containers.accordionclasses.AccordionHeader;
import mx.controls.SimpleButton;
import mx.core.UIComponent;
import mx.core.UIObject;
import mx.core.View;
import mx.effects.Tween;

[RequiresDataBinding(true)]
[IconFile("Accordion.png")]

/**
* @tiptext change event
* @helpid 3012
*/
[Event("change")]

/**
* Accordion class
* - extends View
* - Displays one child view at a time
* - Displays a header for each child view
*
* @tiptext Accordion allows for navigation between different child views
* @helpid 3013
*/

class mx.containers.Accordion extends View
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "Accordion";

/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner:Object = Accordion;
	var className:String = "Accordion";

	#include "../core/ComponentVersion.as"

	////////////////////////////////////////////////////////////////////////////////
	//
	// Constants
	//
	////////////////////////////////////////////////////////////////////////////////

/**
* @private
* Private constants
*/
	private var kBaseHeaderDepth:Number = 1000;
	private var kBaseMaskDepth:Number = 2000;

	private var kHeaderNameBase:String = "_header";	// base for all header names (_header0 - _headerN)
	private var kMaskNameBase:String = "_mask";	// base for all mask names (_mask0 - _maskN)

	////////////////////////////////////////////////////////////////////////////////
	//
	// New properties of Accordion
	//
	////////////////////////////////////////////////////////////////////////////////

/**
* @private
* Private properties
*/
	private var headerClass:Function = AccordionHeader;
	private var __selectedIndex:Number = undefined;
	private var __focusedIndex:Number = 0;
	private var __bDrawFocus:Boolean = false;

/**
* @private
* Cached tween properties to speed up tweening calculations
*/
	private var tweenBorderMetrics:Object;
	private var tweenMargins:Object;
	private var tweenContentWidth:Number;
	private var tweenContentHeight:Number;
	private var tweenOldSelectedIndex:Number;
	private var tweenNewSelectedIndex:Number;
	private var tween:Tween;

	// Flash clip parameters:
	[Inspectable]
	[tiptext("Child symbols to be added to the accordion")]
	[helpid("3000")]
	var childSymbols:Array;

	[Inspectable]
	[tiptext("Instance names for accordions children")]
	[helpid("3000")]
	var childNames:Array;

	[Inspectable]
	[tiptext("Labels for accordion children")]
	[helpid("3000")]
	var childLabels:Array;

	[Inspectable]
	[tiptext("Icons for accordions children (optional)")]
	[helpid("3000")]
	var childIcons:Array;

	// Skins to be used by AccordionHeader
	var falseUpSkin:String;
	var falseDownSkin:String;
	var falseOverSkin:String;
	var falseDisabledSkin:String;
	var trueUpSkin:String;
	var trueDownSkin:String;
	var trueOverSkin:String;
	var trueDisabledSkin:String;

	// dynamic properties:
	// _headerN
	// _maskN

	////////////////////////////////////////////////////////////////////////////////
	//
	// Constructor
	//
	////////////////////////////////////////////////////////////////////////////////

	function Accordion()
	{
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Method overrides
	//
	////////////////////////////////////////////////////////////////////////////////

/**
* @private
* Accordion initialization
*/
	function init()
	{
		super.init();

		// Most views can't take focus, but an accordion can.
		// However, it draws its own focus indicator on the
		// header for the currently selected child view.
		// View.init() has set tabEnabled false, so we
		// have to set it back to true.
		tabEnabled = true;

		boundingBox_mc._visible = false;
		boundingBox_mc._width = boundingBox_mc._height = 0;
	}

/**
* Create a new child segment in the accordion.
* Override View to create header
* @tiptext Creates a new child segment in the Accordion
* @helpid 3014
*/
	// the id is not typed so that a ref can be passed
	function createChild(symbolName, instanceName:String, props:Object):MovieClip
	{
		// Create the content (_childN)
		var content_mc:MovieClip = super.createChild(symbolName, instanceName, props);

		// Make it initially invisible to avoid flicker. It doesn't get correctly
		// positioned until doLayout() executes in a later frame.
		content_mc._visible = false;

		var i:Number = numChildren - 1;

		createHeaderAndMask(content_mc, i);

		invalidate();

		return content_mc;
	}

/**
* Create a new segment in the accordion.
* Wrapper for createChild.
* @tiptext Creates a new segment in the Accordion
* @helpid 3015
*/
	function createSegment(symbolName, instanceName:String, labelStr:String, iconStr:String):MovieClip
	{
		return createChild(symbolName, instanceName, {label: labelStr, icon: iconStr});
	}

/**
* Remove a segment from the accordion.
* Override View to destroy the header and mask and to call invalidate
* @tiptext Removes a segment from the Accordion
* @helpid 3016
*/
	function destroyChildAt(index:Number):Void
	{
		if (numChildren == 0)
			return;

		super.destroyChildAt(index);

		destroyObject(kHeaderNameBase + index);
		destroyObject(kMaskNameBase + index);

		// Shuffle the header and mask names
		var nChildren = numChildren;
		for (var i:Number = Number(index); i < nChildren; i++)
		{
			this[kHeaderNameBase + i] = this[kHeaderNameBase + (i + 1)];
			this[kHeaderNameBase + i]._name = kHeaderNameBase + i;
			this[kMaskNameBase + i] = this[kMaskNameBase + (i + 1)];
			this[kMaskNameBase + i]._name = kMaskNameBase + i;

			// Changing the _name of the Header makes the icon disappear.  This call
			// causes the Header to regain its sanity.
			this[kHeaderNameBase + i].setStateVar(this[kHeaderNameBase + i].getState());
		}

		// Delete the leftover slot
		delete this[kHeaderNameBase + nChildren];
		delete this[kMaskNameBase + nChildren];

		// Shuffle all remaining children, so that their depths are
		// all compacted, adjacent to one another.
		for (var i:Number = 0; i < nChildren; i++)
		{
			this[kHeaderNameBase + i].swapDepths(kBaseHeaderDepth + i);
			this[kMaskNameBase + i].swapDepths(kBaseMaskDepth + i);
			this[mx.core.View.childNameBase + i].swapDepths(i+1);
		}

		// If we just deleted the only child, the accordion is now empty,
		// and no child is now selected.
		if (nChildren == 0)
			__selectedIndex = undefined;

		// If we deleted a child before the selected child, the
		// index of that selected child is now 1 less than it was.
		else if (index < __selectedIndex)
			__selectedIndex--;

		// Now handle the case that we deleted the selected child
		// and there is another child that we must select.
		else if (index == __selectedIndex)
		{
			// If it was the last child, select the previous one.
			if (index == nChildren)
				__selectedIndex--;

			// Otherwise, select the next one. This next child now
			// has the same index as the one we just deleted,
			// so we don't adjust __selectedIndex.

			// Select the new selected index header
			var newHeader = this[kHeaderNameBase + __selectedIndex];
			newHeader.setState(true);
		}

		invalidate();
	}

/**
* @private
*
*/
	function createChildren():Void
	{
		// Create child views based on the clip parameters
		// childSymbols, childNames, childLabels and childIcons.
		var n:Number = childNames.length;
		for (var i:Number = 0; i < n; i++)
		{
			var childSymbol:String = childSymbols[i];
			if (childSymbol == undefined)
				childSymbol = "View";
			createChild(childSymbol, childNames[i], { label: childLabels[i], icon: childIcons[i] });
		}

		super.createChildren();
	}

/**
* @private
*
*/
	function initLayout():Void
	{
		var n:Number = numChildren;
		for (var i:Number = 0; i < n; i++)
		{
			// The content clips (_child0, _child1)
			// have already been created by View.
			var content_mc:MovieClip = getChildAt(i);
			content_mc.swapDepths(i + 1);

			createHeaderAndMask(content_mc, i);
		}

		super.initLayout();
	}

/**
* Layout the accordion contents
* @tiptext Arranges the layout of the Accordion's contents
* @helpid 3017
*/
	function doLayout():Void
	{
		// Measure the border.
		var borderMetrics:Object = border_mc.borderMetrics;
		var marginLeft:Number = -1;// !!@ getStyle("marginLeft");
		var marginRight:Number = -1;// !!@ getStyle("marginRight");
		var marginTop:Number = getStyle("marginTop");
		var verticalGap:Number = getStyle("verticalGap");

		// Determine the width and height of the content area.
		var localContentWidth:Number = calcContentWidth();
		var localContentHeight:Number = calcContentHeight();

		// Arrange the headers, the content clips, and the masks,
		// based on selectedIndex.
		var x:Number = borderMetrics.left + marginLeft;
		var y:Number = borderMetrics.top + marginTop;

		// Adjustments. These are required since the default halo
		// appearance has verticalGap and all margins set to -1
		// so the edges of the headers overlap each other and the
		// border of the accordion. These overlaps cause problems with
		// the content area clipping, so we adjust for them here.
		var contentX:Number = x;
		var adjContentWidth:Number = localContentWidth;
		var headerHeight:Number = getStyle("headerHeight");

		if (marginLeft < 0)
		{
			contentX -= marginLeft;
			adjContentWidth += marginLeft;
		}

		if (marginRight < 0)
			adjContentWidth += marginRight;

		var n:Number = numChildren;
		for (var i:Number = 0; i < n; i++)
		{
			var header_mc:SimpleButton = this[kHeaderNameBase + i];
			var content_mc:MovieClip = getChildAt(i);
			var mask_mc:MovieClip = this[kMaskNameBase + i];

			header_mc.move(x, y);
			header_mc.setSize(localContentWidth, headerHeight);
			// Newly created headers are initially invisible to avoid flicker,
			// so we force all headers to visible at layout time.
			header_mc.visible = true;
			y += headerHeight;

			mask_mc._x = contentX;
			mask_mc._y = y;
			mask_mc._width = adjContentWidth;
			mask_mc._height = localContentHeight + verticalGap;

			content_mc._x = contentX;
			content_mc._y = y;
			content_mc._visible = (i == selectedIndex);

			if (i == selectedIndex)
				y += localContentHeight;

			y += verticalGap;
		}
	}

/**
* @private
*/
	function onSetFocus():Void
	{
		super.onSetFocus();

		// When the accordion has focus, the Focus Manager
		// should not treat the Enter key as a click on
		// the default pushbutton.
		getFocusManager().defaultPushButtonEnabled = false;
	}

/**
* @private
*/
	function onKillFocus():Void
	{
		super.onKillFocus();

		getFocusManager().defaultPushButtonEnabled = true;
	}

/**
* @private
* handle key down events
*/
	function keyDownHandler(evt:Object):Void
	{
		if (tween != undefined)
			return;
			
 		var	prevValue:Number = selectedIndex;

   		switch (evt.code)
   		{
   			case Key.PGDN:
   			{
   				if (selectedIndex < (numChildren - 1))
   					selectedIndex = selectedIndex + 1;
   				else
   					selectedIndex = 0;
 				dispatchChangeEvent(prevValue, selectedIndex);
   				break;
   			}
   
   			case Key.PGUP:
   			{
   				if (selectedIndex > 0)
   					selectedIndex = selectedIndex - 1;
   				else
   					selectedIndex = numChildren - 1;
				dispatchChangeEvent(prevValue, selectedIndex);
   				break;
   			}
   
   			case Key.HOME:
   			{
   				selectedIndex = 0;
				dispatchChangeEvent(prevValue, selectedIndex);
   				break;
   			}
   
   			case Key.END:
   			{
   				selectedIndex = numChildren - 1;
				dispatchChangeEvent(prevValue, selectedIndex);
   				break;
   			}
   
   			case Key.DOWN:
   			case Key.RIGHT:
   			{
   				drawHeaderFocus(__focusedIndex, false);
   				if (__focusedIndex < (numChildren - 1))
   					__focusedIndex++;
   				else
   					__focusedIndex = 0;
   				drawHeaderFocus(__focusedIndex, true);
   				break;
   			}
   
   			case Key.UP:
   			case Key.LEFT:
   			{
   				drawHeaderFocus(__focusedIndex, false);
   				if (__focusedIndex > 0)
   					__focusedIndex--;
   				else
   					__focusedIndex = (numChildren - 1);
   				drawHeaderFocus(__focusedIndex, true);
   				break;
   			}
   
   			case Key.SPACE:
   			case Key.ENTER:
   			{
   				if (__focusedIndex != selectedIndex)
   				{
   					selectedIndex = __focusedIndex;
 					dispatchChangeEvent(prevValue, selectedIndex);
   				}
   			}
   		}
   	}

	function drawFocus(isFocused:Boolean):Void
	{
		__bDrawFocus = isFocused;
		drawHeaderFocus(__focusedIndex, isFocused);
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	//  Getter/Setter properties
	//
	////////////////////////////////////////////////////////////////////////////////

	// ----------------------------------------------------------------------------
	// selectedChild
	// ----------------------------------------------------------------------------

	function getSelectedChild():MovieClip
	{
		return getChildAt(selectedIndex);
	}

/**
* @tiptext Specifies the child view that is currently displayed
* @helpid 3401
*/
	function get selectedChild():MovieClip
	{
		return getSelectedChild();
	}

	function setSelectedChild(v:MovieClip):Void
	{
		var nChildren = numChildren;

		// Find the index of the child
		for (var i = 0; i < nChildren; i++)
		{
			if (getChildAt(i) == v)
			{
				setSelectedIndex(i);
				return;
			}
		}
	}

	function set selectedChild(v:MovieClip):Void
	{
		setSelectedChild(v);
	}

	// ----------------------------------------------------------------------------
	// selectedIndex
	// ----------------------------------------------------------------------------

	function getSelectedIndex():Number
	{
		return __selectedIndex;
	}

/**
* @tiptext Specifies the index of the child view that is currently displayed
* @helpid 3402
*/
	[Bindable]
	[ChangeEvent("change")]
	function get selectedIndex():Number
	{
		return getSelectedIndex();
	}

	function setSelectedIndex(v:Number):Void
	{
		var index:Number = v;

		if (index == __selectedIndex)
			return;

		// De-select the old selected index header
		var oldHeader = this[kHeaderNameBase + __selectedIndex];
		oldHeader.setState(false);

 		var oldIndex = __selectedIndex;
 		// needs to be set here in case the tween has duration = 0
 		__selectedIndex = index;

		// Start the animation.
 		startTween(oldIndex, index);

		// Select the new selected index header
		var newHeader = this[kHeaderNameBase + __selectedIndex];
		newHeader.setState(true);

		// Update header focus
		drawHeaderFocus(__focusedIndex, false);
		__focusedIndex = __selectedIndex;
		drawHeaderFocus(__focusedIndex, __bDrawFocus);
	}

	[tiptext("Index of selected segment")]
	[helpid("3000")]
	function set selectedIndex(v:Number):Void
	{
		setSelectedIndex(v);
	}

	////////////////////////////////////////////////////////////////////////////////
	//
	// Private methods
	//
	////////////////////////////////////////////////////////////////////////////////

/**
* @private
* utility method to create the segment header and mask
*/
	function createHeaderAndMask(content_mc:Object, i:Number):Void
	{
		// An accordion starts out empty, with numChildren = 0
		// and __selectedIndex = undefined. When the first child
		// is added, we change __selectedIndex to 0.
		if (__selectedIndex == undefined)
			__selectedIndex = 0;

		var headerSkins:Object = {};
		if (falseUpSkin != undefined)
			headerSkins.falseUpSkin = falseUpSkin;
		if (falseDownSkin != undefined)
			headerSkins.falseDownSkin = falseDownSkin;
		if (falseOverSkin != undefined)
			headerSkins.falseOverSkin = falseOverSkin;
		if (falseDisabledSkin != undefined)
			headerSkins.falseDisabledSkin = falseDisabledSkin;
		if (trueUpSkin != undefined)
			headerSkins.trueUpSkin = trueUpSkin;
		if (trueDownSkin != undefined)
			headerSkins.trueDownSkin = trueDownSkin;
		if (trueOverSkin != undefined)
			headerSkins.trueOverSkin = trueOverSkin;
		if (trueDisabledSkin != undefined)
			headerSkins.trueDisabledSkin = trueDisabledSkin;

		// Create the header (_headerN)
		var header_mc = createClassObject(headerClass, kHeaderNameBase + i,
										  kBaseHeaderDepth + i, headerSkins);
		// Make it initially invisible to avoid flicker. It doesn't get correctly
		// positioned until doLayout() executes in a later frame.
		header_mc.visible = false;
		header_mc.label = content_mc.label;
		header_mc.tabEnabled = false;
		header_mc.clickHandler = function() { _parent.headerPress(this) };
		header_mc.setSize(header_mc.width, getStyle("headerHeight"));
		header_mc.content_mc = content_mc;
		if (content_mc.icon != undefined)
			header_mc.icon = content_mc.icon;

		// If this new header is the current one, select it
		if (i == __selectedIndex)
			header_mc.setState(true);

		// Create the mask (_maskN)
		var mask_mc:MovieClip = createObject("BoundingBox", kMaskNameBase + i,
										  kBaseMaskDepth + i);

		content_mc.setMask(mask_mc);
	}

/**
* @private
*
*/
	function getHeaderAt(idx:Number):UIComponent
	{
		return this[kHeaderNameBase + idx];
	}

/**
* @private
*
*/
	function calcContentWidth():Number
	{
		// Start with the width of the entire accordion.
		var contentWidth:Number = width;

		// Subtract the widths of the left and right borders.
		var borderMetrics:Object = border_mc.borderMetrics;
		contentWidth -= borderMetrics.left + borderMetrics.right;

		// Subtract the heights of the left and right margins.
		var marginLeft:Number = -1;// !!@ getStyle("marginLeft");
		var marginRight:Number = -1;// !!@ getStyle("marginRight");

		contentWidth -= marginLeft + marginRight;

		return contentWidth;
	}

/**
* @private
*
*/
	function calcContentHeight():Number
	{
		// Start with the height of the entire accordion.
		var contentHeight:Number = height;

		// Subtract the heights of the top and bottom borders.
		var borderMetrics:Object = border_mc.borderMetrics;
		contentHeight -= borderMetrics.top + borderMetrics.bottom;

		// Subtract the heights of the top and bottom margins.
		var marginTop:Number = getStyle("marginTop");
		var marginBottom:Number = getStyle("marginBottom");
		contentHeight -= marginTop + marginBottom;

		// Subtract the header heights.
		var n:Number = numChildren;
		var verticalGap = getStyle("verticalGap");
		for (var i :Number= 0; i < n; i++)
		{
			contentHeight -= this[kHeaderNameBase + i].height;

			if (i > 0)
				contentHeight -= verticalGap;
		}

		return contentHeight;
	}

/**
* @private
*
*/
	function drawHeaderFocus(headerIndex:Number, isFocused:Boolean):Void
	{
		this[kHeaderNameBase + headerIndex].drawFocus(isFocused);
	}

/**
* @private
*
*/
   	function headerPress(header:SimpleButton):Void
   	{
 		var	prevValue:Number = selectedIndex;
 
   		// content_mc is placed onto the button so we have to access it via []
   		selectedChild = header["content_mc"];
   
 		dispatchChangeEvent(prevValue, selectedIndex);
   	}

/**
* @private
*
*/
	function startTween(oldSelectedIndex:Number, newSelectedIndex:Number):Void
	{
		// To improve the animation performance, we set up some invariants
		// used in onTweenUpdate. (Some of these, like contentHeight, are
		// too slow to recalculate at every tween step.)
		tweenBorderMetrics = border_mc.borderMetrics;
		tweenMargins = new Object();
		tweenMargins.left = -1;// !!@ getStyle("marginLeft");
		tweenMargins.top = getStyle("marginTop");
		tweenMargins.right = -1;// !!@ getStyle("marginRight");
		tweenMargins.bottom = getStyle("marginBottom");
		tweenContentWidth = calcContentWidth();
		tweenContentHeight = calcContentHeight();
		tweenOldSelectedIndex = oldSelectedIndex;
		tweenNewSelectedIndex = newSelectedIndex;

		// A single instance of Tween drives the animation.
		tween = new Tween(this, 1, tweenContentHeight - 1, getStyle("openDuration"));
		var easing = getStyle("openEasing");
		if (easing != undefined)
			tween.easingEquation = easing;
	}

/**
* @private
*
*/
	function onTweenUpdate(value:Number):Void
	{
		// Fetch the tween invariants we set up in startTween.
		var borderMetrics:Object = tweenBorderMetrics;
		var localMargins:Object = tweenMargins;
		var contentWidth:Number = tweenContentWidth;
		var contentHeight:Number = tweenContentHeight;
		var oldSelectedIndex:Number = tweenOldSelectedIndex;
		var newSelectedIndex:Number = tweenNewSelectedIndex;

		// The tweened value is the height of the new content area, which varies
		// from 0 to the contentHeight. As the new content area grows, the
		// old content area shrinks.
		var newContentHeight:Number = value;
		var oldContentHeight:Number = contentHeight - value;

		// These offsets for the Y position of the content clips make the content
		// clips appear to be pushed up and pulled down.
		var oldOffset:Number = oldSelectedIndex < newSelectedIndex ? -newContentHeight : 0;
		var newOffset:Number = newSelectedIndex > oldSelectedIndex ? 0 : -oldContentHeight;

		// Loop over all the headers to arrange them vertically.
		// The loop is intentionally over ALL the headers, not just the ones that
		// need to move; this makes the animation look equally smooth
		// regardless of how many headers are moving.
		// We also reposition the two visible content clips and their masks.
		var y:Number = borderMetrics.top + localMargins.top;
		var n:Number = numChildren;
		var verticalGap:Number = getStyle("verticalGap");
		for (var i:Number = 0; i < n; i++)
		{
			var header_mc:SimpleButton = this[kHeaderNameBase + i];
			var content_mc:MovieClip = getChildAt(i);
			var mask_mc:MovieClip = this[kMaskNameBase + i];

			header_mc._y = y;
			y += header_mc.height;

			if (i == oldSelectedIndex)
			{
				mask_mc._y = y;
				mask_mc._height = oldContentHeight;
				content_mc._y = mask_mc._y + oldOffset;
				content_mc._visible = true;
				y += oldContentHeight;

			}
			else if (i == newSelectedIndex)
			{
				mask_mc._y = y;
				mask_mc._height = newContentHeight;
				content_mc._y = mask_mc._y + newOffset;
				content_mc._visible = true;
				y += newContentHeight;
			}

			y += verticalGap;
		}
	}

/**
* @private
*
*/
	function onTweenEnd(value:Number):Void
	{
		// Delete the temporary tween invariants we set up in startTween.
		delete tweenBorderMetrics;
		delete tweenMargins;
		delete tweenContentWidth;
		delete tweenContentHeight;
		delete tweenOldSelectedIndex;
		delete tweenNewSelectedIndex;

		delete tween;

		// Do the final layout based on the new selectedIndex.
		doLayout();
	}

/**
* @private
* dispatch a "change" event
*/
 	function dispatchChangeEvent(prevValue:Number, newValue:Number):Void
   	{
 		dispatchEvent({ type:"change", prevValue:prevValue, newValue:newValue });
		
		// Dispatch a "valueChanged" event.
		dispatchValueChangedEvent(selectedIndex);
	}
}