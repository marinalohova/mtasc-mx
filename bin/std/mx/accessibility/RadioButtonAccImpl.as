//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.RadioButton;
/**
* This is the accessibility class for RadioButton. 
* This class inherits from the CheckBoxAccImpl
* If accessibility has to be enabled in a RadioButton, the following code should be written in the first frame of the FLA file
* import mx.accessibility.RadioButtonAccImpl;
* RadioButtonAccImpl.enableAccessibility();
* @helpid 3008
* @tiptext This is the RadioButtonAccImpl Accessibility Class.
*/ 
class mx.accessibility.RadioButtonAccImpl extends mx.accessibility.CheckBoxAccImpl
{
	var master:Object;
	var ROLE:Number  = 0x2d;
	var owner:Object = RadioButton;
	
	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.RadioButtonAccImpl
	*/
	static function enableAccessibility()
	{
	}

	/**
	* @private
	* _accImpl Object for RadioButton
	*/
	function RadioButtonAccImpl(master:Object)
	{
		super(master);
	}
	
	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new RadioButtonAccImpl(this);
	}

	/**
	* Static Method for swapping the createAccessibilityImplementation method of RadioButton with RadioButtonAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		RadioButton.prototype.createAccessibilityImplementation = mx.accessibility.RadioButtonAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}
	//static variable pointing to the hookAccessibility Method. This is used for initializing RadioButtonAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
