package openfl.display; #if !openfl_legacy


import openfl._internal.renderer.canvas.CanvasGraphics;
import openfl._internal.renderer.RenderSession;
import openfl.display.Stage;
import openfl.errors.RangeError;
import openfl.events.Event;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;

import openfl.utils.UnshrinkableArray;

@:access(openfl.events.Event)
@:access(openfl.display.Graphics)
@:access(openfl.geom.Rectangle)


class DisplayObjectContainer extends InteractiveObject {


	public var mouseChildren:Bool;
	public var numChildren (get, null):Int;
	public var tabChildren:Bool;

	static private var __mouseListenerBranchDepthStack:UnshrinkableArray<Int> = new UnshrinkableArray<Int>(32);

	private function new () {

		super ();

		mouseChildren = true;

		__children = new UnshrinkableArray<DisplayObject> (8);

	}


	inline public function addChild (child:DisplayObject):DisplayObject {
		return addChildAt(child, numChildren);
	}


	public function addChildAt (child:DisplayObject, index:Int):DisplayObject {

		if (index < 0 || index > __children.length) {
			throw "Invalid index position " + index;
		}

		if (!__useSeparateRenderScaleTransform) {
			child.__useSeparateRenderScaleTransform = false;
		}

		var childIndexToRemove:Int = -1;

		if (child.parent == this) {
			childIndexToRemove = __children.indexOf (child);
			__children[childIndexToRemove] = null;
			__children.insert(index,child);
		} else {
			if (child.parent != null) {
				// :TRICKY: We make the stage null to avoid the child being disposed.
				// By default, removing a child makes us assume that the child should be cleaned up
				// In this case it's only moved.
				// :NOTE: This will still be incorrect when manually removing + adding.
				// We should maybe use a smarter internal GC system.
				var childStage:Stage = child.stage;
				child.stage = null;
				child.parent.removeChild (child);
				child.stage = childStage;
			}

			__children.insert(index,child);
			initParent(child);
		}
		__setBranchDirty();
		__updateRecursiveMouseListenerCount(child.__recursiveMouseListenerCount);

		if(childIndexToRemove > -1) {
			removeChildAt(childIndexToRemove < index ? childIndexToRemove : childIndexToRemove + 1);
		}

		return child;

	}

	public function initParent (child:DisplayObject) {

			child.parent = this;

			if (stage != null) {
				// TODO: Dispatch ADDED_TO_STAGE after ADDED (but parent and stage must be set)
				child.setStage(stage);
			}
			child.updateCachedParent ();

			child.__setTransformDirty ();
			child.__setRenderDirty ();
			__setRenderDirty();

			child.dispatchEvent (Event.__create (Event.ADDED, true));
	}

	public function areInaccessibleObjectsUnderPoint (point:Point):Bool {

		return false;

	}


	public function contains (child:DisplayObject):Bool {

		while (child != this && child != null) {

			child = child.parent;

		}

		return child == this;

	}


	public function getChildAt (index:Int):DisplayObject {

		if (index >= 0 && index < __children.length) {

			return __children[index];

		}

		return null;

	}


	public function getChildByName (name:String):DisplayObject {

		for (child in __children) {
			if (child.name == name) return child;

		}

		return null;

	}


	public function getChildIndex (child:DisplayObject):Int {

		return __children.indexOf(child);

	}


	public function getObjectsUnderPoint (point:Point):UnshrinkableArray<DisplayObject> {

		var stack = new UnshrinkableArray<DisplayObject>(32);
		__hitTest (point.x, point.y, false, stack, false, this);
		stack.reverse ();
		return stack;

	}


	public function removeChild (child:DisplayObject):DisplayObject {

		if (child != null && child.parent == this) {

			child.dispatchEvent (Event.__create (Event.REMOVED, true));

			if (stage != null) {
				child.setStage(null);
			}

			__setBranchDirty();
			__updateRecursiveMouseListenerCount(-child.__recursiveMouseListenerCount);
			child.parent = null;
			if(child.__cachedParent != null){
				child.updateCachedParent();
			}
			__children.remove (child);
			child.__setTransformDirty ();
			child.__setRenderDirty ();
			__setRenderDirty();

			var symbol = child.getSymbol();
			if(symbol != null && symbol.poolable) {
				symbol.pool.put(child);
			}
		}

		return child;

	}


