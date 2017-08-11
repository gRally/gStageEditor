Shader "gRally/grs_DNS"
{
	Properties
	{
		_Color ("Main Color", Color) = (1,1,1,1)
		_SpecColor ("Specular Color", Color) = (0.33, 0.33, 0.33, 1)
		_Shininess ("Shininess", Range (0.03, 1)) = 0.078125

		_MainTex ("Albedo", 2D) = "white" {}
		[Enum(UV0,0,UV1,1,UV2,2,UV3,3)] _MainTexID ("Albedo UV", Float) = 0
		_BumpMap ("Normal Map", 2D) = "bump" {}
		[Enum(UV0,0,UV1,1,UV2,2,UV3,3)] _BumpMapID ("Normal Map UV", Float) = 0
		_SpecTex ("Specular", 2D) = "gray" {}
		[Enum(UV0,0,UV1,1,UV2,2,UV3,3)] _SpecTexID ("Specular UV", Float) = 0
	}

	SubShader
	{
		Tags {"RenderType"="Opaque"}
		LOD 300
		
		CGPROGRAM
		#pragma surface surf BlinnPhong vertex:vert
		#pragma target 3.0
		
		sampler2D _MainTex;
		half _MainTexID;
		sampler2D _BumpMap;
		half _BumpMapID;
		sampler2D _SpecTex;
		half _SpecTexID;		
		fixed4 _Color;
		half _Shininess;
		
		struct Input
		{
			float2 main1;
			float2 bump1;
			float2 spec1;
		};

		struct myAppdata
		{
			float4 vertex    	: POSITION;  // The vertex position in model space.
			float3 normal			: NORMAL;    // The vertex normal in model space.
			float4 texcoord		: TEXCOORD0; // The first UV coordinate.
			float4 texcoord1	: TEXCOORD1; // The second UV coordinate.
			float4 texcoord2	: TEXCOORD2;
			float4 texcoord3	: TEXCOORD3;
			float4 tangent		: TANGENT;   // The tangent vector in Model Space (used for normal mapping).
		};

		void vert (inout myAppdata v, out Input o)
		{
			// appdata_full
			UNITY_INITIALIZE_OUTPUT(Input, o);

			// main1
			o.main1 = v.texcoord.xy;
			if(_MainTexID == 1) 		o.main1 = v.texcoord1.xy;
			else if(_MainTexID == 2)	o.main1 = v.texcoord2.xy;
			else if(_MainTexID == 3)	o.main1 = v.texcoord3.xy;

			// bump1
			o.bump1 = v.texcoord.xy;
			if(_BumpMapID == 1) 		o.bump1 = v.texcoord1.xy;
			else if(_BumpMapID == 2)	o.bump1 = v.texcoord2.xy;
			else if(_BumpMapID == 3)	o.bump1 = v.texcoord3.xy;
			
			// spec1
			o.spec1 = v.texcoord.xy;
			if(_SpecTexID == 1) 		o.spec1 = v.texcoord1.xy;
			else if(_SpecTexID == 2)	o.spec1 = v.texcoord2.xy;
			else if(_SpecTexID == 3)	o.spec1 = v.texcoord3.xy;			
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			// diffuse color
			fixed4 c = tex2D(_MainTex, IN.main1) * _Color;
			o.Albedo = c.rgb;
			// specular power in 0..1 range
			o.Specular = _Shininess;
			// specular intensity
			fixed4 s = tex2D(_SpecTex, IN.spec1) * _SpecColor;
			o.Gloss = s.r;
			// tangent space normal, if written
			o.Normal = UnpackNormal(tex2D(_BumpMap, IN.bump1));
		}
		ENDCG
	}

	FallBack "Legacy Shaders/Diffuse"
}