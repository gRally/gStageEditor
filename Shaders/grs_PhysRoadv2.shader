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
		[Toggle]_UseGrooveTex("Use Groove Tex", Float) = 1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 4.6
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float4 vertexColor : COLOR;
		};

		uniform sampler2D _RSpecGTransparencyBAOAWetMap;
		uniform float4 _RSpecGTransparencyBAOAWetMap_ST;
		uniform float _GR_WetSurf;
		uniform sampler2D _Normalmap;
		uniform float4 _Normalmap_ST;
		uniform sampler2D _PhysicalTexture;
		uniform float4 _PhysicalTexture_ST;
		uniform sampler2D _AlbedowithSmoothnessMap;
		uniform float4 _AlbedowithSmoothnessMap_ST;
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
			float2 uv_RSpecGTransparencyBAOAWetMap = i.uv_texcoord * _RSpecGTransparencyBAOAWetMap_ST.xy + _RSpecGTransparencyBAOAWetMap_ST.zw;
			float4 tex2DNode3 = tex2D( _RSpecGTransparencyBAOAWetMap, uv_RSpecGTransparencyBAOAWetMap );
			float smoothstepResult24 = smoothstep( tex2DNode3.a , 1.0 , _GR_WetSurf);
			float2 uv_Normalmap = i.uv_texcoord * _Normalmap_ST.xy + _Normalmap_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _Normalmap, uv_Normalmap ) ,( 1.0 - smoothstepResult24 ) );
			float2 uv_PhysicalTexture = i.uv_texcoord * _PhysicalTexture_ST.xy + _PhysicalTexture_ST.zw;
			float2 uv_AlbedowithSmoothnessMap = i.uv_texcoord * _AlbedowithSmoothnessMap_ST.xy + _AlbedowithSmoothnessMap_ST.zw;
			float4 tex2DNode1 = tex2D( _AlbedowithSmoothnessMap, uv_AlbedowithSmoothnessMap );
			float4 _Color0 = float4(0,0,0,0);
			float2 uv_GrooveMap = i.uv_texcoord * _GrooveMap_ST.xy + _GrooveMap_ST.zw;
			float lerpResult64 = lerp( _Color0.g , i.vertexColor.g , _GR_Groove);
			float4 lerpResult56 = lerp( tex2DNode1 , ( lerp(_Color0,tex2D( _GrooveMap, uv_GrooveMap ),_UseGrooveTex) * tex2DNode1 ) , lerpResult64);
			float clampResult90 = clamp( ( 1.0 - _GR_WetSurf ) , 0.2 , 1.0 );
			float4 lerpResult83 = lerp( tex2D( _PhysicalTexture, uv_PhysicalTexture ) , ( lerpResult56 * clampResult90 ) , ( 1.0 - _GR_PhysDebug ));
			o.Albedo = lerpResult83.rgb;
			float clampResult47 = clamp( ( tex2DNode3.r + smoothstepResult24 ) , 0.0 , 1.0 );
			float3 temp_cast_1 = (clampResult47).xxx;
			o.Specular = temp_cast_1;
			float clampResult33 = clamp( ( ( tex2DNode1.a + smoothstepResult24 ) + ( _GR_WetSurf / 2.0 ) ) , 0.0 , 1.0 );
			o.Smoothness = clampResult33;
			o.Occlusion = ( tex2DNode3.b + _GR_WetSurf );
			o.Alpha = 1;
			clip( tex2DNode3.g - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=14001
208;117;2284;1130;3157.555;433.4003;1.249407;True;True
Node;AmplifyShaderEditor.ColorNode;61;-2653.524,-814.3217;Float;False;Constant;_Color0;Color 0;7;0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;55;-2680.118,-1027.057;Float;True;Property;_GrooveMap;GrooveMap;6;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-2016.154,558.3212;Float;False;Global;_GR_WetSurf;_GR_WetSurf;6;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;8;-1952.962,725.6696;Float;False;Constant;_Float1;Float1;3;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-2154.444,-904.9422;Float;False;Property;_UseGrooveTex;Use Groove Tex;7;0;1;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.VertexColorNode;54;-1874.802,977.3089;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-3206.323,-339.1848;Float;True;Property;_AlbedowithSmoothnessMap;Albedo (with Smoothness Map);1;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;62;-2675.946,-618.5204;Float;False;Global;_GR_Groove;_GR_Groove;8;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-2290.492,211.5107;Float;True;Property;_RSpecGTransparencyBAOAWetMap;(R)Spec-(G)Transparency-(B)AO -(A)WetMap;3;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;89;314.2041,-390.497;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;64;-1735.546,-745.0004;Float;True;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1661.438,-906.6879;Float;False;2;2;0;COLOR;0.0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SmoothstepOpNode;24;-1466.803,394.1573;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0;False;2;FLOAT;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-1224.129,-577.7848;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0.0,0,0,0;False;2;FLOAT;0.0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-794.4315,631.7591;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-1167.691,731.4235;Float;False;2;0;FLOAT;0.0;False;1;FLOAT;2.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;776.6593,-708.5289;Float;False;Global;_GR_PhysDebug;_GR_PhysDebug;6;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;560.4168,-418.9025;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.2;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-1657.665,1597.289;Float;False;Global;_GR_Displacement;_GR_Displacement;6;0;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1827.797,1451.395;Float;False;Property;_MaxDisplacementmeters;Max Displacement (meters);5;0;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-504.8837,608.61;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;269.7823,-763.9866;Float;True;Property;_PhysicalTexture;Physical Texture;0;0;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;81;-1035.406,94.52299;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.NormalVertexDataNode;50;-1423.484,1271.131;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;84;1074.568,-612.0295;Float;False;1;0;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;762.0712,-464.5163;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-479.8809,181.0737;Float;False;2;2;0;FLOAT;0,0,0,0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-1335.746,575.8272;Float;False;2;2;0;FLOAT;0.0;False;1;FLOAT;0.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-822.4285,1284.116;Float;False;4;4;0;FLOAT;0.0;False;1;FLOAT3;0;False;2;FLOAT;0.0,0,0;False;3;FLOAT;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.LerpOp;83;1182.659,-517.5289;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-540.6932,-43.11484;Float;True;Property;_Normalmap;Normal map;2;0;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0.0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1.0;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;33;-170.5482,374.7318;Float;False;3;0;FLOAT;0.0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;47;-176.1671,111.7834;Float;False;3;0;FLOAT;0,0,0;False;1;FLOAT;0.0;False;2;FLOAT;1.0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1606.731,61.65502;Float;False;True;6;Float;ASEMaterialInspector;0;0;StandardSpecular;gRally/Phys Road v2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;0;False;0;0;Custom;0.681;True;True;0;True;Transparent;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;False;0;255;255;0;0;0;0;0;0;0;0;False;0;20;3;10;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;4;-1;-1;-1;0;0;0;False;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0.0;False;5;FLOAT;0.0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0.0;False;9;FLOAT;0.0;False;10;FLOAT;0.0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;70;0;61;0
WireConnection;70;1;55;0
WireConnection;89;0;5;0
WireConnection;64;0;61;2
WireConnection;64;1;54;2
WireConnection;64;2;62;0
WireConnection;66;0;70;0
WireConnection;66;1;1;0
WireConnection;24;0;5;0
WireConnection;24;1;3;4
WireConnection;24;2;8;0
WireConnection;56;0;1;0
WireConnection;56;1;66;0
WireConnection;56;2;64;0
WireConnection;7;0;1;4
WireConnection;7;1;24;0
WireConnection;48;0;5;0
WireConnection;90;0;89;0
WireConnection;34;0;7;0
WireConnection;34;1;48;0
WireConnection;81;0;24;0
WireConnection;84;0;82;0
WireConnection;88;0;56;0
WireConnection;88;1;90;0
WireConnection;25;0;3;1
WireConnection;25;1;24;0
WireConnection;77;0;3;3
WireConnection;77;1;5;0
WireConnection;51;0;54;3
WireConnection;51;1;50;0
WireConnection;51;2;52;0
WireConnection;51;3;85;0
WireConnection;83;0;71;0
WireConnection;83;1;88;0
WireConnection;83;2;84;0
WireConnection;2;5;81;0
WireConnection;33;0;34;0
WireConnection;47;0;25;0
WireConnection;0;0;83;0
WireConnection;0;1;2;0
WireConnection;0;3;47;0
WireConnection;0;4;33;0
WireConnection;0;5;77;0
WireConnection;0;10;3;2
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=9B33C2B92403F342677B50DB318A0DA54240F5E3