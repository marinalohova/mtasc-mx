//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.Button;
/*
* This is the accessibility class for Button. 
* This AccImpl class would be used in CheckBox and RadioButton as these components inherit Button Class.
* If accessibility has to be enabled in a component, the following code should be written in the first frame of the FLA file
* import mx.accessibility.ButtonAccImpl;
* ButtonAccImpl.enableAccessibility();
* @helpid 3002
* @tiptext This is the Button Accessibility Class.
*/ 
class mx.accessibility.ButtonAccImpl extends mx.accessibility.SimpleButtonAccImpl
{
	var master:Object;
	var owner:Object = Button;
	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.ButtonAccImpl
	*/
	static function enableAccessibility()
	{
	}

	/**
	* @private
	* _accImpl Object for Button
	*/
	function ButtonAccImpl(master:Object)
	{
		super(master);
	}

	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new ButtonAccImpl(this);
	}

	
	/**
	* Static Method for swapping the createAccessibilityImplementation method of Button with ButtonAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		Button.prototype.createAccessibilityImplementation = mx.accessibility.ButtonAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}

	//static variable pointing to the hookAccessibility Method. This is used for initializing ButtonAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
