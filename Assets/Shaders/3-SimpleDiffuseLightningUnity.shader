Shader ".ShaderLearning/3-SimpleDiffuseLightningUnity"
{
	Properties
	{
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		[MaterialToggle] _AmbientLight("Ambient Light", Float) = 0
	}
	
	SubShader
	{
		
		Pass
		{
			// indicate that our pass is the "base" pass in forward
			// rendering pipeline. It gets ambient and main directional
			// light data set up; light direction in _WorldSpaceLightPos0
			// and color in _LightColor0
			Tags{ "LightMode" = "ForwardBase" }

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#include "UnityCG.cginc" // for UnityObjectToWorldNormal
			#include "UnityLightingCommon.cginc" // for _LightColor0

			struct v2f
			{
				float2 uv : TEXCOORD0;
				fixed4 diff : COLOR0; // diffuse lighting color
				float4 vertex : SV_POSITION;
			};

			Float _AmbientLight;

			v2f vert(appdata_base v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				// get vertex normal in world space
				half3 worldNormal = UnityObjectToWorldNormal(v.normal);
				// dot product between normal and light direction for
				// standard diffuse (Lambert) lighting
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				// factor in the light color
				o.diff = nl * _LightColor0;
				
				// in addition to the diffuse lighting from the main light,
				// add illumination from ambient or light probes
				// ShadeSH9 function from UnityCG.cginc evaluates it,
				// using world space normal
				if (_AmbientLight > 0)
					o.diff.rgb += ShadeSH9(half4(worldNormal,1));
				return o;
			}

			sampler2D _MainTex;

			fixed4 frag(v2f i) : SV_Target
			{
				// sample texture
				fixed4 col = tex2D(_MainTex, i.uv);
				// multiply by lighting
				col *= i.diff;
				return col;
			}
			ENDCG
		}

		// shadow caster rendering pass, implemented manually
		// using macros from UnityCG.cginc
		Pass
		{
			Tags{ "LightMode" = "ShadowCaster" }

			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag
			#pragma multi_compile_shadowcaster
			#include "UnityCG.cginc"

			struct v2f {
				V2F_SHADOW_CASTER;
				float4 color : COLOR0;
			};

			v2f vert(appdata_base v)
			{
				v2f o;
						
				TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
				o.color = v.texcoord;
				return o;
			}

			float4 frag(v2f i) : SV_Target
			{
				SHADOW_CASTER_FRAGMENT(i)
			}

			ENDCG
		}
			
	}
}