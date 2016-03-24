Shader ".ShaderLearning/Others/VertexModification"
{
	// Simple diffuse shader

	// Properties (material properties)
	Properties{
		_Color("Main Color", Color) = (1,1,1,1)
		_MainTex("Main Texture", 2D) = "grey" {}
		_Amount("Height Adjustment", Range(0, 0.1)) = 0.0
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

			// struct with vertex positions; vertex shader will be filled with this data
			// normal vector for every vertex
			// text coords for UV mapping
			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXCOORD0;
			};

			// vertex data pass from vertex to fragment shader
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 normal : NORMAL;
				float2 texcoord : TEXTCOORD0;
			};

			// CG program needs to declare this variable (also declared in ShaderLab part => Properties block)
			float4 _Color;
			// CG declaration for texture
			sampler2D _MainTex;
			// Color from first light on scene
			float4 _LightColor0;
			// Height displacement 
			float _Amount;

			// Vertex shader 
			// Convert object space to world space
			v2f vert(appdata IN)
			{
				v2f OUT;
				// Apply height displacement on the normal vector direction
				IN.vertex.xyz += IN.normal * _Amount;
				OUT.pos = mul(UNITY_MATRIX_MVP, IN.vertex);
				// Normal from object space to world space
				OUT.normal = mul(float4(IN.normal, 0.0), _Object2World).xyz;
				// Texture coordenades pass through
				OUT.texcoord = IN.texcoord;
				return OUT;
			}

			// pixel shader; returns low precision ("fixed4" type)
			// color ("SV_Target" semantic)
			float4 frag(v2f IN) : SV_Target
			{
				// Map texture to UV mapping with text2D function
				float4 texColor = tex2D(_MainTex, IN.texcoord);
				// Normalize normal vector
				float3 normalDirection = normalize(IN.normal);
				// Normalize first light position on scene 
				float3 lightDirection = normalize(_WorldSpaceLightPos0.xyz);
				// Calculate diffuse factor 
				float3 diffuse = _LightColor0.rgb * max(0.0, dot(normalDirection, lightDirection));
				return _Color * texColor * float4(diffuse, 1);
			}

			// BG program ends
			ENDCG
		}
	}

	// Fallback shader if no one subshader is supported by graphics cards
	FallBack "Diffuse"

	// Custom editor things...(less used)
}
