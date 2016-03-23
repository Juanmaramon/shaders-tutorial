Shader ".ShaderLearning/Others/FaceOrientation"
{
	// VFACE tell us where triangles are facing the camera or not

    Properties
    {
        _ColorFront ("Front Color", Color) = (1, 0.7, 0.7, 1)
        _ColorBack ("Back Color", Color) = (0.7, 1, 0.7, 1)
    }

    SubShader
    {
		// Several pass can be done
		Pass
		{
			Cull Off // turn off backface culling

			// CG code starts with this tag
			CGPROGRAM
			// vertex function = vert
			#pragma vertex vert
			// fragment function = vert
			#pragma fragment frag
			// This feature starts at shader model 3.0
			#pragma target 3.0

			float4 vert (float4 vertex : POSITION) : SV_POSITION
            {
                return mul(UNITY_MATRIX_MVP, vertex);
            }

            fixed4 _ColorFront;
            fixed4 _ColorBack;

            fixed4 frag (fixed facing : VFACE) : SV_Target
            {
                // VFACE input positive for frontbaces,
                // negative for backfaces. Output one
                // of the two colors depending on that.
                return facing > 0 ? _ColorFront : _ColorBack;
            }

			// BG program ends
			ENDCG
		}
    }

	// Fallback shader if no one subshader is supported by graphics cards
	FallBack "Diffuse"
}
