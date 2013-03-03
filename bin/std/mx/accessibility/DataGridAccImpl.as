//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.controls.DataGrid;
/**
* This is the accessibility class for DataGrid.
* This class inherits from the AccImpl
* If accessibility has to be enabled in a DataGrid, the following code should be written in the first frame of the FLA file
* import mx.accessibility.DataGridAccImpl;
* DataGridAccImpl.enableAccessibility();
* @helpid 3031
* @tiptext This is the DataGridAccImpl Accessibility Class.
*/
class mx.accessibility.DataGridAccImpl extends mx.accessibility.AccImpl
{

	var master:Object;
	var ROLE:Number = 0x21; //0x18; // listview / table
	var ROLE_SYSTEM_ROW:Number = 0x1c;
	var ROLE_SYSTEM_COLUMNHEADER:Number = 0x19;
	var ROLE_SYSTEM_CELL:Number = 0x1d;
	var ROLE_SYSTEM_LISTITEM:Number = 0x22;

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

	// in d336, we need to do this to force the
	// datagrid to be created before the accimpl
	var owner:Object = DataGrid;

	// Define functions which would point to main class functions
	var isSelected:Function;
	var getColumnNames:Function;
	var getColumnCount:Function;
	var getColumnIndex:Function;
	var getFocusedCell:Function;

	//children array for getting childIds
	var children:Array;

	// variables from the main ScrollSelectList class. Defining to compile
	var __vPosition:Number;
	var multipleSelection:Boolean;
	var enabled:Boolean;

	var editable:Boolean;
	var columns:Array;

	var _setFocusedCell:Function;
	var _editField:Function;
	var _selectRow:Function;
	//var _onSetFocus:Function;


	/**
	* Method call for enabling accessibility for a component
	* This method is required for compiler to activate the accessibility classes for a component
	* @see mx.accessibility.DataGridAccImpl
	*/
	static function enableAccessibility()
	{
	}

	/**
	* @private
	* _accImpl Object for RadioButton
	*/
	function DataGridAccImpl(master:Object)
	{
		super(master);

		master._selectRow = master.selectRow;
		master.selectRow = selectRow;

		//swap the main class methods with _accImpl class methods
		master._setFocusedCell = master.setFocusedCell;
		master.setFocusedCell = setFocusedCell;

		master._editField = master.editField;
		master.editField = editField;

		//master._onSetFocus = master.onSetFocus;
		//master.onSetFocus = onSetFocus;

		//_root.ii.text = "" + newline + _root.ii.text;
	}

	/**
	* Method for creating Accessibility class. This method is called from UIObject.
	* Accessibility enabling code should be already written in the first frame of the FLA before this method is called
	*/
	function createAccessibilityImplementation()
	{
		_accImpl = new DataGridAccImpl(this);
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

		// 0 -> DataGrid, 1 to (columnCount) -> Headers, (columnCount + 1) to (columnCount + 1) + columnCount*Rows -> Cells

		var len = 0;

		// editable case (cells)
		if(master.editable == false)
		{
			len = master.columns.length + master.getLength();
		}
		// non editable case (rows)
		else
		{
			len = master.columns.length * (1 + master.getLength());
		}

		for (var i = 0; i < len; ++i)
		{
			var id = i+1;
			children[id] = i;
			ret[i] = id;
		}

		return ret;
	}

