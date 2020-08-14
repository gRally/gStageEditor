// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Procedural_Terrain_Shader v3"
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
		[Space(20)][Header(Flat World settings)][Toggle(_FLATWORLDALBEDO_ON)] _FlatWorldAlbedo("Flat World Albedo", Float) = 0
		[Toggle(_FLATWORLDNORMAL_ON)] _FlatWorldNormal("Flat World Normal", Float) = 0
		[NoScaleOffset][Header(The texture mask group on VS must named maskFlatWorld)]_FlatWorldMasks("Flat World Masks", 2D) = "white" {}
		[NoScaleOffset]_AlbedoMapsArrayFlatWorld("Albedo Maps Array FlatWorld", 2DArray ) = "" {}
		[NoScaleOffset]_NormalMapsArrayFlatWorld("Normal Maps Array FlatWorld", 2DArray ) = "" {}
		_UVOffset1stMap("UV & Offset 1st Map", Vector) = (0,0,0,0)
		_UVOffset2ndMap("UV & Offset 2nd Map", Vector) = (0,0,0,0)
		_UVOffset3rdMap("UV & Offset 3rd Map", Vector) = (0,0,0,0)
		_UVOffset4thMap("UV & Offset 4th Map", Vector) = (0,0,0,0)
		_UVOffset5thMap("UV & Offset 5th Map", Vector) = (0,0,0,0)
		[HideInInspector][NoScaleOffset]_FlatNormal("FlatNormal", 2D) = "bump" {}
		[HideInInspector]_VsizetileU("Vsize / tileU", Float) = 0
		[HideInInspector]_TileUUsize("TileU / Usize", Float) = 0
		[HideInInspector]_UsizetileV("Usize / tileV", Float) = 0
		[HideInInspector]_TileVVsize("TileV / Vsize", Float) = 0
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
		#pragma shader_feature _FLATWORLDNORMAL_ON
		#pragma shader_feature _FLATWORLDALBEDO_ON
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
		};

		uniform UNITY_DECLARE_TEX2DARRAY( _NormalMapsArray );
		uniform float2 _MidSlopeNearUV;
		uniform float _CameraDistance;
		uniform float _CamDistanceFalloff;
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
		uniform UNITY_DECLARE_TEX2DARRAY( _NormalMapsArrayFlatWorld );
		uniform float4 _UVOffset5thMap;
		uniform sampler2D _FlatWorldMasks;
		uniform float _UsizetileV;
		uniform float _TileUUsize;
		uniform float _VsizetileU;
		uniform float _TileVVsize;
		uniform float4 _UVOffset4thMap;
		uniform float4 _UVOffset3rdMap;
		uniform float4 _UVOffset2ndMap;
		uniform float4 _UVOffset1stMap;
		uniform sampler2D _FlatNormal;
		uniform UNITY_DECLARE_TEX2DARRAY( _AlbedoMapsArray );
		uniform float _ContrastNoiseMapBChan;
		uniform half _ContrastNoiseMapGChan;
		uniform sampler2D _SecondaryMapVP_Albedo;
		uniform float4 _SecondaryMapVP_Albedo_ST;
		uniform sampler2D _TerraintoPathTexAlbedo;
		uniform float4 _TerraintoPathTexAlbedo_ST;
		uniform UNITY_DECLARE_TEX2DARRAY( _AlbedoMapsArrayFlatWorld );

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_TexCoord301 = i.uv_texcoord * _MidSlopeNearUV;
			float2 MidSlopeNearUV_1312 = uv_TexCoord301;
			float3 ase_worldPos = i.worldPos;
			float clampResult641 = clamp( pow( ( distance( _WorldSpaceCameraPos , ase_worldPos ) / _CameraDistance ) , _CamDistanceFalloff ) , 0.0 , 1.0 );
			half cameraDistance83 = clampResult641;
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
			float2 appendResult573 = (float2(_UVOffset5thMap.x , _UVOffset5thMap.y));
			float2 appendResult588 = (float2(_UVOffset5thMap.z , _UVOffset5thMap.w));
			float2 uv_TexCoord524 = i.uv_texcoord * appendResult573 + appendResult588;
			float2 UV5thMap541 = uv_TexCoord524;
			float2 appendResult526 = (float2(( ( ase_worldPos.x + _UsizetileV ) * _TileUUsize ) , ( ( ase_worldPos.z + _VsizetileU ) * _TileVVsize )));
			float4 tex2DNode501 = tex2D( _FlatWorldMasks, appendResult526 );
			float clampResult503 = clamp( ( tex2DNode501.r + tex2DNode501.g + tex2DNode501.b + tex2DNode501.a ) , 0.0 , 1.0 );
			float FW_mask5545 = ( 1.0 - clampResult503 );
			float3 texArray556 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArrayFlatWorld, float3(UV5thMap541, 4.0)  ), FW_mask5545 );
			float2 appendResult606 = (float2(_UVOffset4thMap.x , _UVOffset4thMap.y));
			float2 appendResult607 = (float2(_UVOffset4thMap.z , _UVOffset4thMap.w));
			float2 uv_TexCoord523 = i.uv_texcoord * appendResult606 + appendResult607;
			float2 UV4thMap540 = uv_TexCoord523;
			float FW_mask4488 = tex2DNode501.r;
			float3 texArray555 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArrayFlatWorld, float3(UV4thMap540, 3.0)  ), FW_mask4488 );
			float2 appendResult617 = (float2(_UVOffset3rdMap.x , _UVOffset3rdMap.y));
			float2 appendResult618 = (float2(_UVOffset3rdMap.z , _UVOffset3rdMap.w));
			float2 uv_TexCoord522 = i.uv_texcoord * appendResult617 + appendResult618;
			float2 UV3rdMap539 = uv_TexCoord522;
			float FW_mask3487 = tex2DNode501.g;
			float3 texArray554 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArrayFlatWorld, float3(UV3rdMap539, 2.0)  ), FW_mask3487 );
			float2 appendResult626 = (float2(_UVOffset2ndMap.x , _UVOffset2ndMap.y));
			float2 appendResult627 = (float2(_UVOffset2ndMap.z , _UVOffset2ndMap.w));
			float2 uv_TexCoord520 = i.uv_texcoord * appendResult626 + appendResult627;
			float2 UV2ndMap538 = uv_TexCoord520;
			float FW_mask2486 = tex2DNode501.b;
			float3 texArray553 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArrayFlatWorld, float3(UV2ndMap538, 1.0)  ), FW_mask2486 );
			float2 appendResult636 = (float2(_UVOffset1stMap.x , _UVOffset1stMap.y));
			float2 appendResult637 = (float2(_UVOffset1stMap.z , _UVOffset1stMap.w));
			float2 uv_TexCoord521 = i.uv_texcoord * appendResult636 + appendResult637;
			float2 UV1stMap537 = uv_TexCoord521;
			float FW_mask1485 = tex2DNode501.a;
			float3 texArray544 = UnpackScaleNormal( UNITY_SAMPLE_TEX2DARRAY(_NormalMapsArrayFlatWorld, float3(UV1stMap537, 0.0)  ), FW_mask1485 );
			float2 uv_FlatNormal656 = i.uv_texcoord;
			float3 FlatWorld_Normal567 = ( ( BlendNormals( BlendNormals( BlendNormals( texArray556 , texArray555 ) , texArray554 ) , BlendNormals( texArray553 , texArray544 ) ) * ( 1.0 - cameraDistance83 ) ) + ( UnpackNormal( tex2D( _FlatNormal, uv_FlatNormal656 ) ) * cameraDistance83 ) );
			#ifdef _FLATWORLDNORMAL_ON
				float3 staticSwitch552 = FlatWorld_Normal567;
			#else
				float3 staticSwitch552 = BlendNormals( BlendNormals( BlendNormals( BlendNormals( texArray328 , texArray329 ) , BlendNormals( BlendNormals( texArray332 , UnpackScaleNormal( tex2D( _SecondaryMapVP_Normal, uv_SecondaryMapVP_Normal ), ( temp_output_179_0 * temp_output_215_0 * SlopeBlend_199 * _SecondaryMapNormalMultiplier ) ) ) , texArray327 ) ) , BlendNormals( texArray330 , texArray331 ) ) , UnpackScaleNormal( tex2D( _TerraintoPathTexNormal, uv_TerraintoPathTexNormal ), VertexColor_AChan423 ) );
			#endif
			float3 NormalsChan416 = staticSwitch552;
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
			float4 texArray511 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(UV1stMap537, 0.0)  );
			float4 texArray634 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(( uv_TexCoord521 * float2( 0.1,0.1 ) ), 0.0)  );
			float4 texArray509 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(UV2ndMap538, 1.0)  );
			float4 texArray624 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(( uv_TexCoord520 * float2( 0.1,0.1 ) ), 1.0)  );
			float4 texArray508 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(UV3rdMap539, 2.0)  );
			float4 texArray609 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(( uv_TexCoord522 * float2( 0.1,0.1 ) ), 2.0)  );
			float4 texArray516 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(UV4thMap540, 3.0)  );
			float4 texArray599 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(( uv_TexCoord523 * float2( 0.1,0.1 ) ), 3.0)  );
			float4 texArray518 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(UV5thMap541, 4.0)  );
			float4 texArray596 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoMapsArrayFlatWorld, float3(( uv_TexCoord524 * float2( 0.1,0.1 ) ), 4.0)  );
			float4 FlatWorld_Albedo463 = ( ( ( ( texArray511 * ( 1.0 - cameraDistance83 ) ) + ( texArray634 * cameraDistance83 ) ) * FW_mask1485 ) + ( ( ( texArray509 * ( 1.0 - cameraDistance83 ) ) + ( texArray624 * cameraDistance83 ) ) * FW_mask2486 ) + ( ( ( texArray508 * ( 1.0 - cameraDistance83 ) ) + ( texArray609 * cameraDistance83 ) ) * FW_mask3487 ) + ( ( ( texArray516 * ( 1.0 - cameraDistance83 ) ) + ( texArray599 * cameraDistance83 ) ) * FW_mask4488 ) + ( FW_mask5545 * ( ( texArray518 * ( 1.0 - saturate( cameraDistance83 ) ) ) + ( texArray596 * cameraDistance83 ) ) ) );
			#ifdef _FLATWORLDALBEDO_ON
				float4 staticSwitch461 = FlatWorld_Albedo463;
			#else
				float4 staticSwitch461 = ( ( ( ( ( ( texArray272 * ( 1.0 - temp_output_115_0 ) ) + ( texArray273 * temp_output_115_0 ) ) * ( 1.0 - temp_output_454_0 ) ) + ( ( ( ( ( texArray271 * ( 1.0 - temp_output_114_0 ) ) + ( texArray270 * temp_output_114_0 ) ) * ( 1.0 - temp_output_450_0 ) ) + ( ( ( ( ( texArray333 * ( 1.0 - temp_output_170_0 ) ) + ( tex2DNode167 * temp_output_170_0 ) ) * ( 1.0 - temp_output_113_0 ) ) + ( ( ( texArray268 * ( 1.0 - temp_output_170_0 ) ) + ( tex2DNode167 * temp_output_170_0 ) ) * temp_output_113_0 ) ) * temp_output_450_0 ) ) * temp_output_454_0 ) ) * ( 1.0 - VertexColor_AChan423 ) ) + ( tex2D( _TerraintoPathTexAlbedo, uv_TerraintoPathTexAlbedo ) * VertexColor_AChan423 ) );
			#endif
			float4 AlbedoChan414 = staticSwitch461;
			o.Albedo = AlbedoChan414.rgb;
			float temp_output_340_0 = 0.0;
			o.Metallic = temp_output_340_0;
			o.Smoothness = temp_output_340_0;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard keepalpha fullforwardshadows 

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
				float2 customPack1 : TEXCOORD1;
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
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
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
Version=17703
1962;9;1845;1018;6030.116;7179.269;1.655;True;True
Node;AmplifyShaderEditor.SamplerNode;55;405.9958,-641.5554;Inherit;True;Property;_SlopeNoiseMasks;Slope Noise Masks;5;0;Create;True;0;0;False;0;-1;None;17d41c6ac262c9a4b9612b5027c39cf8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;101;463.329,-1471.433;Inherit;False;2139.837;502.0616;Comment;22;52;43;46;96;59;58;62;48;54;64;79;80;72;87;89;88;91;97;98;65;99;100;Slope Blender;1,1,1,1;0;0
Node;AmplifyShaderEditor.GammaToLinearNode;421;713.7949,-637.1512;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;52;517.3821,-1120.689;Inherit;False;Property;_LowtoMedSlope;Low to Med Slope;3;0;Create;True;0;0;False;0;0;2.96;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;43;658.3306,-1421.433;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;46;493.704,-1236.619;Inherit;False;Property;_OverallSlopeContrast;Overall Slope Contrast;2;0;Create;True;0;0;False;1;Header(Slope Blender Controls);0;2.02;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;422;919.7399,-634.4264;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.AbsOpNode;97;718.7261,-1121.566;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;536;-7590.861,-6847.858;Inherit;False;6636.256;3463.603;;96;638;637;636;628;627;626;635;634;633;632;631;630;629;623;622;621;620;619;489;521;471;511;537;616;618;617;625;624;615;614;613;612;611;492;520;538;491;509;607;606;608;605;603;604;602;601;610;609;494;522;539;495;508;463;470;472;498;594;497;593;592;518;486;596;487;485;516;591;599;488;545;541;590;600;540;598;473;524;523;503;588;573;502;572;526;527;530;532;531;525;639;666;667;668;669;670;Flat World Albedo;1,1,1,1;0;0
Node;AmplifyShaderEditor.AbsOpNode;96;746.9955,-1234.241;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;164;452.2762,-941.088;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;361;972.1348,-493.4162;Half;False;Property;_ContrastNoiseMapRChan;Contrast Noise Map R Chan;6;0;Create;True;0;0;False;0;0;1.47;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;59;881.5767,-1159.477;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;357;1202.458,-623.2498;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;358;1367.323,-611.1;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;58;891.6416,-1261.346;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;344;460.1158,-767.3024;Half;False;Property;_ContrastVP;Contrast VP;16;0;Create;True;0;0;False;0;0;2.12;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;62;1033.541,-1160.741;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;354;647.6541,-914.2979;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;525;-5944.227,-6459.248;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;668;-5878.786,-6257.008;Inherit;False;Property;_VsizetileU;Vsize / tileU;41;1;[HideInInspector];Create;True;0;0;False;0;0;3590.891;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;667;-5874.161,-6588.273;Inherit;False;Property;_UsizetileV;Usize / tileV;43;1;[HideInInspector];Create;True;0;0;False;0;0;1837.593;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;48;1208.017,-1242.209;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;646;890.389,-1842.311;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;531;-5657.908,-6493.099;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;359;1544.004,-612.29;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;532;-5654.503,-6373.695;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;666;-5512.652,-6597.783;Inherit;False;Property;_TileUUsize;TileU / Usize;42;1;[HideInInspector];Create;True;0;0;False;0;0;0.0002720951;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;1152.43,-1087.493;Inherit;False;Property;_MedtoHighSlope;Med to High Slope;4;0;Create;True;0;0;False;0;0;2.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;669;-5492.996,-6263.348;Inherit;False;Property;_TileVVsize;TileV / Vsize;44;1;[HideInInspector];Create;True;0;0;False;0;0;0.0005569648;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;645;963.4217,-1694.671;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;355;792.629,-906.6579;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.AbsOpNode;98;1388.627,-1107.706;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;644;1197.415,-1785.896;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;4;1200.71,-1671.406;Inherit;False;Property;_CameraDistance;Camera Distance;0;0;Create;True;0;0;False;1;Header(Camera Distance Blender (Near to Far));0;300;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;527;-5280.622,-6505.245;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;356;935.0985,-908.0179;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;54;1366.433,-1223.929;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;360;1687.468,-613.445;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;530;-5264.823,-6366.2;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;526;-5083.844,-6424.808;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.CommentaryNode;670;-4911.171,-6519.375;Inherit;False;571.8501;293.6499;The texture mask group on VS must named "maskFlatWorld";1;501;WARNING;1,0.484723,0,1;0;0
Node;AmplifyShaderEditor.Vector2Node;295;576.6749,-2656.671;Inherit;False;Property;_LowSlopeNearUV;LowSlope Near UV;17;0;Create;True;0;0;False;1;Header(UV Controls);1,1;0.02,0.02;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;64;1518.906,-1140.613;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1.1;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;297;575.9579,-2513.983;Inherit;False;Property;_LowSlopeFarUV;LowSlope Far UV;18;0;Create;True;0;0;False;0;1,1;0.005,0.005;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SaturateNode;353;1057.704,-903.9228;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;643;1369.346,-1782.421;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;171;755.0214,-41.0242;Inherit;False;Property;_VertexPaintBlenderMultiplier;VertexPaint Blender Multiplier;13;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;126;2156.465,-624.1102;Inherit;False;SlopeNoiseMaskRChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;1207.545,-1584.791;Inherit;False;Property;_CamDistanceFalloff;Cam Distance Falloff;1;0;Create;True;0;0;False;0;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;204;1383.106,-40.64891;Inherit;False;VP_Multy;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMaxOpNode;79;1743.166,-1286.216;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;642;1524.911,-1781.036;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;296;867.8963,-2521.708;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;501;-4664.896,-6465.77;Inherit;True;Property;_FlatWorldMasks;Flat World Masks;32;1;[NoScaleOffset];Create;False;0;0;False;1;Header(The texture mask group on VS must named maskFlatWorld);-1;None;406d58c88763b1a49814962dd08e3a46;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;151;-6269.269,-1559.246;Inherit;False;126;SlopeNoiseMaskRChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;294;869.9277,-2661.542;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;435;1323.158,-496.4086;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;437;1088.18,-385.5399;Half;False;Property;_ContrastNoiseMapGChan;Contrast Noise Map G Chan;7;0;Create;True;0;0;False;0;0;1.84;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;165;1204.683,-911.3782;Inherit;False;VertexColor_RChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;168;-6122.151,-1364.745;Inherit;False;165;VertexColor_RChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;307;1122.816,-2661.167;Inherit;False;LowSlopeNearUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;299;1444.052,-2665.085;Inherit;False;Property;_MidSlopeNearUV;MidSlope Near UV;19;0;Create;True;0;0;False;0;1,1;0.01,0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector4Node;608;-4956.859,-5518.89;Inherit;False;Property;_UVOffset4thMap;UV & Offset 4th Map;38;0;Create;True;0;0;False;0;0,0,0,0;0.05,0.05,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;205;-6066.101,-1454.946;Inherit;False;204;VP_Multy;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;366;-5977.259,-1552.009;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;308;1126.631,-2527.746;Inherit;False;LowSlopeFarUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;502;-3924.684,-6385.413;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;300;1446.456,-2523.146;Inherit;False;Property;_MidSlopeFarUV;MidSlope Far UV;20;0;Create;True;0;0;False;0;1,1;0.002,0.002;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector4Node;572;-4948.744,-6024.934;Inherit;False;Property;_UVOffset5thMap;UV & Offset 5th Map;39;0;Create;True;0;0;False;0;0,0,0,0;0.07,0.07,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;80;1909.556,-1285.231;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;641;1729.058,-1784.395;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;436;1488.023,-484.2587;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;315;-6271.809,-2012.885;Inherit;False;308;LowSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;503;-3647.485,-6357.152;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;439;1664.704,-485.4487;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;170;-5790.101,-1437.796;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;607;-4695.534,-5428.745;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;606;-4698.228,-5530.386;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;459;1157.991,-289.9096;Inherit;False;Property;_ContrastNoiseMapBChan;Contrast Noise Map B Chan;8;0;Create;True;0;0;False;0;0;1.83;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;455;1449.596,-374.6834;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;87;2068.082,-1286.96;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;314;-6266.439,-2245.616;Inherit;False;307;LowSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;588;-4687.419,-5934.789;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;301;1744.862,-2682.045;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;302;1748.545,-2534.591;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;573;-4690.113,-6036.43;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;1934.758,-1791.101;Half;False;cameraDistance;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector4Node;638;-4898.005,-3873.085;Inherit;False;Property;_UVOffset1stMap;UV & Offset 1st Map;35;0;Create;True;0;0;False;0;0,0,0,0;0.05,0.05,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;276;-6031.279,-2336.036;Inherit;False;385.5247;534.291;Low Slope (Near-Far);2;268;333;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector4Node;616;-4930.538,-4964.884;Inherit;False;Property;_UVOffset3rdMap;UV & Offset 3rd Map;37;0;Create;True;0;0;False;0;0,0,0,0;0.05,0.05,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;628;-4913.749,-4430.063;Inherit;False;Property;_UVOffset2ndMap;UV & Offset 2nd Map;36;0;Create;True;0;0;False;0;0,0,0,0;0.05,0.05,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;626;-4653.532,-4439.8;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;438;1808.168,-486.6038;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;167;-5969.021,-1784.694;Inherit;True;Property;_SecondaryMapVP_Albedo;Secondary Map VP Blended (Albedo);14;0;Create;False;0;0;False;0;-1;None;d68366b5fdf0f9d43af6c813ac51b5b5;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;387;-5647.844,-2174.075;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;627;-4650.838,-4338.158;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;473;-3025.403,-6262.843;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;618;-4666.043,-4874.564;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;456;1614.461,-362.5335;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;313;2052.281,-2532.294;Inherit;False;MidSlopeFarUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureArrayNode;268;-5972.286,-2036.096;Inherit;True;Property;_AlbedoNoSlopeNear;Albedo NoSlope Near;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;88;2217.123,-1288.865;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMinOpNode;72;1746.504,-1102.371;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;312;2044.869,-2669.149;Inherit;False;MidSlopeNearUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;180;-6389.369,412.6749;Inherit;False;126;SlopeNoiseMaskRChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;333;-5989.312,-2271.534;Inherit;True;Property;_AlbedoMapsArray;Albedo Maps Array;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Object;-1;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;523;-4518.09,-5518.607;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;109;-4557.529,-1736.766;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;637;-4635.094,-3781.181;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;392;-5621.704,-1886.992;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;105;-5488.919,-1449.435;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;636;-4637.788,-3882.822;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;305;580.9476,-2236.007;Inherit;False;Property;_HighSlopeNearUV;HighSlope Near UV;21;0;Create;True;0;0;False;0;1,1;0.01,0.01;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DynamicAppendNode;617;-4668.737,-4976.206;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;306;594.2219,-2103.849;Inherit;False;Property;_HighSlopeFarUV;HighSlope Far UV;22;0;Create;True;0;0;False;0;1,1;0.005,0.005;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;524;-4514.478,-6000.691;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;541;-4223.363,-6009.78;Inherit;False;UV5thMap;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;457;1791.142,-363.7235;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;385;-5490.243,-2242.794;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;391;-5465.82,-1836.751;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;420;-6109.586,420.5436;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;540;-4232.815,-5510.331;Inherit;False;UV4thMap;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;522;-4457.721,-4970.188;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;184;-6308.01,202.485;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;488;-4176.82,-6801.063;Inherit;False;FW_mask4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;521;-4484.91,-3888.335;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;114;-4309.22,-1737.845;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;520;-4489.41,-4435.398;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;390;-5464.103,-1955.711;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-6263.594,575.995;Inherit;False;165;VertexColor_RChan;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;571;-4188.133,1289.346;Inherit;False;2705.416;1370.486;;21;567;570;569;566;544;565;554;553;546;559;548;556;555;557;558;560;561;562;563;564;656;Flat World Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;545;-2783.211,-6180.386;Inherit;False;FW_mask5;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;440;2271.704,-492.9832;Inherit;False;SlopeNoiseMaskGChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;316;-4760.84,-2223.025;Inherit;False;312;MidSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;206;-6214.866,499.58;Inherit;False;204;VP_Multy;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;386;-5491.96,-2123.834;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;99;2362.125,-1292.826;Half;False;SlopeBlend_1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;275;-4527.53,-2306.155;Inherit;False;390.1902;553.3882;Mid Slope (Near-Far);2;270;271;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;113;-5263.259,-1450.965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;317;-4744.84,-1967.025;Inherit;False;313;MidSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;89;1910.527,-1104.556;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;303;893.2517,-2222.619;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;304;893.1249,-2109.454;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;486;-4184.691,-6607.525;Inherit;False;FW_mask2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;487;-4181.56,-6709.704;Inherit;False;FW_mask3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;388;-5346.203,-2165.004;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;397;-4111.615,-2213.965;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;458;1934.606,-364.8786;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;190;-6052.01,202.485;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;485;-4182.931,-6518.767;Inherit;False;FW_mask1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;396;-5118.611,-1716.338;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;537;-4218.523,-3890.33;Inherit;False;UV1stMap;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;310;1149.684,-2236.116;Inherit;False;HighSlopeNearUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;103;-4495.778,-1413.936;Inherit;False;99;SlopeBlend_1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;590;-3642.358,-5914.636;Inherit;False;83;cameraDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;112;-3341.394,-1817.475;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;271;-4478.15,-2258.155;Inherit;True;Property;_TextureArray4;Texture Array 4;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;389;-5320.063,-1877.921;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;561;-4126.433,1617.908;Inherit;False;540;UV4thMap;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;564;-4131.602,1443.434;Inherit;False;545;FW_mask5;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;182;-4503.93,37.36503;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;2086.247,-1106.166;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;562;-4122.241,1721.894;Inherit;False;488;FW_mask4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;563;-4138.133,1342.958;Inherit;False;541;UV5thMap;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;539;-4178.559,-4972.572;Inherit;False;UV3rdMap;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-5940.01,506.485;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;311;1168.576,-2099.281;Inherit;False;HighSlopeFarUV_1;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;441;-4553.276,-1520.095;Inherit;False;440;SlopeNoiseMaskGChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;270;-4498.29,-1986.155;Inherit;True;Property;_TextureArray3;Texture Array 3;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;538;-4200.121,-4435.173;Inherit;False;UV2ndMap;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;598;-4202.37,-5879.507;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;629;-3562.182,-3770.365;Inherit;False;83;cameraDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;619;-3584.826,-4293.887;Inherit;False;83;cameraDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;222;-6212.01,330.485;Inherit;False;99;SlopeBlend_1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;208;-5732.713,-142.79;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;215;-5873.371,169.165;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;546;-4117.696,2412.331;Inherit;False;537;UV1stMap;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;559;-4098.354,1885.839;Inherit;False;539;UV3rdMap;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;460;2307.382,-371.3147;Inherit;False;SlopeNoiseMaskBChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;560;-4094.162,1988.654;Inherit;False;487;FW_mask3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;556;-3786.058,1339.346;Inherit;True;Property;_TextureArray16;Texture Array 16;34;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;544;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;191;-4134.57,785.3248;Inherit;False;83;cameraDistance;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;611;-3616.653,-4805.152;Inherit;False;83;cameraDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;395;-4957.646,-1629.267;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;198;-4664.26,-132.87;Inherit;False;99;SlopeBlend_1;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;548;-4111.164,2512.807;Inherit;False;485;FW_mask1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;274;-3262.335,-2418.945;Inherit;False;328.3904;568.6597;High Slope (Near-Far);2;272;273;;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;318;-3510.09,-2342.275;Inherit;False;310;HighSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;639;-3404.79,-5920.842;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;186;-4247.931,37.36503;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendOpsNode;450;-4224.428,-1545.506;Inherit;False;Overlay;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;319;-3499.735,-2064.63;Inherit;False;311;HighSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;558;-4114.051,2243.714;Inherit;False;486;FW_mask2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;557;-4093.672,2138.558;Inherit;False;538;UV2ndMap;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;394;-4955.929,-1748.227;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;600;-4187.387,-5271.269;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureArrayNode;555;-3775.579,1615.722;Inherit;True;Property;_TextureArray15;Texture Array 15;34;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;544;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;419;-5871.181,30.46696;Inherit;False;Property;_SecondaryMapNormalMultiplier;Secondary Map Normal Multiplier;24;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;601;-3610.557,-5348.625;Inherit;False;83;cameraDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;115;-3098.065,-1810.815;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;625;-4146.055,-4172.85;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;610;-4123.23,-4720.678;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;635;-4107.704,-3627.371;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0.1,0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;338;-5893.268,-68.46199;Inherit;False;Property;_LowSlopeNearNormalMultiplier;Low Slope Near Normal Multiplier;23;0;Create;True;0;0;False;1;Header(Normal Maps Multipliers);0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;399;-3948.933,-2245.854;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;398;-3950.65,-2126.894;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;100;2282.604,-1104.936;Half;False;SlopeBlend_2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;511;-3945.783,-3918.314;Inherit;True;Property;_TextureArray8;Texture Array 8;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;565;-3272.059,1665.872;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureArrayNode;544;-3737.227,2385.396;Inherit;True;Property;_NormalMapsArrayFlatWorld;Normal Maps Array FlatWorld;34;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Object;-1;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;185;-5524.991,75.63;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;336;-3991.754,175.5885;Inherit;False;Property;_MediumSlopeFarNormalMultiplier;Medium Slope Far Normal Multiplier;27;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;554;-3773.676,1891.127;Inherit;True;Property;_TextureArray14;Texture Array 14;34;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;544;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;453;-3163.456,-1570.033;Inherit;False;460;SlopeNoiseMaskBChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;553;-3770.431,2145.093;Inherit;True;Property;_TextureArray13;Texture Array 13;34;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;544;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;233;-4109.37,670.8451;Inherit;False;100;SlopeBlend_2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;624;-3929.459,-4196.33;Inherit;True;Property;_TextureArray20;Texture Array 20;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;591;-3255.52,-5936.152;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;218;-4087.93,-42.63498;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;518;-3969.943,-6033.36;Inherit;True;Property;_TextureArray12;Texture Array 12;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureArrayNode;596;-3966.496,-5825.462;Inherit;True;Property;_TextureArray17;Texture Array 17;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;393;-4811.889,-1670.437;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;630;-3310.458,-3794.069;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;612;-3364.93,-4828.857;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;216;-5492.01,-149.515;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;516;-3970.218,-5540.699;Inherit;True;Property;_TextureArray11;Texture Array 11;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;400;-3804.893,-2168.064;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;320;-5669.37,-273.2751;Inherit;False;307;LowSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureArrayNode;634;-3941.844,-3661.79;Inherit;True;Property;_TextureArray21;Texture Array 21;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;339;-5775.225,560.3792;Inherit;False;Property;_LowSlopeFarNormalMultiplier;Low Slope Far Normal Multiplier;25;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;599;-3957.711,-5288.195;Inherit;True;Property;_TextureArray18;Texture Array 18;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureArrayNode;509;-3958.333,-4461.121;Inherit;True;Property;_TextureArray5;Texture Array 5;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;401;-3812.744,-1709.176;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;508;-3939.803,-4990.394;Inherit;True;Property;_AlbedoMapsArrayFlatWorld;Albedo Maps Array FlatWorld;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Object;-1;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;602;-3358.834,-5372.33;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;273;-3239.96,-2082.945;Inherit;True;Property;_TextureArray6;Texture Array 6;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;235;-4632.225,-390.6102;Inherit;False;100;SlopeBlend_2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;272;-3244.305,-2365.95;Inherit;True;Property;_TextureArray7;Texture Array 7;9;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Textures Arrays);None;0;Instance;333;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;405;-2907.037,-2326.879;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;337;-3919.548,-296.8571;Inherit;False;Property;_MediumSlopeNearNormalMultiplier;Medium Slope Near Normal Multiplier;26;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;609;-3942.706,-4752.225;Inherit;True;Property;_TextureArray19;Texture Array 19;33;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;508;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;620;-3333.103,-4317.592;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;-3846.57,785.3248;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;226;-4119.93,-154.635;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;102;-3131.63,-1471.095;Inherit;False;100;SlopeBlend_2;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;406;-2744.354,-2358.768;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;407;-2746.071,-2239.808;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;335;-3786.462,888.589;Inherit;False;Property;_HighSlopeFarNormalMultiplier;High Slope Far Normal Multiplier;29;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;228;-3727.79,495.225;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;631;-3091.708,-3709.617;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;282;-3461.594,-377.2501;Inherit;False;373.0833;508.5517;Mid Slope (Near-Far);2;329;328;;1,1,1,1;0;0
Node;AmplifyShaderEditor.BlendNormalsNode;569;-2991.557,2088.53;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;265;-3853.37,670.8451;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;614;-3145.824,-4912.296;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BlendOpsNode;454;-2841.338,-1580.415;Inherit;False;Overlay;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;323;-3865.315,-394.3451;Inherit;False;312;MidSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;632;-3091.353,-3877.508;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;592;-3091.77,-5850.599;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;604;-3140.084,-5287.877;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;225;-3707.424,48.44505;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;223;-5513.21,397.685;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;321;-5577.51,307.2849;Inherit;False;308;LowSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;322;-3831.93,-58.63497;Inherit;False;313;MidSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;566;-3004.78,1865.732;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.TextureArrayNode;332;-5338.502,-258.185;Inherit;True;Property;_NormalMapsArray;Normal Maps Array;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Object;-1;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;622;-3113.997,-4401.031;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;593;-3091.413,-6018.49;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;613;-3146.18,-4744.404;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;181;-5348.01,26.48502;Inherit;True;Property;_SecondaryMapVP_Normal;Secondary Map VP Blended (Normal);15;0;Create;False;0;0;False;0;-1;None;6e75dcf2f88b61f4f92a017c49f11b3e;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;224;-3596.623,-254.6453;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;402;-3651.778,-1622.105;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;621;-3114.353,-4233.139;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;403;-3650.061,-1741.065;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;603;-3139.728,-5455.769;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;649;-2537.882,1848.722;Inherit;False;83;cameraDistance;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;334;-3749.654,572.9985;Inherit;False;Property;_HighSlopeNearNormalMultiplier;High Slope Near Normal Multiplier;28;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;594;-2928.333,-5929.85;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;404;-3506.021,-1663.275;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureArrayNode;328;-3413.594,-313.2501;Inherit;True;Property;_TextureArray1;Texture Array 1;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;489;-2686.894,-3853.05;Inherit;False;485;FW_mask1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;285;-3277.37,366.845;Inherit;False;381.8091;535.0601;High Slope (Near-Far);2;331;330;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;633;-2928.271,-3788.868;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;411;-2604.778,-1726.982;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;605;-2976.647,-5367.128;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;325;-3597.37,670.8451;Inherit;False;311;HighSlopeFarUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;408;-2600.313,-2280.978;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureArrayNode;329;-3413.594,-73.24999;Inherit;True;Property;_TextureArray10;Texture Array 10;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;3;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;497;-2742.62,-5406.694;Inherit;False;488;FW_mask4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;492;-2723.637,-4398.609;Inherit;False;486;FW_mask2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;623;-2950.916,-4312.39;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;494;-2731.924,-4885.439;Inherit;False;487;FW_mask3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;230;-3432.521,790.2151;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;231;-3437.869,508.805;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;650;-2286.158,1825.018;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureArrayNode;327;-5300.01,298.485;Inherit;True;Property;_TextureArray9;Texture Array 9;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;1;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;656;-2680.268,2114.208;Inherit;True;Property;_FlatNormal;FlatNormal;40;2;[HideInInspector];[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;615;-2982.743,-4823.655;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.GetLocalVarNode;324;-3613.37,398.845;Inherit;False;310;HighSlopeNearUV_1;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;423;1229.226,-797.4306;Inherit;False;VertexColor_AChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;570;-2685.798,1970.231;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;207;-5004.387,-139.6849;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BlendNormalsNode;212;-3043.3,-220.0201;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;498;-2514.752,-5497.605;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureArrayNode;331;-3213.37,670.8451;Inherit;True;Property;_TextureArray2;Texture Array 2;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;5;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;651;-2067.054,1741.579;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;412;-2442.095,-1758.871;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;214;-4717.572,249.905;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;491;-2468.787,-4481.331;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;652;-2067.409,1909.47;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;433;-2532.336,769.0986;Inherit;False;694.2002;301.6799;Probabilmente va usato anche per "abbassare" il normal power delle altre mappe;1;432;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;472;-2522.707,-5983.777;Inherit;True;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.TextureArrayNode;330;-3229.37,414.845;Inherit;True;Property;_TextureArray0;Texture Array 0;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Instance;332;Auto;True;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;4;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;413;-2443.812,-1639.911;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;424;-2514.85,-1456.806;Inherit;False;423;VertexColor_AChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;495;-2495.994,-4985.939;Inherit;True;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;471;-2489.609,-3920.323;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;217;-2820.01,202.485;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;429;-2500.108,-1339.203;Inherit;True;Property;_TerraintoPathTexAlbedo;Terrain to Path Tex Albedo;11;0;Create;True;0;0;False;0;-1;None;ca5a7e3f6c89fb44ab33c482124a799e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;432;-2482.336,819.0986;Inherit;False;423;VertexColor_AChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;425;-2207.707,-1492.399;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;470;-1722.636,-5300.576;Inherit;True;5;5;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT4;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;227;-2829.37,462.845;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;653;-1903.972,1830.219;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;410;-2298.054,-1681.081;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;567;-1726.516,1963.056;Inherit;False;FlatWorld_Normal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;431;-1959.072,547.8278;Inherit;True;Property;_TerraintoPathTexNormal;Terrain to Path Tex Normal;12;0;Create;True;0;0;False;0;-1;None;02ea2d9225227c243acd283bdddf6575;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;463;-1273.918,-4866.709;Inherit;False;FlatWorld_Albedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;229;-2426.096,204.8299;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;426;-2002.884,-1572.448;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;427;-2010.621,-1442.953;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;464;-1675.963,-1695.622;Inherit;False;463;FlatWorld_Albedo;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;430;-1635.664,341.3177;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;428;-1827.238,-1502.183;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;568;-1517.188,492.2856;Inherit;False;567;FlatWorld_Normal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;552;-1319.598,276.1972;Inherit;False;Property;_FlatWorldNormal;Flat World Normal;31;0;Create;True;0;0;False;0;0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;FLOAT3;0,0,0;False;0;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT3;0,0,0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StaticSwitch;461;-1373.526,-1699.728;Inherit;False;Property;_FlatWorldAlbedo;Flat World Albedo;30;0;Create;True;0;0;False;2;Space(20);Header(Flat World settings);0;0;0;True;;Toggle;2;Key0;Key1;Create;False;9;1;COLOR;0,0,0,0;False;0;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;5;COLOR;0,0,0,0;False;6;COLOR;0,0,0,0;False;7;COLOR;0,0,0,0;False;8;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;416;-870.6987,277.9868;Inherit;False;NormalsChan;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.CommentaryNode;383;1415.937,683.7157;Inherit;False;649.8457;333.8849;Metodo 2;2;379;381;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;414;-952.3846,-1506.981;Inherit;False;AlbedoChan;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;375;1123.656,184.8561;Inherit;False;1454.07;1029.75;Comment;8;373;368;372;370;371;369;380;382;LERP substitute;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;381;1669.242,884.6006;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;341;-61.26202,432.5794;Inherit;False;364;Debug;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;382;1465.937,903.8005;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;370;1147.111,650.6559;Inherit;False;Constant;_Float4;Float 4;26;0;Create;True;0;0;False;0;0;0.5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;368;1173.656,234.8561;Inherit;False;Constant;_Color0;Color 0;25;0;Create;True;0;0;False;0;1,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode;371;1479.836,403.0663;Inherit;False;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;417;-28.59991,92.77209;Inherit;False;416;NormalsChan;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;379;1911.782,778.5956;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;373;1793.576,401.1759;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;372;1634.817,442.756;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;550;-1309.164,-1297.438;Inherit;False;Constant;_Color7;Color 7;45;0;Create;True;0;0;False;0;0.4622642,0.4622642,0.4622642,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;380;1666.598,733.7157;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;364;-46.21906,547.2897;Inherit;False;Debug;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;415;-8.029516,-2.697543;Inherit;False;414;AlbedoChan;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.CameraDepthFade;2;519.2799,-1822.651;Inherit;False;3;2;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;369;1173.656,452.2056;Inherit;False;Constant;_Color1;Color 1;25;0;Create;True;0;0;False;0;0,0.2876301,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;340;-41.86125,235.8529;Inherit;False;Constant;_Float3;Float 3;24;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;269.08,36.79;Float;False;True;-1;3;ASEMaterialInspector;0;0;Standard;gRally/Procedural_Terrain_Shader v3;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
Node;AmplifyShaderEditor.CommentaryNode;384;1429.836,351.1759;Inherit;False;517.7394;224.5801;Metodo 1;0;;1,1,1,1;0;0
WireConnection;421;0;55;0
WireConnection;422;0;421;0
WireConnection;97;0;52;0
WireConnection;96;0;46;0
WireConnection;59;0;43;2
WireConnection;59;1;97;0
WireConnection;357;0;422;0
WireConnection;358;0;357;0
WireConnection;358;1;361;0
WireConnection;58;0;43;2
WireConnection;58;1;96;0
WireConnection;62;0;59;0
WireConnection;354;0;164;1
WireConnection;48;0;58;0
WireConnection;48;1;62;0
WireConnection;531;0;525;1
WireConnection;531;1;667;0
WireConnection;359;0;358;0
WireConnection;532;0;525;3
WireConnection;532;1;668;0
WireConnection;355;0;354;0
WireConnection;355;1;344;0
WireConnection;98;0;65;0
WireConnection;644;0;646;0
WireConnection;644;1;645;0
WireConnection;527;0;531;0
WireConnection;527;1;666;0
WireConnection;356;0;355;0
WireConnection;54;0;48;0
WireConnection;360;0;359;0
WireConnection;530;0;532;0
WireConnection;530;1;669;0
WireConnection;526;0;527;0
WireConnection;526;1;530;0
WireConnection;64;0;54;0
WireConnection;64;1;98;0
WireConnection;353;0;356;0
WireConnection;643;0;644;0
WireConnection;643;1;4;0
WireConnection;126;0;360;0
WireConnection;204;0;171;0
WireConnection;79;0;64;0
WireConnection;642;0;643;0
WireConnection;642;1;3;0
WireConnection;296;0;297;0
WireConnection;501;1;526;0
WireConnection;294;0;295;0
WireConnection;435;0;422;1
WireConnection;165;0;353;0
WireConnection;307;0;294;0
WireConnection;366;0;151;0
WireConnection;308;0;296;0
WireConnection;502;0;501;1
WireConnection;502;1;501;2
WireConnection;502;2;501;3
WireConnection;502;3;501;4
WireConnection;80;0;79;0
WireConnection;641;0;642;0
WireConnection;436;0;435;0
WireConnection;436;1;437;0
WireConnection;503;0;502;0
WireConnection;439;0;436;0
WireConnection;170;0;205;0
WireConnection;170;1;168;0
WireConnection;170;2;366;0
WireConnection;607;0;608;3
WireConnection;607;1;608;4
WireConnection;606;0;608;1
WireConnection;606;1;608;2
WireConnection;455;0;422;2
WireConnection;87;0;80;0
WireConnection;588;0;572;3
WireConnection;588;1;572;4
WireConnection;301;0;299;0
WireConnection;302;0;300;0
WireConnection;573;0;572;1
WireConnection;573;1;572;2
WireConnection;83;0;641;0
WireConnection;626;0;628;1
WireConnection;626;1;628;2
WireConnection;438;0;439;0
WireConnection;387;0;170;0
WireConnection;627;0;628;3
WireConnection;627;1;628;4
WireConnection;473;0;503;0
WireConnection;618;0;616;3
WireConnection;618;1;616;4
WireConnection;456;0;455;0
WireConnection;456;1;459;0
WireConnection;313;0;302;0
WireConnection;268;0;315;0
WireConnection;88;0;87;0
WireConnection;72;0;64;0
WireConnection;312;0;301;0
WireConnection;333;0;314;0
WireConnection;523;0;606;0
WireConnection;523;1;607;0
WireConnection;637;0;638;3
WireConnection;637;1;638;4
WireConnection;392;0;170;0
WireConnection;636;0;638;1
WireConnection;636;1;638;2
WireConnection;617;0;616;1
WireConnection;617;1;616;2
WireConnection;524;0;573;0
WireConnection;524;1;588;0
WireConnection;541;0;524;0
WireConnection;457;0;456;0
WireConnection;385;0;333;0
WireConnection;385;1;387;0
WireConnection;391;0;167;0
WireConnection;391;1;170;0
WireConnection;420;0;180;0
WireConnection;540;0;523;0
WireConnection;522;0;617;0
WireConnection;522;1;618;0
WireConnection;488;0;501;1
WireConnection;521;0;636;0
WireConnection;521;1;637;0
WireConnection;114;0;109;0
WireConnection;520;0;626;0
WireConnection;520;1;627;0
WireConnection;390;0;268;0
WireConnection;390;1;392;0
WireConnection;545;0;473;0
WireConnection;440;0;438;0
WireConnection;386;0;167;0
WireConnection;386;1;170;0
WireConnection;99;0;88;0
WireConnection;113;0;105;0
WireConnection;89;0;72;0
WireConnection;303;0;305;0
WireConnection;304;0;306;0
WireConnection;486;0;501;3
WireConnection;487;0;501;2
WireConnection;388;0;385;0
WireConnection;388;1;386;0
WireConnection;397;0;114;0
WireConnection;458;0;457;0
WireConnection;190;0;184;0
WireConnection;485;0;501;4
WireConnection;396;0;113;0
WireConnection;537;0;521;0
WireConnection;310;0;303;0
WireConnection;271;0;316;0
WireConnection;389;0;390;0
WireConnection;389;1;391;0
WireConnection;91;0;89;0
WireConnection;539;0;522;0
WireConnection;179;0;420;0
WireConnection;179;1;206;0
WireConnection;179;2;176;0
WireConnection;311;0;304;0
WireConnection;270;0;317;0
WireConnection;538;0;520;0
WireConnection;598;0;524;0
WireConnection;208;0;179;0
WireConnection;215;0;190;0
WireConnection;460;0;458;0
WireConnection;556;0;563;0
WireConnection;556;3;564;0
WireConnection;395;0;389;0
WireConnection;395;1;113;0
WireConnection;639;0;590;0
WireConnection;186;0;182;0
WireConnection;450;0;441;0
WireConnection;450;1;103;0
WireConnection;394;0;388;0
WireConnection;394;1;396;0
WireConnection;600;0;523;0
WireConnection;555;0;561;0
WireConnection;555;3;562;0
WireConnection;115;0;112;0
WireConnection;625;0;520;0
WireConnection;610;0;522;0
WireConnection;635;0;521;0
WireConnection;399;0;271;0
WireConnection;399;1;397;0
WireConnection;398;0;270;0
WireConnection;398;1;114;0
WireConnection;100;0;91;0
WireConnection;511;0;537;0
WireConnection;565;0;556;0
WireConnection;565;1;555;0
WireConnection;544;0;546;0
WireConnection;544;3;548;0
WireConnection;185;0;179;0
WireConnection;185;1;215;0
WireConnection;185;2;222;0
WireConnection;185;3;419;0
WireConnection;554;0;559;0
WireConnection;554;3;560;0
WireConnection;553;0;557;0
WireConnection;553;3;558;0
WireConnection;624;0;625;0
WireConnection;591;0;639;0
WireConnection;218;0;186;0
WireConnection;518;0;541;0
WireConnection;596;0;598;0
WireConnection;393;0;394;0
WireConnection;393;1;395;0
WireConnection;630;0;629;0
WireConnection;612;0;611;0
WireConnection;216;0;208;0
WireConnection;216;1;215;0
WireConnection;216;2;222;0
WireConnection;216;3;338;0
WireConnection;516;0;540;0
WireConnection;400;0;399;0
WireConnection;400;1;398;0
WireConnection;634;0;635;0
WireConnection;599;0;600;0
WireConnection;509;0;538;0
WireConnection;401;0;450;0
WireConnection;508;0;539;0
WireConnection;602;0;601;0
WireConnection;273;0;319;0
WireConnection;272;0;318;0
WireConnection;405;0;115;0
WireConnection;609;0;610;0
WireConnection;620;0;619;0
WireConnection;193;0;191;0
WireConnection;226;0;198;0
WireConnection;406;0;272;0
WireConnection;406;1;405;0
WireConnection;407;0;273;0
WireConnection;407;1;115;0
WireConnection;228;0;193;0
WireConnection;631;0;634;0
WireConnection;631;1;629;0
WireConnection;569;0;553;0
WireConnection;569;1;544;0
WireConnection;265;0;233;0
WireConnection;614;0;508;0
WireConnection;614;1;612;0
WireConnection;454;0;453;0
WireConnection;454;1;102;0
WireConnection;632;0;511;0
WireConnection;632;1;630;0
WireConnection;592;0;596;0
WireConnection;592;1;590;0
WireConnection;604;0;599;0
WireConnection;604;1;601;0
WireConnection;225;0;186;0
WireConnection;225;1;226;0
WireConnection;225;2;235;0
WireConnection;225;3;336;0
WireConnection;223;0;190;0
WireConnection;223;1;222;0
WireConnection;223;2;339;0
WireConnection;566;0;565;0
WireConnection;566;1;554;0
WireConnection;332;0;320;0
WireConnection;332;3;216;0
WireConnection;622;0;509;0
WireConnection;622;1;620;0
WireConnection;593;0;518;0
WireConnection;593;1;591;0
WireConnection;613;0;609;0
WireConnection;613;1;611;0
WireConnection;181;5;185;0
WireConnection;224;0;218;0
WireConnection;224;1;226;0
WireConnection;224;2;235;0
WireConnection;224;3;337;0
WireConnection;402;0;393;0
WireConnection;402;1;450;0
WireConnection;621;0;624;0
WireConnection;621;1;619;0
WireConnection;403;0;400;0
WireConnection;403;1;401;0
WireConnection;603;0;516;0
WireConnection;603;1;602;0
WireConnection;594;0;593;0
WireConnection;594;1;592;0
WireConnection;404;0;403;0
WireConnection;404;1;402;0
WireConnection;328;0;323;0
WireConnection;328;3;224;0
WireConnection;633;0;632;0
WireConnection;633;1;631;0
WireConnection;411;0;454;0
WireConnection;605;0;603;0
WireConnection;605;1;604;0
WireConnection;408;0;406;0
WireConnection;408;1;407;0
WireConnection;329;0;322;0
WireConnection;329;3;225;0
WireConnection;623;0;622;0
WireConnection;623;1;621;0
WireConnection;230;0;193;0
WireConnection;230;1;265;0
WireConnection;230;2;335;0
WireConnection;231;0;228;0
WireConnection;231;1;265;0
WireConnection;231;2;334;0
WireConnection;650;0;649;0
WireConnection;327;0;321;0
WireConnection;327;3;223;0
WireConnection;615;0;614;0
WireConnection;615;1;613;0
WireConnection;423;0;164;4
WireConnection;570;0;566;0
WireConnection;570;1;569;0
WireConnection;207;0;332;0
WireConnection;207;1;181;0
WireConnection;212;0;328;0
WireConnection;212;1;329;0
WireConnection;498;0;605;0
WireConnection;498;1;497;0
WireConnection;331;0;325;0
WireConnection;331;3;230;0
WireConnection;651;0;570;0
WireConnection;651;1;650;0
WireConnection;412;0;408;0
WireConnection;412;1;411;0
WireConnection;214;0;207;0
WireConnection;214;1;327;0
WireConnection;491;0;623;0
WireConnection;491;1;492;0
WireConnection;652;0;656;0
WireConnection;652;1;649;0
WireConnection;472;0;545;0
WireConnection;472;1;594;0
WireConnection;330;0;324;0
WireConnection;330;3;231;0
WireConnection;413;0;404;0
WireConnection;413;1;454;0
WireConnection;495;0;615;0
WireConnection;495;1;494;0
WireConnection;471;0;633;0
WireConnection;471;1;489;0
WireConnection;217;0;212;0
WireConnection;217;1;214;0
WireConnection;425;0;424;0
WireConnection;470;0;471;0
WireConnection;470;1;491;0
WireConnection;470;2;495;0
WireConnection;470;3;498;0
WireConnection;470;4;472;0
WireConnection;227;0;330;0
WireConnection;227;1;331;0
WireConnection;653;0;651;0
WireConnection;653;1;652;0
WireConnection;410;0;412;0
WireConnection;410;1;413;0
WireConnection;567;0;653;0
WireConnection;431;5;432;0
WireConnection;463;0;470;0
WireConnection;229;0;217;0
WireConnection;229;1;227;0
WireConnection;426;0;410;0
WireConnection;426;1;425;0
WireConnection;427;0;429;0
WireConnection;427;1;424;0
WireConnection;430;0;229;0
WireConnection;430;1;431;0
WireConnection;428;0;426;0
WireConnection;428;1;427;0
WireConnection;552;1;430;0
WireConnection;552;0;568;0
WireConnection;461;1;428;0
WireConnection;461;0;464;0
WireConnection;416;0;552;0
WireConnection;414;0;461;0
WireConnection;381;0;369;0
WireConnection;381;1;382;0
WireConnection;382;0;370;0
WireConnection;371;0;369;0
WireConnection;371;1;368;0
WireConnection;379;0;380;0
WireConnection;379;1;381;0
WireConnection;373;0;368;0
WireConnection;373;1;372;0
WireConnection;372;0;371;0
WireConnection;372;1;370;0
WireConnection;380;0;368;0
WireConnection;380;1;370;0
WireConnection;0;0;415;0
WireConnection;0;1;417;0
WireConnection;0;3;340;0
WireConnection;0;4;340;0
ASEEND*/
//CHKSM=9D98E4C93099A36E25824B5B622758AFF37C955A