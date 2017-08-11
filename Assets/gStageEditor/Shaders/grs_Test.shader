Shader "gRally/Test" {
	Properties {
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_SpecularColor("Specular", Color) = (0.2,0.2,0.2)
		_NormalBumpTex("Normal Bump", 2D) = "bump" {}
	}
	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200
		
		CGPROGRAM
		// Physically based Standard lighting model, and enable shadows on all light types
		#pragma surface surf StandardSpecular fullforwardshadows

		// Use shader model 3.0 target, to get nicer looking lighting
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _NormalBumpTex;

		struct Input {
			float2 uv_MainTex;
			float2 uv_NormalBumpTex;
		};

		half _Glossiness;
		fixed3 _SpecularColor;
		fixed4 _Color;

		void surf (Input IN, inout SurfaceOutputStandardSpecular o) {
			// Albedo comes from a texture tinted by color
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed3 n_tmp = LinearToGammaSpace(tex2D(_NormalBumpTex, IN.uv_NormalBumpTex).xyz);

			o.Albedo = c.rgb;
			// Specular from specular color
			o.Specular = _SpecularColor;
			// Smoothness come from slider variable
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
			
			fixed4 n;
			//n.x = n_tmp.y;
			n.y = n_tmp.y;
			//n.z = n_tmp.y;
			n.w = n_tmp.x;

			fixed3 normal;
			//n.w = -n.b;
			//#if defined(UNITY_NO_DXT5nm)
			//	normal = n.xyz * 2 - 1;
			//#else
				normal.xy = n.wy * 2 - 1;
				normal.z = sqrt(1 - saturate(dot(normal.xy, normal.xy)));
			//#endif
			//o.Normal = half3(0, 0, 1);
			o.Normal = normal;
			
			//o.Normal = n.xyz * 2 - 1;
			//o.Normal = UnpackNormal(n);
			
			//o.Albedo.r = n.r;
			//o.Albedo.g = n.g;
			//o.Albedo.b = n.b;
			
		}
		ENDCG
	}
	FallBack "Diffuse"
}
