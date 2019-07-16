// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/SurfShad_EmissionAnim"
{
	Properties
	{
		_Albedo("Albedo", 2D) = "white" {}
		_Emission("Emission", 2D) = "white" {}
		[HDR]_EmissionColorMultiplier("Emission Color Multiplier", Color) = (0,0,0,0)
		_EmissionMultiplierUVPannedMap("Emission Multiplier UV Panned Map ", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 3.0
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _Albedo;
		uniform float4 _Albedo_ST;
		uniform sampler2D _Emission;
		uniform float4 _Emission_ST;
		uniform float4 _EmissionColorMultiplier;
		uniform sampler2D _EmissionMultiplierUVPannedMap;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_Albedo = i.uv_texcoord * _Albedo_ST.xy + _Albedo_ST.zw;
			o.Albedo = tex2D( _Albedo, uv_Albedo ).rgb;
			float2 uv_Emission = i.uv_texcoord * _Emission_ST.xy + _Emission_ST.zw;
			float2 panner20 = ( 0.1 * _Time.y * float2( 1,1 ) + i.uv_texcoord);
			o.Emission = ( tex2D( _Emission, uv_Emission ) * _EmissionColorMultiplier * tex2D( _EmissionMultiplierUVPannedMap, panner20 ) ).rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16600
1983;2;1744;1027;2023.931;315.1065;1.545;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;23;-1629.753,905.5955;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;20;-1284.997,911.4198;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;1,1;False;1;FLOAT;0.1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;2;-1040.961,135.4004;Float;True;Property;_Emission;Emission;1;0;Create;True;0;0;False;0;None;e8e8cc8f32ddc0e428b83d0be15b93c6;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;5;-966.9105,335.1903;Float;False;Property;_EmissionColorMultiplier;Emission Color Multiplier;2;1;[HDR];Create;True;0;0;False;0;0,0,0,0;2.996078,1.145098,0.5803922,1;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;21;-1033.678,903.9051;Float;True;Property;_EmissionMultiplierUVPannedMap;Emission Multiplier UV Panned Map ;3;0;Create;True;0;0;False;0;None;1ee730f09c62f4d4eb90f720860c0771;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;7;-2752.991,622.0245;Float;False;1;0;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;10;-2473.415,570.3599;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-408.7101,225.3203;Float;True;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;15;-2204.079,555.0398;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;10;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;11;-1906.651,552.2949;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;18;-999.4986,608.8602;Float;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0.7;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;19;-1223.078,612.5106;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;12;-1677.927,556.0403;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;16;-1469.51,572.9202;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;1;-999.8251,-95.55497;Float;True;Property;_Albedo;Albedo;0;0;Create;True;0;0;False;0;None;e796fb4e2eee42642bd745343d43e02c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;0,0;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;gRally/SurfShad_EmissionAnim;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;20;0;23;0
WireConnection;21;1;20;0
WireConnection;10;0;7;0
WireConnection;3;0;2;0
WireConnection;3;1;5;0
WireConnection;3;2;21;0
WireConnection;15;0;10;0
WireConnection;11;0;15;0
WireConnection;11;1;7;0
WireConnection;18;0;19;0
WireConnection;19;0;16;0
WireConnection;12;0;11;0
WireConnection;16;0;12;0
WireConnection;0;0;1;0
WireConnection;0;2;3;0
ASEEND*/
//CHKSM=5C28097E419889A45170067A562CFC8D3486B7B1