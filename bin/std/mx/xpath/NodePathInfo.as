/*
   Title:       Macromedia Firefly Components
   Description: A set of data components that use XML and HTTP for transferring data between a Flash MX client and a server.
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc
   Author:		Jason Williams & Mark Rausch
   Version:     2.0
*/

/**
  NodePathInfo holds a single node portion of an XPath expression 
  ( e.g. B[@id='1'] from the XPath /A[@name]/B[@id='1']/C )
*/
class mx.xpath.NodePathInfo {
	/**
	  NodePathInfo constructor
	*/
	function NodePathInfo(nodeName:String, filter:String) {
		__nodeName = nodeName;
		__filter = filter;
	} //NodePathInfo constructor
	
	//---------------------------------------------------------------------------------------
	//                                      Properties
	//---------------------------------------------------------------------------------------
	public function get nodeName():String {return this.__nodeName;}
	public function get filter():String {return this.__filter;}
	

	private var __nodeName:String = null;
	private var __filter:String = null;
	
}