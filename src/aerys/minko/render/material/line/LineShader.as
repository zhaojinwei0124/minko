package aerys.minko.render.material.line
{
	import aerys.minko.render.RenderTarget;
	import aerys.minko.render.geometry.primitive.LineGeometry;
	import aerys.minko.render.material.basic.BasicProperties;
	import aerys.minko.render.shader.SFloat;
	import aerys.minko.render.shader.Shader;
	import aerys.minko.render.shader.ShaderSettings;
	import aerys.minko.type.enum.DepthTest;
	import aerys.minko.type.enum.TriangleCulling;
	
	public class LineShader extends Shader
	{
		public function LineShader(renderTarget	: RenderTarget	= null,
									priority		: Number		= 0.0)
		{
			super(renderTarget, priority);
		}
		
		override protected function initializeSettings(settings : ShaderSettings) : void
		{
			super.initializeSettings(settings);
			// depth test
			settings.depthWriteEnabled = meshBindings.getProperty(
				BasicProperties.DEPTH_WRITE_ENABLED, true
			);
			settings.depthTest = meshBindings.getProperty(
				BasicProperties.DEPTH_TEST, DepthTest.LESS
			);
			
			settings.triangleCulling = meshBindings.getProperty(
				BasicProperties.TRIANGLE_CULLING, TriangleCulling.NONE
			);
		}
		
		override protected function getVertexPosition():SFloat
		{
			var lineStart	: SFloat	= getVertexAttribute(LineGeometry.VERTEX_LINE_START);
			var lineStop	: SFloat	= getVertexAttribute(LineGeometry.VERTEX_LINE_STOP);
			var lineSpread	: SFloat	= getVertexAttribute(LineGeometry.VERTEX_LINE_SPREAD);
			var startWeight	: SFloat	= lineStart.w;
			var stopWeight	: SFloat	= lineStop.w;
			
			lineStart = float4(lineStart.xyz, 1);
			lineStop = float4(lineStop.xyz, 1);
			
			lineStart = localToScreen(lineStart);
			lineStop = localToScreen(lineStop);
			
			var position	: SFloat	= add(
				multiply(lineStart, startWeight),
				multiply(lineStop, stopWeight)
			);
			var positionW	: SFloat	= position.w;
			
			lineStart = divide(lineStart, lineStart.w);
			lineStop = divide(lineStop, lineStop.w);
			
			var normal		: SFloat	= float3(
				subtract(lineStart.y, lineStop.y),
				subtract(lineStop.x, lineStart.x),
				0
			);
			
			normal = normalize(normal);
			normal.scaleBy(lineSpread.xxx);
			normal.scaleBy(meshBindings.getParameter('lineThickness', 1, 1));
			normal = divide(normal, float2(viewportWidth, viewportHeight));
			
			position = divide(position.xyz, positionW);
			position = add(position.xyz, normal);
			position = float4(multiply(position, positionW), positionW);
			
			return position;
		}
		
		override protected function getPixelColor():SFloat
		{
			return meshBindings.getParameter(BasicProperties.DIFFUSE_COLOR, 4, 0xffffffff);
		}
	}
}