	//Returning the role
	/**
	* @see get_accRole
	*/
	function get_accRole(childId:Number):Number
	{
		var retRole = ROLE;

		// this is a fix for Role being spoken multiple times.
		retRole = (childId == 0) ? ROLE : ROLE_SYSTEM_LISTITEM;

		/*
		// 0 -> DataGrid
		if(childId==0)
		{
			retRole = ROLE;
			//_root.ii.text = "getAccRole childId" + childId + " retRole " + retRole + newline + _root.ii.text;
		}
		// 1 to (columnCount) -> Headers
		else if(childId < master.columns.length + 1)
		{
			retRole = ROLE_SYSTEM_COLUMNHEADER;
			//_root.ii.text = "getAccRole childId" + childId + " retRole " + retRole + newline + _root.ii.text;
		}
		// editable case (cells)
		else if(master.editable == false && childId > master.columns.length)
		{
			//(columnCount + 1) to (columnCount + 1) + columnCount*Rows -> Cells
			// not announcing Row as it is hardcoded.
			retRole = ROLE_SYSTEM_ROW;
			//_root.ii.text = "getAccRole childId" + childId + " retRole " + retRole + newline + _root.ii.text;
		}
		// non editable case (rows)
		else if(master.editable == true && childId > master.columns.length)
		{
			//(columnCount + 1) to (columnCount + 1) + columnCount*Rows -> Cells
			retRole = ROLE_SYSTEM_CELL;
			//_root.ii.text = "getAccRole childId" + childId + " retRole " + retRole + newline + _root.ii.text;
		}
		//_root.ii.text = "final getAccRole childId" + childId + " retRole " + retRole + newline + _root.ii.text;
		*/
		return retRole;
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
		var retVal;

		// 0 -> DataGrid
		if (childId==0)
		{
			// to activate the Accessibility Panel
			return undefined;
		}
		// 1 to (columnCount) -> Headers
		else if(childId < master.columns.length + 1)
		{
			var temp:Number = childId - 1;
			var cols:Array = master.getColumnNames();

			retVal = cols[temp] + " Column Header";
		}
		//(columnCount + 1) to (columnCount + 1) + columnCount*Rows -> Cells
		else if(childId > master.columns.length) // see if this check needs to be given
		{
			// assuming childId is always ItemId + 1 : because getChildIdArray may not always be invoked.
			var temp:Number = childId - master.columns.length - 1;
			// temp is the (0 based) index of the elements after the headers
			if(master.editable == false)
			{
				// temp is the row id
				var row:Number = temp;
				var item = master.getItemAt(temp);
				if (typeof(item)=="string")
				{
					retVal = "Row " + row + " " + item;
				}
				else
				{
					retVal = "Row " + row;
					var colName:String;
					for(colName in item)
					{
						retVal += " " + colName + " " + item[colName];
					}
				}
			}
			else
			{
				var row:Number = Math.floor(temp/master.columns.length);
				var col:Number = temp % master.columns.length;

				var item = master.getItemAt(row);
				// sometimes item may be an object.
				if (typeof(item)=="string")
				{
					retVal = "Row " + row + " " + item;
				}
				else
				{
					var cols:Array = master.getColumnNames();
					var colName:String = cols[col];
					var itemName:String = item[colName];
					retVal = "Row " + row;

					if(master.selectable == true)
					{
						var tmpColName:String;
						for(tmpColName in item)
						{
							retVal += " " + tmpColName + " " + item[tmpColName];
						}
					}

					retVal += ", Editing " + colName + " " + itemName + " Cell";
				}
			}
		}
		//_root.ii.text = "getAccName childId" + childId + " retVal " + retVal+ newline + _root.ii.text;
		return retVal;
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

		if (childId==0 || childId < master.columns.length + 1)
		{
			return infoFlag;
		}
		//(columnCount + 1) to (columnCount + 1) + columnCount*Rows -> Cells
		else if(childId > master.columns.length)
		{
			var temp:Number = childId - master.columns.length - 1;
			if(master.editable == false)
			{
				var row:Number = temp;
				if (row < master.__vPosition || row >= master.__vPosition + master.__rowCount)
				{
					infoFlag =  infoFlag | STATE_SYSTEM_OFFSCREEN | STATE_SYSTEM_INVISIBLE;
				}
				infoFlag = (master.isSelected(row)) ? STATE_SYSTEM_SELECTED | STATE_SYSTEM_SELECTABLE | infoFlag : STATE_SYSTEM_SELECTABLE | infoFlag;
			}
			else
			{
				var row:Number = Math.floor(temp/master.columns.length);
				var col:Number = temp % master.columns.length;

				if (row < master.__vPosition || row >= master.__vPosition + master.__rowCount)
				{
					infoFlag =  infoFlag | STATE_SYSTEM_OFFSCREEN | STATE_SYSTEM_INVISIBLE;
				}
				infoFlag = (master.isSelected(row)) ? STATE_SYSTEM_SELECTED | STATE_SYSTEM_SELECTABLE | infoFlag : STATE_SYSTEM_SELECTABLE | infoFlag;
			}
			return infoFlag;
		}
	}

	/**
	* @private
	* IAccessible method for returning the bounding box of the ListItem.
	* @param childId : Number
	* @return Location : Number
	*/

