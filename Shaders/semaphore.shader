// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "gRally/semaphore"
{
	Properties
	{
		_TextureSample0("Texture Sample 0", 2D) = "white" {}
		_startFrame("startFrame", Range( 0 , 3)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Opaque"  "Queue" = "Geometry+0" "IsEmissive" = "true"  }
		Cull Back
		CGPROGRAM
		#pragma target 3.5
		#pragma surface surf StandardSpecular keepalpha addshadow fullforwardshadows 
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform sampler2D _TextureSample0;
		uniform fixed _startFrame;

		void surf( Input i , inout SurfaceOutputStandardSpecular o )
		{
			float2 uv_TexCoord11 = i.uv_texcoord * float2( 1,1 ) + float2( 0,0 );
			// *** BEGIN Flipbook UV Animation vars ***
			// Total tiles of Flipbook Texture
			float fbtotaltiles12 = 2 * 2;
			// Offsets for cols and rows of Flipbook Texture
			float fbcolsoffset12 = 1.0f / 2;
			float fbrowsoffset12 = 1.0f / 2;
			// Speed of animation
			float fbspeed12 = _Time[ 1 ] * 0;
			// UV Tiling (col and row offset)
			float2 fbtiling12 = float2(fbcolsoffset12, fbrowsoffset12);
			// UV Offset - calculate current tile linear index, and convert it to (X * coloffset, Y * rowoffset)
			// Calculate current tile linear index
			float fbcurrenttileindex12 = round( fmod( fbspeed12 + _startFrame, fbtotaltiles12) );
			fbcurrenttileindex12 += ( fbcurrenttileindex12 < 0) ? fbtotaltiles12 : 0;
			// Obtain Offset X coordinate from current tile linear index
			float fblinearindextox12 = round ( fmod ( fbcurrenttileindex12, 2 ) );
			// Multiply Offset X by coloffset
			float fboffsetx12 = fblinearindextox12 * fbcolsoffset12;
			// Obtain Offset Y coordinate from current tile linear index
			float fblinearindextoy12 = round( fmod( ( fbcurrenttileindex12 - fblinearindextox12 ) / 2, 2 ) );
			// Reverse Y to get tiles from Top to Bottom
			fblinearindextoy12 = (int)(2-1) - fblinearindextoy12;
			// Multiply Offset Y by rowoffset
			float fboffsety12 = fblinearindextoy12 * fbrowsoffset12;
			// UV Offset
			float2 fboffset12 = float2(fboffsetx12, fboffsety12);
			// Flipbook UV
			half2 fbuv12 = uv_TexCoord11 * fbtiling12 + fboffset12;
			// *** END Flipbook UV Animation vars ***
			float4 tex2DNode10 = tex2D( _TextureSample0, fbuv12 );
			o.Albedo = tex2DNode10.rgb;
			o.Emission = tex2DNode10.rgb;
			o.Alpha = 1;
		}

		ENDCG
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15103
134;97;1458;853;1850.342;460.0829;1.475;True;True
Node;AmplifyShaderEditor.TextureCoordinatesNode;11;-1363.634,-4.699924;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;14;-1373.48,281.1392;Fixed;False;Property;_startFrame;startFrame;1;0;Create;True;0;0;False;0;0;0;0;3;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCFlipBookUVAnimation;12;-1006.184,-3.594935;Float;False;0;0;6;0;FLOAT2;0,0;False;1;FLOAT;2;False;2;FLOAT;2;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SamplerNode;10;-630.9352,1.620116;Float;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;None;6701f7837d69e0544862b46e0474f9ea;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;1;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;277.1951,14.75;Float;False;True;3;Float;ASEMaterialInspector;0;0;StandardSpecular;semaforo;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;0;False;0;Opaque;0.5;True;True;0;False;Opaque;;Geometry;All;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;0;4;10;25;False;0.5;True;0;Zero;Zero;0;Zero;Zero;Add;Add;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;0;0;False;0;0;0;False;-1;-1;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT3;0,0,0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;12;0;11;0
WireConnection;12;4;14;0
WireConnection;10;1;12;0
WireConnection;0;0;10;0
WireConnection;0;2;10;0
ASEEND*/
//CHKSM=0415970B1FB07CA402121F77629E6A00F7D5668A