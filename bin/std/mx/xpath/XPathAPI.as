/*
   Title:       Macromedia Firefly Components
   Description: A set of data components that use XML and HTTP for transferring data between a Flash MX client and a server.
   Copyright:   Copyright (c) 2003
   Company:     Macromedia, Inc
   Author:		Jason Williams & Mark Rausch
   Version:     2.0
*/

import mx.xpath.FilterStack;
import mx.xpath.FilterExpr;
import mx.xpath.NodePathInfo;
import mx.utils.StringTokenParser;

/**
  XPathAPI is a static class that provides the ability to perform XPath against a DOM.
*/
class mx.xpath.XPathAPI {
	//---------------------------------------------------------------------------------------
	//                                    Public methods
	//---------------------------------------------------------------------------------------

	/**
	  Returns a string that represents the code required to access the value specified by the path param from
	  the provided node. 
		
	  @param	node reference to DOM node that is the parent node from which to execute the path statement against
	  @param	path string containing the desired value in x-path format
	  @author	Jason Williams
	  @example
			If the path param is "/id/&at;test" and <id> is the first child of node then
			this method will return the string "childNodes.0.attributes.test"
	*/
	static public function getEvalString( node:XMLNode, path:String ) {
		var result:String = "";
		var chldNode:XMLNode = null;
		var pathSet:Array = getPathSet( path );
		var nodeName:String = pathSet[0].nodeName;
		var attrIndx:Number;
		var curNode:XMLNode = node;
		var found:Boolean = false;
		if(( nodeName != undefined ) && (( nodeName == "*" ) || ( node.nodeName == nodeName ))) {
			// loop through all of the node names and find the node in the tree
			for( var i:Number=1; i<pathSet.length; i++ ) {
				nodeName = pathSet[i].nodeName;
				// if we reached an attribute we need to stop...we are done
				attrIndx = nodeName.indexOf( "@" );
				if( attrIndx >= 0 ) {
					nodeName =nodeName.substring( attrIndx+1 );
					found= curNode.attributes[ nodeName ] != undefined;
					result += ".attributes."+ nodeName; 
				}
				else {
					found = false;
					for( var j:Number=0; j<curNode.childNodes.length; j++ ) {
						chldNode = curNode.childNodes[j];
						if( chldNode.nodeName == nodeName ) {
							result += ".childNodes."+ j;
							// need to move on...
							j = curNode.childNodes.length;
							curNode = chldNode;
							found = true;
						} // if found
					} // for j
				} // if not an attribute
				if( !found )
					return( "" );
			} // for i
			if( !found )
				result = "";
			else
				if( attrIndx == -1 )
					result += ".firstChild.nodeValue";
		} // if on correct node
		else
			result = "";
		return( result );
	} //function getEvalString
	
	/**
	  Returns a list of nodes from the specified node given the xpath statement.  This processor supports
	  where clauses that test for equality, existence and contain boolean operators "and" and "or".
	  
	  @param	node DOM node used to find node within, this node is the root context for the search
	  @param	path string containing the xpath statement see example 
	  @return	array of nodes matching the given x-path statement
	  @author	Jason Williams
	  @example	
			var nodeList = XPathAPI.selectNodeList( xmlNode, "/root/child[&at;id='test' and childB]/childA" );
			for( var i=0; i<nodeList.length; i++ ) 
				trace( nodeList[i].nodeName );
	*/
	static public function selectNodeList(node:XMLNode, path:String):Array {
		var result:Array= new Array( node );
		var pathSet:Array= getPathSet( path );
		var pathInfo:NodePathInfo= pathSet[0];
		var nodeName:String= pathInfo.nodeName;
		var fltrStack:FilterStack = null;
		if (( nodeName != undefined ) && (( nodeName == "*" ) || ( node.nodeName == nodeName ))) {
			if( pathInfo.filter.length > 0 ) {
				//trace(pathInfo.filter);
				fltrStack= new FilterStack( pathInfo.filter );
				result= filterNodes( result, fltrStack );
			}
			if( result.length > 0 ) 
				for( var i:Number=1; i<pathSet.length; i++ ) {
					pathInfo = pathSet[i];
					result= getAllChildNodesByName( result, pathInfo.nodeName );
					if( pathInfo.filter.length > 0 )
						fltrStack= new FilterStack( pathInfo.filter );
					else
						fltrStack = null;

					if(( fltrStack != null ) && ( fltrStack.exprs.length > 0 ))
						result= filterNodes( result, fltrStack );
				} // for
		} // if
		else
			result= new Array();
		return( result );
	} //function selectNodeList
	
	
	/**
	  Returns a single node from the given node and xpath parameters.  If the xpath specified will 
	  result in multiple nodes returned, this method will return only the first one found. This processor 
	  supports where clauses that test for equality, existence and contain boolean operators "and" and "or".
	  
	  @return xml node found for the specified path and node or null if not found.
	  @param node DOM node used to find node within
	  @param path string containing the xpath statement
	  @author Jason Williams
	  @example
			var node:XMLNode = XPathAPI.selectSingleNode( rootNode, "/root/*[&at;id]/firstChild" );
			trace( node.nodeName );
	*/
	static public function selectSingleNode(node:XMLNode, path:String) {
		var nodeList:Array = XPathAPI.selectNodeList( node, path );
		if( nodeList.length > 0 )
			return( nodeList[0] );
		else
			return( null );
	} //function selectSingleNode


