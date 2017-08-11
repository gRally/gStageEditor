Shader "gRally/Cutout/grs_D_T_up"
{
	Properties
	{
		_Color("Main Color", Color) = (1, 1, 1, 1)
		//_SpecColor("Specular Color", Color) = (0.33, 0.33, 0.33, 1)
		_MainTex("Albedo", 2D) = "white" {}
		_Cutoff("Alpha cutoff", Range(0, 1)) = 0.5
	}

	SubShader
		{
			//Offset -1,-1   //THIS IS THE ADDED LINE
			Tags{ "Queue" = "AlphaTest" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout"}
			LOD 300

			CGPROGRAM
#pragma surface surf BlinnPhong alphatest:_Cutoff vertex:vert
#pragma target 3.0
			sampler2D _MainTex;
			half _MainTexID;
			fixed4 _Color;
			half _Gloss;

			struct Input
			{
				float2 main1;
			};

			struct myAppdata
			{
				float4 vertex    	: POSITION;  // The vertex position in model space.
				float3 normal       : NORMAL;    // The vertex normal in model space.
				float4 texcoord		: TEXCOORD0; // The first UV coordinate.
				float4 texcoord1	: TEXCOORD1; // The second UV coordinate.
				float4 texcoord2	: TEXCOORD2;
				float4 texcoord3	: TEXCOORD3;
				float4 tangent		: TANGENT;   // The tangent vector in Model Space (used for normal mapping).
			};

			void vert(inout myAppdata v, out Input o)
			{
				// appdata_full
				UNITY_INITIALIZE_OUTPUT(Input, o);

				// main1
				o.main1 = v.texcoord.xy;
				if (_MainTexID == 1) 		o.main1 = v.texcoord1.xy;
				else if (_MainTexID == 2)	o.main1 = v.texcoord2.xy;
				else if (_MainTexID == 3)	o.main1 = v.texcoord3.xy;

				// normali su
				float3 vn = v.normal;
				vn.x = 0.0f;
				vn.y = 0.0f;
				vn.z = 1.0f;
				v.normal = vn;
			}

			void surf(Input IN, inout SurfaceOutput o)
			{
				// diffuse color
				fixed4 c = tex2D(_MainTex, IN.main1) * _Color;
				o.Albedo = c.rgb;
				// alpha for transparencies
				o.Alpha = c.a * _Color.a;
				// specular power in 0..1 range
				o.Specular = 0.0f;
				// specular intensity
				o.Gloss = 0.0f;
			}
			ENDCG
		}

		FallBack "Legacy Shaders/Transparent/Cutout/Diffuse"
}