	function accLocation(childId:Number):Number
	{
		//_root.ii.text = "accLocation childId" + childId + " " + newline + _root.ii.text;
		if(childId < master.columns.length + 1)
		{
			return master.headerCells[childId - 1];
		}

		var temp:Number = childId - master.columns.length - 1;

		if(master.editable == false)
		{
			var row:Number = temp;
			if (row < master.__vPosition || row >= master.__vPosition + master.__rowCount)
			{
				// return nothing.
			}
			else
			{
				// return the mc for this item
				var mc = master.listContent["listRow" + (master.baseRowZ + (row - master.__vPosition))];
				return mc;
			}
		}
		else
		{
			var row:Number = Math.floor(temp/master.columns.length);
			var col:Number = temp % master.columns.length;

			if (row < master.__vPosition || row >= master.__vPosition + master.__rowCount)
			{
				// return nothing.
			}
			else
			{
				// return the mc for this item
				var mc = master.rows[row - master.__vPosition].cells[col];
				return mc;
			}
		}
	}

	/**
	* @private
	* IAccessible method for returning the positive integer ID of the ListItem, this means that the ListItem has focus.
	* @return childId : Number
	*/

	function get_accFocus():Number
	{
		//_root.ii.text = "getAccFocus " + " " + newline + _root.ii.text;
		// should return headers as well??
		if(master.editable == false)
		{
			var row = master.getSelectedIndex();
			if (row != undefined)
			{
				return master.columns.length + row + 1;
			}
		}
		else
		{
			var cell = master.getFocusedCell();
			if (cell != undefined)
			{
				return 1 + (cell.itemIndex + 1)* master.columns.length + cell.columnIndex;
			}
		}
		return 0;
	}

	/**
	* @private
	* IAccessible method for returning the childIds of ListItems selected.
	* @return childId Array : Array
	*/

	function get_accSelection():Array
	{
		//_root.ii.text = "getAccSelection " + newline + _root.ii.text;
		// should return headers as well
		var rtrn = new Array();

		if(master.editable == false)
		{
			var idx = this.master.getSelectedIndices();
			if (idx!=undefined)
			{
				for (var i=0; i<idx.length; i++)
				{
					rtrn.push(master.columns.length + idx[i]+1);
				}
			}
		}
		else
		{
			var cell = master.getFocusedCell();
			if (cell!=undefined)
			{
				rtrn.push(1 + (cell.itemIndex + 1)* master.columns.length + cell.columnIndex);
			}
		}

		return rtrn;
	}

	function selectRow(rowIndex:Number):String
	{
		var retVal = _selectRow(rowIndex);

		if(this.editable == false)
		{
			var itemIndex = __vPosition + rowIndex;
			var childId = columns.length + itemIndex + 1;

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
		}
		return retVal;
	}

	function setFocusedCell(coord, broadCast)
	{
		_setFocusedCell(coord, broadCast);
		if(this.editable == true)
		{
			var index:Number = coord.itemIndex;
			var col:Number = coord.columnIndex;

			//_root.ii.text = "setFocusedCell index " + index + " col " + col + " childId " + (1 + col + (columns.length * (index + 1)))+ newline + _root.ii.text;
			Accessibility.sendEvent(MovieClip(this), 1 + col + (columns.length * (index + 1)) , _accImpl.EVENT_OBJECT_SELECTION);
		}
	}

/*
	function onSetFocus()
	{
	}
*/
	//over riding main class functions for emiting events
	function editField(index, colName, data)
	{
		_editField(index, colName, data);
		if(this.editable == true)
		{
			var col:Number = getColumnIndex(colName);
			//_root.ii.text = "editField index " + index + " col " + col + " childId " + (1 + col + (columns.length * (index + 1)))+ newline + _root.ii.text;

			// get column index
			Accessibility.sendEvent(MovieClip(this), 1 + col + (columns.length * (index + 1)) , _accImpl.EVENT_OBJECT_SELECTION);
		}
	}

	/**
	* Static Method for swapping the createAccessibilityImplementation method of DataGrid with DataGridAccImpl class
	*/
	static function hookAccessibility():Boolean
	{
		// trace("hooking");
		DataGrid.prototype.createAccessibilityImplementation = mx.accessibility.DataGridAccImpl.prototype.createAccessibilityImplementation;
		return true;
	}
	//static variable pointing to the hookAccessibility Method. This is used for initializing DataGridAccImpl class before createAccessibilityImplementation method call from UIObject
	static var accessibilityHooked:Boolean = hookAccessibility();
}
