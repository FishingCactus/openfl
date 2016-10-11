package openfl.filters.commands;

import openfl.display.BitmapData;
import openfl.display.Shader;

import openfl._internal.renderer.RenderSession;

class OuterKnockoutCommand {

	private static var __shader = new OuterKnockoutShader ();

	public static function apply (renderSession:RenderSession, target:BitmapData, source1:BitmapData, source2:BitmapData) {

		__shader.uSource1Sampler = source1;

		CommandHelper.apply (renderSession, target, source2, __shader, source1 == target || source2 == target);

	}

}

private class OuterKnockoutShader extends Shader {

	@fragment var fragment = [
		'uniform sampler2D uSource1Sampler;',
		'uniform float outer;',

		'void main(void)',
		'{',
			'vec4 src2 = texture2D(${Shader.uSampler}, ${Shader.vTexCoord});',
			'vec4 src1 = texture2D(uSource1Sampler, ${Shader.vTexCoord});', // target image
			'src2 *=  1. - step(0.0001, src1.a);',
			'gl_FragColor = src2;',
		'}',
	];

	public function new () {

		super ();

	}

}