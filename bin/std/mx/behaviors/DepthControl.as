
class mx.behaviors.DepthControl extends Object {
	
	public function DepthControl () {
	}
	
	static public function sendToBack(target:MovieClip):Void {
		var isLowest = false;
		while (isLowest == false) {
			sendBackward(target);
			isLowest = (target==getInstanceAtLowest(target._parent));
		}
	}
	
	static public function bringToFront(target:MovieClip) {
		var isHighest = false;
		while (isHighest == false) {
			bringForward(target);
			isHighest = (target==getInstanceAtHighest(target._parent));
		}
	}
	
	static public function sendBackward(target:MovieClip) {
		var dOrder = trackDepths(target._parent);
		if (target!=getInstanceAtLowest(target._parent)) {
			target.swapDepths(getInstanceLowerThan(target));
		}
	}
	
	static public function bringForward(target:MovieClip) {
		if (target!=getInstanceAtHighest(target._parent)) {
			target.swapDepths(getInstanceHigherThan(target));
		}
	}
	
	static private function trackDepths(mcParent:MovieClip):Array {
		var dOrder:Array=[];
		for (var i in mcParent) {
			if (typeof mcParent[i]=="movieclip") {
				dOrder.push({mc:mcParent[i], depth:mcParent[i].getDepth()});
			}
		}
		dOrder.sort(orderFunc);
		return dOrder;
	}
	
	static private function orderFunc(a,b):Number {
		var depth1 = Number(a.depth);
		var depth2 = Number(b.depth);
		if (depth1 > depth2) {
			return -1;
		} else if (depth2 > depth1) {
			return 1;
		} else {
			return 0;
		}
	}
			
	
	static private function getInstanceAtLowest(targetParent:MovieClip):MovieClip {
		var dOrder = trackDepths(targetParent);
		return dOrder[dOrder.length-1].mc;
	}
	
	static private function getInstanceAtHighest(targetParent:MovieClip):MovieClip {
		var dOrder = trackDepths(targetParent);
		return dOrder[0].mc;
	}
	
	static private function getInstanceLowerThan(target:MovieClip):MovieClip {
		var dOrder = trackDepths(target._parent);
		for (var i=0; i<dOrder.length; i++) {
			if (dOrder[i].mc==target) {
				break;
			}
		}
		return dOrder[i+1].mc;
	}
	
	static private function getInstanceHigherThan(target:MovieClip):MovieClip {
		var dOrder = trackDepths(target._parent);
		for (var i=0; i<dOrder.length; i++) {
			if (dOrder[i].mc==target) {
				break;
			}
		}
		return dOrder[i-1].mc;
	}
}