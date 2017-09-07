Shader "gRally/Phys Road v1"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_FakeNormal("Fake Normal", 2D) = "white" {}
		//_NormalMap("NormalMap", 2D) = "bump" {}

		[Toggle(USE_REFLECTIVITY_MAP)] _UseReflectMap("Use Reflect Map", Float) = 0.0
		_SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
		_Smoothness("Smoothness", Range(0, 1)) = 0
		
		[Toggle(USE_GROOVE)] _UseGroove("Use Groove", Float) = 0.0
		_GrooveTex("GrooveTex", 2D) = "white" {}

		_PhysMap("PhysMap", 2D) = "white" {}
		_PhysDebug("Debug Phys", Range(0, 1)) = 0
		[Toggle(USE_WET)] _UseWet("Use Wet", Float) = 0.0

		_WetInfluence("Wet Influence", Range(0,1)) = 1
		_WetDarkening("Wet Darkening", Range(0,1)) = 0.5

		[HideInInspector] _Mode ("__mode", Float) = 0.0
		[HideInInspector] _TransparentMode ("__transparentMode", Float) = 0.0
		_Cutoff("Cutoff" , Range(0,1)) = 0.25

		_TransparentTex("TransparentTex", 2D) = "white" {}
	}

	// SM3+
	SubShader
	{
		Tags { "RenderType"="Opaque" } 
	 	Offset -3, -3
		//"Queue"="AlphaTest" "IgnoreProjector"="True" }
		//blend SrcAlpha OneMinusSrcAlpha
               
		//ZWrite Off

		CGPROGRAM
		#pragma surface surf StandardSpecular alphatest:_Cutoff fullforwardshadows addshadow

		#pragma exclude_renderers gles
		#pragma target 3.0

		#pragma shader_feature USE_GROOVE
		#pragma shader_feature USE_WET
        #pragma shader_feature USE_REFLECTIVITY_MAP
		// NOTE: bool property
		#pragma shader_feature USE_TRANSPARENT_VERTEX
		#pragma shader_feature USE_TRANSPARENT_TEXTURE

		struct Input
		{
			float4 color : COLOR;
			float2 uv_MainTex;
			float2 uv_FakeNormal;
			float3 viewDir;
		};

		fixed _GR_Groove;
		fixed _GR_WetSurf;
		fixed _GR_PhysDebug;

		sampler2D _MainTex;
		sampler2D _FakeNormal;
		
		fixed _Smoothness;

		sampler2D _GrooveTex;
		sampler2D _PhysMap;

		fixed _WetInfluence;
		fixed _WetDarkening;

		#if defined(USE_TRANSPARENT_TEXTURE)
			sampler2D _TransparentTex;
		#endif

		// https://docs.unity3d.com/Manual/SL-SurfaceShaders.html
		// https://docs.unity3d.com/Manual/SL-ShaderPerformance.html
		void surf(Input IN, inout SurfaceOutputStandardSpecular o)
		{
			// tex
			fixed4 albedo1 = tex2D(_MainTex, IN.uv_MainTex);
			fixed4 normal4 = tex2D(_FakeNormal, IN.uv_FakeNormal);
			fixed normalAlpha = normal4.w;
			fixed3 normal3 = LinearToGammaSpace(normal4.xyz);

			normal4.y = normal3.y;
			normal4.x = normal3.x;
			normal3.xy = normal4.xy * 2.0f - 1.0f;
			normal3.z = sqrt(1.0f - (normal4.x * normal4.x) + (normal4.y * normal4.y));

			// physics debug
			if (_GR_PhysDebug > 0.0f)
			{
				fixed4 albedoPhys = tex2D(_PhysMap, IN.uv_MainTex);
				albedo1 = lerp(albedo1, albedoPhys, _GR_PhysDebug);
			}

			// specular
			#if defined (USE_REFLECTIVITY_MAP)
				fixed specFromNormal = GammaToLinearSpaceExact(normal4.w);
				o.Specular = fixed3(specFromNormal, specFromNormal, specFromNormal);
				//fixed4 specFromNormal = tex2D(GammaToLinearSpaceExact(normal4.a), IN.uv_MainTex) ;
				//o.Specular = specFromNormal.rgb;
			#else
				o.Specular = _SpecColor.rgb;
			#endif

			#if defined(USE_WET)
				o.Smoothness = albedo1.a * ((_GR_WetSurf * _WetInfluence) + _Smoothness);
				fixed darkening = (1.0f - (_GR_WetSurf * _WetInfluence) * _WetDarkening * 2.0f);
			#else
				o.Smoothness = albedo1.a * _Smoothness;
				fixed darkening = 1.0f;
			#endif

			#if defined(USE_GROOVE)
				if (_GR_Groove > 0.0f)
				{
					fixed grooveMult = IN.color.b * _GR_Groove * 2.0f;
					fixed4 groove = tex2D(_GrooveTex, IN.uv_MainTex);
					o.Albedo = lerp(albedo1, albedo1 * groove, grooveMult) * darkening;
					o.Smoothness = o.Smoothness - (groove.a * grooveMult);
				}
				else
				{
					o.Albedo = albedo1 * darkening;
				}
			#else
				o.Albedo = albedo1 * darkening;
			#endif

			// normal
			#if defined(USE_WET)
				o.Normal = lerp(normal3, half3(0.0f, 0.0f, 1.0f), albedo1.a * ((_GR_WetSurf * _WetInfluence) + _Smoothness));
			#else
				o.Normal = normal3;
			#endif
			
			#if defined(USE_TRANSPARENT_VERTEX)
				o.Alpha = IN.color.a;
			#endif

			#if defined(USE_TRANSPARENT_TEXTURE)
				fixed4 transparent = tex2D(_TransparentTex, IN.uv_MainTex);
				o.Alpha = transparent.a;
			#endif

			#if !defined(USE_TRANSPARENT_VERTEX) && !defined(USE_TRANSPARENT_TEXTURE)
				o.Alpha = 1.0f;
			#endif
		}
		ENDCG
	}

	CustomEditor "grs_PhysRoadv1GUI"
}
