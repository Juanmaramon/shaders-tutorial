Shader ".ShaderLearning/3-SimpleDiffuseLightningUnity"
{
	Properties
	{
		[NoScaleOffset] _MainTex("Texture", 2D) = "white" {}
		_BumpMap("Normal Map", 2D) = "bump" {}
		[MaterialToggle] _AmbientLight("Ambient Light", Float) = 0
		[MaterialToggle] _ReceiveShadows("Receive Shadows", Float) = 0
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

			// compile shader into multiple variants, with and without shadows
			// (we don't care about any lightmaps yet, so skip these variants)
			#pragma multi_compile_fwdbase nolightmap nodirlightmap nodynlightmap novertexlight
			// shadow helper functions and macros
			#include "AutoLight.cginc"

			struct v2f
			{
				float2 uv : TEXCOORD0;
				SHADOW_COORDS(1)		// put shadows data into TEXCOORD1
				//fixed3 diff : COLOR0;	// diffuse lighting color
				fixed3 ambient : COLOR1;
				float4 pos : SV_POSITION;

				// For bump mapping
				half3 tspace0 : TEXCOORD2;
				half3 tspace1 : TEXCOORD3;
				half3 tspace2 : TEXCOORD4;
			};

			Float _AmbientLight;
			Float _ReceiveShadows;

			v2f vert(appdata_tan v)
			{
				v2f o;
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.texcoord;
				// get vertex normal in world space
				half3 wNormal = UnityObjectToWorldNormal(v.normal);

				// get tangent space vector
				half3 wTangent = UnityObjectToWorldDir(v.tangent.xyz);
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 wBitangent = cross(wNormal, wTangent) * tangentSign;

				o.tspace0 = half3(wTangent.x, wBitangent.x, wNormal.x);
				o.tspace1 = half3(wTangent.y, wBitangent.y, wNormal.y);
				o.tspace2 = half3(wTangent.z, wBitangent.z, wNormal.z);
		
				// in addition to the diffuse lighting from the main light,
				// add illumination from ambient or light probes
				// ShadeSH9 function from UnityCG.cginc evaluates it,
				// using world space normal
				if (_AmbientLight > 0)
					o.ambient = ShadeSH9(half4(wNormal, 1));
			
				// compute shadows data
				if (_ReceiveShadows > 0)
				{
					TRANSFER_SHADOW(o)
				}
				return o;
			}

			sampler2D _MainTex;
			sampler2D _BumpMap;


			fixed4 frag(v2f i) : SV_Target
			{
				// sample texture
				fixed4 col = tex2D(_MainTex, i.uv);

				// Get normal vector with bump effect
				half3 tnormal = UnpackNormal(tex2D(_BumpMap, i.uv));
				half3 worldNormal;
				worldNormal.x = dot(i.tspace0, tnormal);
				worldNormal.y = dot(i.tspace1, tnormal);
				worldNormal.z = dot(i.tspace2, tnormal);

				// dot product between normal and light direction for
				// standard diffuse (Lambert) lighting
				half nl = max(0, dot(worldNormal, _WorldSpaceLightPos0.xyz));
				// factor in the light color
				fixed3 diff = nl * _LightColor0.rgb;

				if (_AmbientLight > 0)
					diff.rgb += i.ambient;

				if (_ReceiveShadows > 0)
				{
					// compute shadow attenuation (1.0 = fully lit, 0.0 = fully shadowed)
					fixed shadow = SHADOW_ATTENUATION(i);
					// darken light's illumination with shadow, keep ambient intact
					fixed3 lighting = diff * shadow;

					col.rgb *= lighting;
				}
				else
				{
					// multiply by lighting
					col.rgb *= diff;
				}
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
			// Shader gets compiled into several variants
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