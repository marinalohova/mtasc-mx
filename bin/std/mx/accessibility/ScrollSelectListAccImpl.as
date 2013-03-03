//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************
import mx.controls.listclasses.ScrollSelectList;
/**
* @private
* This is the accessibility class for ScrollSelectList. 
* Since ListBox inherits from ScrollSelectListm this class would be used in ListBox accImpl as well.
* If accessibility has to be enabled in a component, the following code should be written in the first frame of the FLA file
* import mx.accessibility.ScrollSelectListAccImpl;
* ScrollSelectListAccImpl.enableAccessibility();
* @helpid 3009
* @tiptext This is the ScrollSelectList Accessibility Class.
*/ 
// accessibility implementation for the TextInput component
class mx.accessibility.ScrollSelectListAccImpl extends mx.accessibility.AccImpl
{
	var owner:Object = ScrollSelectList;
	

	//Define all acessibility variables and values
	var ROLE :Number = 0x21; //role for a ListBox
	var ROLE_SYSTEM_LISTITEM :Number = 0x22; //role of listItem
	var EVENT_OBJECT_SELECTION :Number = 0x8006; //event emitted if 1 item is selected
	var EVENT_OBJECT_SELECTIONADD :Number = 0x8007; //event emitted if CNTRL selection+1 item added to selection
	var EVENT_OBJECT_SELECTIONREMOVE :Number = 0x8008; //event emitted if CTNRL seleciotn + 1 item removed from selection
	var EVENT_OBJECT_SELECTIONWITHIN :Number = 0x8009; //event emitted if SHIFT selection + 1 or more items added to selection

	//define all the states ListItems can have according to MSAA
	var STATE_SYSTEM_UNAVAILABLE :Number =  0x00000001; 
	var STATE_SYSTEM_SELECTED :Number    =  0x00000002;
	var STATE_SYSTEM_INVISIBLE :Number   =  0x00008000;
	var STATE_SYSTEM_OFFSCREEN :Number   =  0x00010000;
	var STATE_SYSTEM_SELECTABLE :Number	=  0x00200000;

	/** defining functions which would be pointing to mainclass functions**/
	var _selectRow:Function;
	var _removeAll:Function;
	var _removeItemAt:Function;
	var _addItemAt:Function;
	var isSelected:Function;

	//children array for getting childIds
	var children:Array;

	// variables from the main ScrollSelectList class. Defining to compile
	var __vPosition:Number;
	var multipleSelection:Boolean;
	var enabled:Boolean;


	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.ScrollSelectListAccImpl
	*/
	static function enableAccessibility()
	{
	}
	

	//Call super class and define the function pointers
	/**
	* @private
	* _accImpl Object for ScrollSelectList
	*/
	function ScrollSelectListAccImpl(m:Object)
	{	
		super(m);
		master._accProps = new Object();

		children = new Array();

		//swap the main class methods with _accImpl class methods
		master._selectRow = master.selectRow;
		master.selectRow = selectRow;
	
		master._removeAll = master.removeAll;
		master.removeAll = removeAll;

		master._removeItemAt = master.removeItemAt;
		master.removeItemAt = removeItemAt;

		master._addItemAt = master.addItemAt;
		master.addItemAt = addItemAt;

	}

	//Create Accessibility object.

	/**
	* @private
	* Method for creating Accessibility class. This method is called from UIObject. 
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new ScrollSelectListAccImpl(this);
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
			children[id] = i;
			ret[i] = id;
		}
		return ret;
	}	

	//Returning the Name
	/**
	* @private
	* IAccessible method for returning the name of the ListItem/ListBox which is spoken out by the screen reader
	* The ListItem should return the label as the name and listBox should return the name specified in the Accessibility Panel.
	* @param childId : Number
	* @return Name : String
	*/
	function get_accName(childId:Number):String
	{
		if (childId==0)
		{
			return undefined;
		}
		else
		{
			// assuming childId is always ItemId + 1 : because getChildIdArray is not always invoked.
			var temp = childId - 1;
			var item = master.getItemAt(temp);
			// sometimes item may be an object.
			if (typeof(item)=="string")
			{
				return item;
			}
			else 
			{
				return item.label;
			}
		}
	}
	

