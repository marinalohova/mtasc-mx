//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.SimpleButton;
/**
* @private
* This is accessibility class for SimpleButton. This would never be used directly. 
* This AccImpl class would be used in CheckBox, RadioButton, Button as these components inherit Button Class, which in turn inherits from SimpleButton Class.
* If accessibility has to be enabled in a component, the following code should be written in the first frame of the FLA file
* import mx.accessibility.SimpleButtonAccImpl;
* SimpleButtonAccImpl.enableAccessibility();
* @helpid 3010
* @tiptext This is Simple Button Accessibility Class.
*/ 
// accessibility implementation for the SimpleButton component
class mx.accessibility.SimpleButtonAccImpl extends mx.accessibility.AccImpl
{
	//MSAA role value for Button
	var ROLE:Number  = 0x2b;
	//MSAA events and states for Button
	var EVENT_OBJECT_NAMECHANGE:Number = 0x800c;
	var EVENT_OBJECT_STATECHANGE:Number = 0x800a;
	var STATE_SYSTEM_PRESSED:Number = 0x00000008;

	var owner:Object = SimpleButton;
	
	/**
	* Method call for enabling accessibility for components
	* This method is required for compiler to activate the accessibility classes for a component
	*/
	static function enableAccessibility()
	{
	}
	
	// have to define all internal variables on SimpleButton in order for
	// the overriding functions to compile.
	var _onRelease:Function;
	var _setLabel:Function;
	/**
	* @private
	* _accImpl Object for Simple Button
	*/
	function SimpleButtonAccImpl(m:Object)
	{	
		super(m);
	
		//swap the main class methods with _accImpl class methods
		master._onRelease = master.onRelease;
		master.onRelease = onRelease;
	
		master._setLabel = master.setLabel;
		master.setLabel = setLabel;
	}
	
	/**
	* @private
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new SimpleButtonAccImpl(this);
	}

	/**
	* @private
	* IAccessible method for returning the name of the SimpleButton which is spoken out by the screen reader
	* The Simple button should return the label inside as the name of the SimpleButton. The name returned here would take precedence over the name specified in the accessibility panel.
	* @param childId : Number
	* @return Name : String
	*/
	function get_accName(childId:Number):String
	{
		var label = master.getLabel();
		// if we will return undefined, it will pick up Name from the Accessibility Panel
		return label != "" ? label : undefined;
	}
	
	/**
	* @private
	* IAccessible method for returning the state of the SimpleButton.
	* States are predefined for all the components in MSAA. Values are assigned to each state.
	* Depending upon the button being pressed or released, a value is returned.
	* @param childId : Number
	* @return STATE : Number
	*/
	function get_accState(childId:Number):Number
	{
		if(master.getState()){
			return STATE_SYSTEM_PRESSED;
		}else{
			return 0;
		}
	}
	
	/**
	* @private
	* IAccessible method for returning the default action of the SimpleButton, which is Press.
	* @param childId : Number
	* @return DefaultAction : String
	*/
	function get_accDefaultAction(childId:Number):String
	{
		return "Press";
	}
	
	/**
	* @private
	* IAccessible method for performing the default action associated with SimpleButton, which is Press.
	* @param childId : Number
	*/
	function accDoDefaultAction(childId:Number)
	{
		master.onPress();
		master.onRelease();
	}
	
	// Over riding functions for emitting Accessibility events. 
	function onRelease()
	{
		_onRelease();
		Accessibility.sendEvent( MovieClip(this), 0, _accImpl.EVENT_OBJECT_STATECHANGE,true );
	}
	
	function setLabel(label:String)
	{
		_setLabel(label);
		Accessibility.sendEvent( MovieClip(this), 0, _accImpl.EVENT_OBJECT_NAMECHANGE);
	}

	/**
	* Static Method for swapping the createAccessibilityImplementation method of SimpleButton with SimpleButtonAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		SimpleButton.prototype.createAccessibilityImplementation = mx.accessibility.SimpleButtonAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}

	//static variable pointing to the hookAccessibility Method. This is used for initializing SimplButtonAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
