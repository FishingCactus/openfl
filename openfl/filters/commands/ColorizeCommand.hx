package openfl.filters.commands;

import openfl.display.BitmapData;
import openfl.display.Shader;

import openfl._internal.renderer.RenderSession;

class ColorizeCommand {

	private static var __shader = new ColorizeShader ();

	public static function apply (renderSession:RenderSession, target:BitmapData, source:BitmapData, color:Int, alpha:Float) {

		__shader.uColor[0] = ((color >> 16) & 0xFF) / 255;
		__shader.uColor[1] = ((color >> 8) & 0xFF) / 255;
		__shader.uColor[2] = (color & 0xFF) / 255;
		__shader.uColor[3] = alpha;

		CommandHelper.apply (renderSession, target, source, __shader, source == target);

	}

}

private class ColorizeShader extends Shader {

	@fragment var fragment = [
		'uniform vec4 uColor;',

		'void main(void)',
		'{',
			'float a = texture2D(${Shader.uSampler}, ${Shader.vTexCoord}).a;',
			'a = clamp(a * uColor.a, 0.0, 1.0);',

			'gl_FragColor = vec4(uColor.rgb * a, a);',
		'}',
	];

	public function new () {

		super ();

	}

}
