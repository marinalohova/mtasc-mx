/*
   Title:       Macromedia Firefly Components
   Description: A set of data components that use XML and HTTP for transferring data between a Flash MX client and a server.
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc
   Author:		Jason Williams & Mark Rausch
   Version:     2.0
*/

/**
  FilterExpr is a class that holds a single predicate filter expression (e.g. @id='1'). The FilterStack class
  holds multiple FilterExpr instances along with the boolean operators that join them.
*/
class mx.xpath.FilterExpr {
	/**
	  FilterExpr constructor
	*/
	function FilterExpr(attrInit:Boolean, nameInit:String, valueInit:String) {
		__attr = attrInit;
		__name = nameInit;
		__value= valueInit;
	} //FilterExpr constructor
	
	//---------------------------------------------------------------------------------------
	//                                      Properties
	//---------------------------------------------------------------------------------------
	function get attr():Boolean { return __attr; }
	function set attr(newVal: Boolean) { __attr = newVal; }
	function get name():String { return __name; }
	function set name(newVal: String) { __name = newVal; }
	function get value():String { return __value; }
	function set value(newVal: String) { __value = newVal; }
	

	public var __attr:Boolean= false;
	public var __value:String= null;
	public var __name:String = null;
	
}