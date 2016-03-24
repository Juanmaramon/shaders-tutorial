// From https://en.wikibooks.org/wiki/Cg_Programming/Unity/Toon_Shading
Shader ".ShaderLearning/7-ComplexToon" {
	Properties{
		_Color("Diffuse Color", Color) = (1,1,1,1)
		_UnlitColor("Unlit Diffuse Color", Color) = (0.5,0.5,0.5,1)
		_DiffuseThreshold("Threshold for Diffuse Colors", Range(0,1))
		= 0.1
		_OutlineColor("Outline Color", Color) = (0,0,0,1)
		_LitOutlineThickness("Lit Outline Thickness", Range(0,1)) = 0.1
		_UnlitOutlineThickness("Unlit Outline Thickness", Range(0,1))
		= 0.4
		_SpecColor("Specular Color", Color) = (1,1,1,1)
		_Shininess("Shininess", Float) = 10
		_MainTex("Texture", 2D) = "white" {}
		//_BumpMap("Normal Map", 2D) = "bump" {}
	}
		SubShader{
		Pass{
		Tags{ "LightMode" = "ForwardBase" }
		// pass for ambient light and first light source

		CGPROGRAM

#pragma vertex vert  
#pragma fragment frag 

#include "UnityCG.cginc"
		uniform float4 _LightColor0;
	// color of light source (from "Lighting.cginc")

	// User-specified properties
	uniform float4 _Color;
	uniform float4 _UnlitColor;
	uniform float _DiffuseThreshold;
	uniform float4 _OutlineColor;
	uniform float _LitOutlineThickness;
	uniform float _UnlitOutlineThickness;
	uniform float4 _SpecColor;
	uniform float _Shininess;	
	//uniform sampler2D _BumpMap;
	//uniform float4 _BumpMap_ST;

	struct vertexInput {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
		float2 texcoord : TEXCOORD0;
		float4 tangent : TANGENT;
	};

	struct vertexOutput {
		float4 pos : SV_POSITION;
		float4 posWorld : TEXCOORD0;
		//float3 normalDir : TEXCOORD1;
		//float2 texcoord : TEXCOORD2;
		float2 texcoord : TEXCOORD1;

		// position of the vertex (and fragment) in world space 
		//float3 tangentWorld : TEXCOORD2;
		float3 normalWorld : TEXCOORD3;
		//float3 binormalWorld : TEXCOORD4;
	};

	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		float4x4 modelMatrix = _Object2World;
		float4x4 modelMatrixInverse = _World2Object;

		output.posWorld = mul(modelMatrix, input.vertex);
		output.normalWorld = normalize(
			mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
	
/*		output.tangentWorld = normalize(
			mul(modelMatrix, float4(input.tangent.xyz, 0.0)).xyz);
		output.normalWorld = normalize(
			mul(float4(input.normal, 0.0), modelMatrixInverse).xyz);
		output.binormalWorld = normalize(
			cross(output.normalWorld, output.tangentWorld)
			* input.tangent.w); // tangent.w is specific to Unity

			*/
		
		output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
		
		output.texcoord = input.texcoord;
		return output;
	}

	sampler2D _MainTex;

	float4 frag(vertexOutput input) : COLOR
	{
		float3 normalDirection = normalize(input.normalWorld);

		// in principle we have to normalize tangentWorld,
		// binormalWorld, and normalWorld again; however, the 
		// potential problems are small since we use this 
		// matrix only to compute "normalDirection", 
		// which we normalize anyways

		/*float4 encodedNormal = tex2D(_BumpMap,
		_BumpMap_ST.xy * input.texcoord.xy + _BumpMap_ST.zw);
		float3 localCoords = float3(2.0 * encodedNormal.a - 1.0,
			2.0 * encodedNormal.g - 1.0, 0.0);
		localCoords.z = sqrt(1.0 - dot(localCoords, localCoords));
		

		// approximation without sqrt:  localCoords.z = 
		// 1.0 - 0.5 * dot(localCoords, localCoords);

		float3x3 local2WorldTranspose = float3x3(
			input.tangentWorld,
			input.binormalWorld,
			input.normalWorld);
		float3 normalDirection =
			normalize(mul(localCoords, local2WorldTranspose));*/

		float3 viewDirection = normalize(
			_WorldSpaceCameraPos - input.posWorld.xyz);
		float3 lightDirection;
		float attenuation;

		if (0.0 == _WorldSpaceLightPos0.w) // directional light?
		{
			attenuation = 1.0; // no attenuation
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		}
		else // point or spot light
		{
			float3 vertexToLightSource =
				_WorldSpaceLightPos0.xyz - input.posWorld.xyz;
			float distance = length(vertexToLightSource);
			attenuation = 1.0 / distance; // linear attenuation 
			lightDirection = normalize(vertexToLightSource);
		}

		// default: unlit 
		float3 fragmentColor = _UnlitColor.rgb;

		// Map texture to UV mapping with text2D function
		float4 texColor = tex2D(_MainTex, input.texcoord);

		// low priority: diffuse illumination
		if (attenuation
			* max(0.0, dot(normalDirection, lightDirection))
			>= _DiffuseThreshold)
		{
			fragmentColor = _LightColor0.rgb * _Color.rgb;
		}

		// higher priority: outline
		if (dot(viewDirection, normalDirection)
			< lerp(_UnlitOutlineThickness, _LitOutlineThickness,
				max(0.0, dot(normalDirection, lightDirection))))
		{
			fragmentColor = _LightColor0.rgb * _OutlineColor.rgb;
		}

		// highest priority: highlights
		if (dot(normalDirection, lightDirection) > 0.0
			// light source on the right side?
			&& attenuation *  pow(max(0.0, dot(
				reflect(-lightDirection, normalDirection),
				viewDirection)), _Shininess) > 0.5)
			// more than half highlight intensity? 
		{
			fragmentColor = _SpecColor.a
				* _LightColor0.rgb * _SpecColor.rgb
				+ (1.0 - _SpecColor.a) * fragmentColor;
		}
		return texColor * float4(fragmentColor, 1.0);
	}
		ENDCG
	}

		Pass{
		Tags{ "LightMode" = "ForwardAdd" }
		// pass for additional light sources
		Blend SrcAlpha OneMinusSrcAlpha
		// blend specular highlights over framebuffer

		CGPROGRAM

#pragma vertex vert  
#pragma fragment frag 

#include "UnityCG.cginc"
		uniform float4 _LightColor0;
	// color of light source (from "Lighting.cginc")

	// User-specified properties
	uniform float4 _Color;
	uniform float4 _UnlitColor;
	uniform float _DiffuseThreshold;
	uniform float4 _OutlineColor;
	uniform float _LitOutlineThickness;
	uniform float _UnlitOutlineThickness;
	uniform float4 _SpecColor;
	uniform float _Shininess;

	struct vertexInput {
		float4 vertex : POSITION;
		float3 normal : NORMAL;
	};
	struct vertexOutput {
		float4 pos : SV_POSITION;
		float4 posWorld : TEXCOORD0;
		float3 normalDir : TEXCOORD1;
	};

	vertexOutput vert(vertexInput input)
	{
		vertexOutput output;

		float4x4 modelMatrix = _Object2World;
		float4x4 modelMatrixInverse = _World2Object;

		output.posWorld = mul(modelMatrix, input.vertex);
		output.normalDir = normalize(
			mul(float4(input.normal, 0.0), modelMatrixInverse).rgb);
		output.pos = mul(UNITY_MATRIX_MVP, input.vertex);
	
		return output;
	}

	float4 frag(vertexOutput input) : COLOR
	{
		float3 normalDirection = normalize(input.normalDir);

		float3 viewDirection = normalize(
			_WorldSpaceCameraPos - input.posWorld.rgb);
		float3 lightDirection;
		float attenuation;

		if (0.0 == _WorldSpaceLightPos0.w) // directional light?
		{
			attenuation = 1.0; // no attenuation
			lightDirection = normalize(_WorldSpaceLightPos0.xyz);
		}
		else // point or spot light
		{
			float3 vertexToLightSource =
				_WorldSpaceLightPos0.xyz - input.posWorld.xyz;
			float distance = length(vertexToLightSource);
			attenuation = 1.0 / distance; // linear attenuation 
			lightDirection = normalize(vertexToLightSource);
		}

		float4 fragmentColor = float4(0.0, 0.0, 0.0, 0.0);

		if (dot(normalDirection, lightDirection) > 0.0
			// light source on the right side?
			&& attenuation *  pow(max(0.0, dot(
				reflect(-lightDirection, normalDirection),
				viewDirection)), _Shininess) > 0.5)
			// more than half highlight intensity? 
		{
			fragmentColor =
				float4(_LightColor0.rgb, 1.0) * _SpecColor;
		}

		return fragmentColor;
	}
		ENDCG
	}
	}
		Fallback "Specular"
}