	/**
	  Sets the value of the node or attribute identified in the xpath string to the value passed in. 
	  Returns the number of nodes that were updated.
	  
	  @param	node DOM node used to find node within, this node is the root context for the search
	  @param	path string containing the xpath statement see example 
	  @param	newValue string containing the new value for the node or attribute
	  @return	number of nodes updated
	  @author	Mark Rausch
	  @example	
			var updateCount:Number = XPathAPI.setNodeValue( xmlNode, "/root/child[id='test' and childB]/childA", "Hello World" );
			trace(updateCount + " nodes updated.");
	*/
	static public function setNodeValue(node:XMLNode, path:String, newValue:String):Number {
		var nodeList:Array= new Array( node );
		var pathSet:Array= getPathSet( path );

		//Check if the xpath is to an attribute
		var attrName:String = pathSet[pathSet.length-1].nodeName;
		if (attrName.charAt(0) == "@") {
			//Xpath is getting an attribute, so store it and remove it from the path so we can get it's parent node
			attrName = attrName.substring(1, attrName.length);
			pathSet.pop();
		}
		else {
			attrName = null;
		} //if node to set is an attribute
		
		//Now filter the node list down to only those that fit the xpath expression
		var pathInfo:NodePathInfo= pathSet[0];
		var nodeName:String= pathInfo.nodeName;
		var fltrStack:FilterStack = null;
		if (( nodeName != undefined ) && (( nodeName == "*" ) || ( node.nodeName == nodeName ))) {
			if( pathInfo.filter.length > 0 ) {
				//trace(pathInfo.filter);
				fltrStack= new FilterStack( pathInfo.filter );
				nodeList= filterNodes( nodeList, fltrStack );
			}
			if( nodeList.length > 0 ) 
				for( var i:Number=1; i<pathSet.length; i++ ) {
					pathInfo = pathSet[i];
					nodeList= getAllChildNodesByName( nodeList, pathInfo.nodeName );
					if( pathInfo.filter.length > 0 )
						fltrStack= new FilterStack( pathInfo.filter );
					else
						fltrStack = null;

					if(( fltrStack != null ) && ( fltrStack.exprs.length > 0 ))
						nodeList= filterNodes( nodeList, fltrStack );
				} // for
		} // if
		else
			nodeList= new Array();
		
		//Now go update all the nodes still in the list.
		var currNode:XMLNode = null;
		var textNode:XMLNode = null;
		var doc:XML = new XML(); //This temporary doc allows me to create text nodes since I don't have access to the actual document
		for (var i:Number = 0; i < nodeList.length; i++) {
			if (attrName != null) {
				//Set the attribute value on the node
				nodeList[i].attributes[attrName] = newValue;
			}
			else {
				//Set the node value
				currNode = nodeList[i];
				if ((currNode.firstChild == null) || (currNode.firstChild.nodeType != 3)) {
					//if the node does not have a text node, then create one for it
					textNode = doc.createTextNode(newValue);
					currNode.appendChild(textNode);
				}
				else {
					textNode = currNode.firstChild;
					textNode.nodeValue = newValue;
				}
			} //if updating an attribute
		} //for each node remaining in the list
		return nodeList.length;
	} //function setNodeValue
	
	
	//---------------------------------------------------------------------------------------
	//                                    Private methods
	//---------------------------------------------------------------------------------------
	/**
	  Makes a copy of a stack (array)
	  
	  @param toStk destination array
	  @param fromStk source array
	*/
	static private function copyStack( toStk:Array, fromStk:Array ) {
		for( var i=0; i<fromStk.length; i++ )
			//toStk.push( fromStk[i] );
			toStk.splice( i, 0, fromStk[i] );
	} //function copyStack
	

