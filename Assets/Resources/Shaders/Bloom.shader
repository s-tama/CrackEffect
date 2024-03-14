Shader "Custom/Bloom"
{
    Properties
    {
        [HideInInspector] [MainTexture] _BaseMap("Base Texture", 2D) = "white" {}
        [HideInInspector] [MainColor] _BaseColor("Base Color", Color) = (1, 1, 1, 1)

        [HideInInspector] _TmpMap("Temp Texture", 2D) = "white" {}

        [HideInInspector] _Strength("Strength", FLoat) = 1
        [HideInInspector] _SamplerCnt("Sampler Cnt", Float) = 1
        [HideInInspector] _Blur("Blur", Float) = 1
        [HideInInspector] _Threshold("Threshold", Float) = 1

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

        TEXTURE2D(_TmpMap);
        SAMPLER(sampler_TmpMap);

        half _Strength;  
        half _SamplerCnt;  
        half _Blur;  
        half _Threshold;

        Varyings vert(Attributes input)
        {
            Varyings output = (Varyings)0;
            VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
            output.positionCS = vertexInput.positionCS;
            output.uv = TRANSFORM_TEX(input.uv, _BaseMap);
            return output;
        }

        half4 fragBright(Varyings input) : SV_Target
        {
            half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
            // ƒsƒNƒZƒ‹‚Ì–¾‚é‚³
            float bright = (baseColor.r + baseColor.g + baseColor.b) / 3;
            // 0 or 1
            float tmp = step(_Threshold, bright);
            return baseColor * tmp * _Strength;
        }

        half4 fragBlur(Varyings input) : SV_Target
        {
            float u = 1 / _ScreenParams.x;
            float v = 1 / _ScreenParams.y;

            half4 result;
            // ‚Ú‚©‚µ
            for (float x = 0; x < _Blur; x++)
            {
                float xx = input.uv.x + (x - _Blur / 2) * u;

                for (float y = 0; y < _Blur; y++)
                {
                    float yy = input.uv.y + (y - _Blur / 2) * v;
                    half4 tmpColor = SAMPLE_TEXTURE2D(_TmpMap, sampler_TmpMap, float2(xx, yy));
                    result += tmpColor;
                }
            }

            result /= _Blur * _Blur;
            half4 baseColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
            return baseColor + result;
        }
        ENDHLSL

        Tags
        {
            "RenderType" = "Transparent"
            //"Queue" = "Transparent"
            "IgnoreProjector" = "True"
            "RenderPipeline" = "UniversalPipeline"
            "PreviewType" = "Plane"
        }
        LOD 100

        //Blend SrcAlpha OneMinusSrcAlpha
        Cull Off
        ZWrite Off
        ZTest Always

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragBright
            ENDHLSL
        }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment fragBlur
            ENDHLSL
        }
    }
}
