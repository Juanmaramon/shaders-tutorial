Shader ".ShaderLearning/Others/ShowUVs"
{
	// Visualize UVs coordinates as colors

	// List of subshaders, Unity will pick the first one that Graphics Card support 
	SubShader{
		// Several pass can be done
		Pass
		{
			// CG code starts with this tag
			CGPROGRAM
			// vertex function = vert
			#pragma vertex vert
			// fragment function = vert
			#pragma fragment frag

			// vertex data pass from vertex to fragment shader
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 texcoord : TEXCOORD0;
			};

			// Vertex shader 
			// Convert object space to world space
			v2f vert (
				float4 pos : POSITION,					// vertex position input
				float2 texcoord : TEXCOORD0				// first texture coordinate input
			)
			{
				v2f OUT;
				OUT.pos = mul(UNITY_MATRIX_MVP, pos);
				// Texture coordenades pass through
				OUT.texcoord = texcoord;
				return OUT;
			}

			// pixel shader; returns low precision ("fixed4" type)
			// color ("SV_Target" semantic)
			float4 frag(v2f IN) : SV_Target
			{
				return fixed4(IN.texcoord, 0, 0);			
			}

			// BG program ends
			ENDCG
		}
	}

	// Fallback shader if no one subshader is supported by graphics cards
	FallBack "Diffuse"

	// Custom editor things...(less used)
}