	/**
	* @private
	* IAccessible method for returning the state of the ListItem.
	* States are predefined for all the components in MSAA. Values are assigned to each state.
	* Depending upon the listItem being Selected, Selectable, Invisible, Offscreen, a value is returned.
	* @param childId : Number
	* @return STATE : Number
	*/
	function get_accState(childId:Number):Number
	{
		var infoFlag = (master.enabled) ? STATE_SYSTEM_NORMAL : STATE_SYSTEM_UNAVAILABLE;
		if (childId==0) return infoFlag;
		var index = childId-1;
			//for returning states (OffScreen and Invisible) when the list Item is not in the displayed rows.
		if (index < master.__vPosition || index >= master.__vPosition + master.__rowCount) 
		{
			infoFlag = infoFlag | STATE_SYSTEM_OFFSCREEN | STATE_SYSTEM_INVISIBLE;
		}
		var temp = (master.isSelected(index)) ? STATE_SYSTEM_SELECTED | STATE_SYSTEM_SELECTABLE | infoFlag : STATE_SYSTEM_SELECTABLE | infoFlag;
		return temp;
	}
	
	/**
	* @private
	* IAccessible method for returning the bounding box of the ListItem.
	* @param childId : Number
	* @return Location : Number
	*/
	function accLocation(childId:Number):Number
	{
		//_root.result.text = " Called from accLocation" + newline + _root.result.text;
		var index = childId - 1;
		if (index < master.__vPosition || index >= master.__vPosition + master.__rowCount) 
		{
			// return nothing.
		} 
		else 
		{
			// return the mc for this item
			var mc = master.listContent["listRow" + (master.baseRowZ + (index - master.__vPosition))];
			return mc;
		}
	}
		
	/**
	* @private
	* IAccessible method for returning the positive integer ID of the ListItem, this means that the ListItem has focus.
	* @return childId : Number
	*/
	function get_accFocus():Number
	{
		var tmp = master.getSelectedIndex();
		if (tmp!=undefined)
		{
			return tmp + 1;
		}
		else
		{
			return 0;
		}
	}

	
	/**
	* @private
	* IAccessible method for returning the childIds of ListItems selected.
	* @return childId Array : Array
	*/
	function get_accSelection():Array
	{
		var rtrn = new Array();
		var idx = this.master.getSelectedIndices();
		if (idx!=undefined) {
			for (var i=0; i<idx.length; i++) {
				rtrn.push(idx[i]+1);
			}
		} else {
			var tmp = this.master.getSelectedIndex();
			if (tmp!=undefined) {
				rtrn.push(tmp+1);
			}
		}
		return rtrn;
	}
	

	//main ScrollSelectList class method over ridden to emit events.
	function selectRow(rowIndex:Number):String
	{
		var retVal = _selectRow(rowIndex);

		var itemIndex = __vPosition + rowIndex;
		var childId = itemIndex + 1;

		if (( !multipleSelection && !Key.isDown(Key.CONTROL)) || (!Key.isDown(Key.SHIFT) && !Key.isDown(Key.CONTROL)))
		{
			Accessibility.sendEvent(MovieClip(this), childId, _accImpl.EVENT_OBJECT_SELECTION);
		}
		else if (Key.isDown(Key.SHIFT) && multipleSelection)
		{
			Accessibility.sendEvent(MovieClip(this), 0, _accImpl.EVENT_OBJECT_SELECTIONWITHIN);
		}
		else if (Key.isDown(Key.CONTROL) && multipleSelection)
		{
			var selectedFlag = isSelected(itemIndex);
			if(selectedFlag)
			{
				Accessibility.sendEvent(MovieClip(this), childId, _accImpl.EVENT_OBJECT_SELECTIONADD);
			}
			else
			{
				Accessibility.sendEvent(MovieClip(this), childId, _accImpl.EVENT_OBJECT_SELECTIONREMOVE);
			}
		}
		return retVal;
	}

	//addItem at for 
	function addItemAt(index:Number, label, data):Void
	{

		//_root.result.text = " old length is "+this._accImpl.children.length+newline+_root.result.text;
		if (index<0 || !this.enabled) return;
		
		//calling super class method
		this._addItemAt(index,label,data);

		//updating children array
		this._accImpl.children[index + 1] = index;

	}


	//removeItemAt at for 
	function removeItemAt(index:Number):Void
	{
		//callnig super class method
		_removeItemAt(index);

		//updating children array
		delete _accImpl.children[index + 1];
	}

	//removeAll
	function removeAll(Void):Void
	{
		//callnig super class method
		this._removeAll();

		//updating children array
		_accImpl.children = new Array();
	}


	/**
	* Static Method for swapping the createAccessibilityImplementation method of ScrollSelectList with ScrollSelectListAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		ScrollSelectList.prototype.createAccessibilityImplementation = mx.accessibility.ScrollSelectListAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}

	//static variable pointing to the hookAccessibility Method. This is used for initializing ScrollSelectListAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
	
	

}

