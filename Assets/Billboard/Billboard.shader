﻿// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'

Shader "Unity Shaders Book/Chapter 11/Billboard" 
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_VerticalBillboard("Vertical Billboard", Range(0,1)) = 1
	}

	SubShader
	{
		// Need to disable batching because of the vertex animation
		Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent" "DisableBatching"="True"}
		
		Pass
		{
			Tags { "LightMode"="ForwardBase" }

			ZWrite Off
			Blend SrcAlpha OneMinusSrcAlpha
			Cull Off
		

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			
			#include "UnityCG.cginc"

			struct a2v
			{
				float4 vertex : POSITION;
				float4 texcoord : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 pos : SV_POSITION;
			};

			sampler2D _MainTex;
			float4 _MainTex_ST;
			fixed4 _Color;
			fixed _VerticalBillboard;
			
			v2f vert (a2v v)
			{
				v2f o;
				// suppose the center in object space is fixed
				float3 center = float3(0.0,0.0,0.0);
				float3 viewer = mul(unity_WorldToObject, float4(_WorldSpaceCameraPos, 1));

				float3 normalDir = viewer - center;
				// if _VerticalBillboard = 1, we use the desired view dir as the normal dir which means the normal dir is fixed
				// or if _VerticalBillboard = 0, the y if normal is 0, which means the up dir is fixed
				normalDir.y = normalDir.y * _VerticalBillboard;
				normalDir = normalize(normalDir);

				// get the approximate up dir
				// if normal dir is already towards up, then the up dir is towards front
				float3 upDir = abs(normalDir.y) > 0.999 ? float3(0,0,1) : float3(0,1,0);
				float3 rightDir = normalize(cross(upDir, normalDir));
				upDir = normalize(cross(normalDir, rightDir));

				float3 centerOffs = v.vertex.xyz - center;
				float3 localPos = center + rightDir * centerOffs.x + upDir * centerOffs.y + normalDir * centerOffs.z;

				o.pos = mul(UNITY_MATRIX_MVP, float4(localPos, 1));
				o.uv = TRANSFORM_TEX(v.texcoord,_MainTex);

				return o;

			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 c = tex2D(_MainTex, i.uv);
				c.rgb *= _Color.rgb;

				return c;
			}
			ENDCG
		}
	}

	FallBack "Transparent/VertexLit"
}