	public function removeChildAt (index:Int):DisplayObject {

		if (index >= 0 && index < __children.length) {

			var child: DisplayObject = __children[index];

			if(child !=null){
				return removeChild (child);
			} else {
				__children.splice(index, 1);
			}

			__setBranchDirty();
		}

		return null;

	}


	public function removeChildren (beginIndex:Int = 0, endIndex:Int = 0x7FFFFFFF):Void {

		if (endIndex == 0x7FFFFFFF) {

			endIndex = __children.length - 1;

			if (endIndex < 0) {

				return;

			}

		}

		if (beginIndex > __children.length - 1) {

			return;

		} else if (endIndex < beginIndex || beginIndex < 0 || endIndex > __children.length) {

			throw new RangeError ("The supplied index is out of bounds.");

		}

		var numRemovals = endIndex - beginIndex;
		while (numRemovals >= 0) {

			removeChildAt (beginIndex);
			numRemovals--;

		}

	}


	public override function resolve (fieldName:String):DisplayObject {

		var result = Reflect.field(this, fieldName);
		if( result != null ) {
			return result;
		}
		return getChildByName(fieldName);

	}


	public function setChildIndex (child:DisplayObject, index:Int):Void {

		if (index >= 0 && index <= __children.length && child.parent == this) {

			if(__children[index]==null){
				var old_index: Int = __children.indexOf (child);
				__children[old_index] = null;
				__children[index] = child;
			} else {

				__children.remove(child);
				__children.insert(index, child);
			}

			__setBranchDirty();
		}

	}


	public function swapChildren (child1:DisplayObject, child2:DisplayObject):Void {

		if (child1.parent == this && child2.parent == this) {

			var index1 = __children.indexOf (child1);
			var index2 = __children.indexOf (child2);
			swapChildrenAt(index1,index2);
		}

	}


	public function swapChildrenAt (index1:Int, index2:Int):Void {

		var swap:DisplayObject = __children[index1];
		__children[index1] = __children[index2];
		__children[index2] = swap;
		__setBranchDirty();

	}

	private override function updateCachedParent (currentCachedParent:DisplayObjectContainer = null){

		currentCachedParent = super.updateCachedParent(currentCachedParent);

		if ( __children != null ) {
			for (child in __children) {
				child.updateCachedParent (currentCachedParent);
			}
		}
		return currentCachedParent;
	}

	private override function __broadcast (event:Event, notifyChilden:Bool):Bool {

		if (event.target == null) {

			event.target = this;

		}

		var result = super.__broadcast (event, notifyChilden);

		if (!event.__isCanceled && notifyChilden) {

			for (child in __children) {

				child.__broadcast (event, true);

				if (event.__isCanceled) {

					return true;

				}

			}

		}

		return result;

	}

	private override function __getBounds (rect:Rectangle):Void {

		super.__getBounds (rect);

		if (__children.length == 0) return;

		var childRect = Rectangle.pool.get ();

		for (child in __children) {

			if (!child.isRenderable()) continue;
			child.__getLocalBounds (childRect);
			rect.__expand (childRect.x, childRect.y, childRect.width, childRect.height);

		}

		Rectangle.pool.put(childRect);

	}

	private override function __getChildrenRenderBounds (rect:Rectangle):Void {

		if (__children.length == 0) {

			return;

		}

		var childRect = Rectangle.pool.get();

		for (child in __children) {

			if (!child.isRenderable()) continue;
			child.__getRenderBounds (childRect);
			rect.__expand (childRect.x, childRect.y, childRect.width, childRect.height);

		}

		Rectangle.pool.put(childRect);
	}


