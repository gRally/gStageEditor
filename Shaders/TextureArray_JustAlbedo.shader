// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/TextureArray/JustAlbedo"
{
	Properties
	{
		[NoScaleOffset]_AlbedoTextureArray("Albedo Texture Array", 2DArray ) = "" {}
		_AlbedoIndexTexture("Albedo Index Texture", Int) = 0
		[NoScaleOffset]_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalMapScale("Normal Map Scale", Float) = 0
		[NoScaleOffset]_MetallicRSmoothnessMap("Metallic (R) + Smoothness Map", 2D) = "white" {}
		[NoScaleOffset]_AmbientOcclusion("Ambient Occlusion", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#pragma target 3.5
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _NormalMapScale;
		uniform sampler2D _NormalMap;
		uniform UNITY_DECLARE_TEX2DARRAY( _AlbedoTextureArray );
		uniform float4 _AlbedoTextureArray_ST;
		uniform int _AlbedoIndexTexture;
		uniform sampler2D _MetallicRSmoothnessMap;
		uniform sampler2D _AmbientOcclusion;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap3 = i.uv_texcoord;
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap3 ), _NormalMapScale );
			float2 uv_AlbedoTextureArray = i.uv_texcoord * _AlbedoTextureArray_ST.xy + _AlbedoTextureArray_ST.zw;
			float4 texArray1 = UNITY_SAMPLE_TEX2DARRAY(_AlbedoTextureArray, float3(uv_AlbedoTextureArray, (float)_AlbedoIndexTexture)  );
			o.Albedo = texArray1.rgb;
			float2 uv_MetallicRSmoothnessMap4 = i.uv_texcoord;
			float4 tex2DNode4 = tex2D( _MetallicRSmoothnessMap, uv_MetallicRSmoothnessMap4 );
			o.Metallic = tex2DNode4.r;
			o.Smoothness = tex2DNode4.a;
			float2 uv_AmbientOcclusion8 = i.uv_texcoord;
			o.Occlusion = tex2D( _AmbientOcclusion, uv_AmbientOcclusion8 ).r;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16600
1958;7;1744;1009;1560.63;312.9695;1.38;True;True
Node;AmplifyShaderEditor.IntNode;6;-944.4602,-120.4598;Float;False;Property;_AlbedoIndexTexture;Albedo Index Texture;1;0;Create;True;0;0;False;0;0;1;0;1;INT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-929.9711,92.75005;Float;False;Property;_NormalMapScale;Normal Map Scale;3;0;Create;True;0;0;False;0;0;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;3;-577.12,52;Float;True;Property;_NormalMap;Normal Map;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;45f53d3b5ecd89b408b8d94da7b73f9d;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureArrayNode;1;-577.26,-170.04;Float;True;Property;_AlbedoTextureArray;Albedo Texture Array;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;0;Object;-1;Auto;False;7;6;SAMPLER2D;;False;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;4;FLOAT2;0,0;False;5;FLOAT2;0,0;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;4;-593.86,271.28;Float;True;Property;_MetallicRSmoothnessMap;Metallic (R) + Smoothness Map;4;1;[NoScaleOffset];Create;True;0;0;False;0;None;36f6fed60c27399408d77570566adace;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;8;-569.7905,501.2303;Float;True;Property;_AmbientOcclusion;Ambient Occlusion;5;1;[NoScaleOffset];Create;True;0;0;False;0;None;4c3c19182162f5041809cf8db760fd05;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;88.31999,173.88;Float;False;True;3;Float;ASEMaterialInspector;0;0;Standard;gRally/TextureArray/JustAlbedo;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;3;5;7;0
WireConnection;1;1;6;0
WireConnection;0;0;1;0
WireConnection;0;1;3;0
WireConnection;0;3;4;1
WireConnection;0;4;4;4
WireConnection;0;5;8;1
ASEEND*/
//CHKSM=922BEC29302287E2E5ED7E69D2B5B8754F0C1A39