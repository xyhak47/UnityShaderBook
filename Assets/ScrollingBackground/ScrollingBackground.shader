Shader "Unity Shaders Book/Chapter 11/Scrolling Background"
{
	Properties
	{
		_MainTex ("base layer", 2D) = "white" {}
		_DetainTex("2nd layer", 2D) = "white" {}
		_ScrollX("base layer scroll speed", Float) = 1.0
		_Scroll2X("2nd layer scroll speed", Float) = 1.0
		_Muiliplier("layer Muiliplier", Float) = 1.0
	}

	SubShader
	{
		Tags { "RenderType"="Opaque" }

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float4 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _DetainTex;
			float4 _DetainTex_ST;
			float _ScrollX;
			float _Scroll2X;
			float _Muiliplier;

			v2f vert (a2v v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);

				// frac - returns the fractional portion of a scalar or each vector component.
				o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex) + frac(float2(_ScrollX, 0.0) * _Time.y); // 
				o.uv.zw = TRANSFORM_TEX(v.texcoord, _DetainTex) + frac(float2(_Scroll2X, 0.0) * _Time.y);;
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 firstLayer = tex2D(_MainTex, i.uv.xy);
				fixed4 secondLayer = tex2D(_DetainTex, i.uv.zw);

				fixed4 c = lerp(firstLayer, secondLayer, secondLayer.a);
				c.rgb *= _Muiliplier;

				return c;
			}

			ENDCG
		}
	}

	Fallback "Disffuse"
}
