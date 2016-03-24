Shader ".ShaderLearning/Others/SkyReflection"
{
	SubShader
	{
		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc"

			struct v2f {
				half3 worldRefl : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			v2f vert(float4 vertex : POSITION, float3 normal : NORMAL)
			{
				v2f OUT;
				OUT.pos = mul(UNITY_MATRIX_MVP, vertex);
				// compute world space position of the vertex
				float3 worldPos = mul(_Object2World, vertex).xyz;
				// compute world space view direction
				float3 worldViewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				// world space normal
				float3 worldNormal = UnityObjectToWorldNormal(normal);
				// world space reflection vector
				OUT.worldRefl = reflect(-worldViewDir, worldNormal);
				return OUT;
			}

			fixed4 frag(v2f IN) : SV_Target
			{
				// sample the default reflection cubemap, using the reflection vector
				// unity_SpecCube0 contains data for the active reflection probe
				half4 skyData = UNITY_SAMPLE_TEXCUBE(unity_SpecCube0, IN.worldRefl);
				// decode cubemap data into actual color
				half3 skyColor = DecodeHDR(skyData, unity_SpecCube0_HDR);
				// output it!
				fixed4 c = 0;
				c.rgb = skyColor;
				return c;
			}

			ENDCG
		}
	}
}