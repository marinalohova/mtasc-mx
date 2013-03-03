//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.containers.Window;

/**
* This is the accessibility class for Window. 
* If accessibility has to be enabled in a component, the following code should be written in the first frame of the FLA file
* import mx.accessibility.WindowAccImpl;
* WindowAccImpl.enableAccessibility();
* @helpid 3011
* @tiptext This is the Window Accessibility Class.
*/ 
class mx.accessibility.WindowAccImpl extends mx.accessibility.AccImpl
{
	var master:Object;	
	var owner:Object = Window;

	//Define all acessibility variables
	var ROLE :Number = 0x09; //role for a window
	var ROLE_SYSTEM_TITLEBAR:Number = 0x01;
	var ROLE_SYSTEM_PUSHBUTTON:Number = 0x2b;
	var ROLE_SYSTEM_DIALOG:Number = 0x12;

	var STATE_SYSTEM_SIZEABLE: Number	=	0x00020000;
	var STATE_SYSTEM_MOVEABLE: Number	=	0x00040000;
	var STATE_SYSTEM_FOCUSABLE: Number	=	0x00100000;
	var STATE_SYSTEM_FOCUSED:Number		=	0x00000004; 
	var STATE_SYSTEM_UNAVAILABLE :Number=   0x00000001; 
	var STATE_SYSTEM_SELECTED :Number   =   0x00000002;
	var STATE_SYSTEM_INVISIBLE :Number  =   0x00008000;
	var STATE_SYSTEM_OFFSCREEN :Number  =   0x00010000;
	var STATE_SYSTEM_SELECTABLE :Number	=   0x00200000;
	var STATE_SYSTEM_DEFAULT:Number = 0x00000100;

	var EVENT_OBJECT_LOCATIONCHANGE:Number = 0x800b;
	var EVENT_OBJECT_CREATE:Number = 0x8000;
	var EVENT_OBJECT_DESTROY:Number = 0x8001;

	//define to compile
	var children:Array;
	var back_mc:MovieClip;
	var button_mc:MovieClip;
	var content:MovieClip;
	var _parent:MovieClip;
	
	/** defining functions which would be pointing to mainclass functions**/
	var _onRelease:Function;
	var _clickHandler:Function;

	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.WindowAccImpl
	*/
	static function enableAccessibility()
	{
	}
	
	/**
	* @private
	* _accImpl Object for Window
	*/
	function WindowAccImpl(m:Object)
	{	
		//Call super class and define the function pointers
		super(m);
		
		master.back_mc._onRelease = master.back_mc.onRelease;
		master.back_mc.onRelease = onRelease;

		master.button_mc._clickHandler = master.button_mc.clickHandler;
		master.button_mc.clickHandler = clickHandler;

		children = new Array();
	}

	/**
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new WindowAccImpl(this);
		Accessibility.sendEvent(MovieClip(this), 0, _accImpl.EVENT_OBJECT_CREATE,true );
	}

	
	/**
	* @see get_accRole
	*/
	function get_accRole(childId:Number):Number
	{
		
		var retRole = ROLE;
		switch(childId)
		{
			case 1: 

				retRole = ROLE_SYSTEM_TITLEBAR;
				break;

			case 2: 

				retRole = ROLE_SYSTEM_DIALOG;
				break;
			default:

				retRole = ROLE;
				break;
		}
		return retRole;
	}
	
	
	/**
	* @private
	* IAccessible method for returning the name of the Window which is spoken out by the screen reader
	* The Window should return the Title as the name.
	* @param childId : Number
	* @return Name : String
	*/
	function get_accName(childId:Number):String
	{
		var retVal = this.master.title;

		switch(childId)
		{
			case 1: 
				retVal = "";
				break;

			case 2:
				retVal = "";
				break			

			default:
				retVal = this.master.title;
				break;
		}

		return retVal;
	}
	
	/**
	* @private
	* IAccessible method for returning the state of the Window.
	* States are predefined for all the components in MSAA. Values are assigned to each state.
	* Depending upon the Window being Focusable, Focused and Moveable, a value is returned.
	* @param childId : Number
	* @return STATE : Number
	*/
	function get_accState(childId:Number):Number
	{
		var retVal = STATE_SYSTEM_FOCUSABLE;
		switch(childId)
		{
			case 1: 
				break;

			case 2:
				retVal |= STATE_SYSTEM_FOCUSED;
				break;
				
			default:
				retVal |= STATE_SYSTEM_MOVEABLE;
				break;
		}
		return retVal;
	}

	//Generating the Child ID Array
	/** 
	* @private
	* Method to return an array of childIds of Window component
	* @return Array
	*/
	function getChildIdArray():Object
	{
		// this is going to return array 5 Scrollbar consists of 5 sub-components
		var ret = new Array();

		// Top button = 1, TrackUp = 2, ScrollThumb = 3, TrackDown = 4, Bottom button = 5.
		for (var i = 0; i < 2; ++i)
		{
			var id = i+1;
			this.children[id] = i; 
			ret[i] = id;
		}
		
		return ret;
	}


	/**
	* @private
	* IAccessible method for returning the bounding box of the Window.
	* @param childId : Number
	* @return Location : Number
	*/
	function accLocation(childId:Number):Number
	{

		var retReference = this.master;
		switch(childId)
		{
			case 1: 
				retReference = this.master.back_mc.back_mc;
				break;

			case 2: 
				retReference = this.master.content;
				break;

			default:
				retReference = this.master;		
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
	* Static Method for swapping the createAccessibilityImplementation method of Window with WindowAccImpl class
	*/
	static function hookAccessibility():Boolean
	{		
		Window.prototype.createAccessibilityImplementation = mx.accessibility.WindowAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}
	
	//static variable pointing to the hookAccessibility Method. This is used for initializing WindowAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accHooked:Boolean = hookAccessibility();
}

