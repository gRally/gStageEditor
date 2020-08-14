// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Phys Road v2 Blend 2 Mat"
{
	Properties
	{
		[NoScaleOffset]_AlbedowithSmoothnessMapMat1("Albedo (with Smoothness Map) Mat1", 2D) = "black" {}
		_AlbedoColorVariationsMat1("Albedo Color Variations Mat1", Color) = (1,1,1,0)
		[NoScaleOffset]_AlbedowithSmoothnessMapMat2("Albedo (with Smoothness Map) Mat2", 2D) = "black" {}
		_AlbedoColorVariationsMat2("Albedo Color Variations Mat2", Color) = (1,1,1,0)
		[NoScaleOffset]_NormalmapMat1("Normal map Mat1", 2D) = "bump" {}
		[NoScaleOffset]_NormalmapMat2("Normal map Mat2", 2D) = "bump" {}
		[NoScaleOffset]_RSpecGTransparencyBAOAWetMapMat1("(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat1", 2D) = "white" {}
		[NoScaleOffset]_RSpecGTransparencyBAOAWetMapMat2("(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat2", 2D) = "white" {}
		_TilingMainTextures("Tiling Main Textures", Vector) = (1,1,0,0)
		_OffsetMainTextures("Offset Main Textures", Vector) = (0,0,0,0)
		_UVMultipliers("Tiling Multipliers For Far Textures", Vector) = (1,0.2,0,0)
		_TransitionDistance("Transition Distance (in meters)", Range( 1 , 150)) = 30
		_TransitionFalloff("Transition Falloff", Float) = 6
		_Cutoff( "Mask Clip Value", Float ) = 0.5
		_GR_Displacement("_GR_Displacement", Range( 0 , 1)) = 1
		_MaxDisplacementmeters("Max Displacement (meters)", Range( -1 , 0)) = 0
		[Toggle]_UseGrooveTex("Use Groove Tex", Float) = 0
		[NoScaleOffset]_GrooveMap("GrooveMap", 2D) = "white" {}
		_procOctaves1("(proc) octaves", Int) = 0
		_procPersistance1("(proc) persistance", Range( 0 , 1)) = 0
		[Toggle]_UsePuddlesTexture("Use Puddles Texture", Float) = 0
		[NoScaleOffset]_PuddlesTexture("Puddles Texture", 2D) = "black" {}
		_procLacunarity1("(proc) lacunarity", Float) = 0
		_PuddlesSize("Puddles Size", Float) = 0
		_procScale1("(proc) scale", Float) = 0
		_procHeightMultiplier1("(proc) heightMultiplier", Float) = 0
		[NoScaleOffset][Space(20)][Header(Physical Texture. Remember to set the texture as ReadWrite Enabled)]_PhysicalTexture("Physical Texture", 2D) = "white" {}
		_procUsedForPatch1("(proc) usedForPatch", Int) = 0
		_procSideNoise1("(proc) sideNoise", Range( 0 , 3)) = 0
		_procSideNoiseDilatation1("(proc) sideNoiseDilatation", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityCG.cginc"
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
			float4 vertexColor : COLOR;
			float3 worldNormal;
			INTERNAL_DATA
		};

		uniform float _procLacunarity1;
		uniform float _procScale1;
		uniform int _procUsedForPatch1;
		uniform float _procSideNoiseDilatation1;
		uniform float _procHeightMultiplier1;
		uniform int _procOctaves1;
		uniform float _procPersistance1;
		uniform float _procSideNoise1;
		uniform float _MaxDisplacementmeters;
		uniform float _GR_Displacement;
		uniform sampler2D _RSpecGTransparencyBAOAWetMapMat2;
		uniform float2 _TilingMainTextures;
		uniform float2 _OffsetMainTextures;
		uniform float2 _UVMultipliers;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform sampler2D _RSpecGTransparencyBAOAWetMapMat1;
		uniform float _UsePuddlesTexture;
		uniform float _GR_WetSurf;
		uniform sampler2D _PuddlesTexture;
		uniform float _PuddlesSize;
		uniform sampler2D _NormalmapMat2;
		uniform sampler2D _NormalmapMat1;
		uniform sampler2D _PhysicalTexture;
		uniform sampler2D _AlbedowithSmoothnessMapMat2;
		uniform float4 _AlbedoColorVariationsMat2;
		uniform sampler2D _AlbedowithSmoothnessMapMat1;
		uniform float4 _AlbedoColorVariationsMat1;
		uniform float _UseGrooveTex;
		uniform sampler2D _GrooveMap;
		uniform float _GR_Groove;
		uniform float _GR_PhysDebug;
		uniform float _Cutoff = 0.5;


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
			float4 tex2DNode253 = tex2D( _RSpecGTransparencyBAOAWetMapMat2, UV_Texture212 );
			float3 temp_cast_0 = (tex2DNode253.a).xxx;
			float3 temp_cast_1 = (tex2DNode253.a).xxx;
			float3 gammaToLinear286 = GammaToLinearSpace( temp_cast_1 );
			float2 UV_Texture_Tiling_Mult215 = ( uv_TexCoord138 * _UVMultipliers );
			float4 tex2DNode277 = tex2D( _RSpecGTransparencyBAOAWetMapMat2, UV_Texture_Tiling_Mult215 );
			float3 temp_cast_2 = (tex2DNode277.a).xxx;
			float3 temp_cast_3 = (tex2DNode277.a).xxx;
			float3 gammaToLinear284 = GammaToLinearSpace( temp_cast_3 );
			float3 ase_worldPos = i.worldPos;
			float clampResult142 = clamp( pow( ( distance( _WorldSpaceCameraPos , ase_worldPos ) / _TransitionDistance ) , _TransitionFalloff ) , 0.0 , 1.0 );
			float Transition210 = clampResult142;
			float lerpResult255 = lerp( gammaToLinear286.x , gammaToLinear284.x , Transition210);
			float4 tex2DNode3 = tex2D( _RSpecGTransparencyBAOAWetMapMat1, UV_Texture212 );
			float3 temp_cast_4 = (tex2DNode3.a).xxx;
			float3 temp_cast_5 = (tex2DNode3.a).xxx;
			float3 gammaToLinear282 = GammaToLinearSpace( temp_cast_5 );
			float4 tex2DNode278 = tex2D( _RSpecGTransparencyBAOAWetMapMat1, UV_Texture_Tiling_Mult215 );
			float3 temp_cast_6 = (tex2DNode278.a).xxx;
			float3 temp_cast_7 = (tex2DNode278.a).xxx;
			float3 gammaToLinear281 = GammaToLinearSpace( temp_cast_7 );
			float lerpResult150 = lerp( gammaToLinear282.x , gammaToLinear281.x , Transition210);
			float AlphaVertexColor251 = i.vertexColor.a;
			float lerpResult262 = lerp( lerpResult255 , lerpResult150 , AlphaVertexColor251);
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
			float simplePerlin2D303 = snoise( i.uv_texcoord*20.0 );
			simplePerlin2D303 = simplePerlin2D303*0.5 + 0.5;
			float Slope_Mixer294 = saturate( ( pow( ase_normWorldNormal.y , 1500.0 ) * 53.0 * simplePerlin2D303 ) );
			float4 break240 = ( (( _UsePuddlesTexture )?( appendResult237 ):( float4(0,0,0,0) )) * Slope_Mixer294 );
			float temp_output_234_0 = ( i.vertexColor.b * _GR_Displacement );
			float clampResult201 = clamp( ( lerpResult262 + break240.x + break240.y + break240.z + break240.w + temp_output_234_0 ) , 0.0 , 1.0 );
			float temp_output_206_0 = ( clampResult201 * _GR_WetSurf );
			float temp_output_81_0 = ( 1.0 - temp_output_206_0 );
			float lerpResult208 = lerp( temp_output_81_0 , 0.0 , Transition210);
			float temp_output_272_0 = ( 1.0 - AlphaVertexColor251 );
			float lerpResult209 = lerp( 0.0 , temp_output_81_0 , Transition210);
			o.Normal = BlendNormals( BlendNormals( UnpackScaleNormal( tex2D( _NormalmapMat2, UV_Texture212 ), ( lerpResult208 * temp_output_272_0 ) ) , UnpackScaleNormal( tex2D( _NormalmapMat2, UV_Texture_Tiling_Mult215 ), ( lerpResult209 * temp_output_272_0 ) ) ) , BlendNormals( UnpackScaleNormal( tex2D( _NormalmapMat1, UV_Texture212 ), ( lerpResult208 * AlphaVertexColor251 ) ) , UnpackScaleNormal( tex2D( _NormalmapMat1, UV_Texture_Tiling_Mult215 ), ( lerpResult209 * AlphaVertexColor251 ) ) ) );
			float2 uv_PhysicalTexture71 = i.uv_texcoord;
			float4 tex2DNode243 = tex2D( _AlbedowithSmoothnessMapMat2, UV_Texture212 );
			float4 tex2DNode244 = tex2D( _AlbedowithSmoothnessMapMat2, UV_Texture_Tiling_Mult215 );
			float4 lerpResult245 = lerp( tex2DNode243 , tex2DNode244 , Transition210);
			float4 tex2DNode1 = tex2D( _AlbedowithSmoothnessMapMat1, UV_Texture212 );
			float4 tex2DNode276 = tex2D( _AlbedowithSmoothnessMapMat1, UV_Texture_Tiling_Mult215 );
			float4 lerpResult145 = lerp( tex2DNode1 , tex2DNode276 , Transition210);
			float4 lerpResult246 = lerp( ( lerpResult245 * _AlbedoColorVariationsMat2 ) , ( lerpResult145 * _AlbedoColorVariationsMat1 ) , AlphaVertexColor251);
			float4 _Color0 = float4(0,0,0,0);
			float2 uv_GrooveMap55 = i.uv_texcoord;
			float lerpResult64 = lerp( _Color0.g , i.vertexColor.g , _GR_Groove);
			float4 lerpResult56 = lerp( lerpResult246 , ( (( _UseGrooveTex )?( tex2D( _GrooveMap, uv_GrooveMap55 ) ):( _Color0 )) * lerpResult246 ) , lerpResult64);
			float clampResult90 = clamp( ( 1.0 - _GR_WetSurf ) , 0.68 , 1.0 );
			float4 lerpResult83 = lerp( tex2D( _PhysicalTexture, uv_PhysicalTexture71 ) , ( lerpResult56 * clampResult90 ) , ( 1.0 - _GR_PhysDebug ));
			o.Albedo = lerpResult83.rgb;
			float lerpResult256 = lerp( tex2DNode253.r , tex2DNode277.r , Transition210);
			float lerpResult147 = lerp( tex2DNode3.r , tex2DNode278.r , Transition210);
			float lerpResult259 = lerp( lerpResult256 , lerpResult147 , AlphaVertexColor251);
			float clampResult47 = clamp( ( lerpResult259 + temp_output_206_0 ) , 0.0 , 1.0 );
			float3 temp_cast_10 = (clampResult47).xxx;
			o.Specular = temp_cast_10;
			float lerpResult248 = lerp( tex2DNode243.a , tex2DNode244.a , Transition210);
			float lerpResult143 = lerp( tex2DNode1.a , tex2DNode276.a , Transition210);
			float lerpResult249 = lerp( lerpResult248 , lerpResult143 , AlphaVertexColor251);
			float clampResult33 = clamp( ( ( lerpResult249 + temp_output_206_0 ) + ( _GR_WetSurf / 2.0 ) ) , 0.0 , 1.0 );
			o.Smoothness = clampResult33;
			float lerpResult257 = lerp( tex2DNode253.b , tex2DNode277.b , Transition210);
			float lerpResult149 = lerp( tex2DNode3.b , tex2DNode278.b , Transition210);
			float lerpResult261 = lerp( lerpResult257 , lerpResult149 , AlphaVertexColor251);
			o.Occlusion = ( lerpResult261 + _GR_WetSurf );
			o.Alpha = 1;
			float lerpResult258 = lerp( tex2DNode253.g , tex2DNode277.g , Transition210);
			float lerpResult148 = lerp( tex2DNode3.g , tex2DNode278.g , Transition210);
			float lerpResult260 = lerp( lerpResult258 , lerpResult148 , AlphaVertexColor251);
			clip( lerpResult260 - _Cutoff );
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
1984;21;1856;983;9167.511;1926.831;2.444998;True;True
Node;AmplifyShaderEditor.WorldPosInputsNode;164;-7769.826,163.1364;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;165;-7753.816,574.2178;Float;False;Property;_PuddlesSize;Puddles Size;23;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;167;-7370.586,529.5403;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;166;-7369.133,795.4211;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-7147.969,760.6581;Inherit;True;2;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-7156.427,485.2687;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2124.411,715.9593;Float;False;Global;_GR_WetSurf;_GR_WetSurf;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-1734.505,840.5292;Float;False;WetSurf;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;153;-6450.924,-1887.099;Float;False;Property;_TilingMainTextures;Tiling Main Textures;8;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.Vector2Node;163;-6454.523,-1742.713;Float;False;Property;_OffsetMainTextures;Offset Main Textures;9;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.FractNode;170;-6915.345,762.4833;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;171;-6933.595,486.9078;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;173;-6698.355,759.808;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;174;-6711.129,475.9588;Inherit;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-4965.893,590.574;Inherit;False;219;WetSurf;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;133;-6957.997,-1422.428;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;132;-7000.345,-1656.708;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.CommentaryNode;288;-4653.028,1381.934;Inherit;False;1213.055;558.0161;Slope Control for Puddles (now set max at 8% slope);10;305;304;303;302;301;300;299;298;297;294;;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;139;-6208.355,-1210.003;Float;False;Property;_UVMultipliers;Tiling Multipliers For Far Textures;10;0;Create;False;0;0;False;0;1,0.2;1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;138;-6091.313,-1766.033;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;172;-7373.157,183.2262;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;300;-4559.103,1444.769;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TextureCoordinatesNode;299;-4620.002,1678.156;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;298;-4606.503,1823.929;Half;False;Constant;_Float1;Float 0;28;0;Create;True;0;0;False;0;20;21.03;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;231;-4758.484,593.2344;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;297;-4549.237,1591.276;Half;False;Constant;_SlopeFalloff1;Slope Falloff;17;0;Create;True;0;0;False;0;1500;1500;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-5668.57,-1373.929;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DistanceOpNode;135;-6485.744,-1553.363;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-6540.418,-1380.008;Float;False;Property;_TransitionDistance;Transition Distance (in meters);11;0;Create;False;0;0;False;0;30;30;1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;177;-6465.865,589.1089;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;176;-6451.795,884.7579;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;175;-6803.148,245.7327;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-5457.772,-1228.409;Float;False;UV_Texture_Tiling_Mult;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;301;-4338.393,1439.89;Half;False;Constant;_Contrast1;Contrast;18;0;Create;True;0;0;False;0;53;53;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;226;-4578.036,579.5547;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;303;-4365.328,1665.724;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-5898.752,1040.984;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-6205.566,-1367.608;Float;False;Property;_TransitionFalloff;Transition Falloff;12;0;Create;True;0;0;False;0;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;302;-4344.929,1530.844;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-5936.264,5.749055;Inherit;True;Property;_PuddlesTexture;Puddles Texture;21;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-5917.002,305.5107;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-5625.425,-1893.385;Float;False;UV_Texture;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-5911.527,546.4092;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-5907.877,794.6091;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-6214.538,-1549.888;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-5276.072,536.4781;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;140;-5970.865,-1557.108;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-4861.418,-1612.395;Inherit;False;215;UV_Texture_Tiling_Mult;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;-4841.993,-2404.332;Inherit;False;212;UV_Texture;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-5279.903,1059.275;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;304;-4151.906,1529.466;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;227;-4405.25,603.9901;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-5287.563,254.9746;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-5289.479,810.3235;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;223;-4081.793,816.6291;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;253;-4270.318,-2571.205;Inherit;True;Property;_RSpecGTransparencyBAOAWetMapMat2;(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat2;7;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SmoothstepOpNode;224;-4087.284,1113.089;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;278;-4588.372,-1035.482;Inherit;True;Property;_TextureSample4;Texture Sample 4;6;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;142;-5675.082,-1563.868;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;221;-4076.484,238.3491;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;305;-3993.273,1526.885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;222;-4072.433,531.0142;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;277;-4494.925,-2239.598;Inherit;True;Property;_TextureSample0;Texture Sample 0;7;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;253;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-4293.974,-1380.888;Inherit;True;Property;_RSpecGTransparencyBAOAWetMapMat1;(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat1;6;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;54;-2957.26,1016.189;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-5408.303,-1572.177;Float;False;Transition;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GammaToLinearNode;286;-4005.306,-2382.979;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.DynamicAppendNode;237;-3862.902,114.8096;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;294;-3835.745,1535.531;Float;False;Slope_Mixer;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;235;-4094.253,-20.81575;Float;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GammaToLinearNode;282;-4082.201,-1174.257;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GammaToLinearNode;284;-4051.705,-2026.859;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GammaToLinearNode;281;-4094.33,-684.5637;Inherit;False;0;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.BreakToComponentsNode;283;-4021.002,-1078.922;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.BreakToComponentsNode;285;-3990.506,-1931.524;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;251;-2617.295,1189.906;Float;False;AlphaVertexColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;236;-3713.763,49.82335;Float;False;Property;_UsePuddlesTexture;Use Puddles Texture;20;0;Create;True;0;0;False;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.BreakToComponentsNode;287;-3944.107,-2287.644;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;296;-3359.851,174.6474;Inherit;False;294;Slope_Mixer;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;280;-4033.131,-589.2287;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.GetLocalVarNode;211;-4838.309,-1236.384;Inherit;False;210;Transition;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;150;-3694.954,-482.0753;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;295;-3091.758,85.03249;Inherit;False;2;2;0;FLOAT4;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.LerpOp;255;-3598.716,-1819.762;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-2179.743,1589.624;Float;False;Property;_GR_Displacement;_GR_Displacement;14;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-3659.555,-1534.666;Inherit;False;251;AlphaVertexColor;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-2427.954,767.16;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;262;-2730.311,-1384.446;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-2657.852,101.4245;Inherit;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-2173.017,129.3398;Inherit;True;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;252;-4304.078,-4085.709;Inherit;False;1465.561;1298.26;Albedo and Smoothness;13;306;246;248;143;145;250;245;276;243;1;244;307;308;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;201;-1884.041,151.1757;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-4251.307,-3334.695;Inherit;True;Property;_AlbedowithSmoothnessMapMat1;Albedo (with Smoothness Map) Mat1;0;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;244;-4236.491,-3811.97;Inherit;True;Property;_TextureSample3;Texture Sample 3;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;243;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;276;-4259.375,-3027.532;Inherit;True;Property;_TextureSample5;Texture Sample 5;0;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;243;-4238.108,-4035.71;Inherit;True;Property;_AlbedowithSmoothnessMapMat2;Albedo (with Smoothness Map) Mat2;2;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;245;-3642.617,-3882.246;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1538.174,161.7106;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;247;-1684.637,-4039.824;Inherit;False;1487.087;675.3145;GrooveMap;7;55;61;70;62;66;64;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ColorNode;306;-3654.578,-4068.769;Inherit;False;Property;_AlbedoColorVariationsMat2;Albedo Color Variations Mat2;3;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;308;-3722.367,-3396.63;Inherit;False;Property;_AlbedoColorVariationsMat1;Albedo Color Variations Mat1;1;0;Create;True;0;0;False;0;1,1,1,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;145;-3638.692,-3201.162;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;250;-3427.011,-3527.254;Inherit;False;251;AlphaVertexColor;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;61;-1606.038,-3777.088;Float;False;Constant;_Color0;Color 0;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;270;-962.0448,-1210.641;Inherit;False;251;AlphaVertexColor;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-1634.637,-3992.339;Inherit;True;Property;_GrooveMap;GrooveMap;17;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;309;-3371.502,-3335.756;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;307;-3329.881,-3805.48;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1119.072,-101.1119;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-1156.305,-265.6345;Inherit;False;210;Transition;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;248;-3638.113,-3722.297;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;246;-3022.519,-3668.197;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;272;-587.513,-1205.134;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1630.465,-3581.286;Float;False;Global;_GR_Groove;_GR_Groove;8;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-1106.956,-3867.709;Float;False;Property;_UseGrooveTex;Use Groove Tex;16;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;264;868.9689,-1945.963;Inherit;False;1146.877;550.084;Show Physical Texture;7;89;82;90;84;88;71;83;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;209;-730.8631,-103.6825;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;143;-3644.522,-3025.673;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;208;-793.7767,-431.3187;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;964.3907,-1522.474;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;249;-3023.833,-3297.414;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-57.14255,-126.4922;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-798.1732,-242.1243;Inherit;False;215;UV_Texture_Tiling_Mult;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;147;-3673.825,-1400.854;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;256;-3608.042,-2572.836;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-800.4777,-796.8667;Inherit;False;212;UV_Texture;1;0;OBJECT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;-172.9781,-92.28183;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-48.01198,-1208.674;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;64;-892.9672,-3687.726;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;-52.2059,-432.6231;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-818.8596,-3849.415;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;56;-381.5501,-3520.51;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;1425.847,-1840.506;Float;False;Global;_GR_PhysDebug;_GR_PhysDebug;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;266;153.9721,-982.8112;Inherit;True;Property;_TextureSample6;Texture Sample 6;5;0;Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Instance;265;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;209.188,-477.1451;Inherit;True;Property;_NormalmapMat1;Normal map Mat1;4;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;257;-3601.972,-2070.957;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;149;-3648.225,-776.2144;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-794.8369,740.6984;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;151;208.9387,-204.0995;Inherit;True;Property;_TextureSample2;Texture Sample 2;4;0;Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Instance;2;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;259;-2714.206,-2008.552;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;265;156.4263,-1255.857;Inherit;True;Property;_NormalmapMat2;Normal map Mat2;5;1;[NoScaleOffset];Create;True;0;0;False;0;-1;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-802.1614,515.9847;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;1211.604,-1551.879;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0.68;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-492.3809,128.5737;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;1723.755,-1744.006;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-504.8837,612.13;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;1411.258,-1596.493;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;148;-3666.145,-1109.014;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;261;-2689.281,-1593.026;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;267;668.654,-1112.766;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalVertexDataNode;50;-1423.484,1271.131;Inherit;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;258;-3605.941,-2331.216;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2445.868,1431.3;Float;False;Property;_MaxDisplacementmeters;Max Displacement (meters);15;0;Create;True;0;0;False;0;0;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;207;666.4252,-347.7034;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;71;920.7538,-1895.963;Inherit;True;Property;_PhysicalTexture;Physical Texture;26;1;[NoScaleOffset];Create;True;0;0;False;2;Space(20);Header(Physical Texture. Remember to set the texture as ReadWrite Enabled);-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;311;-6767.444,-901.5864;Float;False;Property;_procScale1;(proc) scale;24;0;Create;False;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;310;-6767.444,-965.5864;Float;False;Property;_procLacunarity1;(proc) lacunarity;22;0;Create;False;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;312;-6767.444,-773.5864;Float;False;Property;_procUsedForPatch1;(proc) usedForPatch;27;0;Create;False;0;0;True;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.LerpOp;83;1831.846,-1649.506;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;314;-6767.444,-837.5864;Float;False;Property;_procHeightMultiplier1;(proc) heightMultiplier;25;0;Create;False;0;0;True;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;315;-6767.444,-1093.586;Float;False;Property;_procOctaves1;(proc) octaves;18;0;Create;False;0;0;True;0;0;0;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;313;-6763.76,-638.3298;Float;False;Property;_procSideNoiseDilatation1;(proc) sideNoiseDilatation;29;0;Create;False;0;0;True;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;268;1286.064,-715.1789;Inherit;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;316;-6767.444,-1029.586;Float;False;Property;_procPersistance1;(proc) persistance;19;0;Create;False;0;0;True;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-2328.804,371.1309;Inherit;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-207.8844,602.612;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;260;-2700.41,-1797.117;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-233.5018,135.2262;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-493.5717,368.2224;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-6851.741,121.4464;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-854.2187,1285.561;Inherit;True;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;279;-2709.742,-3288.038;Float;False;Smooth_Output;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;317;-6763.76,-705.3298;Float;False;Property;_procSideNoise1;(proc) sideNoise;28;0;Create;False;0;0;True;0;0;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3127.522,1600.646;Float;False;True;-1;6;ASEMaterialInspector;0;0;StandardSpecular;gRally/Phys Road v2 Blend 2 Mat;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;20;3;10;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;1;False;-1;1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;13;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;167;0;164;1
WireConnection;167;1;165;0
WireConnection;166;0;164;3
WireConnection;166;1;165;0
WireConnection;169;0;166;0
WireConnection;168;0;167;0
WireConnection;219;0;5;0
WireConnection;170;0;169;0
WireConnection;171;0;168;0
WireConnection;173;0;170;0
WireConnection;174;0;171;0
WireConnection;138;0;153;0
WireConnection;138;1;163;0
WireConnection;172;0;164;1
WireConnection;172;1;164;3
WireConnection;231;0;220;0
WireConnection;141;0;138;0
WireConnection;141;1;139;0
WireConnection;135;0;132;0
WireConnection;135;1;133;0
WireConnection;177;0;174;0
WireConnection;176;0;173;0
WireConnection;175;0;172;0
WireConnection;175;1;165;0
WireConnection;215;0;141;0
WireConnection;226;0;231;0
WireConnection;303;0;299;0
WireConnection;303;1;298;0
WireConnection;179;0;177;0
WireConnection;179;1;176;0
WireConnection;302;0;300;2
WireConnection;302;1;297;0
WireConnection;178;1;175;0
WireConnection;181;0;174;0
WireConnection;181;1;173;0
WireConnection;212;0;138;0
WireConnection;184;0;174;0
WireConnection;184;1;176;0
WireConnection;186;0;177;0
WireConnection;186;1;173;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;188;0;178;2
WireConnection;188;1;184;0
WireConnection;140;0;137;0
WireConnection;140;1;136;0
WireConnection;187;0;178;4
WireConnection;187;1;179;0
WireConnection;304;0;302;0
WireConnection;304;1;301;0
WireConnection;304;2;303;0
WireConnection;227;0;226;0
WireConnection;190;0;178;1
WireConnection;190;1;181;0
WireConnection;189;0;178;3
WireConnection;189;1;186;0
WireConnection;223;0;189;0
WireConnection;223;1;227;0
WireConnection;253;1;213;0
WireConnection;224;0;187;0
WireConnection;224;1;227;0
WireConnection;278;1;216;0
WireConnection;142;0;140;0
WireConnection;221;0;190;0
WireConnection;221;1;227;0
WireConnection;305;0;304;0
WireConnection;222;0;188;0
WireConnection;222;1;227;0
WireConnection;277;1;216;0
WireConnection;3;1;213;0
WireConnection;210;0;142;0
WireConnection;286;0;253;4
WireConnection;237;0;221;0
WireConnection;237;1;222;0
WireConnection;237;2;223;0
WireConnection;237;3;224;0
WireConnection;294;0;305;0
WireConnection;282;0;3;4
WireConnection;284;0;277;4
WireConnection;281;0;278;4
WireConnection;283;0;282;0
WireConnection;285;0;284;0
WireConnection;251;0;54;4
WireConnection;236;0;235;0
WireConnection;236;1;237;0
WireConnection;287;0;286;0
WireConnection;280;0;281;0
WireConnection;150;0;283;0
WireConnection;150;1;280;0
WireConnection;150;2;211;0
WireConnection;295;0;236;0
WireConnection;295;1;296;0
WireConnection;255;0;287;0
WireConnection;255;1;285;0
WireConnection;255;2;211;0
WireConnection;234;0;54;3
WireConnection;234;1;85;0
WireConnection;262;0;255;0
WireConnection;262;1;150;0
WireConnection;262;2;263;0
WireConnection;240;0;295;0
WireConnection;241;0;262;0
WireConnection;241;1;240;0
WireConnection;241;2;240;1
WireConnection;241;3;240;2
WireConnection;241;4;240;3
WireConnection;241;5;234;0
WireConnection;201;0;241;0
WireConnection;1;1;213;0
WireConnection;244;1;216;0
WireConnection;276;1;216;0
WireConnection;243;1;213;0
WireConnection;245;0;243;0
WireConnection;245;1;244;0
WireConnection;245;2;211;0
WireConnection;206;0;201;0
WireConnection;206;1;5;0
WireConnection;145;0;1;0
WireConnection;145;1;276;0
WireConnection;145;2;211;0
WireConnection;309;0;145;0
WireConnection;309;1;308;0
WireConnection;307;0;245;0
WireConnection;307;1;306;0
WireConnection;81;0;206;0
WireConnection;248;0;243;4
WireConnection;248;1;244;4
WireConnection;248;2;211;0
WireConnection;246;0;307;0
WireConnection;246;1;309;0
WireConnection;246;2;250;0
WireConnection;272;0;270;0
WireConnection;70;0;61;0
WireConnection;70;1;55;0
WireConnection;209;1;81;0
WireConnection;209;2;217;0
WireConnection;143;0;1;4
WireConnection;143;1;276;4
WireConnection;143;2;211;0
WireConnection;208;0;81;0
WireConnection;208;2;217;0
WireConnection;89;0;5;0
WireConnection;249;0;248;0
WireConnection;249;1;143;0
WireConnection;249;2;250;0
WireConnection;274;0;209;0
WireConnection;274;1;270;0
WireConnection;147;0;3;1
WireConnection;147;1;278;1
WireConnection;147;2;211;0
WireConnection;256;0;253;1
WireConnection;256;1;277;1
WireConnection;256;2;211;0
WireConnection;275;0;209;0
WireConnection;275;1;272;0
WireConnection;273;0;208;0
WireConnection;273;1;272;0
WireConnection;64;0;61;2
WireConnection;64;1;54;2
WireConnection;64;2;62;0
WireConnection;271;0;208;0
WireConnection;271;1;270;0
WireConnection;66;0;70;0
WireConnection;66;1;246;0
WireConnection;56;0;246;0
WireConnection;56;1;66;0
WireConnection;56;2;64;0
WireConnection;266;1;218;0
WireConnection;266;5;275;0
WireConnection;2;1;214;0
WireConnection;2;5;271;0
WireConnection;257;0;253;3
WireConnection;257;1;277;3
WireConnection;257;2;211;0
WireConnection;149;0;3;3
WireConnection;149;1;278;3
WireConnection;149;2;211;0
WireConnection;48;0;5;0
WireConnection;151;1;218;0
WireConnection;151;5;274;0
WireConnection;259;0;256;0
WireConnection;259;1;147;0
WireConnection;259;2;263;0
WireConnection;265;1;214;0
WireConnection;265;5;273;0
WireConnection;7;0;249;0
WireConnection;7;1;206;0
WireConnection;90;0;89;0
WireConnection;25;0;259;0
WireConnection;25;1;206;0
WireConnection;84;0;82;0
WireConnection;34;0;7;0
WireConnection;34;1;48;0
WireConnection;88;0;56;0
WireConnection;88;1;90;0
WireConnection;148;0;3;2
WireConnection;148;1;278;2
WireConnection;148;2;211;0
WireConnection;261;0;257;0
WireConnection;261;1;149;0
WireConnection;261;2;263;0
WireConnection;267;0;265;0
WireConnection;267;1;266;0
WireConnection;258;0;253;2
WireConnection;258;1;277;2
WireConnection;258;2;211;0
WireConnection;207;0;2;0
WireConnection;207;1;151;0
WireConnection;83;0;71;0
WireConnection;83;1;88;0
WireConnection;83;2;84;0
WireConnection;268;0;267;0
WireConnection;268;1;207;0
WireConnection;200;0;262;0
WireConnection;200;1;221;0
WireConnection;200;2;222;0
WireConnection;200;3;223;0
WireConnection;200;4;224;0
WireConnection;200;5;234;0
WireConnection;33;0;34;0
WireConnection;260;0;258;0
WireConnection;260;1;148;0
WireConnection;260;2;263;0
WireConnection;47;0;25;0
WireConnection;77;0;261;0
WireConnection;77;1;5;0
WireConnection;195;0;172;0
WireConnection;195;1;165;0
WireConnection;51;0;54;3
WireConnection;51;1;50;0
WireConnection;51;2;52;0
WireConnection;51;3;85;0
WireConnection;279;0;249;0
WireConnection;0;0;83;0
WireConnection;0;1;268;0
WireConnection;0;3;47;0
WireConnection;0;4;33;0
WireConnection;0;5;77;0
WireConnection;0;10;260;0
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=7840AAEF780CF419624FF3554F2D890C733775E8