// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Phys Road v2"
{
	Properties
	{
		[NoScaleOffset]_AlbedowithSmoothnessMap("Albedo (with Smoothness Map)", 2D) = "black" {}
		_AlbedoColorVariations("Albedo Color Variations", Color) = (1,1,1,1)
		[NoScaleOffset]_Normalmap("Normal map", 2D) = "bump" {}
		[NoScaleOffset]_RSpecGTransparencyBAOAWetMap("(R)Spec-(G)Transparency-(B)AO -(A)WetMap", 2D) = "white" {}
		_TilingMainTextures("Tiling Main Textures", Vector) = (1,1,0,0)
		_OffsetMainTextures("Offset Main Textures", Vector) = (0,0,0,0)
		_UVMultipliers("Tiling Multipliers for far texture", Vector) = (1,0.2,0,0)
		_TransitionDistance("Transition Distance (in meters)", Range( 1 , 150)) = 30
		_TransitionFalloff("Transition Falloff", Float) = 6
		_Cutoff( "Mask Clip Value", Float ) = -0.46
		_MaxDisplacementmeters("Max Displacement (meters)", Range( -1 , 0)) = 0
		[Toggle]_UseGrooveTex("Use Groove Tex", Float) = 1
		[NoScaleOffset]_GrooveMap("GrooveMap", 2D) = "white" {}
		[Toggle]_UsePuddlesTexture("Use Puddles Texture", Float) = 1
		[NoScaleOffset]_PuddlesTexture("Puddles Texture", 2D) = "black" {}
		_PuddlesSize("Puddles Size", Float) = 0
		[NoScaleOffset][Space(20)][Header(Physical Texture. Remember to set the texture as ReadWrite Enabled)]_PhysicalTexture("Physical Texture", 2D) = "white" {}
		_procOctaves("(proc) octaves", Int) = 0
		_procPersistance("(proc) persistance", Range( 0 , 1)) = 0
		_procLacunarity("(proc) lacunarity", Float) = 0
		_procScale("(proc) scale", Float) = 0
		_procHeightMultiplier("(proc) heightMultiplier", Float) = 0
		_procUsedForPatch("(proc) usedForPatch", Int) = 0
		_procSideNoise("(proc) sideNoise", Range( 0 , 3)) = 0
		_procSideNoiseDilatation("(proc) sideNoiseDilatation", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] _texcoord2( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 4.6
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
			float2 uv2_texcoord2;
		};

		uniform int _procOctaves;
		uniform float _procSideNoise;
		uniform float _procHeightMultiplier;
		uniform float _procSideNoiseDilatation;
		uniform int _procUsedForPatch;
		uniform float _procPersistance;
		uniform float _procScale;
		uniform float _procLacunarity;
		uniform float _MaxDisplacementmeters;
		uniform float _GR_Displacement;
		uniform sampler2D _RSpecGTransparencyBAOAWetMap;
		uniform float2 _TilingMainTextures;
		uniform float2 _OffsetMainTextures;
		uniform float2 _UVMultipliers;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform float _UsePuddlesTexture;
		uniform float _GR_WetSurf;
		uniform sampler2D _PuddlesTexture;
		uniform float _PuddlesSize;
		uniform sampler2D _Normalmap;
		uniform sampler2D _PhysicalTexture;
		uniform float4 _AlbedoColorVariations;
		uniform sampler2D _AlbedowithSmoothnessMap;
		uniform float _UseGrooveTex;
		uniform sampler2D _GrooveMap;
		uniform float _GR_Groove;
		uniform float _GR_PhysDebug;
		uniform float _Cutoff = -0.46;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( v.color.b * ase_vertexNormal * _MaxDisplacementmeters * _GR_Displacement );
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_TexCoord138 = i.uv_texcoord * _TilingMainTextures + _OffsetMainTextures;
			float2 UV_Texture212 = uv_TexCoord138;
			float4 tex2DNode3 = tex2D( _RSpecGTransparencyBAOAWetMap, UV_Texture212 );
			float2 UV_Texture_Tiling_Mult215 = ( uv_TexCoord138 * _UVMultipliers );
			float4 tex2DNode146 = tex2D( _RSpecGTransparencyBAOAWetMap, UV_Texture_Tiling_Mult215 );
			float3 ase_worldPos = i.worldPos;
			float clampResult142 = clamp( pow( ( distance( _WorldSpaceCameraPos , ase_worldPos ) / _TransitionDistance ) , _TransitionFalloff ) , 0.0 , 1.0 );
			float Transition210 = clampResult142;
			float lerpResult150 = lerp( tex2DNode3.a , tex2DNode146.a , Transition210);
			float WetSurf219 = _GR_WetSurf;
			float clampResult227 = clamp( ( ( 1.0 - WetSurf219 ) + 0.2 ) , 0.0 , 1.0 );
			float2 appendResult172 = (float2(ase_worldPos.x , ase_worldPos.z));
			float4 tex2DNode178 = tex2D( _PuddlesTexture, ( appendResult172 / _PuddlesSize ) );
			float temp_output_174_0 = step( frac( ( ( ase_worldPos.x / _PuddlesSize ) * 0.5 ) ) , 0.5 );
			float temp_output_173_0 = step( frac( ( ( ase_worldPos.z / _PuddlesSize ) * 0.5 ) ) , 0.5 );
			float smoothstepResult221 = smoothstep( clampResult227 , 1.01 , ( tex2DNode178.r * ( temp_output_174_0 * temp_output_173_0 ) ));
			float temp_output_176_0 = ( 1.0 - temp_output_173_0 );
			float smoothstepResult222 = smoothstep( clampResult227 , 1.01 , ( tex2DNode178.g * ( temp_output_174_0 * temp_output_176_0 ) ));
			float temp_output_177_0 = ( 1.0 - temp_output_174_0 );
			float smoothstepResult223 = smoothstep( clampResult227 , 1.01 , ( tex2DNode178.b * ( temp_output_177_0 * temp_output_173_0 ) ));
			float smoothstepResult224 = smoothstep( clampResult227 , 1.01 , ( tex2DNode178.a * ( temp_output_177_0 * temp_output_176_0 ) ));
			float4 appendResult237 = (float4(smoothstepResult221 , smoothstepResult222 , smoothstepResult223 , smoothstepResult224));
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float simplePerlin2D291 = snoise( i.uv_texcoord*20.0 );
			simplePerlin2D291 = simplePerlin2D291*0.5 + 0.5;
			float Slope_Mixer279 = saturate( ( pow( ase_normWorldNormal.y , 1500.0 ) * 53.0 * simplePerlin2D291 ) );
			float4 break240 = ( (( _UsePuddlesTexture )?( appendResult237 ):( float4(0,0,0,0) )) * Slope_Mixer279 );
			float temp_output_234_0 = ( i.vertexColor.b * _GR_Displacement );
			float clampResult201 = clamp( ( lerpResult150 + break240.x + break240.y + break240.z + break240.w + temp_output_234_0 ) , 0.0 , 1.0 );
			float temp_output_206_0 = ( clampResult201 * _GR_WetSurf );
			float temp_output_81_0 = ( 1.0 - saturate( temp_output_206_0 ) );
			float lerpResult208 = lerp( temp_output_81_0 , 0.0 , Transition210);
			float lerpResult209 = lerp( 0.0 , temp_output_81_0 , Transition210);
			o.Normal = BlendNormals( UnpackScaleNormal( tex2D( _Normalmap, UV_Texture212 ), lerpResult208 ) , UnpackScaleNormal( tex2D( _Normalmap, UV_Texture_Tiling_Mult215 ), lerpResult209 ) );
			float2 uv_PhysicalTexture71 = i.uv_texcoord;
			float4 tex2DNode1 = tex2D( _AlbedowithSmoothnessMap, UV_Texture212 );
			float4 tex2DNode144 = tex2D( _AlbedowithSmoothnessMap, UV_Texture_Tiling_Mult215 );
			float4 lerpResult145 = lerp( tex2DNode1 , tex2DNode144 , Transition210);
			float4 temp_output_243_0 = ( _AlbedoColorVariations * lerpResult145 );
			float2 uv2_GrooveMap55 = i.uv2_texcoord2;
			float4 lerpResult56 = lerp( temp_output_243_0 , ( (( _UseGrooveTex )?( tex2D( _GrooveMap, uv2_GrooveMap55 ) ):( float4(1,1,1,1) )) * temp_output_243_0 ) , ( _GR_Groove * i.vertexColor.g ));
			float clampResult90 = clamp( ( 1.0 - _GR_WetSurf ) , 0.68 , 1.0 );
			float4 lerpResult83 = lerp( tex2D( _PhysicalTexture, uv_PhysicalTexture71 ) , ( lerpResult56 * clampResult90 ) , ( 1.0 - _GR_PhysDebug ));
			o.Albedo = lerpResult83.rgb;
			float lerpResult147 = lerp( tex2DNode3.r , tex2DNode146.r , Transition210);
			float clampResult47 = clamp( ( lerpResult147 + temp_output_206_0 ) , 0.0 , 1.0 );
			float3 temp_cast_2 = (clampResult47).xxx;
			o.Specular = temp_cast_2;
			float lerpResult143 = lerp( tex2DNode1.a , tex2DNode144.a , Transition210);
			float clampResult33 = clamp( ( ( lerpResult143 + temp_output_206_0 ) + ( _GR_WetSurf / 2.0 ) ) , 0.0 , 1.0 );
			o.Smoothness = clampResult33;
			float lerpResult149 = lerp( tex2DNode3.b , tex2DNode146.b , Transition210);
			o.Occlusion = ( lerpResult149 + _GR_WetSurf );
			o.Alpha = 1;
			float lerpResult148 = lerp( tex2DNode3.g , tex2DNode146.g , Transition210);
			clip( lerpResult148 - _Cutoff );
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf StandardSpecular keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 4.6
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float4 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				half4 color : COLOR0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				vertexDataFunc( v, customInputData );
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.customPack1.zw = customInputData.uv2_texcoord2;
				o.customPack1.zw = v.texcoord1;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				o.color = v.color;
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				surfIN.uv2_texcoord2 = IN.customPack1.zw;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandardSpecular o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandardSpecular, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17703
1972;7;1856;1039;1837.17;1810.307;2.63;True;True
Node;AmplifyShaderEditor.RangedFloatNode;165;-7958.072,591.9179;Float;False;Property;_PuddlesSize;Puddles Size;15;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;164;-7974.082,180.8364;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;166;-7573.39,813.1212;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;167;-7574.843,547.2404;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-7360.684,502.9687;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2302.857,649.7941;Float;False;Global;_GR_WetSurf;_GR_WetSurf;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-7352.227,778.3582;Inherit;True;2;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-2012.595,829.7492;Float;False;WetSurf;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;170;-7119.604,780.1833;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;171;-7137.854,504.6078;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-7577.414,200.9262;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;173;-6902.614,777.5081;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;272;-4541.034,1298.009;Inherit;False;1424.8;495.1663;Slope Control for Puddles (now set max at 8% slope);7;279;277;276;274;273;291;292;;1,1,1,1;0;0
Node;AmplifyShaderEditor.StepOpNode;174;-6915.388,493.6588;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-5170.152,608.2741;Inherit;False;219;WetSurf;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;175;-7007.407,263.4327;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;296;-4516.015,1586.321;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;273;-4316.308,1507.116;Float;False;Constant;_SlopeFalloff;Slope Falloff;17;0;Create;True;0;0;False;0;1500;1500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;177;-6670.124,606.809;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;132;-5832.527,-1669.023;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;133;-5790.179,-1434.743;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;176;-6656.054,902.458;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;274;-4323.104,1360.609;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;231;-4962.744,610.9344;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;292;-4372.04,1710.604;Inherit;False;Constant;_Float0;Float 0;28;0;Create;True;0;0;False;0;20;21.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-5372.6,-1392.323;Float;False;Property;_TransitionDistance;Transition Distance (in meters);7;0;Create;False;0;0;False;0;30;46.6;1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;275;-4108.93,1446.684;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;135;-5317.926,-1565.678;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;291;-4132.399,1575.424;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-6112.136,812.3092;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-6115.786,564.1093;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-6143.703,26.37904;Inherit;True;Property;_PuddlesTexture;Puddles Texture;14;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;8483e227f8901524981c77e7d51489ca;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;276;-4102.394,1355.73;Float;False;Constant;_Contrast;Contrast;18;0;Create;True;0;0;False;0;53;53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-6103.011,1058.684;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;226;-4782.295,597.2548;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;153;-5283.106,-1899.414;Float;False;Property;_TilingMainTextures;Tiling Main Textures;4;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;163;-5286.705,-1755.028;Float;False;Property;_OffsetMainTextures;Offset Main Textures;5;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-6121.261,323.2107;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;227;-4609.509,621.6901;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-5480.331,554.1782;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-5491.822,272.6746;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;277;-3915.906,1445.306;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-5046.72,-1562.203;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-5493.737,828.0236;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-5037.748,-1379.923;Float;False;Property;_TransitionFalloff;Transition Falloff;8;0;Create;True;0;0;False;0;6;2.45;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;138;-4923.495,-1778.348;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;139;-5040.537,-1222.318;Float;False;Property;_UVMultipliers;Tiling Multipliers for far texture;6;0;Create;False;0;0;False;0;1,0.2;0.21,0.46;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-5484.162,1076.975;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;223;-4286.052,834.3292;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;278;-3757.278,1442.725;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;140;-4803.047,-1569.423;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;224;-4291.543,1130.789;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;222;-4276.692,548.7142;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;221;-4280.743,256.0491;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-4500.752,-1386.244;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;142;-4507.264,-1576.183;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;279;-3552.568,1438.161;Float;False;Slope_Mixer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-4457.607,-1905.7;Float;False;UV_Texture;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-4289.954,-1240.724;Float;False;UV_Texture_Tiling_Mult;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;235;-4298.512,-3.115757;Float;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;237;-3955.072,120.0546;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;271;-3465.48,209.2931;Inherit;False;279;Slope_Mixer;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;-3669.257,-1895.792;Inherit;False;212;UV_Texture;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-4240.485,-1584.492;Float;False;Transition;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-3796.402,-1353.894;Inherit;False;215;UV_Texture_Tiling_Mult;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ToggleSwitchNode;236;-3688.664,76.95332;Float;False;Property;_UsePuddlesTexture;Use Puddles Texture;13;0;Create;True;0;0;False;0;1;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;146;-3274.936,-581.1248;Inherit;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;263;-3157.592,111.3081;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;54;-2953.16,1022.339;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-3187.749,-1176.127;Inherit;True;Property;_RSpecGTransparencyBAOAWetMap;(R)Spec-(G)Transparency-(B)AO -(A)WetMap;3;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;ff54f1b4d19f22a42892a633d3d114be;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;211;-3643.517,-1018.123;Inherit;False;210;Transition;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-2164.926,1609.144;Float;False;Global;_GR_Displacement;_GR_Displacement;10;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-2523.104,787.9199;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-2677.082,106.4245;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;150;-2787.433,-188.9251;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-2340.764,78.62479;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;144;-3227.768,-1657.504;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;201;-2095.796,155.2407;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-3182.482,-1968.898;Inherit;True;Property;_AlbedowithSmoothnessMap;Albedo (with Smoothness Map);0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;c68296334e691ed45b62266cbc716628;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1538.174,161.7106;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-2323.138,-2619.033;Inherit;True;Property;_GrooveMap;GrooveMap;12;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;572078f7efe28924a996e6e0d35f816e;True;1;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;145;-2744.86,-1821.597;Inherit;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;244;-2749.059,-2058.411;Float;False;Property;_AlbedoColorVariations;Albedo Color Variations;1;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-2294.539,-2406.298;Float;False;Constant;_Color0;Color 0;7;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;243;-2430.458,-1965.236;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-1795.457,-2496.918;Float;False;Property;_UseGrooveTex;Use Groove Tex;11;0;Create;True;0;0;False;0;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2318.966,-2210.496;Float;False;Global;_GR_Groove;_GR_Groove;8;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;297;-1348.089,14.84845;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-1281.975,-230.1949;Inherit;False;210;Transition;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;143;-2752.141,-1532.748;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;242;-1591.088,-2305.573;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1217.742,-99.67212;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;315.2041,-390.497;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1507.359,-2478.625;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;208;-919.4467,-395.8791;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-1165.73,-1875.159;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-921.1132,-190.3044;Inherit;False;215;UV_Texture_Tiling_Mult;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;147;-2608.805,-1142.354;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;562.4168,-419.9025;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.68;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;776.6593,-708.5289;Float;False;Global;_GR_PhysDebug;_GR_PhysDebug;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-1167.691,731.4235;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-928.8777,-526.6465;Inherit;False;212;UV_Texture;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-794.4315,631.7591;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;209;-856.5331,-68.24269;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;50;-1423.484,1271.131;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;762.0712,-464.5163;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;149;-2574.024,-517.7145;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;2;-560.7631,-493.5752;Inherit;True;Property;_Normalmap;Normal map;2;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;3a4de728bdf17b34ca3b6a84f065bd13;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;71;258.9923,-763.9866;Inherit;True;Property;_PhysicalTexture;Physical Texture;16;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Physical Texture. Remember to set the texture as ReadWrite Enabled);-1;None;36983654d3947d5468bbf70005735a65;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;84;1074.568,-612.0295;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;151;-561.0124,-220.53;Inherit;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Instance;2;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-479.8809,179.2537;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2219.487,1436.445;Float;False;Property;_MaxDisplacementmeters;Max Displacement (meters);10;0;Create;True;0;0;False;0;0;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-504.8837,608.61;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-170.5482,374.7318;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-2342.544,371.1309;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;247;-5504,-1024;Float;False;Property;_procLacunarity;(proc) lacunarity;19;0;Create;False;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;248;-5504,-960;Float;False;Property;_procScale;(proc) scale;20;0;Create;False;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;207;-108.9855,-364.1339;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-7056,139.1464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;47;-176.1671,113.6034;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-854.2187,1285.561;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.IntNode;253;-5504,-832;Float;False;Property;_procUsedForPatch;(proc) usedForPatch;22;0;Create;False;0;0;True;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.LerpOp;148;-2601.124,-850.5142;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-5500.316,-696.7434;Float;False;Property;_procSideNoiseDilatation;(proc) sideNoiseDilatation;24;0;Create;False;0;0;True;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;249;-5504,-896;Float;False;Property;_procHeightMultiplier;(proc) heightMultiplier;21;0;Create;False;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;1182.659,-517.5289;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-1335.746,575.8272;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;245;-5504,-1152;Float;False;Property;_procOctaves;(proc) octaves;17;0;Create;False;0;0;True;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;246;-5504,-1088;Float;False;Property;_procPersistance;(proc) persistance;18;0;Create;False;0;0;True;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;254;-5500.316,-763.7434;Float;False;Property;_procSideNoise;(proc) sideNoise;23;0;Create;False;0;0;True;0;0;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1719.536,59.48502;Float;False;True;-1;6;ASEMaterialInspector;0;0;StandardSpecular;gRally/Phys Road v2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;-0.46;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;20;3;10;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;9;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;166;0;164;3
WireConnection;166;1;165;0
WireConnection;167;0;164;1
WireConnection;167;1;165;0
WireConnection;168;0;167;0
WireConnection;169;0;166;0
WireConnection;219;0;5;0
WireConnection;170;0;169;0
WireConnection;171;0;168;0
WireConnection;172;0;164;1
WireConnection;172;1;164;3
WireConnection;173;0;170;0
WireConnection;174;0;171;0
WireConnection;175;0;172;0
WireConnection;175;1;165;0
WireConnection;177;0;174;0
WireConnection;176;0;173;0
WireConnection;231;0;220;0
WireConnection;275;0;274;2
WireConnection;275;1;273;0
WireConnection;135;0;132;0
WireConnection;135;1;133;0
WireConnection;291;0;296;0
WireConnection;291;1;292;0
WireConnection;186;0;177;0
WireConnection;186;1;173;0
WireConnection;184;0;174;0
WireConnection;184;1;176;0
WireConnection;178;1;175;0
WireConnection;179;0;177;0
WireConnection;179;1;176;0
WireConnection;226;0;231;0
WireConnection;181;0;174;0
WireConnection;181;1;173;0
WireConnection;227;0;226;0
WireConnection;188;0;178;2
WireConnection;188;1;184;0
WireConnection;190;0;178;1
WireConnection;190;1;181;0
WireConnection;277;0;275;0
WireConnection;277;1;276;0
WireConnection;277;2;291;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;189;0;178;3
WireConnection;189;1;186;0
WireConnection;138;0;153;0
WireConnection;138;1;163;0
WireConnection;187;0;178;4
WireConnection;187;1;179;0
WireConnection;223;0;189;0
WireConnection;223;1;227;0
WireConnection;278;0;277;0
WireConnection;140;0;137;0
WireConnection;140;1;136;0
WireConnection;224;0;187;0
WireConnection;224;1;227;0
WireConnection;222;0;188;0
WireConnection;222;1;227;0
WireConnection;221;0;190;0
WireConnection;221;1;227;0
WireConnection;141;0;138;0
WireConnection;141;1;139;0
WireConnection;142;0;140;0
WireConnection;279;0;278;0
WireConnection;212;0;138;0
WireConnection;215;0;141;0
WireConnection;237;0;221;0
WireConnection;237;1;222;0
WireConnection;237;2;223;0
WireConnection;237;3;224;0
WireConnection;210;0;142;0
WireConnection;236;0;235;0
WireConnection;236;1;237;0
WireConnection;146;1;216;0
WireConnection;263;0;236;0
WireConnection;263;1;271;0
WireConnection;3;1;213;0
WireConnection;234;0;54;3
WireConnection;234;1;85;0
WireConnection;240;0;263;0
WireConnection;150;0;3;4
WireConnection;150;1;146;4
WireConnection;150;2;211;0
WireConnection;241;0;150;0
WireConnection;241;1;240;0
WireConnection;241;2;240;1
WireConnection;241;3;240;2
WireConnection;241;4;240;3
WireConnection;241;5;234;0
WireConnection;144;1;216;0
WireConnection;201;0;241;0
WireConnection;1;1;213;0
WireConnection;206;0;201;0
WireConnection;206;1;5;0
WireConnection;145;0;1;0
WireConnection;145;1;144;0
WireConnection;145;2;211;0
WireConnection;243;0;244;0
WireConnection;243;1;145;0
WireConnection;70;0;61;0
WireConnection;70;1;55;0
WireConnection;297;0;206;0
WireConnection;143;0;1;4
WireConnection;143;1;144;4
WireConnection;143;2;211;0
WireConnection;242;0;62;0
WireConnection;242;1;54;2
WireConnection;81;0;297;0
WireConnection;89;0;5;0
WireConnection;66;0;70;0
WireConnection;66;1;243;0
WireConnection;208;0;81;0
WireConnection;208;2;217;0
WireConnection;56;0;243;0
WireConnection;56;1;66;0
WireConnection;56;2;242;0
WireConnection;147;0;3;1
WireConnection;147;1;146;1
WireConnection;147;2;211;0
WireConnection;90;0;89;0
WireConnection;48;0;5;0
WireConnection;7;0;143;0
WireConnection;7;1;206;0
WireConnection;209;1;81;0
WireConnection;209;2;217;0
WireConnection;88;0;56;0
WireConnection;88;1;90;0
WireConnection;149;0;3;3
WireConnection;149;1;146;3
WireConnection;149;2;211;0
WireConnection;2;1;214;0
WireConnection;2;5;208;0
WireConnection;84;0;82;0
WireConnection;151;1;218;0
WireConnection;151;5;209;0
WireConnection;25;0;147;0
WireConnection;25;1;206;0
WireConnection;34;0;7;0
WireConnection;34;1;48;0
WireConnection;33;0;34;0
WireConnection;200;0;150;0
WireConnection;200;1;221;0
WireConnection;200;2;222;0
WireConnection;200;3;223;0
WireConnection;200;4;224;0
WireConnection;200;5;234;0
WireConnection;207;0;2;0
WireConnection;207;1;151;0
WireConnection;195;0;172;0
WireConnection;195;1;165;0
WireConnection;47;0;25;0
WireConnection;51;0;54;3
WireConnection;51;1;50;0
WireConnection;51;2;52;0
WireConnection;51;3;85;0
WireConnection;148;0;3;2
WireConnection;148;1;146;2
WireConnection;148;2;211;0
WireConnection;83;0;71;0
WireConnection;83;1;88;0
WireConnection;83;2;84;0
WireConnection;77;0;149;0
WireConnection;77;1;5;0
WireConnection;0;0;83;0
WireConnection;0;1;207;0
WireConnection;0;3;47;0
WireConnection;0;4;33;0
WireConnection;0;5;77;0
WireConnection;0;10;148;0
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=E4F03434292CDBC17ECB92AC4B43E2B533DDBA13