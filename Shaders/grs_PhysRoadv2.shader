// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Phys Road v2"
{
	Properties
	{
		[NoScaleOffset]_AlbedowithSmoothnessMap("Albedo (with Smoothness Map)", 2D) = "black" {}
		[NoScaleOffset]_Normalmap("Normal map", 2D) = "bump" {}
		[NoScaleOffset]_RSpecGTransparencyBAOAWetMap("(R)Spec-(G)Transparency-(B)AO -(A)WetMap", 2D) = "white" {}
		_TilingMainTextures("Tiling Main Textures", Vector) = (1,1,0,0)
		_OffsetMainTextures("Offset Main Textures", Vector) = (0,0,0,0)
		_UVMultipliers("Tiling Multipliers for far texture", Vector) = (1,0.2,0,0)
		_TransitionDistance("Transition Distance (in meters)", Range( 1 , 150)) = 30
		_TransitionFalloff("Transition Falloff", Float) = 6
		_Cutoff( "Mask Clip Value", Float ) = 0.681
		_GR_Displacement("_GR_Displacement", Range( 0 , 1)) = 1
		_MaxDisplacementmeters("Max Displacement (meters)", Range( -1 , 0)) = 0
		[Toggle]_UseGrooveTex("Use Groove Tex", Float) = 0
		[NoScaleOffset]_GrooveMap("GrooveMap", 2D) = "white" {}
		[Toggle]_UsePuddlesTexture("Use Puddles Texture", Float) = 0
		[NoScaleOffset]_PuddlesTexture("Puddles Texture", 2D) = "black" {}
		_PuddlesSize("Puddles Size", Float) = 0
		[NoScaleOffset]_PhysicalTexture("Physical Texture", 2D) = "white" {}
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Geometry+0" }
		Cull Back
		CGPROGRAM
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows vertex:vertexDataFunc 
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			float4 vertexColor : COLOR;
		};

		uniform float _MaxDisplacementmeters;
		uniform float _GR_Displacement;
		uniform sampler2D _RSpecGTransparencyBAOAWetMap;
		uniform float2 _TilingMainTextures;
		uniform float2 _OffsetMainTextures;
		uniform float2 _UVMultipliers;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform float _UsePuddlesTexture;
		uniform float _GR_WetSurf;
		uniform sampler2D _PuddlesTexture;
		uniform float _PuddlesSize;
		uniform sampler2D _Normalmap;
		uniform sampler2D _PhysicalTexture;
		uniform sampler2D _AlbedowithSmoothnessMap;
		uniform float _UseGrooveTex;
		uniform sampler2D _GrooveMap;
		uniform float _GR_Groove;
		uniform float _GR_PhysDebug;
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
			float2 UV_Texture212 = uv_TexCoord138;
			float4 tex2DNode3 = tex2D( _RSpecGTransparencyBAOAWetMap, UV_Texture212 );
			float2 UV_Texture_Tiling_Mult215 = ( uv_TexCoord138 * _UVMultipliers );
			float4 tex2DNode146 = tex2D( _RSpecGTransparencyBAOAWetMap, UV_Texture_Tiling_Mult215 );
			float3 ase_worldPos = i.worldPos;
			float clampResult142 = clamp( pow( ( distance( _WorldSpaceCameraPos , ase_worldPos ) / _TransitionDistance ) , _TransitionFalloff ) , 0 , 1 );
			float Transition210 = clampResult142;
			float lerpResult150 = lerp( tex2DNode3.a , tex2DNode146.a , Transition210);
			float WetSurf219 = _GR_WetSurf;
			float clampResult227 = clamp( ( ( 1.0 - WetSurf219 ) + 0.2 ) , 0 , 1 );
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
			float4 break240 = lerp(float4(0,0,0,0),appendResult237,_UsePuddlesTexture);
			float temp_output_234_0 = ( i.vertexColor.b * _GR_Displacement );
			float clampResult201 = clamp( ( lerpResult150 + break240.x + break240.y + break240.z + break240.w + temp_output_234_0 ) , 0 , 1 );
			float temp_output_206_0 = ( clampResult201 * _GR_WetSurf );
			float temp_output_81_0 = ( 1.0 - temp_output_206_0 );
			float lerpResult208 = lerp( temp_output_81_0 , 0 , Transition210);
			float lerpResult209 = lerp( 0 , temp_output_81_0 , Transition210);
			o.Normal = BlendNormals( UnpackScaleNormal( tex2D( _Normalmap, UV_Texture212 ) ,lerpResult208 ) , UnpackScaleNormal( tex2D( _Normalmap, UV_Texture_Tiling_Mult215 ) ,lerpResult209 ) );
			float2 uv_PhysicalTexture71 = i.uv_texcoord;
			float4 tex2DNode1 = tex2D( _AlbedowithSmoothnessMap, UV_Texture212 );
			float4 tex2DNode144 = tex2D( _AlbedowithSmoothnessMap, UV_Texture_Tiling_Mult215 );
			float4 lerpResult145 = lerp( tex2DNode1 , tex2DNode144 , Transition210);
			float4 _Color0 = float4(0,0,0,0);
			float2 uv_GrooveMap55 = i.uv_texcoord;
			float lerpResult64 = lerp( _Color0.g , i.vertexColor.g , _GR_Groove);
			float4 lerpResult56 = lerp( lerpResult145 , ( lerp(_Color0,tex2D( _GrooveMap, uv_GrooveMap55 ),_UseGrooveTex) * lerpResult145 ) , lerpResult64);
			float clampResult90 = clamp( ( 1.0 - _GR_WetSurf ) , 0.68 , 1 );
			float4 lerpResult83 = lerp( tex2D( _PhysicalTexture, uv_PhysicalTexture71 ) , ( lerpResult56 * clampResult90 ) , ( 1.0 - _GR_PhysDebug ));
			o.Albedo = lerpResult83.rgb;
			float lerpResult147 = lerp( tex2DNode3.r , tex2DNode146.r , Transition210);
			float clampResult47 = clamp( ( lerpResult147 + temp_output_206_0 ) , 0 , 1 );
			float3 temp_cast_2 = (clampResult47).xxx;
			o.Specular = temp_cast_2;
			float lerpResult143 = lerp( tex2DNode1.a , tex2DNode144.a , Transition210);
			float clampResult33 = clamp( ( ( lerpResult143 + temp_output_206_0 ) + ( _GR_WetSurf / 2 ) ) , 0 , 1 );
			o.Smoothness = clampResult33;
			float lerpResult149 = lerp( tex2DNode3.b , tex2DNode146.b , Transition210);
			o.Occlusion = ( lerpResult149 + _GR_WetSurf );
			o.Alpha = 1;
			float lerpResult148 = lerp( tex2DNode3.g , tex2DNode146.g , Transition210);
			clip( lerpResult148 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15205
2025;179;1732;729;2815.736;-1110.474;1;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;164;-7008.547,202.1764;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;165;-6992.537,613.2579;Float;False;Property;_PuddlesSize;Puddles Size;15;0;Create;True;0;0;False;0;0;2.62;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;167;-6609.307,568.5803;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;166;-6607.854,834.4611;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-6395.148,524.3087;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-6386.69,799.6981;Float;True;2;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2302.857,649.7941;Float;False;Global;_GR_WetSurf;_GR_WetSurf;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;170;-6154.066,801.5233;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;171;-6172.316,525.9478;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-2012.595,829.7492;Float;False;WetSurf;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-4204.614,629.6141;Float;False;219;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-6611.878,222.2662;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.StepOpNode;174;-5949.85,514.9988;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;173;-5937.076,798.848;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;132;-5832.527,-1669.023;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.OneMinusNode;231;-3997.205,632.2744;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;175;-6041.869,284.7727;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;177;-5704.586,628.149;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;176;-5690.516,923.798;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;133;-5790.179,-1434.743;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-5146.598,833.6492;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;163;-5286.705,-1755.028;Float;False;Property;_OffsetMainTextures;Offset Main Textures;4;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;226;-3816.756,618.5948;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-5178.165,47.71904;Float;True;Property;_PuddlesTexture;Puddles Texture;14;1;[NoScaleOffset];Create;True;0;0;False;0;None;8483e227f8901524981c77e7d51489ca;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-5155.723,344.5507;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-5137.473,1080.024;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-5150.248,585.4493;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;134;-5372.6,-1392.323;Float;False;Property;_TransitionDistance;Transition Distance (in meters);6;0;Create;False;0;0;False;0;30;21.7;1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;135;-5317.926,-1565.678;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;153;-5283.106,-1899.414;Float;False;Property;_TilingMainTextures;Tiling Main Textures;3;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-5046.72,-1562.203;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;139;-5040.537,-1222.318;Float;False;Property;_UVMultipliers;Tiling Multipliers for far texture;5;0;Create;False;0;0;False;0;1,0.2;1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;136;-5037.748,-1379.923;Float;False;Property;_TransitionFalloff;Transition Falloff;7;0;Create;True;0;0;False;0;6;5.56;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-4526.284,294.0146;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-4528.199,849.3636;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-4518.624,1098.315;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;227;-3643.97,643.0301;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;138;-4923.495,-1778.348;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-4514.793,575.5182;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;140;-4803.047,-1569.423;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-4500.752,-1386.244;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;222;-3311.154,570.0542;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;224;-3326.005,1152.129;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;223;-3320.514,855.6691;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;221;-3315.205,277.3891;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-4457.607,-1905.7;Float;False;UV_Texture;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ColorNode;235;-3332.974,18.22424;Float;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;216;-3796.402,-1353.894;Float;False;215;0;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;142;-4507.264,-1576.183;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;-3669.257,-1895.792;Float;False;212;0;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-4289.954,-1240.724;Float;False;UV_Texture_Tiling_Mult;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;237;-3101.623,153.8496;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.VertexColorNode;54;-2953.16,1022.339;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;211;-3642.492,-1018.123;Float;False;210;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-2164.926,1609.144;Float;False;Property;_GR_Displacement;_GR_Displacement;9;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-4240.485,-1584.492;Float;False;Transition;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;146;-3420.286,-562.7644;Float;True;Property;_TextureSample1;Texture Sample 1;2;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ToggleSwitchNode;236;-2954.214,88.86333;Float;False;Property;_UsePuddlesTexture;Use Puddles Texture;13;0;Create;True;0;0;False;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;3;-3183.159,-1176.127;Float;True;Property;_RSpecGTransparencyBAOAWetMap;(R)Spec-(G)Transparency-(B)AO -(A)WetMap;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;7e34e8ef173c161468fe09b5a26c9f01;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-2677.082,106.4245;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-2523.104,787.9199;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;150;-2787.433,-188.9251;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-2340.764,78.62479;Float;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-2418.818,-2344.473;Float;True;Property;_GrooveMap;GrooveMap;12;1;[NoScaleOffset];Create;True;0;0;False;0;None;572078f7efe28924a996e6e0d35f816e;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-3182.482,-1968.898;Float;True;Property;_AlbedowithSmoothnessMap;Albedo (with Smoothness Map);0;1;[NoScaleOffset];Create;True;0;0;False;0;None;dd85de7f5163c2c4191e22573039696a;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-2390.219,-2131.737;Float;False;Constant;_Color0;Color 0;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;144;-3227.768,-1657.504;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ClampOpNode;201;-2095.796,155.2407;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;145;-2744.86,-1821.597;Float;True;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-2414.646,-1935.935;Float;False;Global;_GR_Groove;_GR_Groove;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-1891.137,-2222.358;Float;False;Property;_UseGrooveTex;Use Groove Tex;11;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1538.174,161.7106;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;64;-1677.147,-2042.375;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1603.039,-2204.064;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;217;-1281.975,-230.1949;Float;False;210;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;81;-1244.742,-65.67212;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;143;-2752.141,-1532.748;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;315.2041,-390.497;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-921.1132,-190.3044;Float;False;215;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-1167.691,731.4235;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;209;-856.5331,-68.24269;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-928.8777,-526.6465;Float;False;212;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-794.4315,631.7591;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;208;-919.4467,-395.8791;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;82;776.6593,-708.5289;Float;False;Global;_GR_PhysDebug;_GR_PhysDebug;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;562.4168,-419.9025;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.68;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;147;-2608.805,-1142.354;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-1165.73,-1875.159;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;762.0712,-464.5163;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2219.487,1436.445;Float;False;Property;_MaxDisplacementmeters;Max Displacement (meters);10;0;Create;True;0;0;False;0;0;-0.924;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-479.8809,181.0737;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;151;-561.0124,-220.53;Float;True;Property;_TextureSample2;Texture Sample 2;1;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;2;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.NormalVertexDataNode;50;-1423.484,1271.131;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-504.8837,608.61;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;1074.568,-612.0295;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;71;261.6223,-763.9866;Float;True;Property;_PhysicalTexture;Physical Texture;16;1;[NoScaleOffset];Create;True;0;0;False;0;None;81f56c8c35fbe5947ae76e975e98b7d9;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;-560.7631,-493.5752;Float;True;Property;_Normalmap;Normal map;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;8e3229242cae297439c5d810b71cb074;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;149;-2583.204,-517.7145;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-170.5482,374.7318;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-1335.746,575.8272;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;1182.659,-517.5289;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.BlendNormalsNode;207;-108.9855,-364.1339;Float;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ClampOpNode;47;-176.1671,111.7834;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-2342.544,371.1309;Float;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-854.2187,1285.561;Float;True;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-6090.462,160.4864;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;148;-2601.124,-850.5142;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;1631.336,61.58502;Float;False;True;6;Float;ASEMaterialInspector;0;0;StandardSpecular;gRally/Phys Road v2;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Custom;0.681;True;True;0;True;Transparent;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;20;3;10;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;8;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;167;0;164;1
WireConnection;167;1;165;0
WireConnection;166;0;164;3
WireConnection;166;1;165;0
WireConnection;168;0;167;0
WireConnection;169;0;166;0
WireConnection;170;0;169;0
WireConnection;171;0;168;0
WireConnection;219;0;5;0
WireConnection;172;0;164;1
WireConnection;172;1;164;3
WireConnection;174;0;171;0
WireConnection;173;0;170;0
WireConnection;231;0;220;0
WireConnection;175;0;172;0
WireConnection;175;1;165;0
WireConnection;177;0;174;0
WireConnection;176;0;173;0
WireConnection;186;0;177;0
WireConnection;186;1;173;0
WireConnection;226;0;231;0
WireConnection;178;1;175;0
WireConnection;181;0;174;0
WireConnection;181;1;173;0
WireConnection;179;0;177;0
WireConnection;179;1;176;0
WireConnection;184;0;174;0
WireConnection;184;1;176;0
WireConnection;135;0;132;0
WireConnection;135;1;133;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;190;0;178;1
WireConnection;190;1;181;0
WireConnection;189;0;178;3
WireConnection;189;1;186;0
WireConnection;187;0;178;4
WireConnection;187;1;179;0
WireConnection;227;0;226;0
WireConnection;138;0;153;0
WireConnection;138;1;163;0
WireConnection;188;0;178;2
WireConnection;188;1;184;0
WireConnection;140;0;137;0
WireConnection;140;1;136;0
WireConnection;141;0;138;0
WireConnection;141;1;139;0
WireConnection;222;0;188;0
WireConnection;222;1;227;0
WireConnection;224;0;187;0
WireConnection;224;1;227;0
WireConnection;223;0;189;0
WireConnection;223;1;227;0
WireConnection;221;0;190;0
WireConnection;221;1;227;0
WireConnection;212;0;138;0
WireConnection;142;0;140;0
WireConnection;215;0;141;0
WireConnection;237;0;221;0
WireConnection;237;1;222;0
WireConnection;237;2;223;0
WireConnection;237;3;224;0
WireConnection;210;0;142;0
WireConnection;146;1;216;0
WireConnection;236;0;235;0
WireConnection;236;1;237;0
WireConnection;3;1;213;0
WireConnection;240;0;236;0
WireConnection;234;0;54;3
WireConnection;234;1;85;0
WireConnection;150;0;3;4
WireConnection;150;1;146;4
WireConnection;150;2;211;0
WireConnection;241;0;150;0
WireConnection;241;1;240;0
WireConnection;241;2;240;1
WireConnection;241;3;240;2
WireConnection;241;4;240;3
WireConnection;241;5;234;0
WireConnection;1;1;213;0
WireConnection;144;1;216;0
WireConnection;201;0;241;0
WireConnection;145;0;1;0
WireConnection;145;1;144;0
WireConnection;145;2;211;0
WireConnection;70;0;61;0
WireConnection;70;1;55;0
WireConnection;206;0;201;0
WireConnection;206;1;5;0
WireConnection;64;0;61;2
WireConnection;64;1;54;2
WireConnection;64;2;62;0
WireConnection;66;0;70;0
WireConnection;66;1;145;0
WireConnection;81;0;206;0
WireConnection;143;0;1;4
WireConnection;143;1;144;4
WireConnection;143;2;211;0
WireConnection;89;0;5;0
WireConnection;48;0;5;0
WireConnection;209;1;81;0
WireConnection;209;2;217;0
WireConnection;7;0;143;0
WireConnection;7;1;206;0
WireConnection;208;0;81;0
WireConnection;208;2;217;0
WireConnection;90;0;89;0
WireConnection;147;0;3;1
WireConnection;147;1;146;1
WireConnection;147;2;211;0
WireConnection;56;0;145;0
WireConnection;56;1;66;0
WireConnection;56;2;64;0
WireConnection;88;0;56;0
WireConnection;88;1;90;0
WireConnection;25;0;147;0
WireConnection;25;1;206;0
WireConnection;151;1;218;0
WireConnection;151;5;209;0
WireConnection;34;0;7;0
WireConnection;34;1;48;0
WireConnection;84;0;82;0
WireConnection;2;1;214;0
WireConnection;2;5;208;0
WireConnection;149;0;3;3
WireConnection;149;1;146;3
WireConnection;149;2;211;0
WireConnection;33;0;34;0
WireConnection;77;0;149;0
WireConnection;77;1;5;0
WireConnection;83;0;71;0
WireConnection;83;1;88;0
WireConnection;83;2;84;0
WireConnection;207;0;2;0
WireConnection;207;1;151;0
WireConnection;47;0;25;0
WireConnection;200;0;150;0
WireConnection;200;1;221;0
WireConnection;200;2;222;0
WireConnection;200;3;223;0
WireConnection;200;4;224;0
WireConnection;200;5;234;0
WireConnection;51;0;54;3
WireConnection;51;1;50;0
WireConnection;51;2;52;0
WireConnection;51;3;85;0
WireConnection;195;0;172;0
WireConnection;195;1;165;0
WireConnection;148;0;3;2
WireConnection;148;1;146;2
WireConnection;148;2;211;0
WireConnection;0;0;83;0
WireConnection;0;1;207;0
WireConnection;0;3;47;0
WireConnection;0;4;33;0
WireConnection;0;5;77;0
WireConnection;0;10;148;0
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=5ECCCB2CFAF61CBE3CAFA978F872296A66FA62E7