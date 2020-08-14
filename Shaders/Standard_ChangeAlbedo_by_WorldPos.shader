// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Standard_ChangeAlbedo_by_WorldPos"
{
	Properties
	{
		[NoScaleOffset]_Albedo("Albedo", 2D) = "white" {}
		[NoScaleOffset]_Normal("Normal", 2D) = "bump" {}
		_NormalScale("Normal Scale", Float) = 1
		[NoScaleOffset]_MetallicSmoothnessAO("Metallic + Smoothness + AO", 2D) = "white" {}
		[HideInInspector][NoScaleOffset]_TintColor("TintColor", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _NormalScale;
		uniform sampler2D _Normal;
		uniform sampler2D _Albedo;
		uniform sampler2D _TintColor;
		uniform sampler2D _MetallicSmoothnessAO;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Normal2 = i.uv_texcoord;
			o.Normal = UnpackScaleNormal( tex2D( _Normal, uv_Normal2 ), _NormalScale );
			float2 uv_Albedo1 = i.uv_texcoord;
			float4 transform25 = mul(unity_ObjectToWorld,float4( 0,0,0,1 ));
			float2 appendResult26 = (float2(transform25.x , transform25.z));
			o.Albedo = saturate( ( tex2D( _Albedo, uv_Albedo1 ) + tex2D( _TintColor, ( sin( appendResult26 ) * float2( 10000,10000 ) ) ) ) ).rgb;
			float2 uv_MetallicSmoothnessAO3 = i.uv_texcoord;
			float4 tex2DNode3 = tex2D( _MetallicSmoothnessAO, uv_MetallicSmoothnessAO3 );
			o.Metallic = tex2DNode3.r;
			o.Smoothness = tex2DNode3.g;
			o.Occlusion = tex2DNode3.b;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16902
1944;1;1887;1050;2458.557;1115.217;1.609999;True;True
Node;AmplifyShaderEditor.ObjectToWorldTransfNode;25;-1911.472,-593.3429;Float;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;26;-1651.336,-564.3526;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SinOpNode;27;-1434.376,-555.7024;Float;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;28;-1256.749,-559.3075;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;10000,10000;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;1;-1307.5,-959.1145;Float;True;Property;_Albedo;Albedo;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;01d3bf6d653fa0f41a56fef9fef51f70;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;23;-1056.914,-582.6693;Float;True;Property;_TintColor;TintColor;4;2;[HideInInspector];[NoScaleOffset];Create;True;0;0;False;0;None;b5c33f91c00506c40a12e150a404954b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1064.5,179.5;Float;False;Property;_NormalScale;Normal Scale;2;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-623.4089,-608.915;Float;True;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;2;-683.5,112.5;Float;True;Property;_Normal;Normal;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;a6faf8c8402e8aa4fbaefe70704c9830;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;3;-676.5,352.5;Float;True;Property;_MetallicSmoothnessAO;Metallic + Smoothness + AO;3;1;[NoScaleOffset];Create;True;0;0;False;0;None;5b0c60dc83cbeee42931f3fc79c4ee58;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;31;-267.3484,-261.9176;Float;False;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;gRally/Standard_ChangeAlbedo_by_WorldPos;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;26;0;25;1
WireConnection;26;1;25;3
WireConnection;27;0;26;0
WireConnection;28;0;27;0
WireConnection;23;1;28;0
WireConnection;7;0;1;0
WireConnection;7;1;23;0
WireConnection;2;5;4;0
WireConnection;31;0;7;0
WireConnection;0;0;31;0
WireConnection;0;1;2;0
WireConnection;0;3;3;1
WireConnection;0;4;3;2
WireConnection;0;5;3;3
ASEEND*/
//CHKSM=8651FCEBCDCDC574481CB3DC3505F85751C9BFEF