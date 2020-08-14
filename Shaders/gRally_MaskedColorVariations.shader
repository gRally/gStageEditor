// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/MaskedColorVariations"
{
	Properties
	{
		_ColorChangeFrequence("Color Change Frequence (0 no change)", Float) = 1
		[Header(Color variations will be applied using the masks (Max 4 masks).)]_AlbedoMasksonAlpha("Albedo (Masks on Alpha)", 2D) = "white" {}
		[Header(Each row of colors is used for each mask)]_ColorVariationsMap("Color Variations Map", 2D) = "white" {}
		[Space(20)]_NormalMap("Normal Map", 2D) = "bump" {}
		_NormalMapMultiplier("NormalMap Multiplier", Float) = 1
		[Space(20)]_MetallicRAOGSmoothnessA("Metallic (R) AO (G) Smoothness (A)", 2D) = "white" {}
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
		#pragma exclude_renderers metal xbox360 xboxone ps4 psp2 n3ds wiiu 
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float _NormalMapMultiplier;
		uniform sampler2D _NormalMap;
		uniform float4 _NormalMap_ST;
		uniform sampler2D _AlbedoMasksonAlpha;
		uniform float4 _AlbedoMasksonAlpha_ST;
		uniform sampler2D _ColorVariationsMap;
		uniform float _ColorChangeFrequence;
		uniform sampler2D _MetallicRAOGSmoothnessA;
		uniform float4 _MetallicRAOGSmoothnessA_ST;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 uv_NormalMap = i.uv_texcoord * _NormalMap_ST.xy + _NormalMap_ST.zw;
			o.Normal = UnpackScaleNormal( tex2D( _NormalMap, uv_NormalMap ), _NormalMapMultiplier );
			float2 uv_AlbedoMasksonAlpha = i.uv_texcoord * _AlbedoMasksonAlpha_ST.xy + _AlbedoMasksonAlpha_ST.zw;
			float4 tex2DNode66 = tex2D( _AlbedoMasksonAlpha, uv_AlbedoMasksonAlpha );
			float4 tex2DNode151 = tex2D( _AlbedoMasksonAlpha, uv_AlbedoMasksonAlpha );
			float AlphaChan196 = tex2DNode151.a;
			float temp_output_185_0 = saturate( ( saturate( ( AlphaChan196 - 0.75 ) ) * 4.0 ) );
			float mask189 = temp_output_185_0;
			float temp_output_189_0 = saturate( ( saturate( ( ( AlphaChan196 - temp_output_185_0 ) - 0.5 ) ) * 4.0 ) );
			float mask292 = temp_output_189_0;
			float temp_output_199_0 = saturate( ( temp_output_185_0 + temp_output_189_0 ) );
			float temp_output_195_0 = saturate( ( saturate( ( ( AlphaChan196 - temp_output_199_0 ) - 0.25 ) ) * 4.0 ) );
			float mask394 = temp_output_195_0;
			float mask4166 = saturate( ( saturate( ( AlphaChan196 - saturate( ( temp_output_199_0 + temp_output_195_0 ) ) ) ) * 4.0 ) );
			float3 objToWorld220 = mul( unity_ObjectToWorld, float4( float3( 0,0,0 ), 1 ) ).xyz;
			float2 appendResult61 = (float2(objToWorld220.x , objToWorld220.z));
			float2 break64 = ( appendResult61 * _ColorChangeFrequence );
			float temp_output_148_0 = ( break64.x + break64.y );
			float2 appendResult65 = (float2(temp_output_148_0 , 0.81));
			float2 appendResult113 = (float2(temp_output_148_0 , 0.61));
			float2 appendResult129 = (float2(temp_output_148_0 , 0.41));
			float2 appendResult176 = (float2(temp_output_148_0 , 0.21));
			o.Albedo = ( ( tex2DNode66 * ( 1.0 - saturate( ( mask189 + mask292 + mask394 + mask4166 ) ) ) ) + ( ( tex2D( _ColorVariationsMap, appendResult65 ) * tex2DNode66 * mask189 ) + ( tex2D( _ColorVariationsMap, appendResult113 ) * tex2D( _AlbedoMasksonAlpha, uv_AlbedoMasksonAlpha ) * mask292 ) + ( tex2D( _ColorVariationsMap, appendResult129 ) * tex2D( _AlbedoMasksonAlpha, uv_AlbedoMasksonAlpha ) * mask394 ) + ( tex2D( _ColorVariationsMap, appendResult176 ) * tex2D( _AlbedoMasksonAlpha, uv_AlbedoMasksonAlpha ) * mask4166 ) ) ).rgb;
			float2 uv_MetallicRAOGSmoothnessA = i.uv_texcoord * _MetallicRAOGSmoothnessA_ST.xy + _MetallicRAOGSmoothnessA_ST.zw;
			float4 tex2DNode51 = tex2D( _MetallicRAOGSmoothnessA, uv_MetallicRAOGSmoothnessA );
			o.Metallic = tex2DNode51.r;
			o.Smoothness = tex2DNode51.a;
			o.Occlusion = tex2DNode51.g;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=17703
1944;8;1856;1039;4123.124;320.3825;1.585;True;True
Node;AmplifyShaderEditor.SamplerNode;151;-3390.79,2309.553;Inherit;True;Property;_TextureSample1;Texture Sample 1;1;0;Create;True;0;0;False;0;-1;7179ccb315f2414409e9e5116685a59d;7179ccb315f2414409e9e5116685a59d;True;0;False;white;Auto;False;Instance;66;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;196;-3112.29,2617.026;Inherit;False;AlphaChan;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-2848.007,3039.727;Inherit;False;196;AlphaChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;180;-2532.171,3051.796;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.75;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;183;-2245.372,3045.795;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-2019.773,3049.395;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;185;-1772.573,3048.194;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;215;-2813.177,3364.806;Inherit;False;196;AlphaChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;186;-2515.453,3378.659;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;190;-2238.368,3378.448;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;187;-1984.854,3380.608;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-1759.255,3384.208;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;189;-1512.055,3383.007;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;198;-1256.808,3373.282;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;197;-2126.404,3687.245;Inherit;False;196;AlphaChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;199;-1043.659,3373.281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;191;-1864.23,3677.075;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;192;-1640.065,3676.865;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.25;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;193;-1422.975,3678.729;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;194;-1246.727,3677.24;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;195;-1030.077,3679.954;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-830.6017,3694.457;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;202;-617.4526,3694.456;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;201;-1766.687,3982.374;Inherit;False;196;AlphaChan;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;203;-1504.513,3972.205;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.54;False;1;FLOAT;0
Node;AmplifyShaderEditor.TransformPositionNode;220;-4026.887,287.8624;Inherit;False;Object;World;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;205;-1254.658,3965.885;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1078.409,3965.959;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;4;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-3564.21,439.1668;Inherit;False;Property;_ColorChangeFrequence;Color Change Frequence (0 no change);0;0;Create;False;0;0;False;0;1;0.01;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;61;-3734.677,305.9772;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;218;-3183.378,306.8867;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SaturateNode;207;-861.7598,3967.108;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;92;-830.4339,3254.366;Inherit;False;mask2;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;166;-608.8318,3958.615;Inherit;False;mask4;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;94;-408.8244,3581.541;Inherit;False;mask3;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;64;-3021.101,305.2675;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RegisterLocalVarNode;89;-1462.376,3045.371;Inherit;False;mask1;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;136;-1827.754,748.721;Inherit;False;94;mask3;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;121;-1851.428,-466.4041;Inherit;False;89;mask1;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;122;-1846.575,138.9509;Inherit;False;92;mask2;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;173;-1796.888,1326.972;Inherit;False;166;mask4;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;148;-2748.625,306.1343;Inherit;False;2;2;0;FLOAT;1;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;129;-2164.98,876.0525;Inherit;False;FLOAT2;4;0;FLOAT;0.03;False;1;FLOAT;0.41;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;176;-2104.36,1434.946;Inherit;False;FLOAT2;4;0;FLOAT;0.03;False;1;FLOAT;0.21;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;65;-2349.343,-207.0228;Inherit;False;FLOAT2;4;0;FLOAT;2.22;False;1;FLOAT;0.81;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;113;-2321.74,312.4223;Inherit;False;FLOAT2;4;0;FLOAT;0.09;False;1;FLOAT;0.61;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;137;-866.5574,-144.8756;Inherit;False;4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;155;-1926.95,-61.19067;Inherit;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;66;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;66;-1904.273,-680.657;Inherit;True;Property;_AlbedoMasksonAlpha;Albedo (Masks on Alpha);1;0;Create;True;0;0;False;1;Header(Color variations will be applied using the masks (Max 4 masks).);-1;None;7179ccb315f2414409e9e5116685a59d;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;172;-1867.738,1122.597;Inherit;True;Property;_TextureSample4;Texture Sample 4;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;66;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;154;-1885.921,258.7792;Inherit;True;Property;_TextureSample5;Texture Sample 5;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;67;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;138;-729.4923,-124.3606;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;153;-1893.382,538.0789;Inherit;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;66;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;67;-1887.625,-309.4849;Inherit;True;Property;_ColorVariationsMap;Color Variations Map;2;0;Create;True;0;0;False;1;Header(Each row of colors is used for each mask);-1;None;d70827fe46dfd404c9398a324bd1041b;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;152;-1888.146,847.4148;Inherit;True;Property;_TextureSample0;Texture Sample 0;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;67;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;175;-1839.859,1423.446;Inherit;True;Property;_TextureSample6;Texture Sample 6;2;0;Create;True;0;0;False;0;-1;None;None;True;0;False;white;Auto;False;Instance;67;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;139;-577.9227,-126.1707;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;174;-1278.66,1239.446;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;69;-1195.195,-346.8458;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;132;-1233.053,610.4248;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-1264.97,53.30442;Inherit;False;3;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;70;-282.6653,-343.485;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.CommentaryNode;217;-2585.821,1954.856;Inherit;False;1441.48;946.7561;NODI NON USATI;16;86;102;75;159;91;141;83;88;161;93;140;84;99;163;100;103;;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;178;-509.9921,101.1086;Inherit;False;Property;_NormalMapMultiplier;NormalMap Multiplier;4;0;Create;True;0;0;False;0;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;123;-728.9321,253.0914;Inherit;False;4;4;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;93;-2274.842,2482.066;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;163;-1319.341,2738.583;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;84;-2533.559,2245.382;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.251;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;88;-2067.51,2011.162;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;141;-1343.468,2020.214;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;83;-2289.958,2004.856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;91;-2300.102,2239.786;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;51;-113.1401,260.7094;Inherit;True;Property;_MetallicRAOGSmoothnessA;Metallic (R) AO (G) Smoothness (A);5;0;Create;True;0;0;False;1;Space(20);-1;None;d9da2568a88dd8a43a69e4c57c6cd223;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;100;-1845.175,2088.153;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;86;-2518.394,2485.399;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.51;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;99;-1555.359,2486.196;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;75;-2535.821,2007.305;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;102;-1329.809,2489.701;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SinOpNode;62;-3516.389,201.8024;Inherit;False;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;71;82.76277,-222.5665;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;52;-103.9297,28.84948;Inherit;True;Property;_NormalMap;Normal Map;3;0;Create;True;0;0;False;1;Space(20);-1;None;0f53840bb5714d546bf3ec4ce45f3289;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.WorldToObjectTransfNode;221;-4007.422,456.1773;Inherit;False;1;0;FLOAT4;0,0,0,1;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StepOpNode;159;-2532.183,2768.612;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.751;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;140;-1324.989,2268.33;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;161;-2250.949,2760.795;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;222;-4060.092,106.9519;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SaturateNode;103;-1991.95,2486.116;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;565.5699,-130.3;Float;False;True;-1;2;ASEMaterialInspector;0;0;Standard;gRally/MaskedColorVariations;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;7;d3d9;d3d11_9x;d3d11;glcore;gles;gles3;vulkan;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;196;0;151;4
WireConnection;180;0;216;0
WireConnection;183;0;180;0
WireConnection;184;0;183;0
WireConnection;185;0;184;0
WireConnection;186;0;215;0
WireConnection;186;1;185;0
WireConnection;190;0;186;0
WireConnection;187;0;190;0
WireConnection;188;0;187;0
WireConnection;189;0;188;0
WireConnection;198;0;185;0
WireConnection;198;1;189;0
WireConnection;199;0;198;0
WireConnection;191;0;197;0
WireConnection;191;1;199;0
WireConnection;192;0;191;0
WireConnection;193;0;192;0
WireConnection;194;0;193;0
WireConnection;195;0;194;0
WireConnection;200;0;199;0
WireConnection;200;1;195;0
WireConnection;202;0;200;0
WireConnection;203;0;201;0
WireConnection;203;1;202;0
WireConnection;205;0;203;0
WireConnection;206;0;205;0
WireConnection;61;0;220;1
WireConnection;61;1;220;3
WireConnection;218;0;61;0
WireConnection;218;1;219;0
WireConnection;207;0;206;0
WireConnection;92;0;189;0
WireConnection;166;0;207;0
WireConnection;94;0;195;0
WireConnection;64;0;218;0
WireConnection;89;0;185;0
WireConnection;148;0;64;0
WireConnection;148;1;64;1
WireConnection;129;0;148;0
WireConnection;176;0;148;0
WireConnection;65;0;148;0
WireConnection;113;0;148;0
WireConnection;137;0;121;0
WireConnection;137;1;122;0
WireConnection;137;2;136;0
WireConnection;137;3;173;0
WireConnection;154;1;113;0
WireConnection;138;0;137;0
WireConnection;67;1;65;0
WireConnection;152;1;129;0
WireConnection;175;1;176;0
WireConnection;139;0;138;0
WireConnection;174;0;175;0
WireConnection;174;1;172;0
WireConnection;174;2;173;0
WireConnection;69;0;67;0
WireConnection;69;1;66;0
WireConnection;69;2;121;0
WireConnection;132;0;152;0
WireConnection;132;1;153;0
WireConnection;132;2;136;0
WireConnection;117;0;154;0
WireConnection;117;1;155;0
WireConnection;117;2;122;0
WireConnection;70;0;66;0
WireConnection;70;1;139;0
WireConnection;123;0;69;0
WireConnection;123;1;117;0
WireConnection;123;2;132;0
WireConnection;123;3;174;0
WireConnection;93;0;86;0
WireConnection;93;1;84;0
WireConnection;163;0;161;0
WireConnection;84;0;151;4
WireConnection;88;0;83;0
WireConnection;88;1;86;0
WireConnection;141;0;88;0
WireConnection;83;0;75;0
WireConnection;91;0;84;0
WireConnection;91;1;75;0
WireConnection;100;0;88;0
WireConnection;86;0;151;4
WireConnection;99;0;103;0
WireConnection;99;1;100;0
WireConnection;75;0;151;4
WireConnection;102;0;99;0
WireConnection;62;0;61;0
WireConnection;71;0;70;0
WireConnection;71;1;123;0
WireConnection;52;5;178;0
WireConnection;159;0;151;4
WireConnection;140;0;91;0
WireConnection;161;0;159;0
WireConnection;161;1;86;0
WireConnection;103;0;93;0
WireConnection;0;0;71;0
WireConnection;0;1;52;0
WireConnection;0;3;51;1
WireConnection;0;4;51;4
WireConnection;0;5;51;2
ASEEND*/
//CHKSM=8ECC885DE9C955154BEFB5552F12C7A5DA448E0A