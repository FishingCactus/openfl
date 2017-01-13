package openfl._internal.renderer; #if (!display && !flash)

import haxe.ds.GenericStack;

import lime.graphics.CairoRenderContext;
import lime.graphics.CanvasRenderContext;
import lime.graphics.DOMRenderContext;
import lime.graphics.GLRenderContext;
import lime.graphics.opengl.GLFramebuffer;
import openfl._internal.renderer.opengl.utils.BlendModeManager;
import openfl._internal.renderer.opengl.utils.FilterManager;
import openfl._internal.renderer.opengl.utils.ShaderManager;
import openfl._internal.renderer.opengl.utils.SpriteBatch;
import openfl._internal.renderer.opengl.utils.StencilManager;
import openfl.display.BlendMode;
import openfl.display.IBitmapDrawable;
import openfl.geom.Matrix;
import openfl.geom.Point;


class RenderSession {
	
	
	public var cairo:CairoRenderContext;
	public var context:CanvasRenderContext;
	public var element:DOMRenderContext;
	public var gl:GLRenderContext;
	public var renderer:AbstractRenderer;
	public var roundPixels:Bool;
	public var transformProperty:String;
	public var transformOriginProperty:String;
	public var vendorPrefix:String;
	public var z:Int;
	public var projectionMatrix:Matrix;
	
	public var drawCount:Int;
	public var currentBlendMode:BlendMode;
	public var activeTextures:Int = 0;
	
	public var shaderManager:ShaderManager;
	public var maskManager:AbstractMaskManager;
	public var filterManager:FilterManager;
	public var blendModeManager:BlendModeManager;
	public var spriteBatch:SpriteBatch;
	public var stencilManager:StencilManager;
	public var defaultFramebuffer:GLFramebuffer;
	public var usesMainSpriteBatch(get, never):Bool;
	
	private var renderTargetBaseTransformStack:GenericStack<Matrix>;
	
	
	public function new () {
		
		//maskManager = new MaskManager (this);
		renderTargetBaseTransformStack = new GenericStack<Matrix> ();
		pushRenderTargetBaseTransform (null, null);
	}
	 
	public function pushRenderTargetBaseTransform (source:IBitmapDrawable, renderTargetBaseTransform:Matrix) {
		
		var matrix = Matrix.pool.get ();
		
		var renderTransform:Matrix = Reflect.field (source, "__renderTransform");
		
		if (renderTransform != null) {
			
			matrix.copyFrom (renderTransform);
			matrix.invert ();

		} else {
			
			matrix.identity ();
			
		}
		
		if (renderTargetBaseTransform != null) {
			
			matrix.concat (renderTargetBaseTransform);
			
		}
		
		renderTargetBaseTransformStack.add (matrix);
		
	}
	
	public function popRenderTargetBaseTransform () {
		
		var matrix = renderTargetBaseTransformStack.pop ();
		
		Matrix.pool.put (matrix);
		
	}

	public function getRenderTargetBaseTransform ():Matrix {
		
		return renderTargetBaseTransformStack.first ();
		
	}
	
	public inline function get_usesMainSpriteBatch ():Bool {
		
		var glRenderer:openfl._internal.renderer.opengl.GLRenderer = cast renderer;
		return spriteBatch == glRenderer.mainSpriteBatch;
		
	}

} #end
