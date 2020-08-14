// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/Flipbook Emission"
{
	Properties
	{
		_FlipbookMap("Flipbook Map", 2D) = "white" {}
		_EmissionMultiplier("Emission Multiplier", Float) = 0
		_FlipbookColumns("Flipbook Columns", Float) = 6
		_FlipbookRows("Flipbook Rows", Float) = 6
		_FlipbookSpeed("Flipbook Speed", Float) = 0
		_FlipbookStartFrame("Flipbook StartFrame", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _FlipbookMap;
		uniform float _FlipbookColumns;
		uniform float _FlipbookRows;
		uniform float _FlipbookSpeed;
		uniform float _FlipbookStartFrame;
		uniform float _EmissionMultiplier;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles2 = _FlipbookColumns * _FlipbookRows;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset2 = 1.0f / _FlipbookColumns;
			float fbrowsoffset2 = 1.0f / _FlipbookRows;
			// Speed of animation
			float fbspeed2 = _Time[ 1 ] * _FlipbookSpeed;
			// UV Tiling (col and row offset)
			float2 fbtiling2 = float2(fbcolsoffset2, fbrowsoffset2);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex2 = round( fmod( fbspeed2 + _FlipbookStartFrame, fbtotaltiles2) );
			fbcurrenttileindex2 += ( fbcurrenttileindex2 < 0) ? fbtotaltiles2 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox2 = round ( fmod ( fbcurrenttileindex2, _FlipbookColumns ) );
			// Multiply Offset X by coloffset
			float fboffsetx2 = fblinearindextox2 * fbcolsoffset2;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy2 = round( fmod( ( fbcurrenttileindex2 - fblinearindextox2 ) / _FlipbookColumns, _FlipbookRows ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy2 = (int)(_FlipbookRows-1) - fblinearindextoy2;
			// Multiply Offset Y by rowoffset
			float fboffsety2 = fblinearindextoy2 * fbrowsoffset2;
			// UV Offset
			float2 fboffset2 = float2(fboffsetx2, fboffsety2);
			// Flipbook UV
			half2 fbuv2 = i.uv_texcoord * fbtiling2 + fboffset2;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode1 = tex2D( _FlipbookMap, fbuv2 );
			o.Emission = ( tex2DNode1 * _EmissionMultiplier ).rgb;
			o.Alpha = tex2DNode1.a;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=16600
1983;2;1744;1027;1934.949;512.2974;1.185;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;6;-1403,-216;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;4;-1345,-96;Float;False;Property;_FlipbookColumns;Flipbook Columns;2;0;Create;True;0;0;False;0;6;16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-1337,-21.185;Float;False;Property;_FlipbookRows;Flipbook Rows;3;0;Create;True;0;0;False;0;6;4;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;5;-1351.889,62.37505;Float;False;Property;_FlipbookSpeed;Flipbook Speed;4;0;Create;True;0;0;False;0;0;40;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;14;-1383.926,146.5626;Float;False;Property;_FlipbookStartFrame;Flipbook StartFrame;5;0;Create;True;0;0;False;0;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;2;-906.555,-109.63;Float;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;6;False;2;FLOAT;6;False;3;FLOAT;0.2;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;1;-484,-137;Float;True;Property;_FlipbookMap;Flipbook Map;0;0;Create;True;0;0;False;0;None;685eae6125ceb8645a07a2a34ea1c49f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;8;-334.2399,62.93003;Float;False;Property;_EmissionMultiplier;Emission Multiplier;1;0;Create;True;0;0;False;0;0;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;9;16,-56;Float;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;185.815,-96;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;gRally/Flipbook Emission;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;2;0;6;0
WireConnection;2;1;4;0
WireConnection;2;2;7;0
WireConnection;2;3;5;0
WireConnection;2;4;14;0
WireConnection;1;1;2;0
WireConnection;9;0;1;0
WireConnection;9;1;8;0
WireConnection;0;2;9;0
WireConnection;0;9;1;4
ASEEND*/
//CHKSM=1A9BD41322633F66AF53922A1CDBF85E94D54313