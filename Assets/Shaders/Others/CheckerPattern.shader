Shader "Unlit/CheckerPattern"
{

	//The density slider in the Properties block controls how dense the checkerboard is.In the vertex shader, the mesh UVs are multiplied by the density value to take them from a range of 0 to 1 to a range of 0 to density.Let’s say the density was set to 30 - this will make i.uv input into the fragment shader contain floating point values from zero to 30 for various places of the mesh being rendered.

	//Then the fragment shader code takes only the integer part of the input coordinate using HLSL’s built - in floor function, and divides it by two.Recall that the input coordinates were numbers from 0 to 30; this makes them all be “quantized” to values of 0, 0.5, 1, 1.5, 2, 2.5, and so on.This was done on both the x and y components of the input coordinate.

	//Next up, we add these x and y coordinates together(each of them only having possible values of 0, 0.5, 1, 1.5, …) and only take the fractional part using another built - in HLSL function, frac.Result of this can only be either 0.0 or 0.5.We then multiply it by two to make it either 0.0 or 1.0, and output as a color(this results in black or white color respectively).

	Properties
	{
		_Density("Density", Range(2,50)) = 30
	}
	
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			float _Density;

			v2f vert(float4 pos : POSITION, float2 uv : TEXCOORD0)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, pos);
				o.uv = uv * _Density;
				return o;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float2 c = i.uv;
				c = floor(c) / 2;
				float checker = frac(c.x + c.y) * 2;
				return checker;
			}
			ENDCG
		}
	}
}