	private override function __hitTest (x:Float, y:Float, shapeFlag:Bool, stack:UnshrinkableArray<DisplayObject>, interactiveOnly:Bool, hitObject:DisplayObject):Bool {

		if (!__mustEvaluateHitTest() || !hitObject.visible || __isMask || (interactiveOnly && !mouseChildren && !mouseEnabled)) return false;
		if (mask != null && !mask.__hitTestMask (x, y)) return false;
		var point = Point.pool.get();
		point.setTo (x, y);
		if (__scrollRect != null && !__scrollRect.containsPoint (globalToLocal (point))) {
			Point.pool.put(point);

			return false;
		} else {
			Point.pool.put(point);
		}

		var symbol = getSymbol();
		shapeFlag = shapeFlag && ( symbol != null ? symbol.pixelPerfectHitTest : true );

		var itHasMouseListener = __hasMouseListener ();

		__pushHitTestLevel (itHasMouseListener);

		var i = __children.length;

		if (interactiveOnly) {

			if (stack == null || !mouseChildren) {

				while (--i >= 0) {

					var child = __children[i];
					var clippedAt = child.__clippedAt;

					if (clippedAt != -1) {
						// :TODO: Do not recheck the mask several times.
						if ( __children[clippedAt] != null && !__children[clippedAt].__hitTestMask(x,y) ) {
							i = clippedAt;
							continue;
						}
					}

					if (child != null && child.__hitTest (x, y, shapeFlag, null, mouseChildren, cast child)) {

						if (stack != null) {

							stack.push (hitObject);

						}

						__popHitTestLevel (itHasMouseListener);

						return true;

					}

				}

			} else if (stack != null) {

				var length = stack.length;

				var interactive = false;
				var hitTest = false;

				while (--i >= 0) {

					var child = __children[i];
					var clippedAt = child.__clippedAt;

					if (clippedAt != -1) {
						// :TODO: Do not recheck the mask several times.
						if ( __children[clippedAt] != null && !__children[clippedAt].__hitTestMask(x,y) ) {
							i = clippedAt;
							continue;
						}
					}

					interactive = child.__getInteractive (null);

					if (interactive || (mouseEnabled && !hitTest)) {

						if (child.__hitTest (x, y, shapeFlag, stack, true, cast child)) {

							if(mouseEnabled) {
								hitTest = true;
							}

							if (interactive) {

								if ( !hitTest ) {

									__popHitTestLevel (itHasMouseListener);

									return true;
								}
								break;

							}

						}

					}

				}

				if (hitTest) {

					stack.insert (length, hitObject);
					__popHitTestLevel (itHasMouseListener);

					return true;

				}

			}

		} else {

			while (--i >= 0) {

				if ( __children[i].__hitTest (x, y, shapeFlag, stack, false, cast __children[i]) ) {
					if (stack != null) {

						stack.push (hitObject);

					}

					__popHitTestLevel (itHasMouseListener);

					return true;
				};

			}

		}

		__popHitTestLevel (itHasMouseListener);

		return false;

	}


	private override function __hitTestMask (x:Float, y:Float):Bool {

		var i = __children.length;

		while (--i >= 0) {

			if (__children[i] == null ) continue;

			if (__children[i].__hitTestMask (x, y)) {

				return true;

			}

		}

		return false;

	}


	public override function __renderCanvas (renderSession:RenderSession):Void {

		if (!isRenderable() || __worldAlpha <= 0) return;

		#if !neko

		super.__renderCanvas (renderSession);

		if (__scrollRect != null) {

			renderSession.maskManager.pushRect (__scrollRect, __worldTransform);

		}

		if (__mask != null) {

			renderSession.maskManager.pushMask (__mask);

		}

		for (child in __children) {
			child.__renderCanvas (renderSession);

		}

		if (__mask != null) {

			renderSession.maskManager.popMask ();

		}

		if (__scrollRect != null) {

			renderSession.maskManager.popRect ();

		}

		#end

	}


	public override function __renderCanvasMask (renderSession:RenderSession):Void {
		throw ":TODO: Remove";
	}


	public override function __renderGL (renderSession:RenderSession):Void {

		if (!isRenderable() || __worldAlpha <= 0) return;

		if (__resolvedCacheAsBitmap) {
			__isCachingAsBitmap = true;
			__cacheGL(renderSession);
			__isCachingAsBitmap = false;
			return;
		}

		__preRenderGL (renderSession);
		__drawGraphicsGL (renderSession);

		var maskEndDepth = -1;

		for (child in __children) {

			--maskEndDepth;

			if( maskEndDepth == -1 ){
				renderSession.maskManager.popMask();
			}

			if( child.__clipDepth != 0 ){

				if( !child.__maskCached ){
					if( child.__cachedBitmap != null ){
						child.__cachedBitmap.dispose();
						child.__cachedBitmap = null;
					}

					child.__isMask = true;
					child.__update (true, true);

					child.__maskCached = true;
				}

				renderSession.maskManager.pushMask (child);
				maskEndDepth =  child.__clipDepth;
			}
			else {
				child.__renderGL (renderSession);
			}
		}

		if( maskEndDepth >= 0 ){
			renderSession.maskManager.popMask();
		}

		__postRenderGL (renderSession);

	}

