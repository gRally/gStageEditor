// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Phys Road v2 Blend 2 Mat"
{
	Properties
	{
		[NoScaleOffset]_AlbedowithSmoothnessMapMat1("Albedo (with Smoothness Map) Mat1", 2D) = "black" {}
		[NoScaleOffset]_AlbedowithSmoothnessMapMat2("Albedo (with Smoothness Map) Mat2", 2D) = "black" {}
		[NoScaleOffset]_NormalmapMat1("Normal map Mat1", 2D) = "bump" {}
		[NoScaleOffset]_NormalmapMat2("Normal map Mat2", 2D) = "bump" {}
		[NoScaleOffset]_RSpecGTransparencyBAOAWetMapMat1("(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat1", 2D) = "white" {}
		[NoScaleOffset]_RSpecGTransparencyBAOAWetMapMat2("(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat2", 2D) = "white" {}
		_TilingMainTextures("Tiling Main Textures", Vector) = (1,1,0,0)
		_OffsetMainTextures("Offset Main Textures", Vector) = (0,0,0,0)
		_UVMultipliers("Tiling Multipliers For Far Textures", Vector) = (1,0.2,0,0)
		_TransitionDistance("Transition Distance (in meters)", Range( 1 , 150)) = 30
		_TransitionFalloff("Transition Falloff", Float) = 6
		_Cutoff( "Mask Clip Value", Float ) = 0.5
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
		uniform sampler2D _RSpecGTransparencyBAOAWetMapMat2;
		uniform float2 _TilingMainTextures;
		uniform float2 _OffsetMainTextures;
		uniform float2 _UVMultipliers;
		uniform float _TransitionDistance;
		uniform float _TransitionFalloff;
		uniform sampler2D _RSpecGTransparencyBAOAWetMapMat1;
		uniform float _UsePuddlesTexture;
		uniform float _GR_WetSurf;
		uniform sampler2D _PuddlesTexture;
		uniform float _PuddlesSize;
		uniform sampler2D _NormalmapMat2;
		uniform sampler2D _NormalmapMat1;
		uniform sampler2D _PhysicalTexture;
		uniform sampler2D _AlbedowithSmoothnessMapMat2;
		uniform sampler2D _AlbedowithSmoothnessMapMat1;
		uniform float _UseGrooveTex;
		uniform sampler2D _GrooveMap;
		uniform float _GR_Groove;
		uniform float _GR_PhysDebug;
		uniform float _Cutoff = 0.5;

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
			float4 tex2DNode253 = tex2D( _RSpecGTransparencyBAOAWetMapMat2, UV_Texture212 );
			float2 UV_Texture_Tiling_Mult215 = ( uv_TexCoord138 * _UVMultipliers );
			float4 tex2DNode277 = tex2D( _RSpecGTransparencyBAOAWetMapMat2, UV_Texture_Tiling_Mult215 );
			float3 ase_worldPos = i.worldPos;
			float clampResult142 = clamp( pow( ( distance( _WorldSpaceCameraPos , ase_worldPos ) / _TransitionDistance ) , _TransitionFalloff ) , 0 , 1 );
			float Transition210 = clampResult142;
			float lerpResult255 = lerp( tex2DNode253.a , tex2DNode277.a , Transition210);
			float4 tex2DNode3 = tex2D( _RSpecGTransparencyBAOAWetMapMat1, UV_Texture212 );
			float4 tex2DNode278 = tex2D( _RSpecGTransparencyBAOAWetMapMat1, UV_Texture_Tiling_Mult215 );
			float lerpResult150 = lerp( tex2DNode3.a , tex2DNode278.a , Transition210);
			float AlphaVertexColor251 = i.vertexColor.a;
			float lerpResult262 = lerp( lerpResult255 , lerpResult150 , AlphaVertexColor251);
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
			float clampResult201 = clamp( ( lerpResult262 + break240.x + break240.y + break240.z + break240.w + temp_output_234_0 ) , 0 , 1 );
			float temp_output_206_0 = ( clampResult201 * _GR_WetSurf );
			float temp_output_81_0 = ( 1.0 - temp_output_206_0 );
			float lerpResult208 = lerp( temp_output_81_0 , 0 , Transition210);
			float temp_output_272_0 = ( 1.0 - AlphaVertexColor251 );
			float lerpResult209 = lerp( 0 , temp_output_81_0 , Transition210);
			o.Normal = BlendNormals( BlendNormals( UnpackScaleNormal( tex2D( _NormalmapMat2, UV_Texture212 ) ,( lerpResult208 * temp_output_272_0 ) ) , UnpackScaleNormal( tex2D( _NormalmapMat2, UV_Texture_Tiling_Mult215 ) ,( lerpResult209 * temp_output_272_0 ) ) ) , BlendNormals( UnpackScaleNormal( tex2D( _NormalmapMat1, UV_Texture212 ) ,( lerpResult208 * AlphaVertexColor251 ) ) , UnpackScaleNormal( tex2D( _NormalmapMat1, UV_Texture_Tiling_Mult215 ) ,( lerpResult209 * AlphaVertexColor251 ) ) ) );
			float2 uv_PhysicalTexture71 = i.uv_texcoord;
			float4 tex2DNode243 = tex2D( _AlbedowithSmoothnessMapMat2, UV_Texture212 );
			float4 tex2DNode244 = tex2D( _AlbedowithSmoothnessMapMat2, UV_Texture_Tiling_Mult215 );
			float4 lerpResult245 = lerp( tex2DNode243 , tex2DNode244 , Transition210);
			float4 tex2DNode1 = tex2D( _AlbedowithSmoothnessMapMat1, UV_Texture212 );
			float4 tex2DNode276 = tex2D( _AlbedowithSmoothnessMapMat1, UV_Texture_Tiling_Mult215 );
			float4 lerpResult145 = lerp( tex2DNode1 , tex2DNode276 , Transition210);
			float4 lerpResult246 = lerp( lerpResult245 , lerpResult145 , AlphaVertexColor251);
			float4 _Color0 = float4(0,0,0,0);
			float2 uv_GrooveMap55 = i.uv_texcoord;
			float lerpResult64 = lerp( _Color0.g , i.vertexColor.g , _GR_Groove);
			float4 lerpResult56 = lerp( lerpResult246 , ( lerp(_Color0,tex2D( _GrooveMap, uv_GrooveMap55 ),_UseGrooveTex) * lerpResult246 ) , lerpResult64);
			float clampResult90 = clamp( ( 1.0 - _GR_WetSurf ) , 0.68 , 1 );
			float4 lerpResult83 = lerp( tex2D( _PhysicalTexture, uv_PhysicalTexture71 ) , ( lerpResult56 * clampResult90 ) , ( 1.0 - _GR_PhysDebug ));
			o.Albedo = lerpResult83.rgb;
			float lerpResult256 = lerp( tex2DNode253.r , tex2DNode277.r , Transition210);
			float lerpResult147 = lerp( tex2DNode3.r , tex2DNode278.r , Transition210);
			float lerpResult259 = lerp( lerpResult256 , lerpResult147 , AlphaVertexColor251);
			float clampResult47 = clamp( ( lerpResult259 + temp_output_206_0 ) , 0 , 1 );
			float3 temp_cast_2 = (clampResult47).xxx;
			o.Specular = temp_cast_2;
			float lerpResult248 = lerp( tex2DNode243.a , tex2DNode244.a , Transition210);
			float lerpResult143 = lerp( tex2DNode1.a , tex2DNode276.a , Transition210);
			float lerpResult249 = lerp( lerpResult248 , lerpResult143 , AlphaVertexColor251);
			float clampResult33 = clamp( ( ( lerpResult249 + temp_output_206_0 ) + ( _GR_WetSurf / 2 ) ) , 0 , 1 );
			o.Smoothness = clampResult33;
			float lerpResult257 = lerp( tex2DNode253.b , tex2DNode277.b , Transition210);
			float lerpResult149 = lerp( tex2DNode3.b , tex2DNode278.b , Transition210);
			float lerpResult261 = lerp( lerpResult257 , lerpResult149 , AlphaVertexColor251);
			o.Occlusion = ( lerpResult261 + _GR_WetSurf );
			o.Alpha = 1;
			float lerpResult258 = lerp( tex2DNode253.g , tex2DNode277.g , Transition210);
			float lerpResult148 = lerp( tex2DNode3.g , tex2DNode278.g , Transition210);
			float lerpResult260 = lerp( lerpResult258 , lerpResult148 , AlphaVertexColor251);
			clip( lerpResult260 - _Cutoff );
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15205
2025;179;1732;729;6869.458;1873.7;1.155;True;False
Node;AmplifyShaderEditor.WorldPosInputsNode;164;-7008.547,202.1764;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;165;-6992.537,613.2579;Float;False;Property;_PuddlesSize;Puddles Size;18;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;167;-6609.307,568.5803;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;166;-6607.854,834.4611;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;169;-6386.69,799.6981;Float;True;2;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;168;-6395.148,524.3087;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-2124.411,715.9593;Float;False;Global;_GR_WetSurf;_GR_WetSurf;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;171;-6172.316,525.9478;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.FractNode;170;-6154.066,801.5233;Float;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;219;-1734.505,840.5292;Float;False;WetSurf;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;220;-4204.614,629.6141;Float;False;219;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;172;-6611.878,222.2662;Float;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceCameraPos;132;-7000.345,-1656.708;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.WorldPosInputsNode;133;-6957.997,-1422.428;Float;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.StepOpNode;173;-5937.076,798.848;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.StepOpNode;174;-5949.85,514.9988;Float;True;2;0;FLOAT;0.5;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;175;-6041.869,284.7727;Float;False;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node;163;-6454.523,-1742.713;Float;False;Property;_OffsetMainTextures;Offset Main Textures;7;0;Create;True;0;0;False;0;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RangedFloatNode;134;-6540.418,-1380.008;Float;False;Property;_TransitionDistance;Transition Distance (in meters);9;0;Create;False;0;0;False;0;30;30;1;150;0;1;FLOAT;0
Node;AmplifyShaderEditor.DistanceOpNode;135;-6485.744,-1553.363;Float;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector2Node;153;-6450.924,-1887.099;Float;False;Property;_TilingMainTextures;Tiling Main Textures;6;0;Create;True;0;0;False;0;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.OneMinusNode;176;-5690.516,923.798;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;231;-3997.205,632.2744;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;177;-5704.586,628.149;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;179;-5137.473,1080.024;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;181;-5155.723,344.5507;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;184;-5150.248,585.4493;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;178;-5174.985,44.78904;Float;True;Property;_PuddlesTexture;Puddles Texture;17;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;226;-3816.756,618.5948;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0.2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;186;-5146.598,833.6492;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;136;-6205.566,-1367.608;Float;False;Property;_TransitionFalloff;Transition Falloff;10;0;Create;True;0;0;False;0;6;6;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;137;-6214.538,-1549.888;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;138;-6091.313,-1766.033;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node;139;-6208.355,-1210.003;Float;False;Property;_UVMultipliers;Tiling Multipliers For Far Textures;8;0;Create;False;0;0;False;0;1,0.2;1,0.2;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.ClampOpNode;227;-3643.97,643.0301;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;141;-5668.57,-1373.929;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;190;-4526.284,294.0146;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;188;-4514.793,575.5182;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-4518.624,1098.315;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;189;-4528.199,849.3636;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;140;-5970.865,-1557.108;Float;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;215;-5457.772,-1228.409;Float;False;UV_Texture_Tiling_Mult;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.ClampOpNode;142;-5675.082,-1563.868;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;212;-5625.425,-1893.385;Float;False;UV_Texture;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;216;-4861.418,-1612.395;Float;False;215;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;223;-3320.514,855.6691;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;224;-3326.005,1152.129;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;222;-3311.154,570.0542;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;213;-4841.993,-2404.332;Float;False;212;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SmoothstepOpNode;221;-3315.205,277.3891;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1.01;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;253;-4270.318,-2571.205;Float;True;Property;_RSpecGTransparencyBAOAWetMapMat2;(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat2;5;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;237;-3101.623,153.8496;Float;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SamplerNode;3;-4293.974,-1380.888;Float;True;Property;_RSpecGTransparencyBAOAWetMapMat1;(R)Spec-(G)Transparency-(B)AO -(A)WetMap Mat1;4;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.VertexColorNode;54;-2957.26,1016.189;Float;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;278;-4325.209,-1115.463;Float;True;Property;_TextureSample4;Texture Sample 4;4;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;3;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;277;-4299.716,-2281.248;Float;True;Property;_TextureSample0;Texture Sample 0;5;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;253;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;235;-3332.974,18.22424;Float;False;Constant;_Color1;Color 1;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;211;-4838.309,-1236.384;Float;False;210;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;210;-5408.303,-1572.177;Float;False;Transition;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;85;-2179.743,1589.624;Float;False;Property;_GR_Displacement;_GR_Displacement;12;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;263;-3659.555,-1534.666;Float;False;251;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;255;-3598.716,-1819.762;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;236;-2952.484,88.86333;Float;False;Property;_UsePuddlesTexture;Use Puddles Texture;16;0;Create;True;0;0;False;0;0;2;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;251;-2617.295,1189.906;Float;False;AlphaVertexColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;150;-3694.954,-482.0753;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;234;-2427.954,767.16;Float;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;240;-2657.852,101.4245;Float;False;FLOAT4;1;0;FLOAT4;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.LerpOp;262;-2730.311,-1384.446;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;241;-2173.017,129.3398;Float;True;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;252;-4304.078,-4076.99;Float;False;1465.561;1298.26;Albedo and Smoothness;11;1;246;249;143;145;250;244;243;245;248;276;;1,1,1,1;0;0
Node;AmplifyShaderEditor.ClampOpNode;201;-1884.041,151.1757;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;243;-4238.109,-4026.99;Float;True;Property;_AlbedowithSmoothnessMapMat2;Albedo (with Smoothness Map) Mat2;1;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;1;-4251.307,-3325.974;Float;True;Property;_AlbedowithSmoothnessMapMat1;Albedo (with Smoothness Map) Mat1;0;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;276;-4259.375,-3018.812;Float;True;Property;_TextureSample5;Texture Sample 5;0;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;247;-1684.637,-4039.824;Float;False;1487.087;675.3145;GrooveMap;7;55;61;70;62;66;64;56;;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;206;-1538.174,161.7106;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;244;-4236.491,-3803.25;Float;True;Property;_TextureSample3;Texture Sample 3;1;0;Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Instance;243;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.OneMinusNode;81;-1119.072,-101.1119;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;250;-3619.532,-3440.518;Float;False;251;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;55;-1634.637,-3992.339;Float;True;Property;_GrooveMap;GrooveMap;15;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;61;-1606.038,-3777.088;Float;False;Constant;_Color0;Color 0;7;0;Create;True;0;0;False;0;0,0,0,0;0,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;217;-1156.305,-265.6345;Float;False;210;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;245;-3642.617,-3873.526;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;145;-3638.692,-3192.442;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;270;-962.0448,-1210.641;Float;False;251;0;1;FLOAT;0
Node;AmplifyShaderEditor.ToggleSwitchNode;70;-1106.956,-3867.709;Float;False;Property;_UseGrooveTex;Use Groove Tex;14;0;Create;True;0;0;False;0;0;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.LerpOp;209;-730.8631,-103.6825;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;208;-793.7767,-431.3187;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;246;-3022.519,-3659.476;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;272;-587.513,-1205.134;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;248;-3638.113,-3713.577;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;62;-1630.465,-3581.286;Float;False;Global;_GR_Groove;_GR_Groove;8;0;Create;True;0;0;False;0;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;143;-3644.522,-3016.953;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;264;868.9689,-1945.963;Float;False;1146.877;550.084;Show Physical Texture;7;89;82;90;84;88;71;83;;1,1,1,1;0;0
Node;AmplifyShaderEditor.LerpOp;256;-3608.042,-2572.836;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-798.1732,-242.1243;Float;False;215;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;271;-52.2059,-432.6231;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;274;-57.14255,-126.4922;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-818.8596,-3849.415;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.OneMinusNode;89;964.3907,-1522.474;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;147;-3673.825,-1400.854;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;214;-800.4777,-796.8667;Float;False;212;0;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;275;-172.9781,-92.28183;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;249;-3023.833,-3297.414;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;64;-892.9672,-3687.726;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;273;-48.01198,-1208.674;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;56;-381.5501,-3520.51;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;82;1425.847,-1840.506;Float;False;Global;_GR_PhysDebug;_GR_PhysDebug;6;0;Create;True;0;0;False;0;1;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;151;208.9387,-204.0995;Float;True;Property;_TextureSample2;Texture Sample 2;2;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;2;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;265;156.4263,-1255.857;Float;True;Property;_NormalmapMat2;Normal map Mat2;3;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;2;209.188,-477.1451;Float;True;Property;_NormalmapMat1;Normal map Mat1;2;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;257;-3601.972,-2070.957;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;7;-802.1614,515.9847;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;90;1211.604,-1551.879;Float;False;3;0;FLOAT;0;False;1;FLOAT;0.68;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;149;-3648.225,-776.2144;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;48;-794.8369,740.6984;Float;False;2;0;FLOAT;0;False;1;FLOAT;2;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;266;153.9721,-982.8112;Float;True;Property;_TextureSample6;Texture Sample 6;3;0;Create;True;0;0;False;0;None;None;True;0;True;bump;Auto;True;Instance;265;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;259;-2714.206,-2008.552;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-2445.868,1431.3;Float;False;Property;_MaxDisplacementmeters;Max Displacement (meters);13;0;Create;True;0;0;False;0;0;0;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;84;1723.755,-1744.006;Float;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;267;668.654,-1112.766;Float;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;88;1411.258,-1596.493;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.NormalVertexDataNode;50;-1423.484,1271.131;Float;False;0;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BlendNormalsNode;207;666.4252,-347.7034;Float;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SamplerNode;71;920.7538,-1895.963;Float;True;Property;_PhysicalTexture;Physical Texture;19;1;[NoScaleOffset];Create;True;0;0;False;0;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;258;-3605.941,-2331.216;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;34;-504.8837,612.13;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;25;-492.3809,128.5737;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;261;-2689.281,-1593.026;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;148;-3666.145,-1109.014;Float;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;83;1831.846,-1649.506;Float;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ClampOpNode;47;-233.5018,135.2262;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;279;-2709.742,-3288.038;Float;False;Smooth_Output;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;260;-2700.41,-1797.117;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;33;-207.8844,602.612;Float;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;51;-854.2187,1285.561;Float;True;4;4;0;FLOAT;0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;77;-493.5717,368.2224;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;195;-6090.462,160.4864;Float;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BlendNormalsNode;268;1286.064,-715.1789;Float;True;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;200;-2328.804,371.1309;Float;False;6;6;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;3127.522,1600.646;Float;False;True;6;Float;ASEMaterialInspector;0;0;StandardSpecular;gRally/Phys Road v2 Blend 2 Mat;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Custom;0.5;True;True;0;True;Transparent;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;20;3;10;False;0.5;True;0;0;False;-1;0;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;11;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;167;0;164;1
WireConnection;167;1;165;0
WireConnection;166;0;164;3
WireConnection;166;1;165;0
WireConnection;169;0;166;0
WireConnection;168;0;167;0
WireConnection;171;0;168;0
WireConnection;170;0;169;0
WireConnection;219;0;5;0
WireConnection;172;0;164;1
WireConnection;172;1;164;3
WireConnection;173;0;170;0
WireConnection;174;0;171;0
WireConnection;175;0;172;0
WireConnection;175;1;165;0
WireConnection;135;0;132;0
WireConnection;135;1;133;0
WireConnection;176;0;173;0
WireConnection;231;0;220;0
WireConnection;177;0;174;0
WireConnection;179;0;177;0
WireConnection;179;1;176;0
WireConnection;181;0;174;0
WireConnection;181;1;173;0
WireConnection;184;0;174;0
WireConnection;184;1;176;0
WireConnection;178;1;175;0
WireConnection;226;0;231;0
WireConnection;186;0;177;0
WireConnection;186;1;173;0
WireConnection;137;0;135;0
WireConnection;137;1;134;0
WireConnection;138;0;153;0
WireConnection;138;1;163;0
WireConnection;227;0;226;0
WireConnection;141;0;138;0
WireConnection;141;1;139;0
WireConnection;190;0;178;1
WireConnection;190;1;181;0
WireConnection;188;0;178;2
WireConnection;188;1;184;0
WireConnection;187;0;178;4
WireConnection;187;1;179;0
WireConnection;189;0;178;3
WireConnection;189;1;186;0
WireConnection;140;0;137;0
WireConnection;140;1;136;0
WireConnection;215;0;141;0
WireConnection;142;0;140;0
WireConnection;212;0;138;0
WireConnection;223;0;189;0
WireConnection;223;1;227;0
WireConnection;224;0;187;0
WireConnection;224;1;227;0
WireConnection;222;0;188;0
WireConnection;222;1;227;0
WireConnection;221;0;190;0
WireConnection;221;1;227;0
WireConnection;253;1;213;0
WireConnection;237;0;221;0
WireConnection;237;1;222;0
WireConnection;237;2;223;0
WireConnection;237;3;224;0
WireConnection;3;1;213;0
WireConnection;278;1;216;0
WireConnection;277;1;216;0
WireConnection;210;0;142;0
WireConnection;255;0;253;4
WireConnection;255;1;277;4
WireConnection;255;2;211;0
WireConnection;236;0;235;0
WireConnection;236;1;237;0
WireConnection;251;0;54;4
WireConnection;150;0;3;4
WireConnection;150;1;278;4
WireConnection;150;2;211;0
WireConnection;234;0;54;3
WireConnection;234;1;85;0
WireConnection;240;0;236;0
WireConnection;262;0;255;0
WireConnection;262;1;150;0
WireConnection;262;2;263;0
WireConnection;241;0;262;0
WireConnection;241;1;240;0
WireConnection;241;2;240;1
WireConnection;241;3;240;2
WireConnection;241;4;240;3
WireConnection;241;5;234;0
WireConnection;201;0;241;0
WireConnection;243;1;213;0
WireConnection;1;1;213;0
WireConnection;276;1;216;0
WireConnection;206;0;201;0
WireConnection;206;1;5;0
WireConnection;244;1;216;0
WireConnection;81;0;206;0
WireConnection;245;0;243;0
WireConnection;245;1;244;0
WireConnection;245;2;211;0
WireConnection;145;0;1;0
WireConnection;145;1;276;0
WireConnection;145;2;211;0
WireConnection;70;0;61;0
WireConnection;70;1;55;0
WireConnection;209;1;81;0
WireConnection;209;2;217;0
WireConnection;208;0;81;0
WireConnection;208;2;217;0
WireConnection;246;0;245;0
WireConnection;246;1;145;0
WireConnection;246;2;250;0
WireConnection;272;0;270;0
WireConnection;248;0;243;4
WireConnection;248;1;244;4
WireConnection;248;2;211;0
WireConnection;143;0;1;4
WireConnection;143;1;276;4
WireConnection;143;2;211;0
WireConnection;256;0;253;1
WireConnection;256;1;277;1
WireConnection;256;2;211;0
WireConnection;271;0;208;0
WireConnection;271;1;270;0
WireConnection;274;0;209;0
WireConnection;274;1;270;0
WireConnection;66;0;70;0
WireConnection;66;1;246;0
WireConnection;89;0;5;0
WireConnection;147;0;3;1
WireConnection;147;1;278;1
WireConnection;147;2;211;0
WireConnection;275;0;209;0
WireConnection;275;1;272;0
WireConnection;249;0;248;0
WireConnection;249;1;143;0
WireConnection;249;2;250;0
WireConnection;64;0;61;2
WireConnection;64;1;54;2
WireConnection;64;2;62;0
WireConnection;273;0;208;0
WireConnection;273;1;272;0
WireConnection;56;0;246;0
WireConnection;56;1;66;0
WireConnection;56;2;64;0
WireConnection;151;1;218;0
WireConnection;151;5;274;0
WireConnection;265;1;214;0
WireConnection;265;5;273;0
WireConnection;2;1;214;0
WireConnection;2;5;271;0
WireConnection;257;0;253;3
WireConnection;257;1;277;3
WireConnection;257;2;211;0
WireConnection;7;0;249;0
WireConnection;7;1;206;0
WireConnection;90;0;89;0
WireConnection;149;0;3;3
WireConnection;149;1;278;3
WireConnection;149;2;211;0
WireConnection;48;0;5;0
WireConnection;266;1;218;0
WireConnection;266;5;275;0
WireConnection;259;0;256;0
WireConnection;259;1;147;0
WireConnection;259;2;263;0
WireConnection;84;0;82;0
WireConnection;267;0;265;0
WireConnection;267;1;266;0
WireConnection;88;0;56;0
WireConnection;88;1;90;0
WireConnection;207;0;2;0
WireConnection;207;1;151;0
WireConnection;258;0;253;2
WireConnection;258;1;277;2
WireConnection;258;2;211;0
WireConnection;34;0;7;0
WireConnection;34;1;48;0
WireConnection;25;0;259;0
WireConnection;25;1;206;0
WireConnection;261;0;257;0
WireConnection;261;1;149;0
WireConnection;261;2;263;0
WireConnection;148;0;3;2
WireConnection;148;1;278;2
WireConnection;148;2;211;0
WireConnection;83;0;71;0
WireConnection;83;1;88;0
WireConnection;83;2;84;0
WireConnection;47;0;25;0
WireConnection;279;0;249;0
WireConnection;260;0;258;0
WireConnection;260;1;148;0
WireConnection;260;2;263;0
WireConnection;33;0;34;0
WireConnection;51;0;54;3
WireConnection;51;1;50;0
WireConnection;51;2;52;0
WireConnection;51;3;85;0
WireConnection;77;0;261;0
WireConnection;77;1;5;0
WireConnection;195;0;172;0
WireConnection;195;1;165;0
WireConnection;268;0;267;0
WireConnection;268;1;207;0
WireConnection;200;0;262;0
WireConnection;200;1;221;0
WireConnection;200;2;222;0
WireConnection;200;3;223;0
WireConnection;200;4;224;0
WireConnection;200;5;234;0
WireConnection;0;0;83;0
WireConnection;0;1;268;0
WireConnection;0;3;47;0
WireConnection;0;4;33;0
WireConnection;0;5;77;0
WireConnection;0;10;260;0
WireConnection;0;11;51;0
ASEEND*/
//CHKSM=BD37771FBED028CC57B5A6D8F1706EF8C8428E49