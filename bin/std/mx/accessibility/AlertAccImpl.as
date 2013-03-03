//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.Alert;
/**
* This is the accessibility class for Alert. 
* If accessibility has to be enabled in a component, the following code should be written in the first frame of the FLA file
* import mx.accessibility.AlertAccImpl;
* AlertAccImpl.enableAccessibility();
* @helpid 3030
* @tiptext This is the AlertAcc Accessibility Class.
*/ 

class mx.accessibility.AlertAccImpl extends mx.accessibility.WindowAccImpl
{
	var master:Object;	

	//Define all acessibility variables
	var ROLE_SYSTEM_STATICTEXT:Number = 0x29;
	var STATE_SYSTEM_READONLY:Number = 0x40;
	var EVENT_OBJECT_SHOW:Number = 0x8002;	
	var EVENT_OBJECT_FOCUS:Number = 0x8005;	
	var EVENT_OBJECT_REORDER:Number = 0x8004;	
	
	//define to compile
	var children:Array;
	var back_mc:MovieClip;
	var button_mc:MovieClip;
	var content:MovieClip;
	var _parent:MovieClip;
	
	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.AlertAccImpl
	*/
	static function enableAccessibility()
	{
	}

	/**
	* @private
	* _accImpl Object for Alert
	*/
	function AlertAccImpl(master:Object)
	{	
		//Call super class and define the function pointers
		super(master);

		children = new Array();

	}

	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new AlertAccImpl(this);		

		//Accessibility.sendEvent(this, 0, _accImpl.EVENT_OBJECT_REORDER,true );
		Accessibility.sendEvent(MovieClip(this), 0, _accImpl.EVENT_OBJECT_CREATE);
		//Accessibility.sendEvent(this, 0, _accImpl.EVENT_OBJECT_FOCUS);
		//Accessibility.sendEvent(this, 0, _accImpl.EVENT_OBJECT_SHOW);
	}

	/**
	* @see get_accRole
	*/
	function get_accRole(childId:Number):Number
	{		
		// initialization value must be given.
		var retRole = ROLE;

		switch(childId)
		{
			case 0: 
				retRole = ROLE;
				break;
			/*
			case 1: 
				retRole = ROLE_SYSTEM_TITLEBAR;
				break;

			case 2: 
				retRole = ROLE_SYSTEM_DIALOG;
				break;
			*/
			case 1:
				retRole = ROLE_SYSTEM_STATICTEXT;
				break;

			default:
				//retRole = 0x2d;
				retRole = ROLE_SYSTEM_PUSHBUTTON;
				break;

		}
		return retRole;
	}

	/**
	* @private
	* IAccessible method for returning the name of the Alert which is spoken out by the screen reader
	* The Alert should return the Title as the name.
	* @param childId : Number
	* @return Name : String
	*/
	function get_accName(childId:Number):String
	{
		// initialization value must be given.
		var retVal = this.master.title;

		switch(childId)
		{
			case 0:
				retVal = this.master.title;
				break;
			/*
			case 1:
				retVal = "";
				break;

			case 2:
				//retVal = this.master.title;
				retVal = "";
				break;		
			*/
			case 1:
				retVal = this.master.text;
				break;

			default:
				retVal = this.master._child0.buttons[childId -2].getLabel();
				break;
		}

		return retVal;
	}
	
	/**
	* @private
	* IAccessible method for returning the state of the Alert.
	* States are predefined for all the components in MSAA. Values are assigned to each state.
	* Depending upon the Alert being Focusable, Focused and Moveable, a value is returned.
	* @param childId : Number
	* @return STATE : Number
	*/
	function get_accState(childId:Number):Number
	{
		var retVal = STATE_SYSTEM_NORMAL;
		switch(childId)
		{
			case 0:
				retVal |= STATE_SYSTEM_FOCUSABLE;
				retVal |= STATE_SYSTEM_MOVEABLE;
				break;
			/*
			case 1:
				retVal |= STATE_SYSTEM_FOCUSABLE;
				break;

			case 2:
				break;		
			*/
			case 1:
				retVal |= STATE_SYSTEM_READONLY;
				break;

			default:
				break;
		}
		return retVal;
	}

	//Generating the Child ID Array
	/** 
	* @private
	* Method to return an array of childIds of Alert component
	* @return Array
	*/
	function getChildIdArray():Object
	{
		// this is going to return array 5 Scrollbar consists of 5 sub-components
		var ret = new Array();

		for (var i = 0; i < 1 + this.master._child0.buttons.length; ++i)
		{
			var id = i+1;
			this.children[id] = i; 
			ret[i] = id;
		}
		
		return ret;
	}


	/**
	* @private
	* IAccessible method for returning the bounding box of the Alert.
	* @param childId : Number
	* @return Location : Number
	*/
	function accLocation(childId:Number):Number
	{
		// initialization value must be given.
		var retReference = this.master;
		switch(childId)
		{
			case 0: 
				retReference = this.master;
				break;
/*
			case 1: 
				retReference = this.master.back_mc.back_mc;
				break;

			case 2: 
				retReference = this.master._child0;
				break;
*/
			case 1: 
				retReference = this.master._child0.text_mc;
				break;
				
			default:
				retReference = this.master._child0.buttons[childId - 2];
				break;
		}

		return retReference;
	}
	
	//over riding the main class funciton to emit events
	function onRelease()
	{
		Accessibility.sendEvent(_parent, 0, _parent._accImpl.EVENT_OBJECT_LOCATIONCHANGE, true);
		_onRelease();
	}

	//over riding the main class funciton to emit events
	function clickHandler()
	{
		Accessibility.sendEvent(_parent, 0, _parent._accImpl.EVENT_OBJECT_DESTROY, true);
		_clickHandler();
	}

	/**
	* Static Method for swapping the createAccessibilityImplementation method of Alert with AlertAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		Alert.prototype.createAccessibilityImplementation = mx.accessibility.AlertAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}
	
	//static variable pointing to the hookAccessibility Method. This is used for initializing AlertAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accHooked:Boolean = hookAccessibility();
}