	private override function __fireRemovedFromStageEvent(stack=null) {
		super.__fireRemovedFromStageEvent(stack);

		if (__children != null) {
			#if compliant_stage_events
				#if dev
					if ( stack[stack.length-1] != this ) {
						throw "Unexpected stack. Fix behavior..";
					}
				#end
				stack.push(null);
			#end
			for (child in __children) {
				#if compliant_stage_events
					stack[stack.length-1] = child;
				#end
				child.__fireRemovedFromStageEvent(stack);
			}
			#if compliant_stage_events
				stack.pop();
			#end
		}
	}

	private override function __updateStageInternal(value:Stage) {
		super.__updateStageInternal(value);

		if (__children != null) {
			for (child in __children) {
				child.__updateStageInternal(value);
			}
		}
	}

	private override function __fireAddedToStageEvent(stack=null) {
		super.__fireAddedToStageEvent(stack);

		if (__children != null) {
			#if compliant_stage_events
				#if dev
					if ( stack[stack.length-1] != this ) {
						throw "Unexpected stack. Fix behavior..";
					}
				#end
				stack.push(null);
			#end
			for (child in __children) {
				#if compliant_stage_events
					stack[stack.length-1] = child;
				#end
				child.__fireAddedToStageEvent(stack);
			}
			#if compliant_stage_events
				stack.pop();
			#end
		}
	}

	private override function __releaseResources ():Void {

		super.__releaseResources();

		if (__children != null) {
			for (child in __children) {
				child.__releaseResources();
			}
		}
	}

	private override function __cleanupIntermediateTextures() {
		super.__cleanupIntermediateTextures();
		for (child in __children) {
			child.__cleanupIntermediateTextures();
		}
	}

	public override function __update (transformOnly:Bool, updateChildren:Bool):Void {

		super.__update (transformOnly, updateChildren);

		// nested objects into a mask are non renderables but are part of the mask
		if (!isRenderable() && !__isMask) {

			return;

		}

		//if (!__renderable) return;

		if (updateChildren) {

			for (child in __children) {

				child.__update (transformOnly, true);

			}

		}

	}


	public override function __updateChildren (transformOnly:Bool):Void {

		super.__updateChildren (transformOnly);

		for (child in __children) {

			child.__update (transformOnly, true);

		}

	}


	public override function isRenderable() {
		return super.isRenderable() && (__graphics != null || (__children != null && __children.length > 0));
	}


	private inline function __pushHitTestLevel (itHasMouseListener:Bool):Void {
		if (itHasMouseListener) {
			__mouseListenerBranchDepthStack.push (__branchDepth);

			if (__branchDepth == null) {
				var depth = 0;
				var parent = this;

				while (parent.__branchDepth == null) {
					parent = parent.parent;
					++depth;
				}

				__branchDepth = parent.__branchDepth + depth;
			}

			// :TRICKY: do not use stage branch depth (== 0) to avoid having to hittest everything under the stage
			DisplayObject.__lastMouseListenerBranchDepth = __branchDepth != 0 ? __branchDepth : DisplayObject.NO_MOUSE_LISTENER_BRANCH_DEPTH;
		}
	}

	private inline function __popHitTestLevel (itHasMouseListener:Bool):Void {
		if (itHasMouseListener) {
			__mouseListenerBranchDepthStack.pop ();
			var branchDepth = __mouseListenerBranchDepthStack.last ();

			// :TRICKY: do not use stage branch depth (== 0) to avoid having to hittest everything under the stage
			DisplayObject.__lastMouseListenerBranchDepth = branchDepth != 0 ? branchDepth : DisplayObject.NO_MOUSE_LISTENER_BRANCH_DEPTH;
		}
	}



	// Get & Set Methods




	inline private function get_numChildren ():Int {

		return __children.length;

	}

	private override function __onResolvedCacheAsBitmapChanged() {

		var cachedParent = __resolvedCacheAsBitmap ? this : null;

		for(child in __children){

			child.updateCachedParent (cachedParent);

		}

	}
}


#else
typedef DisplayObjectContainer = openfl._legacy.display.DisplayObjectContainer;
#end
