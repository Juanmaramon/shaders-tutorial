Shader ".ShaderLearning/Others/ScreenPosition"
{
	// Use screen space pixel position : VPOS

	Properties
	{
		_MainTex("Main Texture", 2D) = "white" {}
	}

	// List of subshaders, Unity will pick the first one that Graphics Card support 
	SubShader
	{
		// Several pass can be done
		Pass
		{
			// CG code starts with this tag
			CGPROGRAM
			// vertex function = vert
			#pragma vertex vert
			// fragment function = vert
			#pragma fragment frag
			// This feature starts at shader model 3.0
			#pragma target 3.0

			// Only texture coordinates goes in this struct
			// This is because vertex clip space position and screen pixel position
			// can't be on the same struct
			// SO clip space position has to be as an output varible on vertex shader 
			struct v2f
			{
				//float4 pos : SV_POSITION;	
				float2 texcoord : TEXCOORD0;
			};

			// CG declaration for texture
			sampler2D _MainTex;

			// Vertex shader 
			// Convert object space to world space
			v2f vert (
				float4 pos : POSITION,					// vertex position input
				float2 texcoord : TEXCOORD0,			// first texture coordinate input
				out float4 outpos : SV_POSITION			// clip space position output
			)
			{
				v2f OUT;
				// Clip space vertex position goes as output var
				outpos = mul(UNITY_MATRIX_MVP, pos);
				// Texture coordenades pass through
				OUT.texcoord = texcoord;
				return OUT;
			}

			// pixel shader; returns low precision ("fixed4" type)
			// color ("SV_Target" semantic)
			float4 frag(
						v2f IN,
						UNITY_VPOS_TYPE screenPos : VPOS	// Screen space pixel position!
			) : SV_Target
			{
				// screenPos.xy will contain pixel integer coordinates.
                // use them to implement a checkerboard pattern that skips rendering
                // 4x4 blocks of pixels
				screenPos.xy = floor(screenPos.xy * 0.25) * 0.5;

				// checker value will be negative for 4x4 blocks of pixels
                // in a checkerboard pattern
				float checker =  -frac(screenPos.x + screenPos.y);

				// clip HLSL instruction stops rendering a pixel if value is negative
				clip(checker);

				// for pixels that were kept, read the texture and output it
				fixed4 c = tex2D(_MainTex, IN.texcoord);

				return c;			
			}

			// BG program ends
			ENDCG
		}
	}

	// Fallback shader if no one subshader is supported by graphics cards
	FallBack "Diffuse"

	// Custom editor things...(less used)
}
