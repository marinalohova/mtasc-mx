//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.Button;
import mx.skins.CustomBorder;

/**
* a button that resizes in one dimension by placing two end caps
* and stretching a middle piece
*
* @helpid 3081
* @tiptext
*/ 
class mx.controls.CustomButton extends Button
{

	// Version string
#include "../core/ComponentVersion.as"

/**
* name of this class
*/
	var className:String = "CustomButton";
	// ignore class styles for Button
	var ignoreClassStyleDeclaration = { Button: 1 };

/**
* whether the caps and middle are placed horizontally or vertically
*
* @tiptext
* @helpid 3082
*/
	var horizontal:Boolean;

	// skins for the button are always CustomBorders
	var falseUpSkin = CustomBorder.symbolName;
	var falseDownSkin = CustomBorder.symbolName;
	var falseOverSkin = CustomBorder.symbolName;
	var falseDisabledSkin = CustomBorder.symbolName;
	var trueUpSkin = CustomBorder.symbolName;
	var trueDownSkin = "";
	var trueOverSkin = "";
	var trueDisabledSkin = CustomBorder.symbolName;
	
/**
* symbol name of skin element for the left end cap in the up state
*
* @tiptext
* @helpid 3083
*/
	var falseUpSkinL = "F3PieceLeft";
/**
* symbol name of skin element for the middle piece in the up state
*
* @tiptext
* @helpid 3084
*/
	var falseUpSkinM = "F3PieceMiddle";
/**
* symbol name of skin element for the right end cap in the up state
*
* @tiptext
* @helpid 3085
*/
	var falseUpSkinR = "F3PieceRight";
/**
* symbol name of skin element for the left end cap in the down state
*
* @tiptext
* @helpid 3086
*/
	var falseDownSkinL = "F3PieceLeftDown";
/**
* symbol name of skin element for the middle piece in the down state
*
* @tiptext
* @helpid 3087
*/
	var falseDownSkinM = "F3PieceMiddleDown";
/**
* symbol name of skin element for the right end cap in the down state
*
* @tiptext
* @helpid 3088
*/
	var falseDownSkinR = "F3PieceRightDown";
/**
* symbol name of skin element for the left end cap in the over state
*
* @tiptext
* @helpid 3089
*/
	var falseOverSkinL = "F3PieceLeftOver";
/**
* symbol name of skin element for the middle piece in the over state
*
* @tiptext
* @helpid 3090
*/
	var falseOverSkinM = "F3PieceMiddleOver";
/**
* symbol name of skin element for the right end cap in the over state
*
* @tiptext
* @helpid 3091
*/
	var falseOverSkinR = "F3PieceRightOver";
/**
* symbol name of skin element for the left end cap in the selected up state
*
* @tiptext
* @helpid 3092
*/
	var trueUpSkinL = falseDownSkinL;
/**
* symbol name of skin element for the middle piece in the selected up state
*
* @tiptext
* @helpid 3093
*/
	var trueUpSkinM = falseDownSkinM;
/**
* symbol name of skin element for the right end cap in the selected up state
*
* @tiptext
* @helpid 3094
*/
	var trueUpSkinR = falseDownSkinR;
/**
* symbol name of skin element for the left end cap in the selected down state
*
* @tiptext
* @helpid 3095
*/
	var trueDownSkinL = falseDownSkinL;
/**
* symbol name of skin element for the middle piece in the selected down state
*
* @tiptext
* @helpid 3096
*/
	var trueDownSkinM = falseDownSkinM;
/**
* symbol name of skin element for the right end cap in the selected down state
*
* @tiptext
* @helpid 3097
*/
	var trueDownSkinR = falseDownSkinR;
/**
* symbol name of skin element for the left end cap in the selected over state
*
* @tiptext
* @helpid 3098
*/
	var trueOverSkinL = falseOverSkinL;
/**
* symbol name of skin element for the middle piece in the selected over state
*
* @tiptext
* @helpid 3099
*/
	var trueOverSkinM = falseOverSkinM;
/**
* symbol name of skin element for the right end cap in the selected over state
*
* @tiptext
* @helpid 3100
*/
	var trueOverSkinR = falseOverSkinR;
/**
* symbol name of skin element for the left end cap in the disabled state
*
* @tiptext
* @helpid 3101
*/
	var falseDisabledSkinL = "F3PieceLeftDisabled";
/**
* symbol name of skin element for the middle piece in the disabled state
*
* @tiptext
* @helpid 3102
*/
	var falseDisabledSkinM = "F3PieceMiddleDisabled";
/**
* symbol name of skin element for the right end cap in the disabled state
*
* @tiptext
* @helpid 3103
*/
	var falseDisabledSkinR = "F3PieceRightDisabled";
/**
* symbol name of skin element for the left end cap in the selected disabled state
*
* @tiptext
* @helpid 3104
*/
	var trueDisabledSkinL = falseDisabledSkinL;
/**
* symbol name of skin element for the middle piece in the selected disabled state
*
* @tiptext
* @helpid 3105
*/
	var trueDisabledSkinM = falseDisabledSkinM;
/**
* symbol name of skin element for the right end cap in the selected disabled state
*
* @tiptext
* @helpid 3106
*/
	var trueDisabledSkinR = falseDisabledSkinR;

	function CustomButton()
	{
	}
	
/**
* @private
* re-calculate the minimum sizes of the button after a skin loads
*/
	function calcSize(tag:Number, ref:String):Void
	{
		if (tag < 7)
		{
			_minHeight = this[idNames[tag]].minHeight;
			_minWidth = this[idNames[tag]].minWidth;
		}
		super.calcSize(tag, ref);
	}
	
/**
* @private
* assign the skins when we need them
*/
	function setSkin(tag:Number, linkageName:String, io:Object):Object
	{
		io.horizontal = horizontal;
		io.validateNow = true;
		
		var s = stateNames[tag];
		io.leftSkin = this[s + "SkinL"];
		io.middleSkin = this[s + "SkinM"];
		io.rightSkin = this[s + "SkinR"];
		
		return super.setSkin(tag, linkageName, io);
	}
}
