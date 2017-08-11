Shader "gRally/Trees"
{
    Properties
    {
        _Color("Main Color", Color) = (1, 1, 1, 1)
        //|_|_HueVariation("Hue Variation", Color) = (1.0,0.5,0.0,0.1)
        _MainTex("Albedo", 2D) = "white" {}
        _Cutoff("Alpha cutoff", Range(0, 1)) = 0.5
        _NormalUpX("Normal up X", Range(0, 1)) = 0
        _NormalUpY("Normal up Y", Range(0, 1)) = 0
        _NormalUpZ("Normal up Z", Range(0, 1)) = 1
    }

    SubShader
    {
        Tags{ "Queue" = "Transparent" "IgnoreProjector" = "True" "RenderType" = "TransparentCutout" }
        LOD 300

        CGPROGRAM
        #pragma surface surf Lambert alphatest:_Cutoff vertex:vert
        //|_|#pragma multi_compile_instancing
        //|_|#pragma instancing_options assumeuniformscaling lodfade maxcount:50
        //|_|#pragma target 4.0
        #pragma target 3.0
        //|_|#pragma shader_feature EFFECT_HUE_VARIATION
        sampler2D _MainTex;
        half _MainTexID;
        fixed4 _Color;
        half _NormalUpX;
        half _NormalUpY;
        half _NormalUpZ;

        struct Input
        {
            float2 uv_MainTex;
            //|_|half3 color;
            //|_|half3 interpolator1;
        };

        //|_|#ifdef EFFECT_HUE_VARIATION
        //|_|#define HueVariationAmount interpolator1.z
        //|_|half4 _HueVariation;
        //|_|#endif

        void vert(inout appdata_full v, out Input o)
        {
            // appdata_full
            UNITY_INITIALIZE_OUTPUT(Input, o);

            // normals up
            v.normal = half3(_NormalUpX, _NormalUpY, _NormalUpZ);
            //|_|o.color = _Color;
            //|_|o.color.rgb *= v.color.r;
            //|_|#ifdef EFFECT_HUE_VARIATION
            //|_|float hueVariationAmount = frac(unity_ObjectToWorld[0].w + unity_ObjectToWorld[1].w + unity_ObjectToWorld[2].w);
            //|_|hueVariationAmount += frac(v.vertex.x + v.normal.y + v.normal.x) * 0.5 - 0.3;
            //|_|o.HueVariationAmount = saturate(hueVariationAmount * _HueVariation.a);
            //|_|#endif
        }

        void surf(Input IN, inout SurfaceOutput o)
        {
            // diffuse color
            fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;

            //|_|#ifdef EFFECT_HUE_VARIATION
            //|_|half3 shiftedColor = lerp(c.rgb, _HueVariation.rgb, IN.HueVariationAmount);
            //|_|half maxBase = max(c.r, max(c.g, c.b));
            //|_|half newMaxBase = max(shiftedColor.r, max(shiftedColor.g, shiftedColor.b));
            //|_|maxBase /= newMaxBase;
            //|_|maxBase = maxBase * 0.5f + 0.5f;
            //|_|// preserve vibrance
            //|_|shiftedColor.rgb *= maxBase;
            //|_|c.rgb = saturate(shiftedColor);
            //|_|#endif

            //|_|o.Albedo = c.rgb * IN.color.rgb;
            o.Albedo = c.rgb;
            // alpha for transparencies
            o.Alpha = c.a;
            // specular power in 0..1 range
            o.Specular = 0.0f;
            // specular intensity
            o.Gloss = 0.0f;
        }
        ENDCG
    }
    FallBack "Legacy Shaders/Transparent/Cutout/Diffuse"
}
