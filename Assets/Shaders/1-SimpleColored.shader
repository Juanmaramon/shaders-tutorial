Shader ".ShaderLearning/1-SimpleColored"
{
	// Super simple shader :)

	// Properties (material properties)
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
	}

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

		// struct with vertex positions; vertex shader will be filled with this data
		struct appdata
		{
			float4 vertex: POSITION;
		};

		// vertex data pass from vertex to fragment shader
		struct v2f
		{
			float4 pos: SV_POSITION;
		};

		// CG program needs to declare this variable (also declared in ShaderLab part => Properties block)
		float4 _Color;

		// Vertex shader 
		// Convert object space to view space
		v2f vert(appdata IN)
		{
			v2f OUT;
			OUT.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
			return OUT;
		}

		float4 frag(v2f IN) : COLOR
		{
			return _Color;
		}

			// BG program ends
			ENDCG
		}
	}

	// Fallback shader if no one subshader is supported by graphics cards
	FallBack "Diffuse"

	// Custom editor things...(less used)
}
