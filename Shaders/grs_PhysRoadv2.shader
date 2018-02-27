// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Phys Road v2"
{
	Properties
	{
		_AlbedowithSmoothnessMap("Albedo (with Smoothness Map)", 2D) = "white" {}
		_Normalmap("Normal map", 2D) = "bump" {}
		_RSpecGTransparencyBAOAWetMap("(R)Spec-(G)Transparency-(B)AO -(A)WetMap", 2D) = "white" {}
		_TilingMainTextures("Tiling Main Textures", Vector) = (1,1,0,0)
		_OffsetMainTextures("Offset Main Textures", Vector) = (0,0,0,0)
		_Cutoff( "Mask Clip Value", Float ) = 0.681
		_MaxDisplacementmeters("Max Displacement (meters)", Range( -1 , 0)) = 0
		[Toggle]_UseGrooveTex("Use Groove Tex", Float) = 0
		_GrooveMap("GrooveMap", 2D) = "white" {}
		_PuddlesTexture("Puddles Texture", 2D) = "white" {}
		_PuddlesSize("Puddles Size", Float) = 0
		_TransitionFalloff("Transition Falloff", Float) = 6
		_TransitionDistance("Transition Distance (in meters)", Range( 1 , 150)) = 30
		_UVMultipliers("Tiling Multipliers for far texture", Vector) = (1,0.2,0,0)
		_PhysicalTexture("Physical Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#include "UnityStandardUtils.cginc"
		#pragma target 4.6
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _RSpecGTransparencyBAOAWetMap;
		uniform float2 _TilingMainTextures;
		uniform float2 _OffsetMainTextures;
		uniform float2 _UVMultipliers;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform sampler2D _PuddlesTexture;
		uniform float _PuddlesSize;
		uniform float _GR_WetSurf;
		uniform sampler2D _Normalmap;
		uniform sampler2D _PhysicalTexture;
		uniform float4 _PhysicalTexture_ST;
		uniform sampler2D _AlbedowithSmoothnessMap;
		uniform float _UseGrooveTex;
		uniform sampler2D _GrooveMap;
		uniform float4 _GrooveMap_ST;
		uniform float _GR_Groove;
		uniform float _GR_PhysDebug;
		uniform float _MaxDisplacementmeters;
		uniform float _GR_Displacement;
		uniform float _Cutoff = 0.681;

		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_vertexNormal = v.normal.xyz;
			v.vertex.xyz += ( v.color.b * ase_vertexNormal * _MaxDisplacementmeters * _GR_Displacement );
		}

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_TexCoord138 = i.uv_texcoord * _TilingMainTextures + _OffsetMainTextures;
			float4 tex2DNode3 = tex2D( _RSpecGTransparencyBAOAWetMap, uv_TexCoord138 );
			float2 temp_output_141_0 = ( uv_TexCoord138 * _UVMultipliers );
			float4 tex2DNode146 = tex2D( _RSpecGTransparencyBAOAWetMap, temp_output_141_0 );
			float3 ase_worldPos = i.worldPos;
			float clampResult142 = clamp( pow( ( distance( _WorldSpaceCameraPos , ase_worldPos ) / _TransitionDistance ) , _TransitionFalloff ) , 0.0 , 1.0 );
			float lerpResult150 = lerp( tex2DNode3.a , tex2DNode146.a , clampResult142);
			float2 appendResult172 = (float2(ase_worldPos.x , ase_worldPos.z));
			float4 tex2DNode178 = tex2D( _PuddlesTexture, ( appendResult172 / _PuddlesSize ) );
			float temp_output_174_0 = step( frac( ( ( ase_worldPos.x / _PuddlesSize ) * 0.5 ) ) , 0.5 );
			float temp_output_173_0 = step( frac( ( ( ase_worldPos.z / _PuddlesSize ) * 0.5 ) ) , 0.5 );
			float temp_output_176_0 = ( 1.0 - temp_output_173_0 );
			float temp_output_177_0 = ( 1.0 - temp_output_174_0 );
			float clampResult201 = clamp( ( lerpResult150 + ( tex2DNode178.r * ( temp_output_174_0 * temp_output_173_0 ) ) + ( tex2DNode178.g * ( temp_output_174_0 * temp_output_176_0 ) ) + ( tex2DNode178.b * ( temp_output_177_0 * temp_output_173_0 ) ) + ( tex2DNode178.a * ( temp_output_177_0 * temp_output_176_0 ) ) ) , 0.0 , 1.0 );
			float temp_output_206_0 = ( clampResult201 * _GR_WetSurf );
			float temp_output_81_0 = ( 1.0 - temp_output_206_0 );
			float3 lerpResult152 = lerp( UnpackScaleNormal( tex2D( _Normalmap, uv_TexCoord138 ) ,temp_output_81_0 ) , UnpackScaleNormal( tex2D( _Normalmap, temp_output_141_0 ) ,temp_output_81_0 ) , clampResult142);
			o.Normal = lerpResult152;
			float2 uv_PhysicalTexture = i.uv_texcoord * _PhysicalTexture_ST.xy + _PhysicalTexture_ST.zw;
			float4 tex2DNode1 = tex2D( _AlbedowithSmoothnessMap, uv_TexCoord138 );
			float4 tex2DNode144 = tex2D( _AlbedowithSmoothnessMap, temp_output_141_0 );
			float4 lerpResult145 = lerp( tex2DNode1 , tex2DNode144 , clampResult142);
			float4 _Color0 = float4(0,0,0,0);
			float2 uv_GrooveMap = i.uv_texcoord * _GrooveMap_ST.xy + _GrooveMap_ST.zw;
			float lerpResult64 = lerp( _Color0.g , i.vertexColor.g , _GR_Groove);
			float4 lerpResult56 = lerp( lerpResult145 , ( lerp(_Color0,tex2D( _GrooveMap, uv_GrooveMap ),_UseGrooveTex) * lerpResult145 ) , lerpResult64);
			float clampResult90 = clamp( ( 1.0 - _GR_WetSurf ) , 0.2 , 1.0 );
			float4 lerpResult83 = lerp( tex2D( _PhysicalTexture, uv_PhysicalTexture ) , ( lerpResult56 * clampResult90 ) , ( 1.0 - _GR_PhysDebug ));
			o.Albedo = lerpResult83.rgb;
			float lerpResult147 = lerp( tex2DNode3.r , tex2DNode146.r , clampResult142);
			float clampResult47 = clamp( ( lerpResult147 + temp_output_206_0 ) , 0.0 , 1.0 );
			float3 temp_cast_1 = (clampResult47).xxx;
			o.Specular = temp_cast_1;
			float lerpResult143 = lerp( tex2DNode1.a , tex2DNode144.a , clampResult142);
			float clampResult33 = clamp( ( ( lerpResult143 + temp_output_206_0 ) + ( _GR_WetSurf / 2.0 ) ) , 0.0 , 1.0 );
			o.Smoothness = clampResult33;
			float lerpResult149 = lerp( tex2DNode3.b , tex2DNode146.b , clampResult142);
			o.Occlusion = ( lerpResult149 + _GR_WetSurf );
			o.Alpha = 1;
			float lerpResult148 = lerp( tex2DNode3.g , tex2DNode146.g , clampResult142);
			clip( lerpResult148 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14401
1967;63;1762;925;6307.701;700.1129;3.120002;True;True
Node;AmplifyShaderEditor.RangedFloatNode;165;-5468.566,617.5628;Float;False;Property;_PuddlesSize;Puddles Size;10;0;Create;True;0;1.19;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;164;-5484.576,206.4814;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;167;-4838.894,603.1854;Float;False;2;0;FLOAT;0,0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;166;-4837.441,869.0663;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-4616.277,834.3033;Float;True;2;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-4624.735,558.9138;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;133;-5790.179,-1434.743;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldSpaceCameraPos;132;-5832.527,-1669.023;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FractNode;170;-4383.653,836.1284;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;171;-4401.903,560.5529;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;153;-5283.106,-1899.414;Float;False;Property;_TilingMainTextures;Tiling Main Textures;3;0;Create;True;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.DistanceOpNode;135;-5317.926,-1565.678;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-5325.348,-1392.323;Float;False;Property;_TransitionDistance;Transition Distance (in meters);12;0;Create;False;30;21.7;1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;163;-5286.705,-1755.028;Float;False;Property;_OffsetMainTextures;Offset Main Textures;4;0;Create;True;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.StepOpNode;173;-4166.663,823.3531;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;174;-4179.437,549.6039;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;139;-4766.535,-1378.159;Float;False;Property;_UVMultipliers;Tiling Multipliers for far texture;13;0;Create;False;1,0.2;1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-5046.72,-1562.203;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-5087.907,226.5712;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;138;-4923.495,-1778.348;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;136;-5028.298,-1394.098;Float;False;Property;_TransitionFalloff;Transition Falloff;11;0;Create;True;6;5.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;176;-3920.102,958.403;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;177;-3934.172,662.7542;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-4474.364,-1402.484;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;140;-4803.047,-1569.423;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;175;-4517.898,289.0777;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-3613.501,1084.329;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-3626.276,589.7542;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-3622.626,837.9541;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-3631.751,348.8557;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-3656.103,52.02406;Float;True;Property;_PuddlesTexture;Puddles Texture;9;0;Create;True;None;90955cf0c640ef9429f2fcadc9f090b0;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;146;-3288.857,-525.3444;Float;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;None;3f659051237889a43a35e1e72967b0c6;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;142;-4537.712,-1547.763;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-3187.949,-1173.582;Float;True;Property;_RSpecGTransparencyBAOAWetMap;(R)Spec-(G)Transparency-(B)AO -(A)WetMap;2;0;Create;True;None;78848ef3aaf6a57448e918a46b6c77ae;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-2994.651,1102.62;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-3004.226,853.6685;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-3002.311,298.3196;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;150;-2580.643,-205.3951;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-2990.821,579.8231;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-3180.502,-1849.383;Float;True;Property;_AlbedowithSmoothnessMap;Albedo (with Smoothness Map);0;0;Create;True;None;6da51ff8e4c3f1245b902f360cb6fc4f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;55;-2418.818,-2344.473;Float;True;Property;_GrooveMap;GrooveMap;8;0;Create;True;None;572078f7efe28924a996e6e0d35f816e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-2392.224,-2131.737;Float;False;Constant;_Color0;Color 0;7;0;Create;True;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;144;-3207.363,-1628.354;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-2319.007,154.951;Float;False;5;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2414.646,-1935.935;Float;False;Global;_GR_Groove;_GR_Groove;8;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;145;-2744.86,-1821.597;Float;True;3;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;201;-2095.796,155.2407;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2141.357,651.4941;Float;False;Global;_GR_WetSurf;_GR_WetSurf;6;0;Create;True;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-1893.142,-2222.358;Float;False;Property;_UseGrooveTex;Use Groove Tex;7;0;Create;True;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;54;-1874.802,977.3089;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;64;-1677.147,-2042.375;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;314.2041,-390.497;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1538.174,161.7106;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;143;-2752.141,-1532.748;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1603.039,-2204.064;Float;False;2;2;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;147;-2608.805,-1142.354;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;560.4168,-418.9025;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.2;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-1165.73,-1875.159;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;776.6593,-708.5289;Float;False;Global;_GR_PhysDebug;_GR_PhysDebug;6;0;Create;True;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-794.4315,631.7591;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-1167.691,731.4235;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;2.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1047.891,0.9829391;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;149;-2583.204,-517.7145;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1827.797,1451.395;Float;False;Property;_MaxDisplacementmeters;Max Displacement (meters);6;0;Create;True;0;-0.924;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;269.7823,-763.9866;Float;True;Property;_PhysicalTexture;Physical Texture;14;0;Create;True;None;81f56c8c35fbe5947ae76e975e98b7d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;762.0712,-464.5163;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;151;-561.0124,-219.145;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;None;e21ec1677435594459eb949cdb8bdef9;True;0;True;bump;Auto;True;Instance;2;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-479.8809,181.0737;Float;False;2;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;1074.568,-612.0295;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-504.8837,608.61;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;50;-1423.484,1271.131;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-560.7631,-493.5752;Float;True;Property;_Normalmap;Normal map;1;0;Create;True;None;e21ec1677435594459eb949cdb8bdef9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;85;-1657.665,1597.289;Float;False;Global;_GR_Displacement;_GR_Displacement;6;0;Create;True;0;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;196;-4842.266,739.489;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;1182.659,-517.5289;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;33;-170.5482,374.7318;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-4566.491,164.7914;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;148;-2601.124,-850.5142;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-1335.746,575.8272;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;152;-99.40269,-279.355;Float;False;3;0;FLOAT3;0.0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0.0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;47;-176.1671,111.7834;Float;False;3;0;FLOAT;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-4846.291,476.9939;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-822.4285,1284.116;Float;False;4;4;0;FLOAT;0.0;False;1;FLOAT3;0;False;2;FLOAT;0.0,0,0;False;3;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1612.121,58.40502;Float;False;True;6;Float;ASEMaterialInspector;0;0;StandardSpecular;gRally/Phys Road v2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Custom;0.681;True;True;0;True;Transparent;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;20;3;10;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;5;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;167;0;164;1
WireConnection;167;1;165;0
WireConnection;166;0;164;3
WireConnection;166;1;165;0
WireConnection;169;0;166;0
WireConnection;168;0;167;0
WireConnection;170;0;169;0
WireConnection;171;0;168;0
WireConnection;135;0;132;0
WireConnection;135;1;133;0
WireConnection;173;0;170;0
WireConnection;174;0;171;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;172;0;164;1
WireConnection;172;1;164;3
WireConnection;138;0;153;0
WireConnection;138;1;163;0
WireConnection;176;0;173;0
WireConnection;177;0;174;0
WireConnection;141;0;138;0
WireConnection;141;1;139;0
WireConnection;140;0;137;0
WireConnection;140;1;136;0
WireConnection;175;0;172;0
WireConnection;175;1;165;0
WireConnection;179;0;177;0
WireConnection;179;1;176;0
WireConnection;184;0;174;0
WireConnection;184;1;176;0
WireConnection;186;0;177;0
WireConnection;186;1;173;0
WireConnection;181;0;174;0
WireConnection;181;1;173;0
WireConnection;178;1;175;0
WireConnection;146;1;141;0
WireConnection;142;0;140;0
WireConnection;3;1;138;0
WireConnection;187;0;178;4
WireConnection;187;1;179;0
WireConnection;189;0;178;3
WireConnection;189;1;186;0
WireConnection;190;0;178;1
WireConnection;190;1;181;0
WireConnection;150;0;3;4
WireConnection;150;1;146;4
WireConnection;150;2;142;0
WireConnection;188;0;178;2
WireConnection;188;1;184;0
WireConnection;1;1;138;0
WireConnection;144;1;141;0
WireConnection;200;0;150;0
WireConnection;200;1;190;0
WireConnection;200;2;188;0
WireConnection;200;3;189;0
WireConnection;200;4;187;0
WireConnection;145;0;1;0
WireConnection;145;1;144;0
WireConnection;145;2;142;0
WireConnection;201;0;200;0
WireConnection;70;0;61;0
WireConnection;70;1;55;0
WireConnection;64;0;61;2
WireConnection;64;1;54;2
WireConnection;64;2;62;0
WireConnection;89;0;5;0
WireConnection;206;0;201;0
WireConnection;206;1;5;0
WireConnection;143;0;1;4
WireConnection;143;1;144;4
WireConnection;143;2;142;0
WireConnection;66;0;70;0
WireConnection;66;1;145;0
WireConnection;147;0;3;1
WireConnection;147;1;146;1
WireConnection;147;2;142;0
WireConnection;90;0;89;0
WireConnection;56;0;145;0
WireConnection;56;1;66;0
WireConnection;56;2;64;0
WireConnection;7;0;143;0
WireConnection;7;1;206;0
WireConnection;48;0;5;0
WireConnection;81;0;206;0
WireConnection;149;0;3;3
WireConnection;149;1;146;3
WireConnection;149;2;142;0
WireConnection;88;0;56;0
WireConnection;88;1;90;0
WireConnection;151;1;141;0
WireConnection;151;5;81;0
WireConnection;25;0;147;0
WireConnection;25;1;206;0
WireConnection;84;0;82;0
WireConnection;34;0;7;0
WireConnection;34;1;48;0
WireConnection;2;1;138;0
WireConnection;2;5;81;0
WireConnection;196;0;164;3
WireConnection;196;1;165;0
WireConnection;83;0;71;0
WireConnection;83;1;88;0
WireConnection;83;2;84;0
WireConnection;33;0;34;0
WireConnection;195;0;172;0
WireConnection;195;1;165;0
WireConnection;148;0;3;2
WireConnection;148;1;146;2
WireConnection;148;2;142;0
WireConnection;77;0;149;0
WireConnection;77;1;5;0
WireConnection;152;0;2;0
WireConnection;152;1;151;0
WireConnection;152;2;142;0
WireConnection;47;0;25;0
WireConnection;197;0;164;1
WireConnection;197;1;165;0
WireConnection;51;0;54;3
WireConnection;51;1;50;0
WireConnection;51;2;52;0
WireConnection;51;3;85;0
WireConnection;0;0;83;0
WireConnection;0;1;152;0
WireConnection;0;3;47;0
WireConnection;0;4;33;0
WireConnection;0;5;77;0
WireConnection;0;10;148;0
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=11CE5CD8D1FE2FC91D705D19B32A775965B718EC