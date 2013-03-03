//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.CheckBox;
/**
* This is the accessibility class for CheckBox. 
* If accessibility has to be enabled in a CheckBox, the following code should be written in the first frame of the FLA file
* import mx.accessibility.CheckBoxAccImpl;
* CheckBoxAccImpl.enableAccessibility();
* @helpid 3003
* @tiptext This is the CheckBoxAccImpl Accessibility Class.
*/ 
class mx.accessibility.CheckBoxAccImpl extends mx.accessibility.ButtonAccImpl
{
	var master:Object;
	var ROLE:Number  = 0x2c;
	var STATE_SYSTEM_CHECKED:Number = 0x10;
	var owner:Object = CheckBox;
	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.CheckBoxAccImpl
	*/
	static function enableAccessibility()
	{
	}

	/**
	* @private
	* _accImpl Object for CheckBox
	*/
	function CheckBoxAccImpl(master:Object)
	{
		super(master);
	}
	
	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new CheckBoxAccImpl(this);
	}
	
	/**
	* IAccessible method for returning the state of the CheckBox.
	* States are predefined for all the components in MSAA. Values are assigned to each state.
	* Depending upon the CheckBox is checked or unchecked, a value is returned.
	* @param childId : Number
	* @return STATE : Number
	*/
	function get_accState(childId :Number):Number
	{
		if(master.getState())
		{
			return STATE_SYSTEM_CHECKED;
		}
		else
		{
			return STATE_SYSTEM_NORMAL;
		}
	}
	

	/**
	* IAccessible method for returning the default action of the CheckBox, which is Check or UnCheck depending on the state.
	* @param childId : Number
	* @return DefaultAction : String
	*/
	function get_accDefaultAction(childId :Number) :String
	{
		if(master.getState())
		{
			return "Check";
		}
		else
		{
			return "UnCheck";
		}
	}	
	
	/**
	* Static Method for swapping the createAccessibilityImplementation method of CheckBox with CheckBoxAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		CheckBox.prototype.createAccessibilityImplementation = mx.accessibility.CheckBoxAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}
	//static variable pointing to the hookAccessibility Method. This is used for initializing CheckBoxAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
