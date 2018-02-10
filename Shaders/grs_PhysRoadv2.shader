// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Phys Road v2"
{
	Properties
	{
		_PhysicalTexture("Physical Texture", 2D) = "white" {}
		_AlbedowithSmoothnessMap("Albedo (with Smoothness Map)", 2D) = "white" {}
		_Normalmap("Normal map", 2D) = "bump" {}
		_RSpecGTransparencyBAOAWetMap("(R)Spec-(G)Transparency-(B)AO -(A)WetMap", 2D) = "white" {}
		_Cutoff( "Mask Clip Value", Float ) = 0.681
		_MaxDisplacementmeters("Max Displacement (meters)", Range( -1 , 0)) = 0
		_GrooveMap("GrooveMap", 2D) = "white" {}
		[Toggle]_UseGrooveTex("Use Groove Tex", Float) = 0
		_PuddlesTexture("Puddles Texture", 2D) = "white" {}
		_PuddlesSize("Puddles Size", Float) = 0
		_TransitionFalloff("Transition Falloff", Float) = 2
		_TransitionDistance("Transition Distance", Range( 1 , 150)) = 1
		_UVMultipliers("UV Multipliers (XY = UV)", Vector) = (0,0,0,0)
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
			float2 uv_TexCoord138 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			float4 tex2DNode3 = tex2D( _RSpecGTransparencyBAOAWetMap, uv_TexCoord138 );
			float2 temp_output_141_0 = ( uv_TexCoord138 * _UVMultipliers );
			float4 tex2DNode146 = tex2D( _RSpecGTransparencyBAOAWetMap, temp_output_141_0 );
			float3 ase_worldPos = i.worldPos;
			float clampResult142 = clamp( pow( ( distance( _WorldSpaceCameraPos , ase_worldPos ) / _TransitionDistance ) , _TransitionFalloff ) , 0.0 , 1.0 );
			float lerpResult150 = lerp( tex2DNode3.a , tex2DNode146.a , clampResult142);
			float2 appendResult109 = (float2(ase_worldPos.x , ase_worldPos.z));
			float4 tex2DNode118 = tex2D( _PuddlesTexture, ( appendResult109 / _PuddlesSize ) );
			float temp_output_110_0 = step( frac( ( ( ase_worldPos.x / _PuddlesSize ) * 0.5 ) ) , 0.5 );
			float temp_output_111_0 = step( frac( ( ( ase_worldPos.z / _PuddlesSize ) * 0.5 ) ) , 0.5 );
			float temp_output_112_0 = ( 1.0 - temp_output_111_0 );
			float temp_output_114_0 = ( 1.0 - temp_output_110_0 );
			float smoothstepResult24 = smoothstep( ( lerpResult150 * ( 1.0 - ( tex2DNode118.r * ( temp_output_110_0 * temp_output_111_0 ) ) ) * ( 1.0 - ( ( temp_output_110_0 * temp_output_112_0 ) * tex2DNode118.g ) ) * ( 1.0 - ( ( temp_output_114_0 * temp_output_111_0 ) * tex2DNode118.b ) ) * ( 1.0 - ( ( temp_output_114_0 * temp_output_112_0 ) * tex2DNode118.a ) ) ) , 1.0 , _GR_WetSurf);
			float temp_output_81_0 = ( 1.0 - smoothstepResult24 );
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
			float clampResult47 = clamp( ( lerpResult147 + smoothstepResult24 ) , 0.0 , 1.0 );
			float3 temp_cast_1 = (clampResult47).xxx;
			o.Specular = temp_cast_1;
			float lerpResult143 = lerp( tex2DNode1.a , tex2DNode144.a , clampResult142);
			float clampResult33 = clamp( ( ( lerpResult143 + smoothstepResult24 ) + ( _GR_WetSurf / 2.0 ) ) , 0.0 , 1.0 );
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
1927;29;1880;1004;5240.584;2003.314;3.454999;True;True
Node;AmplifyShaderEditor.RangedFloatNode;93;-5956.034,789.8777;Float;False;Property;_PuddlesSize;Puddles Size;9;0;Create;True;0;1.66;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;101;-5974.614,378.795;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleDivideOpNode;126;-5328.933,775.5002;Float;False;2;0;FLOAT;0,0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;127;-5327.48,1041.381;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;106;-5106.317,1006.618;Float;True;2;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;105;-5116.414,732.8682;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;132;-5832.527,-1669.023;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;133;-5790.179,-1434.743;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.FractNode;108;-4873.692,1008.443;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;107;-4891.942,732.8674;Float;True;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-5326.368,-1392.323;Float;False;Property;_TransitionDistance;Transition Distance;11;0;Create;True;1;21.7;1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;135;-5317.926,-1565.678;Float;False;2;0;FLOAT3;0,0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;110;-4671.116,721.9183;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;109;-5577.945,398.8848;Float;False;FLOAT2;4;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;111;-4658.343,995.6678;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-5028.298,-1394.098;Float;False;Property;_TransitionFalloff;Transition Falloff;10;0;Create;True;2;5.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-5046.72,-1562.203;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;125;-5007.937,461.3911;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;112;-4410.142,1130.718;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;114;-4437.517,835.069;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;138;-4923.495,-1778.348;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;139;-4766.535,-1378.159;Float;False;Property;_UVMultipliers;UV Multipliers (XY = UV);12;0;Create;False;0,0;1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;116;-4116.316,762.0689;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;118;-4147.423,225.6178;Float;True;Property;_PuddlesTexture;Puddles Texture;8;0;Create;True;None;712f91f147bbc354f8cbf87e4fa0a6ef;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-4103.541,1256.643;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;140;-4803.047,-1569.423;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;115;-4112.666,1010.269;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-4474.364,-1402.484;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;119;-4121.791,521.1699;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;142;-4537.712,-1547.763;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;146;-3288.857,-525.3444;Float;True;Property;_TextureSample1;Texture Sample 1;3;0;Create;True;None;3f659051237889a43a35e1e72967b0c6;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-3187.949,-1173.582;Float;True;Property;_RSpecGTransparencyBAOAWetMap;(R)Spec-(G)Transparency-(B)AO -(A)WetMap;3;0;Create;True;None;3f659051237889a43a35e1e72967b0c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;123;-3492.351,470.6331;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;122;-3494.266,1025.983;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;121;-3480.861,752.138;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;120;-3484.691,1274.934;Float;True;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;144;-3207.363,-1628.354;Float;True;Property;_TextureSample0;Texture Sample 0;1;0;Create;True;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-2392.224,-2131.737;Float;False;Constant;_Color0;Color 0;7;0;Create;True;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;130;-3143.753,726.7655;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-2418.818,-2344.473;Float;True;Property;_GrooveMap;GrooveMap;6;0;Create;True;None;572078f7efe28924a996e6e0d35f816e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;129;-3138.188,617.3212;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;128;-3136.236,506.4707;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;150;-2580.643,-205.3951;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-3180.502,-1849.383;Float;True;Property;_AlbedowithSmoothnessMap;Albedo (with Smoothness Map);1;0;Create;True;None;6da51ff8e4c3f1245b902f360cb6fc4f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;131;-3141.899,841.7762;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;97;-1870.149,411.8238;Float;False;5;5;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;3;FLOAT;0.0;False;4;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2414.646,-1935.935;Float;False;Global;_GR_Groove;_GR_Groove;8;0;Create;True;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-1893.142,-2222.358;Float;False;Property;_UseGrooveTex;Use Groove Tex;7;0;Create;True;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2022.701,618.5539;Float;False;Global;_GR_WetSurf;_GR_WetSurf;6;0;Create;True;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1952.962,725.6696;Float;False;Constant;_Float1;Float1;3;0;Create;True;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;145;-2744.86,-1821.597;Float;True;3;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;54;-1874.802,977.3089;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;64;-1677.147,-2042.375;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;143;-2752.141,-1532.748;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;314.2041,-390.497;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1603.039,-2204.064;Float;False;2;2;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;24;-1466.803,394.1573;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0;False;2;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;147;-2608.805,-1142.354;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-1165.73,-1875.159;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1035.406,94.52299;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-794.4315,631.7591;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;560.4168,-418.9025;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.2;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-1167.691,731.4235;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;2.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;776.6593,-708.5289;Float;False;Global;_GR_PhysDebug;_GR_PhysDebug;6;0;Create;True;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-504.8837,608.61;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;50;-1423.484,1271.131;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;151;-561.0124,-219.145;Float;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;None;e21ec1677435594459eb949cdb8bdef9;True;0;True;bump;Auto;True;Instance;2;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-560.7631,-493.5752;Float;True;Property;_Normalmap;Normal map;2;0;Create;True;None;e21ec1677435594459eb949cdb8bdef9;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;84;1074.568,-612.0295;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;149;-2583.204,-517.7145;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1827.797,1451.395;Float;False;Property;_MaxDisplacementmeters;Max Displacement (meters);5;0;Create;True;0;-0.924;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;762.0712,-464.5163;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1657.665,1597.289;Float;False;Global;_GR_Displacement;_GR_Displacement;6;0;Create;True;0;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;269.7823,-763.9866;Float;True;Property;_PhysicalTexture;Physical Texture;0;0;Create;True;None;81f56c8c35fbe5947ae76e975e98b7d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-479.8809,181.0737;Float;False;2;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;113;-5056.53,337.105;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-822.4285,1284.116;Float;False;4;4;0;FLOAT;0.0;False;1;FLOAT3;0;False;2;FLOAT;0.0,0,0;False;3;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-5332.305,911.8035;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;148;-2601.124,-850.5142;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-5336.329,649.3081;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;1182.659,-517.5289;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;47;-176.1671,111.7834;Float;False;3;0;FLOAT;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-1335.746,575.8272;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-170.5482,374.7318;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;152;-99.40269,-279.355;Float;False;3;0;FLOAT3;0.0,0,0;False;1;FLOAT3;0.0;False;2;FLOAT;0.0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1609.486,58.40502;Float;False;True;6;Float;ASEMaterialInspector;0;0;StandardSpecular;gRally/Phys Road v2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;False;0;Custom;0.681;True;True;0;True;Transparent;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;20;3;10;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;4;-1;-1;-1;0;0;0;False;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;126;0;101;1
WireConnection;126;1;93;0
WireConnection;127;0;101;3
WireConnection;127;1;93;0
WireConnection;106;0;127;0
WireConnection;105;0;126;0
WireConnection;108;0;106;0
WireConnection;107;0;105;0
WireConnection;135;0;132;0
WireConnection;135;1;133;0
WireConnection;110;0;107;0
WireConnection;109;0;101;1
WireConnection;109;1;101;3
WireConnection;111;0;108;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;125;0;109;0
WireConnection;125;1;93;0
WireConnection;112;0;111;0
WireConnection;114;0;110;0
WireConnection;116;0;110;0
WireConnection;116;1;112;0
WireConnection;118;1;125;0
WireConnection;117;0;114;0
WireConnection;117;1;112;0
WireConnection;140;0;137;0
WireConnection;140;1;136;0
WireConnection;115;0;114;0
WireConnection;115;1;111;0
WireConnection;141;0;138;0
WireConnection;141;1;139;0
WireConnection;119;0;110;0
WireConnection;119;1;111;0
WireConnection;142;0;140;0
WireConnection;146;1;141;0
WireConnection;3;1;138;0
WireConnection;123;0;118;1
WireConnection;123;1;119;0
WireConnection;122;0;115;0
WireConnection;122;1;118;3
WireConnection;121;0;116;0
WireConnection;121;1;118;2
WireConnection;120;0;117;0
WireConnection;120;1;118;4
WireConnection;144;1;141;0
WireConnection;130;0;122;0
WireConnection;129;0;121;0
WireConnection;128;0;123;0
WireConnection;150;0;3;4
WireConnection;150;1;146;4
WireConnection;150;2;142;0
WireConnection;1;1;138;0
WireConnection;131;0;120;0
WireConnection;97;0;150;0
WireConnection;97;1;128;0
WireConnection;97;2;129;0
WireConnection;97;3;130;0
WireConnection;97;4;131;0
WireConnection;70;0;61;0
WireConnection;70;1;55;0
WireConnection;145;0;1;0
WireConnection;145;1;144;0
WireConnection;145;2;142;0
WireConnection;64;0;61;2
WireConnection;64;1;54;2
WireConnection;64;2;62;0
WireConnection;143;0;1;4
WireConnection;143;1;144;4
WireConnection;143;2;142;0
WireConnection;89;0;5;0
WireConnection;66;0;70;0
WireConnection;66;1;145;0
WireConnection;24;0;5;0
WireConnection;24;1;97;0
WireConnection;24;2;8;0
WireConnection;147;0;3;1
WireConnection;147;1;146;1
WireConnection;147;2;142;0
WireConnection;56;0;145;0
WireConnection;56;1;66;0
WireConnection;56;2;64;0
WireConnection;81;0;24;0
WireConnection;7;0;143;0
WireConnection;7;1;24;0
WireConnection;90;0;89;0
WireConnection;48;0;5;0
WireConnection;34;0;7;0
WireConnection;34;1;48;0
WireConnection;151;1;141;0
WireConnection;151;5;81;0
WireConnection;2;1;138;0
WireConnection;2;5;81;0
WireConnection;84;0;82;0
WireConnection;149;0;3;3
WireConnection;149;1;146;3
WireConnection;149;2;142;0
WireConnection;88;0;56;0
WireConnection;88;1;90;0
WireConnection;25;0;147;0
WireConnection;25;1;24;0
WireConnection;113;0;109;0
WireConnection;113;1;93;0
WireConnection;51;0;54;3
WireConnection;51;1;50;0
WireConnection;51;2;52;0
WireConnection;51;3;85;0
WireConnection;104;0;101;3
WireConnection;104;1;93;0
WireConnection;148;0;3;2
WireConnection;148;1;146;2
WireConnection;148;2;142;0
WireConnection;103;0;101;1
WireConnection;103;1;93;0
WireConnection;83;0;71;0
WireConnection;83;1;88;0
WireConnection;83;2;84;0
WireConnection;47;0;25;0
WireConnection;77;0;149;0
WireConnection;77;1;5;0
WireConnection;33;0;34;0
WireConnection;152;0;2;0
WireConnection;152;1;151;0
WireConnection;152;2;142;0
WireConnection;0;0;83;0
WireConnection;0;1;152;0
WireConnection;0;3;47;0
WireConnection;0;4;33;0
WireConnection;0;5;77;0
WireConnection;0;10;148;0
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=AB0EBC350C1CAFE586800A40FCF2B5A044B4AE00