//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
/**
* The base class for accessibility in components.
* AccImpl supports System ROLES, Object based EVENTS and STATES.
*
* @helpid 3001
* @tiptext The base class for accessibility in components.
*/ 
class mx.accessibility.AccImpl extends Object
{
	//pointer to the component itself
	var master:Object;
	var stub:Boolean;
	var ROLE:Number;
	//this is a default state for all the components
	var STATE_SYSTEM_NORMAL:Number = 0x0;
	
	// this is never filled out but is needed by the
	// createAccessibilityImplementation method in order
	// to compile correctly.
	var _accImpl:Object;

	function AccImpl(m:Object)
	{
		//super(master);
		master = m;
		stub = false;
	}
 /**
 * Returns the System ROLE for the component
 *
 * @param childId : String
 * @return ROLE : Number
 *
 * @tiptext Returns the system ROLE for the component
 * @helpid 3000
 */
	function get_accRole(childId:String):Number
	{
		return ROLE;
	}
}

