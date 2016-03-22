Shader ".ShaderLearning/2-SimpleTexturing"
{
	// Simple texturing shader

	// Properties (material properties)
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "grey" {}
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
			// text coords for UV mapping
			struct appdata
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			// vertex data pass from vertex to fragment shader
			struct v2f
			{
				float4 pos : SV_POSITION;
				float2 texcoord : TEXTCOORD0;
			};

			// CG program needs to declare this variable (also declared in ShaderLab part => Properties block)
			float4 _Color;
			// CG declaration for texture
			sampler2D _MainTex;

			// Vertex shader 
			// Convert object space to view space
			v2f vert(appdata IN)
			{
				v2f OUT;
				OUT.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
				// Texture coordenades pass through
				OUT.texcoord = IN.texcoord;
				return OUT;
			}

			float4 frag(v2f IN) : COLOR
			{
				// Map texture to UV mapping with text2D function
				float4 texColor = tex2D(_MainTex, IN.texcoord);
				return _Color * texColor;
			}

			// BG program ends
			ENDCG
		}
	}

	// Fallback shader if no one subshader is supported by graphics cards
	FallBack "Diffuse"

	// Custom editor things...(less used)
}
