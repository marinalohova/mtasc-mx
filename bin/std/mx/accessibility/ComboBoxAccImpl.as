//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.ComboBox;
import mx.accessibility.ListAccImpl;

/**
* This is the accessibility class for List. 
* If accessibility has to be enabled in a List, the following code should be written in the first frame of the FLA file
* import mx.accessibility.ComboBoxAccImpl;
* ComboBoxAccImpl.enableAccessibility();
* @helpid 3005
* @tiptext This is the ComboBoxAccImpl Accessibility Class.
*/ 
class mx.accessibility.ComboBoxAccImpl extends mx.accessibility.ComboBaseAccImpl
{
	var master:Object;
	var owner:Object = ComboBox;

	// Pointers to main class functions, defining to compile.
	var _setSelectedItem:Function;
	

	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.ComboBoxAccImpl
	*/
	static function enableAccessibility()
	{
		ListAccImpl.enableAccessibility();
	}

	/**
	* @private
	* _accImpl Object for ComboBox
	*/	
	function ComboBoxAccImpl(master:Object)
	{
		super(master);

		master._setSelectedItem = master.setSelectedItem;
		master.setSelectedItem = setSelectedItem;
	}

	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new ComboBoxAccImpl(this);
	}

	//over-riding main class functions for emitting events
	function setSelectedItem(v)
	{
		var retVal = _setSelectedItem(v);
		Accessibility.sendEvent(MovieClip(this), 0, _accImpl.EVENT_OBJECT_VALUECHANGE,true);
		return retVal;
	}


	/**
	* Static Method for swapping the createAccessibilityImplementation method of ComboBox with ComboBoxAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		ComboBox.prototype.createAccessibilityImplementation = mx.accessibility.ComboBoxAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}

	//static variable pointing to the hookAccessibility Method. This is used for initializing ComboBoxAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