    /**
	  Compares a node to an expression (e.g. @id='1') and evaluates whether or not the node fits the 
	  expression criteria. If it does this method returns true.
	  
	  @param expr Expression to evaluate against the node
	  @param node XMLNode to compare to the expression
	  @return boolean true if the node matches the expression
	*/
	static private function evalExpr( expr:FilterExpr, node:XMLNode ):Boolean {
		var result:Boolean= true; 
		if( expr.attr ) {
			result= expr.value != null ? node.attributes[expr.name] == expr.value: node.attributes[expr.name] != null;
		}
		else {
			var childNode:XMLNode=getChildNodeByName( node, expr.name );
			if ( childNode != null )
				result= (expr.value != null) ? childNode.firstChild.nodeValue == expr.value: true;
			else
				result= false;
		}
		return( result );
	} //function evalExpr
	
	
	/**
	  Evaluates an array of nodes to comparing them against a set of filter expressions. 
	  
	  @return array Set of XMLNodes that fit the set of filter expressions
	  @param nodeList Array of XMLNodes to compare
	  @param stack FilterStack object filled with filter expressions
	*/
	static private function filterNodes( nodeList:Array, stack:FilterStack ):Array {
		var result:Array = new Array();
		var exprs:Array;
		var ops:Array;
		var filterExpr1:FilterExpr; 
		var filterExpr2:FilterExpr;
		var filterBool:Boolean;
		var keepNode:Boolean = true;
		var node:XMLNode;
		var cont:Boolean;
		for( var i:Number=0; i<nodeList.length; i++ ) {
			cont= true;
			exprs= new Array();
			ops= new Array();
			copyStack( exprs, stack.exprs );
			copyStack( ops, stack.ops );
			node= nodeList[i];
			while(( exprs.length > 0 ) && cont ) {
				if( typeof( exprs[exprs.length-1] ) == "object" ) {
					// pop the first expression
					filterExpr1= FilterExpr( exprs.pop());
					keepNode= evalExpr( filterExpr1, node );
				}
				else {
					//Not storing an object, so its a boolean from a previous evaluation
					filterBool= Boolean( exprs.pop());
					keepNode= filterBool;
				}
					
				if( ops.length > 0 ) {
					var temp = exprs.pop();
					filterExpr2= temp;
					switch( ops[ops.length-1] ) {
						case "and":
							keepNode= keepNode && evalExpr( filterExpr2, node );
							cont= keepNode;
						break;
						
						case "or":
							keepNode= keepNode || evalExpr( filterExpr2, node );
							cont= !keepNode;
						break;
					}
					ops.pop();
					exprs.push( keepNode );
				} // if there are operations
			} // while there are expressions
			// remove the node from the list?
			if ( keepNode ) {
				result.push(node);
			} // if
		} // for
		return result;
	} //function filterNodes
	
	
	/**
	  Returns a list of all nodes that match the specified name within the list of nodes.
	  
	  @param nodeList array containing each node to search from
	  @param name string containing the name of the nodes to find and return
	  @return array of nodes with the name matching that specified.
	  @access private
	  @author Jason Williams 
	*/
	static private function getAllChildNodesByName( nodeList:Array, name:String ):Array {
	
		var result:Array = new Array();
		var newList:Array;
		for( var i:Number=0; i<nodeList.length; i++ ) {
			newList = nodeList[i].childNodes;
			if( newList != null ) {
				for( var j:Number=0; j<newList.length; j++ ) {
					if(( name == "*" ) || ( newList[j].nodeName == name ))
						//result.splice( result.length, 0, newList[j] );
						result.push(newList[j]);
				} // for j
			} // if
		} // for
		return( result );
	} //function getAllChildNodesByName


	/**
  	  Returns the first child node of the specified node found with the specified name.
	
	  @param	node reference to the node object to search from
	  @param	nodeName string containing the name of the desired child node
	  @access	private
	  @author	Jason Williams
	*/
	static private function getChildNodeByName(node:XMLNode, nodeName:String):XMLNode {
		var result:XMLNode;
		var childNodes:Array = node.childNodes;
		for( var i:Number=0; i<childNodes.length; i++ ) {
			result = childNodes[i];
			if( result.nodeName == nodeName )
				return( result );
		} // for
		return( null );
	} //function getChildNodeByName


