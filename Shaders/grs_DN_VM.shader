Shader "gRally/grs_DN_VM"
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
		
		_MainTexBlend ("Albedo Blend", 2D) = "white" {}
		[Enum(UV0,0,UV1,1,UV2,2,UV3,3)] _MainTexBlendID ("Albedo Blend UV", Float) = 0
		_BumpMapBlend ("Normal Blend Map", 2D) = "bump" {}
		[Enum(UV0,0,UV1,1,UV2,2,UV3,3)] _BumpMapBlendID ("Normal Blend Map UV", Float) = 0
		
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
		sampler2D _MainTexBlend;
		float _MainBlendID;
		sampler2D _BumpMapBlend;
		float _BumpBlendID;
				
		fixed4 _Color;
		half _Shininess;
		
		struct Input
		{
			fixed4 vColor;
			float2 main1;
			float2 main2;
			float2 bump1;
			float2 bump2;
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
			float4 color     	: COLOR;     // Per-vertex color  
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

            // main2
            o.main2 = v.texcoord.xy;
            if(_MainBlendID == 1) 		o.main2 = v.texcoord1.xy;
            else if(_MainBlendID == 2)	o.main2 = v.texcoord2.xy;
            else if(_MainBlendID == 3)	o.main2 = v.texcoord3.xy;
            
			// bump1
			o.bump1 = v.texcoord.xy;
			if(_BumpMapID == 1) 		o.bump1 = v.texcoord1.xy;
			else if(_BumpMapID == 2)	o.bump1 = v.texcoord2.xy;
			else if(_BumpMapID == 3)	o.bump1 = v.texcoord3.xy;
			
            // bump2
            o.bump2 = v.texcoord.xy;
            if(_BumpBlendID == 1) 		o.bump2 = v.texcoord1.xy;
            else if(_BumpBlendID == 2)	o.bump2 = v.texcoord2.xy;
            else if(_BumpBlendID == 3)	o.bump2 = v.texcoord3.xy;
                        
            o.vColor = v.color;			
		}

		void surf (Input IN, inout SurfaceOutput o)
		{
			// diffuse color
			fixed4 cW = tex2D(_MainTex, IN.main1) * IN.vColor.r;
			fixed4 cB = tex2D(_MainTexBlend, IN.main2) * (1 - IN.vColor.r);
			fixed4 c = (cW + cB) * _Color;
			o.Albedo = c.rgb;
			// specular power in 0..1 range
			o.Specular = _Shininess;
			// specular intensity
			o.Gloss = 0.5;
			// tangent space normal, if written
			o.Normal = (UnpackNormal(tex2D(_BumpMap, IN.bump1)) * IN.vColor.r) + (UnpackNormal(tex2D(_BumpMapBlend, IN.bump2)) * (1 - IN.vColor.r));
		}
		ENDCG
	}

	FallBack "Legacy Shaders/Diffuse"
}


