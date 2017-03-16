﻿Shader "Unity Shaders Book/Chapter 5/Simple Shader"
{
	Properties
	{
		_Color("Color Tint", Color) = (1.0, 1.0, 1.0, 1.0)	// 声明一个Color类型的属性
	}


	SubShader
	{
		Pass
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag

			fixed4 _Color;  // 在Cg代码中，我们需要电镀工艺一个与属性名称和类型都匹配的变量

			struct a2v
			{
				float4 vertex : POSITION; 	// POSITION 语义告诉unity，用模型空间的顶点坐标填充vertex变量
				float3 normal : NORMAL;		// NORMAL 语义告诉unity，用模型空间的法线方向填充normal变量
				float4 texcoord : TEXCOORD0; // TEXCOORD0 语义告诉unity，用模型的第一套纹理坐标填充texcoord变量
			};

			struct v2f	// 使用一个结构体来定义顶点着色器的输出
			{
				float4 pos : SV_POSITION; // SV_POSITION 语义告诉unity，pos里包含了顶点在裁剪空间中的位置信息
				fixed3 color : COLOR0;		// COLOR0 用于存储颜色信息
			};


			v2f vert(a2v v)
			{
				v2f o; // 声明输出结构
				o.pos = mul(UNITY_MATRIX_MVP, v.vertex);

				//v.normal 包含了顶点的法线方向，其分量范围在[-1.0, 1.0]
				// 下面的代码吧分量范围映射到了[0.0, 1.0],存储到o.color中传递给片元着色器
				o.color = v.normal * 0.5 + fixed3(0.5, 0.5, 0.5);
				return o;

				//return mul(UNITY_MATRIX_MVP, v.vertex); // 使用v.vertex来访问模型空间的顶点坐标
			}

			fixed4 frag(v2f i) : SV_Target
			{
				//return fixed4(1.0, 1.0, 1.0, 1.0);
				//return fixed4(i.color, 1.0); // 将插值后的i.color现实到屏幕上

				fixed3 c = i.color;
				c *= _Color.rgb; 		// 使用_Color属性来控制输出的颜色
				return fixed4(c, 1.0);
			}

			ENDCG
		}
	}
}