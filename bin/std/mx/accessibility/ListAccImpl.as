//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.List;

// accessibility implementation for the List component

/**
* This is the accessibility class for List. 
* If accessibility has to be enabled in a List, the following code should be written in the first frame of the FLA file
* import mx.accessibility.ListAccImpl;
* ListAccImpl.enableAccessibility();
* @helpid 3007
* @tiptext This is the ListAccImpl Accessibility Class.
*/ 
class mx.accessibility.ListAccImpl extends mx.accessibility.ScrollSelectListAccImpl
{
	var master:Object;
	var owner:Object = List;

	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.ListAccImpl
	*/
	static function enableAccessibility()
	{
	}

	
	/**
	* @private
	* _accImpl Object for List
	*/
	function ListAccImpl(master:Object)
	{
		super(master);
	}

	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new ListAccImpl(this);
	}

	/**
	* Static Method for swapping the createAccessibilityImplementation method of List with ListAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		List.prototype.createAccessibilityImplementation = mx.accessibility.ListAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}
	
	//static variable pointing to the hookAccessibility Method. This is used for initializing ListAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}

