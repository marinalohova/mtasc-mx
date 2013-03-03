/*
   Title:       Macromedia Firefly Components
   Description: A set of data components that use XML and HTTP for transferring data between a Flash MX client and a server.
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc
   Author:		Jason Williams & Mark Rausch
   Version:     2.0
*/

import mx.utils.StringTokenParser;
import mx.xpath.FilterExpr;

/**
  FilterStack is a class that holds a set of expressions (operands) and operations to perform on them. 
  The stack stores expressions and operators from the predicate ([]) portion of an XPath statement.
*/
class mx.xpath.FilterStack {
	//---------------------------------------------------------------------------------------
	//                                      Properties
	//---------------------------------------------------------------------------------------
	function get exprs():Array {return this.__expr;}
	function get ops():Array {return this.__ops;}
	
	/*
	  FilterStack class constructor. Builds a new FilterStack object using the filter string passed into it.
	*/
	function FilterStack(filterVal:String) {
		__expr = new Array();
		__ops = new Array();
		var parser:StringTokenParser = new StringTokenParser( filterVal );
		var kind:Number = parser.nextToken();
		var obj:FilterExpr;
		var token:String = parser.token;
		while( kind != StringTokenParser.tkEOF ) {
			if( token == "@" ) {
				//build attribute expr
				kind= parser.nextToken();
				token= parser.token;
				obj= new FilterExpr(true, token, null );
				__expr.splice( 0, 0, obj );
				if( parser.nextToken() == mx.utils.StringTokenParser.tkSymbol )
					if( parser.token == "=" ) {
						kind =parser.nextToken();
						obj.value= parser.token
					}
			}
			else
				if(( token == "and" ) || ( token == "or" )) 
					__ops.splice( 0, 0, token );
				else 
					if(( token != ")" ) && ( token != "(" )) {
						// build node expr
						obj= new FilterExpr(false, token, null );
						__expr.splice( 0, 0, obj );
						if( parser.nextToken() == mx.utils.StringTokenParser.tkSymbol )
							if( parser.token == "=" ) {
								kind=parser.nextToken();
								obj.value= parser.token
							}
					} // if is a node compare
				kind = parser.nextToken();
				token = parser.token;
		} // while
	} //FilterStack class constructor
	
	
	private var __expr: Array;
	private var __ops: Array;
	
} //FilterStack class
