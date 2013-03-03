//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

/*
* Accordion header control.
*
* @private
*/

import mx.controls.Button;
import mx.core.UIObject;
import mx.skins.RectBorder;

class mx.containers.accordionclasses.AccordionHeader extends Button 
{
/**
* @private
* SymbolName for object
*/
	static var symbolName:String = "AccordionHeader";
	
/**
* @private
* 
*/		
	var ignoreClassStyleDeclaration = { Button: 1 };
	
/**
* @private
* Class used in createClassObject
*/
	static var symbolOwner = mx.containers.accordionclasses.AccordionHeader;
	var	className:String = "AccordionHeader";

	// Disable skins
	var falseUpSkin:String  = "AccordionHeaderSkin";
	var falseDownSkin:String  = "AccordionHeaderSkin";
	var falseOverSkin:String = "AccordionHeaderSkin"
	var falseDisabledSkin:String = "AccordionHeaderSkin";
	var trueUpSkin:String = "AccordionHeaderSkin";
	var trueDownSkin:String = "AccordionHeaderSkin";
	var trueOverSkin:String = "AccordionHeaderSkin";
	var trueDisabledSkin:String = "AccordionHeaderSkin";
	
	// Overrides
	var centerContent:Boolean = false;
	var btnOffset:Number = 0;
	
	// Max depth. This is needed because the header edges overlap
	// by a pixel (according to halo spec), so we need to dynamically
	// swap depths when we are rolled over or focused.
	// The default value is determined by the accordions mask layer.
	var maxDepth:Number = 1999;
	
	var focus_mc:MovieClip;
	
	function AccordionHeader()
	{
	}

	#include "../../core/ComponentVersion.as"
	
	function onRollOver():Void
	{
		// The halo design specifies that accordion headers overlap by a pixel when layed out.
		// In order for the border to be completely drawn on rollover, we need to swapDepths
		// here to bring this header to the front.
		swapDepths(maxDepth);
		super.onRollOver();
	}
	
	function drawFocus(isFocused:Boolean):Void
	{
		// Accordion header focus is drawn inside the control.
		if (isFocused)
		{
			if (focus_mc == undefined)
				focus_mc = createObject("FocusRect", "focus_mc", 10);
			
			focus_mc.move(1, 1);
			focus_mc.setSize(width - 2, height - 2, 0, 100, getStyle("themeColor"));
			focus_mc._visible = true;
		}
		else
		{
			focus_mc._visible = false;
		}
	}
}
