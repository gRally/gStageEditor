// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/SlopeMaterial_VP"
{
	Properties
	{
		_SlopeNoiseMask("Slope Noise Mask", 2D) = "white" {}
		_Contrast("Contrast", Float) = 0
		_SlopeFalloff("Slope Falloff", Float) = 0
		_HorizontalAlbedo("Horizontal Albedo", 2D) = "white" {}
		_HorizontalDetailMap("Horizontal Detail Map", 2D) = "white" {}
		_HorizontalDetailMapMix("Horizontal Detail Map Mix", Range( 0 , 1)) = 0.1998947
		_DetailMapContrast("Detail Map Contrast", Float) = 0
		_VerticalAlbedo("Vertical Albedo", 2D) = "white" {}
		_Path2TerrainMap("Path2Terrain Map", 2D) = "white" {}
		_ContrastPathtoTerrain("Contrast Path to Terrain", Float) = 3.21
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
			float3 worldNormal;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _VerticalAlbedo;
		uniform float4 _VerticalAlbedo_ST;
		uniform sampler2D _HorizontalAlbedo;
		uniform float4 _HorizontalAlbedo_ST;
		uniform sampler2D _HorizontalDetailMap;
		uniform float4 _HorizontalDetailMap_ST;
		uniform float _DetailMapContrast;
		uniform float _HorizontalDetailMapMix;
		uniform float _SlopeFalloff;
		uniform sampler2D _SlopeNoiseMask;
		uniform float4 _SlopeNoiseMask_ST;
		uniform float _Contrast;
		uniform sampler2D _Path2TerrainMap;
		uniform float4 _Path2TerrainMap_ST;
		uniform float _ContrastPathtoTerrain;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_VerticalAlbedo = i.uv_texcoord * _VerticalAlbedo_ST.xy + _VerticalAlbedo_ST.zw;
			float2 uv_HorizontalAlbedo = i.uv_texcoord * _HorizontalAlbedo_ST.xy + _HorizontalAlbedo_ST.zw;
			float4 tex2DNode69 = tex2D( _HorizontalAlbedo, uv_HorizontalAlbedo );
			float4 GrassAlbedo107 = tex2DNode69;
			float4 temp_output_71_0 = ( 1.0 - tex2DNode69 );
			float2 uv_HorizontalDetailMap = i.uv_texcoord * _HorizontalDetailMap_ST.xy + _HorizontalDetailMap_ST.zw;
			float temp_output_84_0 = saturate( ( tex2D( _HorizontalDetailMap, uv_HorizontalDetailMap ).r * _DetailMapContrast ) );
			float4 AlbedoSoftLight106 = ( ( ( temp_output_71_0 * tex2DNode69 * temp_output_84_0 ) + tex2DNode69 ) * ( 1.0 - ( temp_output_71_0 * ( 1.0 - temp_output_84_0 ) ) ) );
			float4 lerpResult65 = lerp( GrassAlbedo107 , AlbedoSoftLight106 , _HorizontalDetailMapMix);
			float3 ase_worldNormal = i.worldNormal;
			float3 ase_normWorldNormal = normalize( ase_worldNormal );
			float temp_output_59_0 = pow( ase_normWorldNormal.y , _SlopeFalloff );
			float2 uv_SlopeNoiseMask = i.uv_texcoord * _SlopeNoiseMask_ST.xy + _SlopeNoiseMask_ST.zw;
			float4 tex2DNode36 = tex2D( _SlopeNoiseMask, uv_SlopeNoiseMask );
			float clampResult26 = clamp( step( tex2DNode36.r , 0.5 ) , 0.0 , 1.0 );
			float lerpResult27 = lerp( ( temp_output_59_0 * tex2DNode36.r * 2 ) , ( 1.0 - ( ( 1.0 - temp_output_59_0 ) * ( 1.0 - tex2DNode36.r ) * 2 ) ) , clampResult26);
			float Slope61 = saturate( ( ( ( lerpResult27 - 0.5 ) * _Contrast ) + 0.5 ) );
			float4 lerpResult4 = lerp( tex2D( _VerticalAlbedo, uv_VerticalAlbedo ) , lerpResult65 , Slope61);
			float2 uv_Path2TerrainMap = i.uv_texcoord * _Path2TerrainMap_ST.xy + _Path2TerrainMap_ST.zw;
			float NoiseFromSlopeNoiseMap114 = tex2DNode36.b;
			float temp_output_115_0 = ( i.vertexColor.r * NoiseFromSlopeNoiseMap114 );
			float4 lerpResult110 = lerp( lerpResult4 , tex2D( _Path2TerrainMap, uv_Path2TerrainMap ) , saturate( (0.0 + (( temp_output_115_0 + ( ( temp_output_115_0 * _ContrastPathtoTerrain ) + 0.5 ) ) - 0.0) * (1.0 - 0.0) / (10.0 - 0.0)) ));
			o.Albedo = lerpResult110.rgb;
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
			#pragma target 3.0
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
				float3 worldPos : TEXCOORD2;
				float3 worldNormal : TEXCOORD3;
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
				o.worldNormal = worldNormal;
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
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
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldNormal = IN.worldNormal;
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
Version=17101
1927;1;1888;1050;5312.835;558.1545;2.005;True;True
Node;AmplifyShaderEditor.CommentaryNode;63;-4312.792,340.3193;Inherit;False;2196.871;657.3665;Comment;20;36;60;59;3;17;19;46;18;21;12;27;35;26;51;48;50;49;13;61;114;SLOPE;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-4257.786,566.8008;Float;False;Property;_SlopeFalloff;Slope Falloff;2;0;Create;True;0;0;False;0;0;3.27;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldNormalVector;3;-4262.792,390.3193;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;36;-4261.728,703.6609;Inherit;True;Property;_SlopeNoiseMask;Slope Noise Mask;0;0;Create;True;0;0;False;0;None;ff9db8256cb4dca49b4352ae31c261dc;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PowerNode;59;-4006.585,428.6005;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;19;-3857.073,739.8017;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;70;-3499.24,-595.0387;Inherit;True;Property;_HorizontalDetailMap;Horizontal Detail Map;4;0;Create;True;0;0;False;0;None;2603faf0ae0a4654bb2b5217211d7bf8;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;82;-3405.077,-724.3887;Float;False;Property;_DetailMapContrast;Detail Map Contrast;6;0;Create;True;0;0;False;0;0;2.68;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;17;-3834.277,503.4058;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.IntNode;46;-3827.201,608.6559;Float;False;Constant;_Int0;Int 0;7;0;Create;True;0;0;False;0;2;0;0;1;INT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;83;-3152.344,-729.909;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;18;-3622.523,705.4917;Inherit;False;3;3;0;FLOAT;2;False;1;FLOAT;0;False;2;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;35;-3833.833,844.1211;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;84;-2930.053,-737.154;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;26;-3610.985,841.6858;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;21;-3465.424,725.8913;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;-3614.39,441.7088;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;INT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;69;-3446.744,-988.5787;Inherit;True;Property;_HorizontalAlbedo;Horizontal Albedo;3;0;Create;True;0;0;False;0;None;4fe9ee2bbaa4e624094b2256da9e0f64;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;71;-2745.948,-975.7439;Inherit;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;75;-2661.769,-591.8093;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;27;-3255.156,696.8862;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;114;-3972.381,935.7603;Inherit;False;NoiseFromSlopeNoiseMap;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;72;-2524.253,-958.1838;Inherit;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;51;-3057.347,692.1402;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode;109;-1043.081,328.9611;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;113;-1153.92,592.0906;Inherit;True;114;NoiseFromSlopeNoiseMap;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;76;-2470.61,-591.6191;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;48;-3052.667,591.6597;Float;False;Property;_Contrast;Contrast;1;0;Create;True;0;0;False;0;0;7.77;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;77;-2241.38,-591.5241;Inherit;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;50;-2864.801,678.2397;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-815.6655,322.5008;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;73;-2267.439,-916.4792;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;116;-725.286,584.5239;Float;False;Property;_ContrastPathtoTerrain;Contrast Path to Terrain;9;0;Create;True;0;0;False;0;3.21;127;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;78;-1909.655,-751.854;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;49;-2687.538,679.274;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-441.8697,557.6136;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;106;-1604.635,-753.1326;Float;False;AlbedoSoftLight;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;13;-2541.206,680.2398;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;107;-3070.233,-1048.574;Float;False;GrassAlbedo;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;118;-284.7368,556.308;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;108;-1391.212,16.72633;Inherit;False;107;GrassAlbedo;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;68;-1404.09,288.9603;Float;False;Property;_HorizontalDetailMapMix;Horizontal Detail Map Mix;5;0;Create;True;0;0;False;0;0.1998947;0.251;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;61;-2358.921,672.9658;Float;False;Slope;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;66;-1408.606,154.4412;Inherit;False;106;AlbedoSoftLight;1;0;OBJECT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;121;-211.9947,342.4429;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;122;-84.94483,343.633;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;10;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;65;-787.2101,115.1005;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;56;-845.9412,-187.5939;Inherit;True;Property;_VerticalAlbedo;Vertical Albedo;7;0;Create;True;0;0;False;0;None;ed8af6e22ea10504e8eac6763542e132;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;62;-357.9266,191.316;Inherit;False;61;Slope;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;111;-137.5724,751.7571;Inherit;True;Property;_Path2TerrainMap;Path2Terrain Map;8;0;Create;True;0;0;False;0;None;dc9ecdaed93fb754099bb075da710339;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;4;-132.2449,82.685;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;117;61.90523,556.1038;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;120;-831.7599,662.3128;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0.05;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;79;-1019.844,-684.3691;Float;False;Debug;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;110;330.5927,320.1821;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;80;32.92025,-128.4743;Inherit;False;79;Debug;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1024.135,79.39501;Float;False;True;2;ASEMaterialInspector;0;0;Standard;gRally/SlopeMaterial_VP;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;59;0;3;2
WireConnection;59;1;60;0
WireConnection;19;0;36;1
WireConnection;17;0;59;0
WireConnection;83;0;70;1
WireConnection;83;1;82;0
WireConnection;18;0;17;0
WireConnection;18;1;19;0
WireConnection;18;2;46;0
WireConnection;35;0;36;1
WireConnection;84;0;83;0
WireConnection;26;0;35;0
WireConnection;21;0;18;0
WireConnection;12;0;59;0
WireConnection;12;1;36;1
WireConnection;12;2;46;0
WireConnection;71;0;69;0
WireConnection;75;0;84;0
WireConnection;27;0;12;0
WireConnection;27;1;21;0
WireConnection;27;2;26;0
WireConnection;114;0;36;3
WireConnection;72;0;71;0
WireConnection;72;1;69;0
WireConnection;72;2;84;0
WireConnection;51;0;27;0
WireConnection;76;0;71;0
WireConnection;76;1;75;0
WireConnection;77;0;76;0
WireConnection;50;0;51;0
WireConnection;50;1;48;0
WireConnection;115;0;109;1
WireConnection;115;1;113;0
WireConnection;73;0;72;0
WireConnection;73;1;69;0
WireConnection;78;0;73;0
WireConnection;78;1;77;0
WireConnection;49;0;50;0
WireConnection;119;0;115;0
WireConnection;119;1;116;0
WireConnection;106;0;78;0
WireConnection;13;0;49;0
WireConnection;107;0;69;0
WireConnection;118;0;119;0
WireConnection;61;0;13;0
WireConnection;121;0;115;0
WireConnection;121;1;118;0
WireConnection;122;0;121;0
WireConnection;65;0;108;0
WireConnection;65;1;66;0
WireConnection;65;2;68;0
WireConnection;4;0;56;0
WireConnection;4;1;65;0
WireConnection;4;2;62;0
WireConnection;117;0;122;0
WireConnection;120;0;113;0
WireConnection;110;0;4;0
WireConnection;110;1;111;0
WireConnection;110;2;117;0
WireConnection;0;0;110;0
ASEEND*/
//CHKSM=645F5163B1A09262A8E3B30F46546CD4F11B1705