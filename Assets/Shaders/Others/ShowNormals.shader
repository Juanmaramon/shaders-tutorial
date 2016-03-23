Shader ".ShaderLearning/Others/ShowNormals"
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
			// include file that contains UnityObjectToWorldNormal helper function
			#include "UnityCG.cginc"

			// vertex data pass from vertex to fragment shader
			struct v2f
			{
				float4 pos : SV_POSITION;
				float3 color : COLOR;
			};

			// Vertex shader 
			// Convert object space to world space
			v2f vert (appdata_base v)
			{
				v2f OUT;
                OUT.pos = mul (UNITY_MATRIX_MVP, v.vertex);
                // UnityCG.cginc file contains function to transform
                // normal from object to world space, use that

                // normal is a 3D vector with xyz components; in -1..1
                // range. To display it as color, bring the range into 0..1
                // and put into red, green, blue components
                OUT.color = UnityObjectToWorldNormal(v.normal) * 0.5 + 0.5;
                return OUT;
			}

			// pixel shader; returns low precision ("fixed4" type)
			// color ("SV_Target" semantic)
			float4 frag(v2f IN) : SV_Target
			{
				return fixed4(IN.color, 1);			
			}

			// BG program ends
			ENDCG
		}
	}

	// Fallback shader if no one subshader is supported by graphics cards
	FallBack "Diffuse"

	// Custom editor things...(less used)
}
