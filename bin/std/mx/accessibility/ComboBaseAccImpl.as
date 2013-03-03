//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.ComboBase;
/**
* @private
* This is the accessibility class for ComboBase. 
* Since ComboBox inherits from ComboBase this class would be used in ComboBox accImpl as well.
* If accessibility has to be enabled in a component, the following code should be written in the first frame of the FLA file
* import mx.accessibility.ComboBaseAccImpl;
* ComboBaseAccImpl.enableAccessibility();
* @helpid 3004
* @tiptext This is the ComboBase Accessibility Class.
*/ 
class mx.accessibility.ComboBaseAccImpl extends mx.accessibility.AccImpl
{
	var master:Object;

	//Define all acessibility variables and values
	var ROLE:Number  = 0x2e;
	var ROLE_SYSTEM_LISTITEM :Number = 0x22;
	var EVENT_OBJECT_VALUECHANGE:Number = 0x800e;
	var EVENT_OBJECT_SELECTION :Number = 0x8006;
	var owner:Object = ComboBase;

	// Define functions which would point to main class functions
	var _setText:Function;
	var _setSelectedIndex:Function;

	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	*/
	static function enableAccessibility()
	{
	}

	/**
	* @private
	* _accImpl Object for ComboBase
	*/
	function ComboBaseAccImpl(master:Object)
	{
		super(master);

		master._setSelectedIndex = master.setSelectedIndex;
		master.setSelectedIndex = setSelectedIndex;

		master._setText = master.setText;
		master.setText = setText;
	}
	
	/**
	* @private
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new ComboBaseAccImpl(this);
	}

	//Returning the role
	/**
	* @see get_accRole
	*/
	function get_accRole(childId:Number):Number
	{
		var temp = (childId==0) ? ROLE : ROLE_SYSTEM_LISTITEM;
		return temp;
	}

	//Generating the Child ID Array
	/** 
	* @private
	* Method to return an array of childIds
	* @return Array
	*/
	function getChildIdArray():Array
	{
		var ret = new Array();

		for (var i = 0; i < master.getLength(); ++i)
		{
			var id = i+1;
			ret[i] = id;
		}
		return ret;
	}	

	//Returning the Name
	/**
	* @private
	* IAccessible method for returning the value of the ComboBox (which would be the item selected)
	* The ComboBox should return the label of the ListItem as the value and listBox should return the name specified in the Accessibility Panel.
	* @param childId : Number
	* @return Value : String
	*/
	function get_accValue(childId:Number)
	{

		if(childId != 0)
		{
			var item = master.getItemAt(childId - 1);
			if (typeof(item)!="object") return item;
			return (item.data==undefined) ? item.label : item.data;
		}
		else
		{
			return master.getValue();
		}
	}

	/**
	* @private
	* IAccessible method for returning the childId of ListItem selected.
	* @return childId : Number
	*/
	function get_accSelection():Array
	{
		var rtrn = new Array();
		rtrn.push(master.getSelectedIndex() + 1);
		return rtrn;
	}

	//over riding main class functions for emiting events
	function setSelectedIndex(v:Number)
	{
		var retVal = _setSelectedIndex(v);
		Accessibility.sendEvent(MovieClip(this), v + 1 , _accImpl.EVENT_OBJECT_SELECTION);
		Accessibility.sendEvent(MovieClip(this), 0 , _accImpl.EVENT_OBJECT_VALUECHANGE);
		return retVal;
	}

	//over riding main class functions for emiting events
	function setText(t:String)
	{
		var retVal = _setText(t);
		Accessibility.sendEvent(MovieClip(this), 0, _accImpl.EVENT_OBJECT_VALUECHANGE,true);
		return retVal;
	}

	/**
	* Static Method for swapping the createAccessibilityImplementation method of ComboBase with ComboBaseAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		ComboBase.prototype.createAccessibilityImplementation = mx.accessibility.ComboBaseAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}

	//static variable pointing to the hookAccessibility Method. This is used for initializing ComboBaseAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
