Shader "gRally/Terrain v1"
{
	Properties
	{
		_MainTex("Albedo", 2D) = "white" {}
		_FakeNormal("Fake Normal", 2D) = "white" {}
		_SpecColor("Specular", Color) = (0.2, 0.2, 0.2)
		_Smoothness("Smoothness", Range(0, 1)) = 0

		[Toggle(USE_REFLECTIVITY_MAP)] _UseReflectMap("Use Reflect Map", Float) = 0.0

		[Toggle(USE_REFLECTIVITY_MAP_R)] _UseReflectMapR("Use Reflect MapR", Float) = 0.0
		[Toggle(USE_R_COLOR)] _UseR_Color("Use R color", Float) = 0.0
		_MainTexR("Albedo R", 2D) = "white" {}
		_FakeNormalR("Fake Normal R", 2D) = "white" {}
		_SpecColorR("Specular R", Color) = (0.2, 0.2, 0.2)
		_SmoothnessR("Smoothness R", Range(0, 1)) = 0

		[Toggle(USE_REFLECTIVITY_MAP_G)] _UseReflectMapG("Use Reflect MapG", Float) = 0.0
		[Toggle(USE_G_COLOR)] _UseG_Color("Use G color", Float) = 0.0
		_MainTexG("Albedo G", 2D) = "white" {}
		_FakeNormalG("Fake Normal R", 2D) = "white" {}
		_SpecColorG("Specular G", Color) = (0.2, 0.2, 0.2)
		_SmoothnessG("Smoothness G", Range(0, 1)) = 0

		[Toggle(USE_REFLECTIVITY_MAP_B)] _UseReflectMapB("Use Reflect MapB", Float) = 0.0
		[Toggle(USE_B_COLOR)] _UseB_Color("Use B color", Float) = 0.0
		_MainTexB("Albedo B", 2D) = "white" {}
		_FakeNormalB("Fake Normal R", 2D) = "white" {}
		_SpecColorB("Specular B", Color) = (0.2, 0.2, 0.2)
		_SmoothnessB("Smoothness B", Range(0, 1)) = 0

		[Toggle(USE_WET)] _UseWet("Use Wet", Float) = 0.0
		_WetInfluence("Wet Influence", Range(0,1)) = 1
		_WetDarkening("Wet Darkening", Range(0,1)) = 0.5
	}

	// SM3+
	SubShader
	{
		Tags{ "RenderType" = "Opaque" "Queue" = "Geometry+0"}
		//Offset -2, -2
		Cull Back

		CGPROGRAM
		#pragma surface surf StandardSpecular fullforwardshadows addshadow
		// until texCubeLOD is solved
		#pragma exclude_renderers gles
		#pragma target 5.0

		#pragma shader_feature USE_WET
        #pragma shader_feature USE_REFLECTIVITY_MAP

		#pragma shader_feature USE_R_COLOR
		#pragma shader_feature USE_REFLECTIVITY_MAP_R
		#pragma shader_feature USE_G_COLOR
		#pragma shader_feature USE_REFLECTIVITY_MAP_G
		#pragma shader_feature USE_B_COLOR
		#pragma shader_feature USE_REFLECTIVITY_MAP_B

		struct Input
		{
			float4 color : COLOR;
			float2 uv_MainTex;
			float2 uv_FakeNormal;
			float3 viewDir;
			float2 uv_MainTexR;
			float2 uv_FakeNormalR;
			float2 uv_MainTexG;
			float2 uv_FakeNormalG;
			float2 uv_MainTexB;
			float2 uv_FakeNormalB;
		};

		fixed _GR_WetSurf;

		sampler2D _MainTex;
		sampler2D _FakeNormal;

		fixed _Smoothness;

		// R
		sampler2D _MainTexR;
		sampler2D _FakeNormalR;
		fixed _SmoothnessR;
		fixed3 _SpecColorR;
		// G
		sampler2D _MainTexG;
		sampler2D _FakeNormalG;
		fixed _SmoothnessG;
		fixed3 _SpecColorG;
		// B
		sampler2D _MainTexB;
		sampler2D _FakeNormalB;
		fixed _SmoothnessB;
		fixed3 _SpecColorB;

		fixed _WetInfluence;
		fixed _WetDarkening;

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
			normal3.xy = normal4.xy * 2 - 1;
			normal3.z = sqrt(1 - (normal4.x * normal4.x) + (normal4.y * normal4.y));

			fixed4 albedoTmp;
			fixed3 specTmp;
			fixed smoothTmp;
			fixed3 normalTmp;
			
			// specular
			#if defined (USE_REFLECTIVITY_MAP)
				fixed specFromNormal = GammaToLinearSpaceExact(normal4.a);
				specTmp = fixed3(specFromNormal, specFromNormal, specFromNormal);
			#else
				specTmp = _SpecColor.rgb;
			#endif

			#if defined(USE_WET)
				smoothTmp = albedo1.a * ((_GR_WetSurf * _WetInfluence) + _Smoothness);
				fixed darkening = (1.0 - (_GR_WetSurf * _WetInfluence) * _WetDarkening * 2.0);
			#else
				smoothTmp = albedo1.a * _Smoothness;
				fixed darkening = 1.0;
			#endif

			albedoTmp = albedo1 * darkening;

			// normal
			#if defined(USE_WET)
				normalTmp = lerp(normal3, half3(0, 0, 1), albedo1.a * ((_GR_WetSurf * _WetInfluence) + _Smoothness));
			#else
				normalTmp = normal3;
			#endif

			#if defined (USE_R_COLOR)
				fixed4 albedoR = tex2D(_MainTexR, IN.uv_MainTexR);
				fixed4 normalR4 = tex2D(_FakeNormalR, IN.uv_FakeNormalR);
				fixed normalAlphaR = normalR4.w;
				fixed3 normalR3 = LinearToGammaSpace(normalR4.xyz);

				normalR4.y = normalR3.y;
				normalR4.x = normalR3.x;
				normalR3.xy = normalR4.xy * 2 - 1;
				normalR3.z = sqrt(1 - (normalR4.x * normalR4.x) + (normalR4.y * normalR4.y));

				// specular
				#if defined (USE_REFLECTIVITY_MAP_R)
					fixed specFromNormalR = GammaToLinearSpaceExact(normalR4.a);
					specTmp = lerp(specTmp, fixed3(specFromNormalR, specFromNormalR, specFromNormalR), IN.color.r);
				#else
					specTmp = lerp(specTmp, _SpecColorR.rgb, IN.color.r);
				#endif

				#if defined(USE_WET)
					smoothTmp = lerp(smoothTmp, albedoR.a * ((_GR_WetSurf * _WetInfluence) + _SmoothnessR), IN.color.r);
					fixed darkeningR = (1.0 - (_GR_WetSurf * _WetInfluence) * _WetDarkening * 2.0);
				#else
					smoothTmp = lerp(smoothTmp, albedoR.a * _SmoothnessR, IN.color.r);
					fixed darkeningR = 1.0;
				#endif
	
				albedoTmp = lerp(albedoTmp * darkeningR, albedoR, IN.color.r);

				#if defined(USE_WET)
					normalTmp = lerp(normalTmp, lerp(normalR3, half3(0, 0, 1), albedoR.a * ((_GR_WetSurf * _WetInfluence) + _SmoothnessR)), IN.color.r);
				#else
					normalTmp = lerp(normalTmp, normalR3, IN.color.r);
				#endif
			#endif

			#if defined (USE_G_COLOR)
				fixed4 albedoG = tex2D(_MainTexG, IN.uv_MainTexG);
				fixed4 normalG4 = tex2D(_FakeNormalG, IN.uv_FakeNormalG);
				fixed normalAlphaG = normalG4.w;
				fixed3 normalG3 = LinearToGammaSpace(normalG4.xyz);

				normalG4.y = normalG3.y;
				normalG4.x = normalG3.x;
				normalG3.xy = normalG4.xy * 2 - 1;
				normalG3.z = sqrt(1 - (normalG4.x * normalG4.x) + (normalG4.y * normalG4.y));

				// specular
				#if defined (USE_REFLECTIVITY_MAP_G)
					fixed specFromNormalG = GammaToLinearSpaceExact(normalG4.a);
					specTmp = lerp(specTmp, fixed3(specFromNormalG, specFromNormalG, specFromNormalG), IN.color.g);
				#else
					specTmp = lerp(specTmp, _SpecColorG.rgb, IN.color.g);
				#endif

				#if defined(USE_WET)
					smoothTmp = lerp(smoothTmp, albedoG.a * ((_GR_WetSurf * _WetInfluence) + _SmoothnessG), IN.color.g);
					fixed darkeningG = (1.0 - (_GR_WetSurf * _WetInfluence) * _WetDarkening * 2.0);
				#else
					smoothTmp = lerp(smoothTmp, albedoG.a * _SmoothnessG, IN.color.g);
					fixed darkeningG = 1.0;
				#endif

				albedoTmp = lerp(albedoTmp * darkeningG, albedoG, IN.color.g);

				#if defined(USE_WET)
					normalTmp = lerp(normalTmp, lerp(normalG3, half3(0, 0, 1), albedoG.a * ((_GR_WetSurf * _WetInfluence) + _SmoothnessG)), IN.color.g);
				#else
					normalTmp = lerp(normalTmp, normalG3, IN.color.g);
				#endif
			#endif

			#if defined (USE_B_COLOR)
				fixed4 albedoB = tex2D(_MainTexB, IN.uv_MainTexB);
				fixed4 normalB4 = tex2D(_FakeNormalB, IN.uv_FakeNormalB);
				fixed normalAlphaB = normalB4.w;
				fixed3 normalB3 = LinearToGammaSpace(normalB4.xyz);

				normalB4.y = normalB3.y;
				normalB4.x = normalB3.x;
				normalB3.xy = normalB4.xy * 2 - 1;
				normalB3.z = sqrt(1 - (normalB4.x * normalB4.x) + (normalB4.y * normalB4.y));

				// specular
				#if defined (USE_REFLECTIVITY_MAP_B)
					fixed specFromNormalB = GammaToLinearSpaceExact(normalB4.a);
					specTmp = lerp(specTmp, fixed3(specFromNormalB, specFromNormalB, specFromNormalB), IN.color.b);
				#else
					specTmp = lerp(specTmp, _SpecColorB.rgb, IN.color.b);
				#endif

				#if defined(USE_WET)
					smoothTmp = lerp(smoothTmp, albedoB.a * ((_GR_WetSurf * _WetInfluence) + _SmoothnessB), IN.color.b);
					fixed darkeningB = (1.0 - (_GR_WetSurf * _WetInfluence) * _WetDarkening * 2.0);
				#else
					smoothTmp = lerp(smoothTmp, albedoB.a * _SmoothnessB, IN.color.b);
					fixed darkeningB = 1.0;
				#endif

				albedoTmp = lerp(albedoTmp * darkeningB, albedoB, IN.color.b);

				#if defined(USE_WET)
					normalTmp = lerp(normalTmp, lerp(normalB3, half3(0, 0, 1), albedoB.a * ((_GR_WetSurf * _WetInfluence) + _SmoothnessB)), IN.color.b);
				#else
					normalTmp = lerp(normalTmp, normalB3, IN.color.b);
				#endif
			#endif

			o.Albedo = albedoTmp;
			o.Specular = specTmp;
			o.Normal = normalTmp;
			o.Smoothness = smoothTmp;
		}
		ENDCG
	}

	CustomEditor "grs_Terrainv1GUI"
}
