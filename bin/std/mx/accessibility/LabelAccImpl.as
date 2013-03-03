//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.accessibility.AccImpl;
import mx.controls.Label;

// accessibility implementation for the Label component

/**
* This is the accessibility class for Label. 
* If accessibility has to be enabled in a Label, the following code should be written in the first frame of the FLA file
* import mx.accessibility.LabelAccImpl;
* labelAccImpl.enableAccessibility();
* @helpid 3006
* @tiptext This is the LabelAccImpl Accessibility Class.
*/ 
class mx.accessibility.LabelAccImpl extends mx.accessibility.AccImpl
{
	var master:Object;

	//MSAA roles and events for static Text
	var ROLE:Number = 0x29;
	var EVENT_OBJECT_NAMECHANGE:Number = 0x800c;
	var owner:Object = Label;
	

	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.LabelAccImpl
	*/
	static function enableAccessibility()
	{
		
	}
	
	// have to define all internal variables on SimpleButton in order for
	// the overriding functions to compile.
	var _setText:Function;

	/**
	* @private
	* _accImpl Object for Label
	*/
	function LabelAccImpl(m:Object)
	{	
		super(m);
	
		master._setText = master.setText;
		master.setText = setText;
	}
	
	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new LabelAccImpl(this);
	}

	/**
	* @private
	* IAccessible method for returning the name of the Label which is spoken out by the screen reader
	* The Label should return the label inside as the name. The name returned here would take precedence over the name specified in the accessibility panel.
	* @param childId : Number
	* @return Name : String
	*/
	function get_accName(childId :Number) :String
	{
		var label = master.getText();
		return label != "" ? label : undefined;
	}
	
	//over riding main Label class method for emitting events
	function setText(text :String) :String
	{
		var retVal = _setText(text);
		Accessibility.sendEvent( MovieClip(this), 0, _accImpl.EVENT_OBJECT_NAMECHANGE);
		return retVal;
	}


	/**
	* Static Method for swapping the createAccessibilityImplementation method of Label with LabelAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		Label.prototype.createAccessibilityImplementation = mx.accessibility.LabelAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}

	//static variable pointing to the hookAccessibility Method. This is used for initializing LabelAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