	static private function getKeyValues( node:XMLNode, keySpec:String ):String {
		var result:String ="";
		var keySpecInfo:StringTokenParser= new StringTokenParser( keySpec );  
		var keySpecToken:Number = keySpecInfo.nextToken();
		var tok:String;
		var childNode:XMLNode; // child node
		// parse keySpec information and get the values e.g. [id]/child[@id and act] --> [id='100']/child[@id='test' and act='12']
		while( keySpecToken != StringTokenParser.tkEOF ) {
			tok = keySpecInfo.token;
			result += " " +tok;
			if( keySpecToken == StringTokenParser.tkSymbol ) {
				// if it is an attribute
				if( tok == "@" ) {
					keySpecToken =keySpecInfo.nextToken();
					tok = keySpecInfo.token;
					if( keySpecToken == StringTokenParser.tkSymbol )
						result += tok+ "='"+ node.attributes[tok]+ "'";
				}
				else {
					if( tok == "/" ) {
						keySpecToken = keySpecInfo.nextToken();
						if( keySpecToken == StringTokenParser.tkSymbol ) {
							tok = keySpecInfo.token;
							node = getChildNodeByName( node, tok );
							if( node != null )
								result += tok;
						} // moving down
					} // is "/"
					else {
						// we have a node value
						if(( tok != "and" ) && ( tok != "or" ) && ( tok != "[" ) && ( tok != "]" )) {
							childNode = getChildNodeByName( node, tok );
							if( childNode != null ) 
								result += "='"+ childNode.firstChild.nodeValue+ "'";
						} // if using node
					} // not "/"
				} // not "@"
			} // if tkSymbol
			if( node == null ) {
				trace( "Invalid keySpec specified. '"+ keySpec +"' Error." );
				return( "ERR" );
			}
			keySpecToken = keySpecInfo.nextToken();
		} // while
		return( result.slice( 1 ));
	} //function getKeyValues


	/**
	  Returns the path statement for the specified node and keySpec list.
		
	  @param	node XML node object to extract the path information from
	  @param	keySpecs array of strings containing the keySpecs to use when creating the
								 path statement, if the keySpec list is empty the path will be
								 generated using any value and attribute that it can find
	  @return	string containing the path statement
	  @access	private
	  @author	Jason Williams
	*/
	static private function getPath( node:XMLNode, keySpecs:Array ):String {	
		var result:String ="" ;
		var keySpec:String= keySpecs[node.nodeName];
		// if no keySpec has been defined for this node use everything
		if( keySpec == undefined ) {
			// get all attributes of the node
			var attrs:String="";
			var currAttr:String;
			for( var currAttr in node.attributes )
				attrs += "@"+currAttr+ "='"+ node.attributes[currAttr]+ "' and ";
			// get child nodes
			var nodeValues:String = "";
			var curNode:XMLNode;
			var value:String;
			for( var i:Number=0; i<node.childNodes.length; i++ ) {
				curNode = node.childNodes[i];
				value =curNode.firstChild.nodeValue;
				if( value != undefined )
					nodeValues += curNode.nodeName + "='"+ value+ "' and ";
			} // for
			// if there are attributes on the node
			if( attrs.length > 0 ) {
				if( nodeValues.length > 0 )
					result = "/"+ node.nodeName+ "["+ attrs+ nodeValues.substring( 0, nodeValues.length-4 )+ "]";
				else
					result = "/"+ node.nodeName+ "["+ attrs.substring( 0, attrs.length-4 )+ "]";
			}
			else
				result = "/"+ node.nodeName+"[" +nodeValues.substring( 0, nodeValues.length-4 ) +"]";
		}
		else
			result += "/"+ node.nodeName+ getKeyValues( node, keySpec );
			
		// get path to root
		var curNode:XMLNode = node.parentNode;
		while( curNode.parentNode != null ) {
			keySpec = keySpecs[curNode.nodeName];
			if( keySpec != undefined ) {
				result = "/"+curNode.nodeName+ getKeyValues( curNode, keySpec )+ result;
			}
			else
				result = "/"+ curNode.nodeName + result;
			curNode = curNode.parentNode;
		} // while
		return( result );
	} //function getPath


	/**
	  Returns an array of paths from the path statement in order from left to right.
	  
	  @param	path string containing the xpath statement to order
	  @return	list of path sets derived from the specified path statement.
	  @access	private
	  @author	Jason Williams
	  @example
			path = "/rowdata/row[&at;field='123']/field" returns
				result[0].nodeName="rowdata" 
				result[1].nodeName="row"
				result[1].filter="[&at;field='123']" 
				result[2].nodeName="field"
	*/
	static private function getPathSet( path:String ):Array {
		var result:Array = new Array();
		var index:Number;
		var nodeName:String;
		var fltrIndx:Number;
		var fltr:String;
		while( path.length > 0 ) {
			index= path.lastIndexOf( "/" );
			nodeName= path.substring( index+1 );
			fltrIndx= nodeName.indexOf( "[", 0 );
			fltr= fltrIndx >= 0 ? nodeName.substring( fltrIndx+1, nodeName.length -1 ): "";
			nodeName= fltrIndx >=0 ? nodeName.substring( 0, fltrIndx ): nodeName;
			result.splice( 0, 0, new NodePathInfo( nodeName, fltr ));
			path = path.substring( 0, index );
		} // while
		return( result );
	} //function getPathSet


}