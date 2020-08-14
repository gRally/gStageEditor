// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Procedural_Terrain_Shader"
{
	Properties
	{
		[Header(Camera Distance Blender (Near to Far))]_CameraDistance("Camera Distance", Float) = 0
		_CamDistanceFalloff("Cam Distance Falloff", Float) = 0
		[Header(Slope Blender Controls)]_OverallSlopeContrast("Overall Slope Contrast", Float) = 0
		_LowtoMedSlope("Low to Med Slope", Float) = 0
		_MedtoHighSlope("Med to High Slope", Float) = 0
		_SlopeNoiseMasks("Slope Noise Masks", 2D) = "white" {}
		_ContrastNoiseMapRChan("Contrast Noise Map R Chan", Float) = 0
		_ContrastNoiseMapGChan("Contrast Noise Map G Chan", Float) = 0
		_ContrastNoiseMapBChan("Contrast Noise Map B Chan", Float) = 0
		[NoScaleOffset][Space(20)][Header(Textures Arrays)]_AlbedoMapsArray("Albedo Maps Array", 2DArray ) = "" {}
		[NoScaleOffset]_NormalMapsArray("Normal Maps Array", 2DArray ) = "" {}
		_TerraintoPathTexAlbedo("Terrain to Path Tex Albedo", 2D) = "white" {}
		_TerraintoPathTexNormal("Terrain to Path Tex Normal", 2D) = "bump" {}
		_VertexPaintBlenderMultiplier("VertexPaint Blender Multiplier", Range( 0 , 1)) = 0
		_SecondaryMapVP_Albedo("Secondary Map VP Blended (Albedo)", 2D) = "white" {}
		_SecondaryMapVP_Normal("Secondary Map VP Blended (Normal)", 2D) = "bump" {}
		_ContrastVP("Contrast VP", Float) = 0
		[Header(UV Controls)]_LowSlopeNearUV("LowSlope Near UV", Vector) = (1,1,0,0)
		_LowSlopeFarUV("LowSlope Far UV", Vector) = (1,1,0,0)
		_MidSlopeNearUV("MidSlope Near UV", Vector) = (1,1,0,0)
		_MidSlopeFarUV("MidSlope Far UV", Vector) = (1,1,0,0)
		_HighSlopeNearUV("HighSlope Near UV", Vector) = (1,1,0,0)
		_HighSlopeFarUV("HighSlope Far UV", Vector) = (1,1,0,0)
		[Header(Normal Maps Multipliers)]_LowSlopeNearNormalMultiplier("Low Slope Near Normal Multiplier", Float) = 0
		_SecondaryMapNormalMultiplier("Secondary Map Normal Multiplier", Float) = 0
		_LowSlopeFarNormalMultiplier("Low Slope Far Normal Multiplier", Float) = 0
		_MediumSlopeNearNormalMultiplier("Medium Slope Near Normal Multiplier", Float) = 0
		_MediumSlopeFarNormalMultiplier("Medium Slope Far Normal Multiplier", Float) = 0
		_HighSlopeNearNormalMultiplier("High Slope Near Normal Multiplier", Float) = 0
		_HighSlopeFarNormalMultiplier("High Slope Far Normal Multiplier", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityCG.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.5
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
			float eyeDepth;
			float3 worldNormal;
			INTERNAL_DATA
			float4 vertexColor : COLOR;
		};

		uniform UNITY_DECLARE_TEX2DARRAY( _NormalMapsArray );
		uniform float2 _MidSlopeNearUV;
		uniform float _CamDistanceFalloff;
		uniform float _CameraDistance;
		uniform float _OverallSlopeContrast;
		uniform float _LowtoMedSlope;
		uniform float _MedtoHighSlope;
		uniform float _MediumSlopeNearNormalMultiplier;
		uniform float2 _MidSlopeFarUV;
		uniform float _MediumSlopeFarNormalMultiplier;
		uniform float2 _LowSlopeNearUV;
		uniform sampler2D _SlopeNoiseMasks;
		uniform float4 _SlopeNoiseMasks_ST;
		uniform half _ContrastNoiseMapRChan;
		uniform float _VertexPaintBlenderMultiplier;
		uniform half _ContrastVP;
		uniform float _LowSlopeNearNormalMultiplier;
		uniform float _SecondaryMapNormalMultiplier;
		uniform sampler2D _SecondaryMapVP_Normal;
		uniform float4 _SecondaryMapVP_Normal_ST;
		uniform float2 _LowSlopeFarUV;
		uniform float _LowSlopeFarNormalMultiplier;
		uniform float2 _HighSlopeNearUV;
		uniform float _HighSlopeNearNormalMultiplier;
		uniform float2 _HighSlopeFarUV;
		uniform float _HighSlopeFarNormalMultiplier;
		uniform sampler2D _TerraintoPathTexNormal;
		uniform float4 _TerraintoPathTexNormal_ST;
		uniform UNITY_DECLARE_TEX2DARRAY( _AlbedoMapsArray );
		uniform float _ContrastNoiseMapBChan;
		uniform half _ContrastNoiseMapGChan;
		uniform sampler2D _SecondaryMapVP_Albedo;
		uniform float4 _SecondaryMapVP_Albedo_ST;
		uniform sampler2D _TerraintoPathTexAlbedo;
		uniform float4 _TerraintoPathTexAlbedo_ST;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			o.eyeDepth = -UnityObjectToViewPos( v.vertex.xyz ).z;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord301 = i.uv_texcoord * _MidSlopeNearUV;
			float2 MidSlopeNearUV_1312 = uv_TexCoord301;
			float cameraDepthFade2 = (( i.eyeDepth -_ProjectionParams.y - _CameraDistance ) / _CamDistanceFalloff);
			half cameraDistance83 = cameraDepthFade2;
			float temp_output_186_0 = saturate( cameraDistance83 );
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float temp_output_64_0 = pow( saturate( ( pow( ase_normWorldNormal.y , abs( _OverallSlopeContrast ) ) - ( 1.0 - pow( ase_normWorldNormal.y , abs( _LowtoMedSlope ) ) ) ) ) , abs( _MedtoHighSlope ) );
			half SlopeBlend_199 = saturate( ( ( max( temp_output_64_0 , 0.5 ) - 0.5 ) * 2.0 ) );
			float temp_output_226_0 = ( 1.0 - SlopeBlend_199 );
			half SlopeBlend_2100 = ( ( min( temp_output_64_0 , 0.5 ) * 2.0 ) - 0.0 );
			float3 texArray328 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArray, float3(MidSlopeNearUV_1312, 2.0)  ), ( ( 1.0 - temp_output_186_0 ) * temp_output_226_0 * SlopeBlend_2100 * _MediumSlopeNearNormalMultiplier ) );
			float2 uv_TexCoord302 = i.uv_texcoord * _MidSlopeFarUV;
			float2 MidSlopeFarUV_1313 = uv_TexCoord302;
			float3 texArray329 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArray, float3(MidSlopeFarUV_1313, 3.0)  ), ( temp_output_186_0 * temp_output_226_0 * SlopeBlend_2100 * _MediumSlopeFarNormalMultiplier ) );
			float2 uv_TexCoord294 = i.uv_texcoord * _LowSlopeNearUV;
			float2 LowSlopeNearUV_1307 = uv_TexCoord294;
			float2 uv_SlopeNoiseMasks = i.uv_texcoord * _SlopeNoiseMasks_ST.xy + _SlopeNoiseMasks_ST.zw;
			float3 gammaToLinear421 = GammaToLinearSpace( tex2D( _SlopeNoiseMasks, uv_SlopeNoiseMasks ).rgb );
			float3 break422 = gammaToLinear421;
			float SlopeNoiseMaskRChan126 = saturate( ( ( ( break422.x - 0.5 ) * _ContrastNoiseMapRChan ) + 0.5 ) );
			float VP_Multy204 = _VertexPaintBlenderMultiplier;
			float VertexColor_RChan165 = saturate( ( ( ( i.vertexColor.r - 0.5 ) * _ContrastVP ) + 0.5 ) );
			float temp_output_179_0 = ( ( 1.0 - SlopeNoiseMaskRChan126 ) * VP_Multy204 * VertexColor_RChan165 );
			float temp_output_190_0 = saturate( cameraDistance83 );
			float temp_output_215_0 = ( 1.0 - temp_output_190_0 );
			float3 texArray332 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArray, float3(LowSlopeNearUV_1307, 0.0)  ), ( ( 1.0 - temp_output_179_0 ) * temp_output_215_0 * SlopeBlend_199 * _LowSlopeNearNormalMultiplier ) );
			float2 uv_SecondaryMapVP_Normal = i.uv_texcoord * _SecondaryMapVP_Normal_ST.xy + _SecondaryMapVP_Normal_ST.zw;
			float2 uv_TexCoord296 = i.uv_texcoord * _LowSlopeFarUV;
			float2 LowSlopeFarUV_1308 = uv_TexCoord296;
			float3 texArray327 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArray, float3(LowSlopeFarUV_1308, 1.0)  ), ( temp_output_190_0 * SlopeBlend_199 * _LowSlopeFarNormalMultiplier ) );
			float2 uv_TexCoord303 = i.uv_texcoord * _HighSlopeNearUV;
			float2 HighSlopeNearUV_1310 = uv_TexCoord303;
			float temp_output_193_0 = saturate( cameraDistance83 );
			float temp_output_265_0 = ( 1.0 - SlopeBlend_2100 );
			float3 texArray330 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArray, float3(HighSlopeNearUV_1310, 4.0)  ), ( ( 1.0 - temp_output_193_0 ) * temp_output_265_0 * _HighSlopeNearNormalMultiplier ) );
			float2 uv_TexCoord304 = i.uv_texcoord * _HighSlopeFarUV;
			float2 HighSlopeFarUV_1311 = uv_TexCoord304;
			float3 texArray331 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArray, float3(HighSlopeFarUV_1311, 5.0)  ), ( temp_output_193_0 * temp_output_265_0 * _HighSlopeFarNormalMultiplier ) );
			float VertexColor_AChan423 = i.vertexColor.a;
			float2 uv_TerraintoPathTexNormal = i.uv_texcoord * _TerraintoPathTexNormal_ST.xy + _TerraintoPathTexNormal_ST.zw;
			float3 NormalsChan416 = BlendNormals( BlendNormals( BlendNormals( BlendNormals( texArray328 , texArray329 ) , BlendNormals( BlendNormals( texArray332 , UnpackScaleNormal( tex2D( _SecondaryMapVP_Normal, uv_SecondaryMapVP_Normal ), ( temp_output_179_0 * temp_output_215_0 * SlopeBlend_199 * _SecondaryMapNormalMultiplier ) ) ) , texArray327 ) ) , BlendNormals( texArray330 , texArray331 ) ) , UnpackScaleNormal( tex2D( _TerraintoPathTexNormal, uv_TerraintoPathTexNormal ), VertexColor_AChan423 ) );
			o.Normal = NormalsChan416;
			float4 texArray272 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArray, float3(HighSlopeNearUV_1310, 4.0)  );
			float temp_output_115_0 = saturate( cameraDistance83 );
			float4 texArray273 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArray, float3(HighSlopeFarUV_1311, 5.0)  );
			float SlopeNoiseMaskBChan460 = saturate( ( ( ( break422.z - 0.5 ) * _ContrastNoiseMapBChan ) + 0.5 ) );
			float blendOpSrc454 = SlopeNoiseMaskBChan460;
			float blendOpDest454 = SlopeBlend_2100;
			float temp_output_454_0 = ( saturate( (( blendOpDest454 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest454 ) * ( 1.0 - blendOpSrc454 ) ) : ( 2.0 * blendOpDest454 * blendOpSrc454 ) ) ));
			float4 texArray271 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArray, float3(MidSlopeNearUV_1312, 2.0)  );
			float temp_output_114_0 = saturate( cameraDistance83 );
			float4 texArray270 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArray, float3(MidSlopeFarUV_1313, 3.0)  );
			float SlopeNoiseMaskGChan440 = saturate( ( ( ( break422.y - 0.5 ) * _ContrastNoiseMapGChan ) + 0.5 ) );
			float blendOpSrc450 = SlopeNoiseMaskGChan440;
			float blendOpDest450 = SlopeBlend_199;
			float temp_output_450_0 = ( saturate( (( blendOpDest450 > 0.5 ) ? ( 1.0 - 2.0 * ( 1.0 - blendOpDest450 ) * ( 1.0 - blendOpSrc450 ) ) : ( 2.0 * blendOpDest450 * blendOpSrc450 ) ) ));
			float4 texArray333 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArray, float3(LowSlopeNearUV_1307, 0.0)  );
			float temp_output_170_0 = ( VP_Multy204 * VertexColor_RChan165 * ( 1.0 - SlopeNoiseMaskRChan126 ) );
			float2 uv_SecondaryMapVP_Albedo = i.uv_texcoord * _SecondaryMapVP_Albedo_ST.xy + _SecondaryMapVP_Albedo_ST.zw;
			float4 tex2DNode167 = tex2D( _SecondaryMapVP_Albedo, uv_SecondaryMapVP_Albedo );
			float temp_output_113_0 = saturate( cameraDistance83 );
			float4 texArray268 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArray, float3(LowSlopeFarUV_1308, 1.0)  );
			float2 uv_TerraintoPathTexAlbedo = i.uv_texcoord * _TerraintoPathTexAlbedo_ST.xy + _TerraintoPathTexAlbedo_ST.zw;
			float4 AlbedoChan414 = ( ( ( ( ( ( texArray272 * ( 1.0 - temp_output_115_0 ) ) + ( texArray273 * temp_output_115_0 ) ) * ( 1.0 - temp_output_454_0 ) ) + ( ( ( ( ( texArray271 * ( 1.0 - temp_output_114_0 ) ) + ( texArray270 * temp_output_114_0 ) ) * ( 1.0 - temp_output_450_0 ) ) + ( ( ( ( ( texArray333 * ( 1.0 - temp_output_170_0 ) ) + ( tex2DNode167 * temp_output_170_0 ) ) * ( 1.0 - temp_output_113_0 ) ) + ( ( ( texArray268 * ( 1.0 - temp_output_170_0 ) ) + ( tex2DNode167 * temp_output_170_0 ) ) * temp_output_113_0 ) ) * temp_output_450_0 ) ) * temp_output_454_0 ) ) * ( 1.0 - VertexColor_AChan423 ) ) + ( tex2D( _TerraintoPathTexAlbedo, uv_TerraintoPathTexAlbedo ) * VertexColor_AChan423 ) );
			o.Albedo = AlbedoChan414.rgb;
			float temp_output_340_0 = 0.0;
			o.Metallic = temp_output_340_0;
			o.Smoothness = temp_output_340_0;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows vertex:vertexDataFunc 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.5
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
				float3 customPack1 : TEXCOORD1;
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
				o.customPack1.z = customInputData.eyeDepth;
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
				surfIN.eyeDepth = IN.customPack1.z;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				surfIN.vertexColor = IN.color;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
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
Version=17701
1936;7;1897;1044;1533.678;1754.127;2.695001;True;True
Node;AmplifyShaderEditor.SamplerNode;55;405.9958,-641.5554;Inherit;True;Property;_SlopeNoiseMasks;Slope Noise Masks;5;0;Create;True;0;0;False;0;-1;None;0fbded8ac7bd79c42a0803c7f8e22dba;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;101;463.329,-1471.433;Inherit;False;2139.837;502.0616;Comment;22;52;43;46;96;59;58;62;48;54;64;79;80;72;87;89;88;91;97;98;65;99;100;Slope Blender;1,1,1,1;0;0
Node;AmplifyShaderEditor.GammaToLinearNode;421;713.7949,-637.1512;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;52;517.3821,-1120.689;Inherit;False;Property;_LowtoMedSlope;Low to Med Slope;3;0;Create;True;0;0;False;0;0;2.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;43;658.3306,-1421.433;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;46;493.704,-1236.619;Inherit;False;Property;_OverallSlopeContrast;Overall Slope Contrast;2;0;Create;True;0;0;False;1;Header(Slope Blender Controls);0;1.91;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;97;718.7261,-1121.566;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;422;919.7399,-634.4264;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleSubtractOpNode;357;1202.458,-623.2498;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;361;972.1348,-493.4162;Half;False;Property;_ContrastNoiseMapRChan;Contrast Noise Map R Chan;6;0;Create;True;0;0;False;0;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;164;452.2762,-941.088;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;59;881.5767,-1159.477;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;96;746.9955,-1234.241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;58;891.6416,-1261.346;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;1033.541,-1160.741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;344;460.1158,-767.3024;Half;False;Property;_ContrastVP;Contrast VP;16;0;Create;True;0;0;False;0;0;5.06;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;354;647.6541,-914.2979;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;1367.323,-611.1;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;1544.004,-612.29;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;1152.43,-1087.493;Inherit;False;Property;_MedtoHighSlope;Med to High Slope;4;0;Create;True;0;0;False;0;0;2.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;792.629,-906.6579;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;1208.017,-1242.209;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;98;1388.627,-1107.706;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;54;1366.433,-1223.929;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;356;935.0985,-908.0179;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;360;1687.468,-613.445;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;353;1057.704,-903.9228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;2156.465,-624.1102;Inherit;False;SlopeNoiseMaskRChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;64;1518.906,-1140.613;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;542.1313,-41.0242;Inherit;False;Property;_VertexPaintBlenderMultiplier;VertexPaint Blender Multiplier;13;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;295;576.6749,-2656.671;Inherit;False;Property;_LowSlopeNearUV;LowSlope Near UV;17;0;Create;True;0;0;False;1;Header(UV Controls);1,1;0.08,0.08;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;297;575.9579,-2513.983;Inherit;False;Property;_LowSlopeFarUV;LowSlope Far UV;18;0;Create;True;0;0;False;0;1,1;0.001,0.001;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMaxOpNode;79;1743.166,-1286.216;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;1383.106,-40.64891;Inherit;False;VP_Multy;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;151;-4796.519,-1096.996;Inherit;False;126;SlopeNoiseMaskRChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;294;869.9277,-2661.542;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;296;867.8963,-2521.708;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;3;589.9503,-1852.681;Inherit;False;Property;_CamDistanceFalloff;Cam Distance Falloff;1;0;Create;True;0;0;False;0;0;450;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;437;1088.18,-385.5399;Half;False;Property;_ContrastNoiseMapGChan;Contrast Noise Map G Chan;7;0;Create;True;0;0;False;0;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;591.8602,-1741.531;Inherit;False;Property;_CameraDistance;Camera Distance;0;0;Create;True;0;0;False;1;Header(Camera Distance Blender (Near to Far));0;150;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;435;1323.158,-496.4086;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;1204.683,-911.3782;Inherit;False;VertexColor_RChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;299;1444.052,-2665.085;Inherit;False;Property;_MidSlopeNearUV;MidSlope Near UV;19;0;Create;True;0;0;False;0;1,1;0.03,0.03;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;300;1446.456,-2523.146;Inherit;False;Property;_MidSlopeFarUV;MidSlope Far UV;20;0;Create;True;0;0;False;0;1,1;0.002,0.002;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.GetLocalVarNode;168;-4649.401,-902.4949;Inherit;False;165;VertexColor_RChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;1122.816,-2661.167;Inherit;False;LowSlopeNearUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;205;-4593.351,-992.6956;Inherit;False;204;VP_Multy;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;80;1909.556,-1285.231;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.CameraDepthFade;2;872.0098,-1851.256;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;1488.023,-484.2587;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;308;1126.631,-2527.746;Inherit;False;LowSlopeFarUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;366;-4504.509,-1089.759;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;2068.082,-1286.96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;459;1157.991,-289.9096;Inherit;False;Property;_ContrastNoiseMapBChan;Contrast Noise Map B Chan;8;0;Create;True;0;0;False;0;0;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;302;1748.545,-2534.591;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;301;1744.862,-2682.045;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;455;1449.596,-374.6834;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-4793.689,-1783.366;Inherit;False;307;LowSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;276;-4558.529,-1873.786;Inherit;False;385.5247;534.291;Low Slope (Near-Far);2;268;333;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;439;1664.704,-485.4487;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;1181.224,-1849.117;Half;False;cameraDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;-4799.059,-1550.635;Inherit;False;308;LowSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-4317.351,-975.5455;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;88;2217.123,-1288.865;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;72;1746.504,-1102.371;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;268;-4507.53,-1569.786;Inherit;True;Property;_AlbedoNoSlopeNear;Albedo NoSlope Near;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;305;580.9476,-2236.007;Inherit;False;Property;_HighSlopeNearUV;HighSlope Near UV;21;0;Create;True;0;0;False;0;1,1;0.0025,0.0025;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;2052.281,-2532.294;Inherit;False;MidSlopeFarUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureArrayNode;333;-4517.482,-1809.284;Inherit;True;Property;_AlbedoMapsArray;Albedo Maps Array;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Object;-1;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;306;594.2219,-2103.849;Inherit;False;Property;_HighSlopeFarUV;HighSlope Far UV;22;0;Create;True;0;0;False;0;1,1;0.005,0.005;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;2044.869,-2669.149;Inherit;False;MidSlopeNearUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;392;-4148.954,-1424.742;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;1614.461,-362.5335;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;167;-4496.271,-1322.444;Inherit;True;Property;_SecondaryMapVP_Albedo;Secondary Map VP Blended (Albedo);14;0;Create;False;0;0;False;0;-1;None;fe330077b33ebe646ad9213f6dd52470;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;387;-4175.094,-1711.825;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;109;-3084.779,-1274.516;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;180;-6389.369,412.6749;Inherit;False;126;SlopeNoiseMaskRChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;438;1808.168,-486.6038;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-4016.169,-987.1849;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;2362.125,-1292.826;Half;False;SlopeBlend_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;1910.527,-1104.556;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;304;893.1249,-2109.454;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;113;-3790.509,-988.7152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-6214.866,499.58;Inherit;False;204;VP_Multy;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;184;-6308.01,202.485;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;385;-4017.493,-1780.544;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-3288.09,-1760.775;Inherit;False;312;MidSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;440;2271.704,-492.9832;Inherit;False;SlopeNoiseMaskGChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;391;-3993.07,-1374.501;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;114;-2836.47,-1275.595;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;457;1791.142,-363.7235;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;420;-6109.586,420.5436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;275;-3054.78,-1843.905;Inherit;False;390.1902;553.3882;Mid Slope (Near-Far);2;270;271;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;390;-3991.353,-1493.461;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;386;-4019.21,-1661.584;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-6263.594,575.995;Inherit;False;165;VertexColor_RChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;303;893.2517,-2222.619;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;317;-3272.09,-1504.775;Inherit;False;313;MidSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;389;-3847.313,-1415.671;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;396;-3645.861,-1254.088;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;271;-3005.4,-1795.905;Inherit;True;Property;_TextureArray4;Texture Array 4;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;2086.247,-1106.166;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;-4503.93,37.36503;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-5940.01,506.485;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-3023.028,-951.6863;Inherit;False;99;SlopeBlend_1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;397;-2638.865,-1751.715;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;190;-6052.01,202.485;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;441;-3080.526,-1057.845;Inherit;False;440;SlopeNoiseMaskGChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;458;1934.606,-364.8786;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-1868.644,-1355.225;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;270;-3025.54,-1523.905;Inherit;True;Property;_TextureArray3;Texture Array 3;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;1149.684,-2236.116;Inherit;False;HighSlopeNearUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;388;-3873.453,-1702.754;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;1168.576,-2099.281;Inherit;False;HighSlopeFarUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;191;-4134.57,785.3248;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-1625.315,-1348.565;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;338;-5893.268,-68.46199;Inherit;False;Property;_LowSlopeNearNormalMultiplier;Low Slope Near Normal Multiplier;23;0;Create;True;0;0;False;1;Header(Normal Maps Multipliers);0;0.81;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;-2477.9,-1664.644;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;-3484.896,-1167.017;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;-3483.179,-1285.977;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;-2476.183,-1783.604;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;186;-4247.931,37.36503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;460;2307.382,-371.3147;Inherit;False;SlopeNoiseMaskBChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-6212.01,330.485;Inherit;False;99;SlopeBlend_1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;274;-1789.585,-1956.695;Inherit;False;328.3904;568.6597;High Slope (Near-Far);2;272;273;;1,1,1,1;0;0
Node;AmplifyShaderEditor.OneMinusNode;215;-5873.371,169.165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;2282.604,-1104.936;Half;False;SlopeBlend_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;419;-5871.181,30.46696;Inherit;False;Property;_SecondaryMapNormalMultiplier;Secondary Map Normal Multiplier;24;0;Create;True;0;0;False;0;0;1.3;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;450;-2751.678,-1083.256;Inherit;False;Overlay;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-2026.985,-1602.38;Inherit;False;311;HighSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;208;-5732.713,-142.79;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-2037.34,-1880.025;Inherit;False;310;HighSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-4664.26,-132.87;Inherit;False;99;SlopeBlend_1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;226;-4119.93,-154.635;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-1658.88,-1008.845;Inherit;False;100;SlopeBlend_2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;400;-2332.143,-1705.814;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;218;-4087.93,-42.63498;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;272;-1771.555,-1903.7;Inherit;True;Property;_TextureArray7;Texture Array 7;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;193;-3846.57,785.3248;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;273;-1767.21,-1620.695;Inherit;True;Property;_TextureArray6;Texture Array 6;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;235;-4632.225,-390.6102;Inherit;False;100;SlopeBlend_2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;393;-3339.139,-1208.187;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;233;-4109.37,670.8451;Inherit;False;100;SlopeBlend_2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;-5669.37,-273.2751;Inherit;False;307;LowSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-5524.991,75.63;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;405;-1434.287,-1864.629;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;453;-1690.706,-1107.783;Inherit;False;460;SlopeNoiseMaskBChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;339;-5775.225,560.3792;Inherit;False;Property;_LowSlopeFarNormalMultiplier;Low Slope Far Normal Multiplier;25;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;-5492.01,-149.515;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;401;-2339.994,-1246.926;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-3919.548,-296.8571;Inherit;False;Property;_MediumSlopeNearNormalMultiplier;Medium Slope Near Normal Multiplier;26;0;Create;True;0;0;False;0;0;1.35;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;336;-3991.754,175.5885;Inherit;False;Property;_MediumSlopeFarNormalMultiplier;Medium Slope Far Normal Multiplier;27;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;-5577.51,307.2849;Inherit;False;308;LowSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-3831.93,-58.63497;Inherit;False;313;MidSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureArrayNode;332;-5338.502,-258.185;Inherit;True;Property;_NormalMapsArray;Normal Maps Array;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Object;-1;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;228;-3727.79,495.225;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-3707.424,48.44505;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-5513.21,397.685;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;323;-3865.315,-394.3451;Inherit;False;312;MidSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;181;-5348.01,26.48502;Inherit;True;Property;_SecondaryMapVP_Normal;Secondary Map VP Blended (Normal);15;0;Create;False;0;0;False;0;-1;None;34153614eddec894caeaa08cea467368;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;334;-3749.654,572.9985;Inherit;False;Property;_HighSlopeNearNormalMultiplier;High Slope Near Normal Multiplier;28;0;Create;True;0;0;False;0;0;1.32;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;-1271.604,-1896.518;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;403;-2177.311,-1278.815;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;282;-3461.594,-377.2501;Inherit;False;373.0833;508.5517;Mid Slope (Near-Far);2;329;328;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;-3596.623,-254.6453;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;335;-3786.462,888.589;Inherit;False;Property;_HighSlopeFarNormalMultiplier;High Slope Far Normal Multiplier;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;407;-1273.321,-1777.558;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;265;-3853.37,670.8451;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;-2179.028,-1159.855;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendOpsNode;454;-1368.588,-1118.165;Inherit;False;Overlay;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-3597.37,670.8451;Inherit;False;311;HighSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;-3432.521,790.2151;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;423;1229.226,-797.4306;Inherit;False;VertexColor_AChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;327;-5300.01,298.485;Inherit;True;Property;_TextureArray9;Texture Array 9;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;324;-3613.37,398.845;Inherit;False;310;HighSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;404;-2033.271,-1201.025;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureArrayNode;329;-3413.594,-73.24999;Inherit;True;Property;_TextureArray10;Texture Array 10;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;207;-5004.387,-139.6849;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;-3437.869,508.805;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;411;-1132.028,-1264.732;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;408;-1127.563,-1818.728;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;285;-3277.37,366.845;Inherit;False;381.8091;535.0601;High Slope (Near-Far);2;331;330;;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureArrayNode;328;-3413.594,-313.2501;Inherit;True;Property;_TextureArray1;Texture Array 1;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;214;-4717.572,249.905;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;424;-1042.1,-994.556;Inherit;False;423;VertexColor_AChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;433;-2532.336,769.0986;Inherit;False;694.2002;301.6799;Probabilmente va usato anche per "abbassare" il normal power delle altre mappe;1;432;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendNormalsNode;212;-3043.3,-220.0201;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;413;-971.0615,-1177.661;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureArrayNode;330;-3229.37,414.845;Inherit;True;Property;_TextureArray0;Texture Array 0;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureArrayNode;331;-3213.37,670.8451;Inherit;True;Property;_TextureArray2;Texture Array 2;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;412;-969.3444,-1296.621;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;410;-825.304,-1218.831;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;227;-2829.37,462.845;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;217;-2820.01,202.485;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;432;-2482.336,819.0986;Inherit;False;423;VertexColor_AChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;425;-734.9567,-1030.149;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;429;-1027.358,-876.9534;Inherit;True;Property;_TerraintoPathTexAlbedo;Terrain to Path Tex Albedo;11;0;Create;True;0;0;False;0;-1;None;64395af60de8fcb4cb9dd2a27bb9c72b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;229;-2426.096,204.8299;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;-530.1332,-1110.198;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;-537.8704,-980.7032;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;431;-1959.072,547.8278;Inherit;True;Property;_TerraintoPathTexNormal;Terrain to Path Tex Normal;12;0;Create;True;0;0;False;0;-1;None;a63f5829966223a439331c27c5d8c011;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;428;-354.4879,-1039.933;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;430;-1635.664,341.3177;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;414;45.46556,-1211.441;Inherit;False;AlbedoChan;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-870.6987,277.9868;Inherit;False;NormalsChan;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;375;1123.656,184.8561;Inherit;False;1454.07;1029.75;Comment;8;373;368;372;370;371;369;380;382;LERP substitute;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;383;1415.937,683.7157;Inherit;False;649.8457;333.8849;Metodo 2;2;379;381;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;415;-8.029516,-2.697543;Inherit;False;414;AlbedoChan;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;443;-675.0496,-438.1314;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;1,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;445;-1090.654,-425.596;Inherit;False;Constant;_Color3;Color 3;29;0;Create;True;0;0;False;0;1,1,1,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-371.5667,-390.7144;Inherit;True;Debug;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;444;-1095.625,-620.436;Inherit;False;Constant;_Color2;Color 2;29;0;Create;True;0;0;False;0;0.01,0.01,0.01,1;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;341;-70.292,414.4446;Inherit;False;364;Debug;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;382;1465.937,903.8005;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;417;-28.59991,92.77209;Inherit;False;416;NormalsChan;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;1634.817,442.756;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;369;1173.656,452.2056;Inherit;False;Constant;_Color1;Color 1;25;0;Create;True;0;0;False;0;0,0.2876301,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;340;-41.86125,235.8529;Inherit;False;Constant;_Float3;Float 3;24;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;371;1479.836,403.0663;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;1669.242,884.6006;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;380;1666.598,733.7157;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;373;1793.576,401.1759;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;368;1173.656,234.8561;Inherit;False;Constant;_Color0;Color 0;25;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;379;1911.782,778.5956;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;370;1147.111,650.6559;Inherit;False;Constant;_Float4;Float 4;26;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;262.21,36.79;Float;False;True;-1;3;ASEMaterialInspector;0;0;Standard;gRally/Procedural_Terrain_Shader;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;384;1429.836,351.1759;Inherit;False;517.7394;224.5801;Metodo 1;0;;1,1,1,1;0;0
WireConnection;421;0;55;0
WireConnection;97;0;52;0
WireConnection;422;0;421;0
WireConnection;357;0;422;0
WireConnection;59;0;43;2
WireConnection;59;1;97;0
WireConnection;96;0;46;0
WireConnection;58;0;43;2
WireConnection;58;1;96;0
WireConnection;62;0;59;0
WireConnection;354;0;164;1
WireConnection;358;0;357;0
WireConnection;358;1;361;0
WireConnection;359;0;358;0
WireConnection;355;0;354;0
WireConnection;355;1;344;0
WireConnection;48;0;58;0
WireConnection;48;1;62;0
WireConnection;98;0;65;0
WireConnection;54;0;48;0
WireConnection;356;0;355;0
WireConnection;360;0;359;0
WireConnection;353;0;356;0
WireConnection;126;0;360;0
WireConnection;64;0;54;0
WireConnection;64;1;98;0
WireConnection;79;0;64;0
WireConnection;204;0;171;0
WireConnection;294;0;295;0
WireConnection;296;0;297;0
WireConnection;435;0;422;1
WireConnection;165;0;353;0
WireConnection;307;0;294;0
WireConnection;80;0;79;0
WireConnection;2;0;3;0
WireConnection;2;1;4;0
WireConnection;436;0;435;0
WireConnection;436;1;437;0
WireConnection;308;0;296;0
WireConnection;366;0;151;0
WireConnection;87;0;80;0
WireConnection;302;0;300;0
WireConnection;301;0;299;0
WireConnection;455;0;422;2
WireConnection;439;0;436;0
WireConnection;83;0;2;0
WireConnection;170;0;205;0
WireConnection;170;1;168;0
WireConnection;170;2;366;0
WireConnection;88;0;87;0
WireConnection;72;0;64;0
WireConnection;268;0;315;0
WireConnection;313;0;302;0
WireConnection;333;0;314;0
WireConnection;312;0;301;0
WireConnection;392;0;170;0
WireConnection;456;0;455;0
WireConnection;456;1;459;0
WireConnection;387;0;170;0
WireConnection;438;0;439;0
WireConnection;99;0;88;0
WireConnection;89;0;72;0
WireConnection;304;0;306;0
WireConnection;113;0;105;0
WireConnection;385;0;333;0
WireConnection;385;1;387;0
WireConnection;440;0;438;0
WireConnection;391;0;167;0
WireConnection;391;1;170;0
WireConnection;114;0;109;0
WireConnection;457;0;456;0
WireConnection;420;0;180;0
WireConnection;390;0;268;0
WireConnection;390;1;392;0
WireConnection;386;0;167;0
WireConnection;386;1;170;0
WireConnection;303;0;305;0
WireConnection;389;0;390;0
WireConnection;389;1;391;0
WireConnection;396;0;113;0
WireConnection;271;0;316;0
WireConnection;91;0;89;0
WireConnection;179;0;420;0
WireConnection;179;1;206;0
WireConnection;179;2;176;0
WireConnection;397;0;114;0
WireConnection;190;0;184;0
WireConnection;458;0;457;0
WireConnection;270;0;317;0
WireConnection;310;0;303;0
WireConnection;388;0;385;0
WireConnection;388;1;386;0
WireConnection;311;0;304;0
WireConnection;115;0;112;0
WireConnection;398;0;270;0
WireConnection;398;1;114;0
WireConnection;395;0;389;0
WireConnection;395;1;113;0
WireConnection;394;0;388;0
WireConnection;394;1;396;0
WireConnection;399;0;271;0
WireConnection;399;1;397;0
WireConnection;186;0;182;0
WireConnection;460;0;458;0
WireConnection;215;0;190;0
WireConnection;100;0;91;0
WireConnection;450;0;441;0
WireConnection;450;1;103;0
WireConnection;208;0;179;0
WireConnection;226;0;198;0
WireConnection;400;0;399;0
WireConnection;400;1;398;0
WireConnection;218;0;186;0
WireConnection;272;0;318;0
WireConnection;193;0;191;0
WireConnection;273;0;319;0
WireConnection;393;0;394;0
WireConnection;393;1;395;0
WireConnection;185;0;179;0
WireConnection;185;1;215;0
WireConnection;185;2;222;0
WireConnection;185;3;419;0
WireConnection;405;0;115;0
WireConnection;216;0;208;0
WireConnection;216;1;215;0
WireConnection;216;2;222;0
WireConnection;216;3;338;0
WireConnection;401;0;450;0
WireConnection;332;0;320;0
WireConnection;332;3;216;0
WireConnection;228;0;193;0
WireConnection;225;0;186;0
WireConnection;225;1;226;0
WireConnection;225;2;235;0
WireConnection;225;3;336;0
WireConnection;223;0;190;0
WireConnection;223;1;222;0
WireConnection;223;2;339;0
WireConnection;181;5;185;0
WireConnection;406;0;272;0
WireConnection;406;1;405;0
WireConnection;403;0;400;0
WireConnection;403;1;401;0
WireConnection;224;0;218;0
WireConnection;224;1;226;0
WireConnection;224;2;235;0
WireConnection;224;3;337;0
WireConnection;407;0;273;0
WireConnection;407;1;115;0
WireConnection;265;0;233;0
WireConnection;402;0;393;0
WireConnection;402;1;450;0
WireConnection;454;0;453;0
WireConnection;454;1;102;0
WireConnection;230;0;193;0
WireConnection;230;1;265;0
WireConnection;230;2;335;0
WireConnection;423;0;164;4
WireConnection;327;0;321;0
WireConnection;327;3;223;0
WireConnection;404;0;403;0
WireConnection;404;1;402;0
WireConnection;329;0;322;0
WireConnection;329;3;225;0
WireConnection;207;0;332;0
WireConnection;207;1;181;0
WireConnection;231;0;228;0
WireConnection;231;1;265;0
WireConnection;231;2;334;0
WireConnection;411;0;454;0
WireConnection;408;0;406;0
WireConnection;408;1;407;0
WireConnection;328;0;323;0
WireConnection;328;3;224;0
WireConnection;214;0;207;0
WireConnection;214;1;327;0
WireConnection;212;0;328;0
WireConnection;212;1;329;0
WireConnection;413;0;404;0
WireConnection;413;1;454;0
WireConnection;330;0;324;0
WireConnection;330;3;231;0
WireConnection;331;0;325;0
WireConnection;331;3;230;0
WireConnection;412;0;408;0
WireConnection;412;1;411;0
WireConnection;410;0;412;0
WireConnection;410;1;413;0
WireConnection;227;0;330;0
WireConnection;227;1;331;0
WireConnection;217;0;212;0
WireConnection;217;1;214;0
WireConnection;425;0;424;0
WireConnection;229;0;217;0
WireConnection;229;1;227;0
WireConnection;426;0;410;0
WireConnection;426;1;425;0
WireConnection;427;0;429;0
WireConnection;427;1;424;0
WireConnection;431;5;432;0
WireConnection;428;0;426;0
WireConnection;428;1;427;0
WireConnection;430;0;229;0
WireConnection;430;1;431;0
WireConnection;414;0;428;0
WireConnection;416;0;430;0
WireConnection;443;0;444;0
WireConnection;443;1;445;0
WireConnection;443;2;450;0
WireConnection;364;0;443;0
WireConnection;382;0;370;0
WireConnection;372;0;371;0
WireConnection;372;1;370;0
WireConnection;371;0;369;0
WireConnection;371;1;368;0
WireConnection;381;0;369;0
WireConnection;381;1;382;0
WireConnection;380;0;368;0
WireConnection;380;1;370;0
WireConnection;373;0;368;0
WireConnection;373;1;372;0
WireConnection;379;0;380;0
WireConnection;379;1;381;0
WireConnection;0;0;415;0
WireConnection;0;1;417;0
WireConnection;0;3;340;0
WireConnection;0;4;340;0
ASEEND*/
//CHKSM=A3A9CFDA01C8F9F3D99D780828E0AB809D84724F