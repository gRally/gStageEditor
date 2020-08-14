// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Dirt"
{
	Properties
	{
		_AlbedoTransparency("AlbedoTransparency", 2D) = "white" {}
		_Normal("Normal", 2D) = "bump" {}
		_MetallicSmoothnessAO("MetallicSmoothnessAO", 2D) = "white" {}
		_Dirt("Dirt", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Normal;
		uniform float4 _Normal_ST;
		uniform sampler2D _AlbedoTransparency;
		uniform float4 _AlbedoTransparency_ST;
		uniform sampler2D _Dirt;
		uniform float4 _Dirt_ST;
		uniform float _GR_Displacement;
		uniform float4 _DIRT_1_COLOR;
		uniform sampler2D _MetallicSmoothnessAO;
		uniform float4 _MetallicSmoothnessAO_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal = i.uv_texcoord * _Normal_ST.xy + _Normal_ST.zw;
			o.Normal = UnpackNormal( tex2D( _Normal, uv_Normal ) );
			float2 uv_AlbedoTransparency = i.uv_texcoord * _AlbedoTransparency_ST.xy + _AlbedoTransparency_ST.zw;
			float2 uv_Dirt = i.uv_texcoord * _Dirt_ST.xy + _Dirt_ST.zw;
			float4 tex2DNode4 = tex2D( _Dirt, uv_Dirt );
			float dirtVar14 = ( 1.0 - ( tex2DNode4.r * _GR_Displacement ) );
			o.Albedo = ( ( tex2D( _AlbedoTransparency, uv_AlbedoTransparency ) * dirtVar14 ) + ( _DIRT_1_COLOR * tex2DNode4.r * _GR_Displacement ) ).rgb;
			float2 uv_MetallicSmoothnessAO = i.uv_texcoord * _MetallicSmoothnessAO_ST.xy + _MetallicSmoothnessAO_ST.zw;
			float4 tex2DNode3 = tex2D( _MetallicSmoothnessAO, uv_MetallicSmoothnessAO );
			o.Metallic = tex2DNode3.r;
			o.Smoothness = min( tex2DNode3.a , dirtVar14 );
			o.Occlusion = tex2DNode3.g;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17200
31;3;1828;1018;1541.734;1245.499;1.664456;True;True
Node;AmplifyShaderEditor.SamplerNode;4;-390.6348,-577.5753;Inherit;True;Property;_Dirt;Dirt;3;0;Create;True;0;0;False;0;-1;None;ed222bdaf91fc1b4c9e54a3122759d7b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;5;-33.46157,-571.8078;Inherit;False;Global;_GR_Displacement;_GR_Displacement;4;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;8;-47.54895,-352.1513;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;9;125.1935,-316.0601;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;14;302.4909,-231.4853;Inherit;False;dirtVar;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-692.5,-318.5;Inherit;True;Property;_AlbedoTransparency;AlbedoTransparency;0;0;Create;True;0;0;False;0;-1;None;e83fde1f82a448f4c996c88bd76dba62;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;15;74.31246,95.7472;Inherit;False;14;dirtVar;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;6;375.0271,-564.92;Inherit;False;Global;_DIRT_1_COLOR;_DIRT_1_COLOR;4;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;10;580.5,-321.5;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;12;208.2807,-81.17237;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;17;-700.4324,576.545;Inherit;False;14;dirtVar;1;0;OBJECT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-957.3349,60.88705;Inherit;True;Property;_MetallicSmoothnessAO;MetallicSmoothnessAO;2;0;Create;True;0;0;False;0;-1;None;dee622cab3b03e84f8e3231f6f3362ad;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-647.5,-123.5;Inherit;True;Property;_Normal;Normal;1;0;Create;True;0;0;False;0;-1;None;6a115d9e824bfdd4eac93bf391facd76;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;13;463.453,8.190369;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMinOpNode;16;-180.3981,551.7814;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;402.98,314.5759;Float;False;True;2;ASEMaterialInspector;0;0;Standard;gRally/Dirt;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;ForwardOnly;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;8;0;4;1
WireConnection;8;1;5;0
WireConnection;9;0;8;0
WireConnection;14;0;9;0
WireConnection;10;0;6;0
WireConnection;10;1;4;1
WireConnection;10;2;5;0
WireConnection;12;0;1;0
WireConnection;12;1;15;0
WireConnection;13;0;12;0
WireConnection;13;1;10;0
WireConnection;16;0;3;4
WireConnection;16;1;17;0
WireConnection;0;0;13;0
WireConnection;0;1;2;0
WireConnection;0;3;3;1
WireConnection;0;4;16;0
WireConnection;0;5;3;2
ASEEND*/
//CHKSM=900C0DBADA8B6239EC0D7066C4CD38AD4D3E08F1