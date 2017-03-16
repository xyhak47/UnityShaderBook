Shader "Unity Shaders Book/Chapter 12/Motion Blur With Depth Texture"
{
	Properties
	{
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_BlurSize("Blur Size", Float) = 1.0
		_SampleAmount("Sample Amount", Int) = 3
	}

	SubShader
	{
		CGINCLUDE

		#include "UnityCG.cginc"

		//This file is automatically included when compiling shaders. 
		//It declares various preprocessor macros to aid in multi-platform shader development.
		//#include "HLSLSupport.cginc"  

		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		sampler2D _CameraDepthTexture;
		float4x4 _CurrentViewProjectionInverseMatrix;
		float4x4 _PreviousViewProjectionMatrix;
		half _BlurSize;
		int _SampleAmount;

		struct v2f
		{
			float4 pos : POSITION;
			half2 uv : TEXCOORD0;
			half2 uv_depth : TEXCOORD1;
		};

		v2f vert(appdata_img v)
		{
			v2f o;
			o.pos = mul(UNITY_MATRIX_MVP, v.vertex);
			o.uv = v.texcoord;
			o.uv_depth = v.texcoord;

			#if UNITY_UV_STARTS_AT_TOP
			if(_MainTex_TexelSize.y < 0)
				o.uv_depth.y = 1- o.uv_depth.y;
			#endif

			return o;
		}

		fixed4 frag(v2f i) : SV_Target
		{
			//get the depth buffer value at this pixel
			float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
			// H is the viewport position at this pixel in the range -1 to 1
			float4 H = float4(i.uv.x * 2 - 1, i.uv.y * 2 - 1, d * 2 - 1, 1);
			// transform by the view-projection inverse
			float4 D = mul(_CurrentViewProjectionInverseMatrix, H);
			// divide by w to get the world position
			float4 worldPos = D/D.w;

			// current viewport postion
			float4 currentPos = H;
			// use the world postion, and transform by the previous view-projection matrix
			float4 previousPos = mul(_PreviousViewProjectionMatrix, worldPos);
			// convert to nonhomogeneous points [-1,1] by dividing by w
			previousPos /= previousPos.w;

			// use this frame's position and last frame's to compute the pixel velocity
			float2 velocity = (currentPos.xy - previousPos.xy)/2.0f;

			float2 uv = i.uv;
			float4 c = tex2D(_MainTex, uv);
			uv += velocity * _BlurSize;
			for(int it = 1; it < _SampleAmount; it++, uv += velocity * _BlurSize)
			{
				float4 currentColor = tex2D(_MainTex, uv);
				c += currentColor;
			}
			c /= _SampleAmount;

			return fixed4(c.rgb, 1.0);
		}
		ENDCG


		ZTest Always Cull Off ZWrite Off

		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			ENDCG
		}
	}


	FallBack Off
}
