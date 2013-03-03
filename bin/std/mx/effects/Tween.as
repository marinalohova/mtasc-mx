//****************************************************************************
//Copyright (C) 2003 Macromedia, Inc. All Rights Reserved.
//The following is Sample Code and is subject to all restrictions on
//such code as contained in the End User License Agreement accompanying
//this product.
//****************************************************************************

class mx.effects.Tween extends Object
{

	static var ActiveTweens : Array = new Array();
	static var Interval : Number = 10;
	static var IntervalToken : Number;
	static var Dispatcher : Object = new Object();

	static function AddTween(tween : Tween) : Void
	{
		tween.ID = ActiveTweens.length;
		ActiveTweens.push(tween);
		if (IntervalToken==undefined) {
			Dispatcher.DispatchTweens = DispatchTweens;
			IntervalToken = setInterval(Dispatcher, "DispatchTweens", Interval);
		}
	}

	static function RemoveTweenAt(index : Number) : Void
	{
		var aT = ActiveTweens;

		if (index>=aT.length || index<0 || index==undefined) return;

		aT.splice(index, 1);
		var len = aT.length;
		for (var i=index; i<len; i++) {
			aT[i].ID--;
		}
		if (len==0) {
			clearInterval(IntervalToken);
			delete IntervalToken;
		}
	}

	static function DispatchTweens(Void) : Void
	{
		var aT = ActiveTweens;
		var len = aT.length;
		for (var i=0; i<len; i++) {
			aT[i].doInterval();
		}
		updateAfterEvent();
	}


	/* Tween

	   arguments :
			listenerObj (tweenListener obj)
			init (array of nums, or one num)
			end (array of num, or one num)
			[ dur (int msecs),]

		tweenListener interface is :
			function onTweenUpdate(tweenValue)
				parameter : tweenValues
							an Array of the current values in each dimension
			function onTweenEnd(tweenValue); */


	var listener : Object;
	var initVal; // relaxed type to accommodate numbers or arrays
	var endVal;
	var duration : Number = 3000;
	var arrayMode : Boolean;
	var startTime : Number;

	var updateFunc : Function;
	var endFunc : Function;
	var ID : Number;

	function Tween(listenerObj, init, end, dur)
	{

		if ( listenerObj==undefined ) return;
		if (typeof(init) != "number") arrayMode = true;

		listener = listenerObj;
		initVal = init;
		endVal = end;
		if (dur!=undefined) {
			duration = dur;
		}

		startTime = getTimer();

		if ( duration==0 ) {
 			endTween(); //doInterval() this called easingEq which got a div/by/zero
		} else {
			Tween.AddTween(this);
		}
	}



	function doInterval()
	{
		var curTime = getTimer()-startTime;
		var curVal= getCurVal(curTime);

		if (curTime >= duration) {
			endTween();
		} else {
			if (updateFunc!=undefined) {
				listener[updateFunc](curVal);
			} else {
				listener.onTweenUpdate(curVal);
			}
		}
	}


	function getCurVal(curTime)
	{
		if (arrayMode) {
			var returnArray = new Array();
			for (var i=0; i<initVal.length; i++) {
				returnArray[i] = easingEquation(curTime, initVal[i], endVal[i]-initVal[i], duration);
			}
			return returnArray;
		}
		else {
			return easingEquation(curTime, initVal, endVal-initVal, duration);
		}
	}

	function endTween()
	{
		if (endFunc!=undefined) {
			listener[endFunc](endVal);
		} else {
			listener.onTweenEnd(endVal);
		}
		mx.effects.Tween.RemoveTweenAt(ID);
	}

	function setTweenHandlers(update, end)
	{
		updateFunc = update;
		endFunc = end;
	}

	// defaults to sin
	function easingEquation(t,b,c,d)
	{
		return c/2 * ( Math.sin( Math.PI * (t/d-0.5) ) + 1 ) + b;
	}

}