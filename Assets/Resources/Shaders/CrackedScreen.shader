Shader "Custom/CrackedScreen"
{
    Properties
    {
        [MainTexture] _BaseMap("Base Texture", 2D) = "white" {}
        [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        [NoScaleOffset] _CrackMap("Crack Texture", 2D) = "white" {}
        _CrackColor("Crack Color", Color) = (1, 1, 1, 1)
        _CrackRatio("Crack Ratio", Range(0.0, 1.0)) = 1.0

        [NoScaleOffset] _CrackNoiseMap("Crack Noise Texture", 2D) = "white" {}
        _CrackNoiseRatio("Crack Noise Ratio", Range(0.0, 1.0)) = 1.0

        [NoScaleOffset] _GapMap("Gap Texture", 2D) = "white" {}
        _GapRatio("Gap Ratio", Range(0.0, 1.0)) = 0.1

        [NoScaleOffset] _GapBrightnessMap("Gap Brightness Texture", 2D) = "white" {}
        _GapBrightness("Gap Brightness", Range(0.0, 1.0)) = 1

        _Strength("Strength", FLoat) = 0.3
        _SamplerCnt("Sampler Cnt", Float) = 6
        _Blur("Blur", Float) = 20
        _Threshold("Threshold", Float) = 0.3

        // ObsoleteProperties
        [HideInInspector] _MainTex("BaseMap", 2D) = "white" {}
        [HideInInspector] _Color("Base Color", Color) = (0.5, 0.5, 0.5, 1)
        [HideInInspector] _SampleGI("SampleGI", float) = 0.0 // needed from bakedlit
    }
    SubShader
    {
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Unlit.hlsl"
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

        struct Attributes
        {
            float4 positionOS : POSITION;
            float2 uv : TEXCOORD0;

            UNITY_VERTEX_INPUT_INSTANCE_ID
        };

        struct Varyings
        {
            float2 uv : TEXCOORD0;
            float4 positionCS : SV_POSITION;

            UNITY_VERTEX_INPUT_INSTANCE_ID
            UNITY_VERTEX_OUTPUT_STEREO
        };

        float4 _BaseMap_ST;
        half4 _BaseColor;

        TEXTURE2D(_CrackMap);
        SAMPLER(sampler_CrackMap);
        half4 _CrackColor;
        half _CrackRatio;

        TEXTURE2D(_CrackNoiseMap);
        SAMPLER(sampler_CrackNoiseMap);
        half _CrackNoiseRatio;

        TEXTURE2D(_GapMap);
        SAMPLER(sampler_GapMap);
        half _GapRatio;

        TEXTURE2D(_GapBrightnessMap);
        SAMPLER(sampler_GapBrightnessMap);
        half _GapBrightness;

        // Bloom
        half _Strength;
        half _SamplerCnt;
        half _Blur;
        half _Threshold;

        half4 getBrightness(half4 texColor)
        {
            // �s�N�Z���̖��邳
            half bright = max(max(texColor.r, texColor.g), texColor.b);
            // 0 or 1
            half tmp = step(_Threshold, bright);
            return texColor * tmp * _Strength;
        }

        //half4 blur(half4 baseColor, half4 brightColor) : SV_Target
        //{
        //    float u = 1 / _ScreenParams.x;
        //    float v = 1 / _ScreenParams.y;

        //    half4 result;
        //    // �ڂ���
        //    for (float x = 0; x < _Blur; x++)
        //    {
        //        float xx = input.uv.x + (x - _Blur / 2) * u;

        //        for (float y = 0; y < _Blur; y++)
        //        {
        //            float yy = input.uv.y + (y - _Blur / 2) * v;
        //            half4 tmpColor = SAMPLE_TEXTURE2D(_TmpMap, sampler_TmpMap, float2(xx, yy));
        //            result += tmpColor;
        //        }
        //    }

        //    result /= _Blur * _Blur;
        //    return baseColor + result;
        //}

        Varyings vert(Attributes input)
        {
            Varyings output = (Varyings)0;
            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
            output.positionCS = vertexInput.positionCS;
            output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
            return output;
        }
        ENDHLSL

        Tags
        {
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "PreviewType" = "Plane"
        }
        LOD 100

        Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            half4 frag(Varyings input) : SV_Target
            {
                float2 uv = input.uv;

                // �Ђъ���摜�T���v�����O
                half4 crackColor = SAMPLE_TEXTURE2D(_CrackMap, sampler_CrackMap, uv);
                crackColor.a *= step(crackColor.r, _CrackRatio);
                crackColor.rgb = lerp(crackColor.rgb, _CrackColor.rgb, 1);

                // �Ђъ���̃m�C�Y�摜�T���v�����O
                half4 crackNoiseColor = SAMPLE_TEXTURE2D(_CrackNoiseMap, sampler_CrackNoiseMap, uv + _Time * 0.1);
                crackColor.a *= crackNoiseColor.r * _CrackNoiseRatio;
                crackColor.rgb += crackNoiseColor.r * _CrackNoiseRatio;

                // �P�x�Z�o
                half4 brightColor = half4(lerp(0, crackColor.rgb, crackColor.a), 1);
                half4 brightness = getBrightness(brightColor);

                // ����摜������uv�����炷
                half4 gapColor = SAMPLE_TEXTURE2D(_GapMap, sampler_GapMap, uv);
                half2 gapOffset = (gapColor.rg * 2 - 1) * _GapRatio;
                float2 gapUV = uv + gapOffset;

                // �j�Ђ̋P�x�摜�T���v�����O
                half4 gapBrightnessColor = SAMPLE_TEXTURE2D(_GapBrightnessMap, sampler_GapBrightnessMap, uv);
                gapBrightnessColor.rgb *= _GapBrightness;

                // �x�[�X�摜�T���v�����O
                half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, gapUV);
                baseColor.rgb += _BaseColor * gapBrightnessColor.r;

                half3 rgb = lerp(baseColor.rgb, crackColor.rgb, crackColor.a);
                return half4(rgb, 1);
            }
            ENDHLSL
        }
    }
}
