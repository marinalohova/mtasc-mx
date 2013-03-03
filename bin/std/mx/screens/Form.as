//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

import mx.screens.Screen;
import mx.managers.SystemManager;

[InspectableList("autoLoad","contentPath")]
/**
* Form class
* - extends Screen
* - enables author-defined handling of Form visibility and containment
*
* @tiptext Form class.  Extends Screen.
* @helpid 1895
*/ 
[InspectableList("visible", "autoLoad","contentPath")]
class mx.screens.Form extends Screen {
  // SymbolName for object
  static var symbolName:String = "Form";
  
  // Class used in createClassObject
  static var symbolOwner:Object = mx.screens.Form;

  // name of this class
  var className:String = "Form";

  // indicates whether this is a form
  private var _isForm = true;

  // list of children of this form
  private var _childForms:Array;

  // 0-based index of where this screen is in its parent's childScreens array
  private var _indexInParentForm:Number = 0;

  // If Form is initially visible, send "reveal" event when redraw is first called.
  private var _sendRevealDuringRedraw:Boolean = true;

// //////////////////////////////////////////////////
//
// properties
//
// //////////////////////////////////////////////////


// //////////////////////////////////////////////////
//
// getters/setters
//
// //////////////////////////////////////////////////

	/**
	* True if object is visible -- override to get different verbose setting
	*/
	[Inspectable(defaultValue=true, verbose=0, category="Other")]
/**
* controls whether the form is visible
* @tiptext controls whether the form is visible
* @helpid 1896
*/
	function get visible():Boolean
	{
		return super.visible;
	}
	function set visible(x:Boolean):Void
	{
		if (x == true && visible == false)
			_sendRevealDuringRedraw = false;
		super.setVisible(x, false);
	}

/**
* zero-based index of this form in its parent (getChildForm)
* Read-Only: use createChild() to add new child form
* @tiptext  index of this form in its parent (getChildForm)
* @helpid   1897
*/
    public function get indexInParentForm():Number
    {
	    return _indexInParentForm;
    }

/**
* number of children of this form that are forms, not including slides
* Read-Only: use createChild() to add new child forms
* @tiptext  number of child forms of this form
* @helpid   1898
*/
    public function get numChildForms():Number
    {
        return _childForms.length;
    }

/**
* True if this form's _parent is a form
* Read-Only: use createChild() to add new child forms
* @tiptext  True if this forms's _parent is a form
* @helpid   1899
*/
	public function get parentIsForm():Boolean
	{
		return((parentForm != null) && (parentForm._isForm));
	}

/**
* Form containing this form.  May be null for the root form.
* Read-Only: use createChild() to add new child forms
* @tiptext  Form containing this form
* @helpid   1900
*/
	public function get parentForm():Form
	{
		var theParent:Object = _parent;
		while (true) {
			if (theParent == null) {
				return(null);
			} else if (theParent._isForm) {
				return(Form(theParent));
			} else if (theParent._isFormContainer) { // test for zombized Form caused by createChild
				theParent = theParent._parent;
			} else if (!theParent._isForm) {
				return(null);
			}
		}
	}

/**
* Root form of the form subtree that contains this form
* Read-Only: use createChild() to add new child forms
* @tiptext  Root form of the form subtree that contains this form
* @helpid   1901
*/
	public function get rootForm():Form
	{
		var frm:Form = this;
		while (frm.parentIsForm) {
			frm = frm.parentForm;
		}
		return(frm);
	}

/**
* Leaf-node form that contains the current focused field or component
* Read-Only: use setFocus() to set the focus
* @tiptext  Leaf-node form that contains the current focused field or component
* @helpid   1902
*/
	public static function get currentFocusedForm():Form
	{
		var curFocus:Object;
		curFocus = _root.focusManager.getFocus();
		if (!curFocus || (curFocus == undefined)) {
			curFocus = eval(Selection.getFocus());
		}
		while (curFocus && !curFocus._isForm) {
			curFocus = curFocus._parent;
		}
		if (curFocus == undefined)
			return(null);
		else
			return(mx.screens.Form(curFocus));
	}



// //////////////////////////////////////////////////
//
// Public methods
//
// //////////////////////////////////////////////////

/**
* Get the nth child of this form (zero-based)
* @param childIndex which form to get
* @tiptext	Get the nth child of this form
* @helpid	1903
*/
  public function getChildForm(childIndex:Number):Form
  {
    return _childForms[childIndex];
  }


// //////////////////////////////////////////////////
//
// Private methods
//
// //////////////////////////////////////////////////

  // Override UIComponent to not draw focus around form
  function drawFocus()
  {
  }

  // Form class constructor
  function Form()
  {
  }

  // initialize this form
  private function init()
  {
   _childForms = [];

    super.init();

    if (parentIsForm) {
      _parent.registerChildForm(this);
    }


  }

  // set up the relationship between this form and a new child form
  private function registerChildForm(form:Form)
  {
    form._indexInParentForm = _childForms.push (form) - 1;
  }


  // make sure forms get an initial reveal event
  private function redraw(bAlways:Boolean):Void
	{
		super.redraw(bAlways);

		// When redraw is called for the first time (during object
		// initialization), send a "reveal" event if the object is
		// initially visible.
		if (_sendRevealDuringRedraw && visible == true)
		{

			dispatchEvent({type:"reveal", target:this})
			_sendRevealDuringRedraw = false;
		}
	}

  // handle fixups when we load a subtree in from an external movie using createChild()
  function childLoaded(obj:MovieClip):Void
  {
	  super.childLoaded(obj);
	  if (obj._containedScreen._isForm) {

		  var loadedForm:Form = obj._containedForm;
		  var realParentForm: Form = mx.screens.Form(obj._parent);

		  obj._isFormContainer = true;
		  obj._containedForm = loadedForm;

		  loadedForm._indexInParentForm = realParentForm._childForms.push(loadedForm) - 1;
	  }
  }

	// Override from View class.  destroy n'th child form
  function destroyChildAt(childIndex:Number):Void
  {
	  _childForms.splice(childIndex, 1);
	  super.destroyChildAt(childIndex);
  }

}

